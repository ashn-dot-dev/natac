#!/usr/bin/env python3
import argparse
import json
import re
import subprocess

INDENT = " " * 4

RE_TYPE_FUN = re.compile(r"(.+)\((.+)\)")
RE_TYPE_ARR = re.compile(r"(.*)\[(\d+)\]")
RE_TYPE_PTR = re.compile(r"(.*)\*")
RE_TYPE_UXX = re.compile(r"unsigned (.+)")

# Mapping of excplicit declarations/definitions.
EXPLICIT = {
    "Word": "type Word = u32;",

    "NBN_ERROR": "let NBN_ERROR: sint = -1;",

    "NBN_MAX_MESSAGE_TYPES": "let NBN_MAX_MESSAGE_TYPES: u8 = 255;",
    "NBN_BYTE_ARRAY_MESSAGE_TYPE":  "let NBN_BYTE_ARRAY_MESSAGE_TYPE: u8 = NBN_MAX_MESSAGE_TYPES - 4;",

    "NBN_ConnectionHandle": "type NBN_ConnectionHandle = uint32_t;",

    "NBN_NO_EVENT": "let NBN_NO_EVENT: sint = 0;",
    "NBN_SKIP_EVENT": "let NBN_SKIP_EVENT: sint = 1;",

    "NBN_CONNECTED": "let NBN_CONNECTED: sint = 2;",
    "NBN_DISCONNECTED": "let NBN_DISCONNECTED: sint = 3;",
    "NBN_MESSAGE_RECEIVED": "let NBN_MESSAGE_RECEIVED: sint = 4;",

    "NBN_NEW_CONNECTION": "let NBN_NEW_CONNECTION: sint = 2;",
    "NBN_CLIENT_DISCONNECTED": "let NBN_CLIENT_DISCONNECTED: sint = 3;",
    "NBN_CLIENT_MESSAGE_RECEIVED": "let NBN_CLIENT_MESSAGE_RECEIVED: sint = 4;",

    # nbnet.c
    "NBN_LogType": "enum NBN_LogType { NBN_LOG_INFO; NBN_LOG_ERROR; NBN_LOG_DEBUG; NBN_LOG_TRACE; NBN_LOG_WARNING; }",
    "NBN_Log_SetIsEnabled": "extern func NBN_Log_SetIsEnabled(type_: NBN_LogType, enabled: bool) void;",
    "NBN_Log_GetIsEnabled": "extern func NBN_Log_GetIsEnabled(type_: NBN_LogType) bool;",
    "NBN_Driver_Init": "extern func NBN_Driver_Init() void;",
}

def identifier(s):
    # Set of Sunder keywords to be substituted.
    # Updated as necessary.
    KEYWORDS = {"func", "type"}
    # Substitute `<identifier>` for `<identifier>_` if the identifier would be
    # a reserved keyword.
    return f"{s}_" if s in KEYWORDS else s

def generate_type(s):
    s = s.replace("const ", "").strip()
    s = s.replace("struct ", "").strip()
    s = s.replace("union ", "").strip()
    s = s.replace("enum ", "").strip()
    if s == "...":
        return "[]any" # Sunder does not have a replacement for varargs.
    match = RE_TYPE_FUN.match(s)
    if match:
        params = [generate_type(t) for t in match[2].split(",")] if match[2] != "void" else ""
        return f"func({', '.join(params)}) {generate_type(match[1])}"
    match = RE_TYPE_ARR.match(s)
    if match:
        return f"[{match[2]}]{generate_type(match[1])}"
    match = RE_TYPE_PTR.match(s)
    if match:
        return f"*{generate_type(match[1])}" if match[1].strip() != "void" else "*any"
    match = RE_TYPE_UXX.match(s)
    if match:
        return f"u{match[1]}"
    if s == "_Bool":
        return "bool"
    if s == "int":
        return "sint"
    if s == "short":
        return "sshort"
    if s == "long":
        return "slong"
    if s == "long long":
        return "slonglong"
    return s.strip()

def generate_type_function_pointer(s):
    # The qualified type will be reported by clang as:
    #
    #   rettype (*)(argtype1, argtype2, etc)'
    #
    # Removing the "(*)" and feeding the result through `generate_type`
    # should produce the proper Sunder function type:
    #
    #   int (*)(NBN_Stream *, unsigned int *, unsigned int, unsigned int)
    #       vvvv remove "(*)"
    #   int (NBN_Stream *, unsigned int *, unsigned int, unsigned int)
    #       vvvv generate_type
    #   func(*NBN_Stream, *uint, uint, uint) sint
    return generate_type(s.replace("(*)", ""))

