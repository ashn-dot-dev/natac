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

## License
All content in this repository, unless otherwise noted, is licensed under the
Zero-Clause BSD license.

See LICENSE for more information.
