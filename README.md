# Bubby

Bubby is a minimalist data format designed to express simple structured data in
human-readable plaintext.

Bubby data consists of four value-types: str, vec, map, and set.

**str**: byte string

    "foo🍔bar"
    "raw bytes (hex-encoded): \x22 \xAB \xFF"

**vec**: vector of values

    []
    ["foo" "bar" "baz"]
    ["foo" [["bar" "baz"]] {"abc" "123"} "foo"]

**map**: mapping of unique keys to values

    {}
    {"key" "value"}
    {"key-1" "value-1" "key-2" "value-2"}
    {["+123" "-456"] (["foo" "bar"] {"abc" "123"})}
    {
      "name" "Mya"
      "age"  "11"
    }

**set**: set of unique values

    ()
    ("foo" "bar" "baz")
    (["foo" "bar"] {"key" "value"})

The bubby data format is named after and dedicated to my dog Mya, who I
affectionately called my bubby girl.

May she rest in peace.

## EBNF Grammar

```
value = str | vec | map | set ;

str = '"' { byte } '"' ;
vec = '[' value_list ']' ;
map = '{' pairs_list '}' ;
set = '(' value_list ')' ;

byte = byte_raw | byte_hex ;
byte_raw = ? any byte except '"' and '\' ? ;
byte_hex = '\x' hex_digit hex_digit ;
hex_digit = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7'
          | '8' | '9' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' ;
value_list = [ value { whitespace value } ] ;
pairs_list = [ value_pair { whitespace value_pair } ] ;
value_pair = value whitespace value ;
whitespace = ( ' ' | '\t' | '\n' ) { ' ' | '\t' | '\n' } ;
```

## License
All content in this repository, unless otherwise noted, is licensed under the
Zero-Clause BSD license.

See LICENSE for more information.