def generate_typedef(node):
    assert node["kind"] == "TypedefDecl"
    match = RE_TYPE_FUN.match(node["type"]["qualType"])
    if not match:
        raise Exception(f"failed to match function typedef with type `{node['type']['qualType']}`")
    type = generate_type_function_pointer(node["type"]["qualType"])
    return f"type {node['name']} = {type};"

def generate_function(node):
    assert node["kind"] == "FunctionDecl"
    match = RE_TYPE_FUN.match(node["type"]["qualType"])
    if not match:
        raise Exception(f"failed to match function with type `{node['type']['qualType']}`")
    return_type = generate_type(match[1])
    param_types = [generate_type(t) for t in match[2].split(",")] if match[2] != "void" else []
    # XXX: Function prototypes in nbnet.h do not have parameter names.
    # The generic parameter names param1, param2, etc. are used instead.
    return f"extern func {node['name']}(" + ", ".join([f"param{idx+1}: {t}" for idx, t in enumerate(param_types)]) + f") {return_type};"

def generate_struct(node):
    assert node["kind"] == "RecordDecl"
    assert node["tagUsed"] == "struct"
    assert node["completeDefinition"]
    lines = [f"struct {node['name']} {{"]
    for field in node["inner"]:
        if field["kind"] != "FieldDecl":
            continue
        if RE_TYPE_FUN.match(field["type"]["qualType"]):
            type = generate_type_function_pointer(field["type"]["qualType"])
            lines.append(f"{INDENT}var {identifier(field['name'])}: {type};")
            continue
        lines.append(f"{INDENT}var {identifier(field['name'])}: {generate_type(field['type']['qualType'])};")
    lines.append("}")
    return "\n".join(lines)

def generate_union(node):
    assert node["kind"] == "RecordDecl"
    assert node["tagUsed"] == "union"
    assert node["completeDefinition"]
    lines = [f"union {node['name']} {{"]
    for field in node["inner"]:
        if field["kind"] != "FieldDecl":
            continue
        lines.append(f"{INDENT}var {identifier(field['name'])}: {generate_type(field['type']['qualType'])};")
    lines.append("}")
    return "\n".join(lines)

def generate_enum(node):
    assert node["kind"] == "EnumDecl"
    lines = [f"enum {node['name']} {{"]
    for constant in node["inner"]:
        if constant["kind"] != "EnumConstantDecl":
            continue
        if constant.get("inner") is not None and constant["inner"][0].get("value") is not None:
            lines.append(f"{INDENT}{constant['name']} = {constant['inner'][0]['value']};")
        else:
            lines.append(f"{INDENT}{constant['name']};")
    lines.append("}")
    return "\n".join(lines)

def generate_node(node):
    if node["kind"] == "TypedefDecl":
        return generate_typedef(node)
    if node["kind"] == "FunctionDecl":
        return generate_function(node)
    if node["kind"] == "RecordDecl" and node["tagUsed"] == "struct":
        return generate_struct(node)
    if node["kind"] == "RecordDecl" and node["tagUsed"] == "union":
        return generate_union(node)
    if node["kind"] == "EnumDecl":
        return generate_enum(node)
    raise Exception(f"unhandled node `{node['name']}` with kind `{node['kind']}`")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("path", metavar="FILE")
    args = parser.parse_args()

    clang_ast_dump = ['clang', '-Xclang', '-ast-dump=json', '-c', args.path]
    ast = json.loads(subprocess.check_output(clang_ast_dump))
    assert ast["kind"] == "TranslationUnitDecl"

    # Extract the list of AST nodes.
    ast = [node for node in ast["inner"]]

    def ast_node_from_nbnet(node):
        return (
            node.get("name") is not None and
            (node["name"].startswith("NBN") or node["name"] in EXPLICIT)
        )

    # Ignore builtin and included declarations/definitions.
    ast = [node for node in ast if ast_node_from_nbnet(node)]

    def ast_node_is_forward_record_decl(node):
        return node["kind"] == "RecordDecl" and node.get("completeDefinition") is None

    # Ignore forward struct declations.
    ast = [node for node in ast if not ast_node_is_forward_record_decl(node)]

    def ast_node_is_unknown_typedef_decl(node):
        return (
            node["kind"] == "TypedefDecl" and
            node["name"] not in EXPLICIT and
            not RE_TYPE_FUN.match(node["type"]["qualType"]) # function pointer
        )

    # ignore all unknown typedefs.
    ast = [node for node in ast if not ast_node_is_unknown_typedef_decl(node)]

    print("import \"c\";")
    print("\n", end="")
    for decl in EXPLICIT.values():
        print(decl)
    for node in ast:
        if node["name"] in EXPLICIT:
            continue
        print(generate_node(node))

if __name__ == "__main__":
    main()
