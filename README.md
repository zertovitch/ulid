# ULID-Ada

Implementation of [ULID](https://github.com/ulid/spec/blob/master/README.md) (Universally Unique Lexicographically Sortable Identifier) in Ada.

In a nutshell, a ULID code (Universally Unique Lexicographically Sortable Identifier) is
a combination of a 48-bit time stamp (most significant part, with a millisecond accuracy),
and a 80-bit random number (least significant part), totalling 128 bits, that is 16 bytes (octets).

## Usage

The package **`ULID`** provides two functions `Generate`.
One function produces a 128-bit number that can be output (for instance) in the UUID format.
One function produces a string in the Base32 format (Crockford variant) - the preferred (canonical) representation of a ULID.
Additionally, the `Generate_Monotonic` function enables the production of a monotonically increasing sequence of ULID numbers within the same millisecond.
The function `Encode_as_8_4_4_4_12` outputs a text representation of a ULID number in the usual UUID 8-4-4-4-12 format (like: 01920161-d64d-5a3e-589e-c45df155547b).
Both formats (Base32 and 8-4-4-4-12) are also recognized by the `Decode` function.

All functions are task-safe (several Ada tasks can call `Generate` at the same
time without messing the pseudo-random generator) and you can optionally set a time zone offset.

### Generating ULID's
Here is an example for generating ULID's:
```
with Ada.Text_IO;
with ULID;

procedure ULID_Test is
  use Ada.Text_IO, ULID;
  gen : Random_Generator;
begin
  Reset (gen);  --  Randomize
  for i in 1 .. 10 loop
    Put_Line (ULID.Generate (gen));
  end loop;
  Put ("Press Return");
  Skip_Line;
end ULID_Test;
```

With AdaCore's GNAT you can build and run the test using the **ulid.gpr** project file.

## License

ULID-Ada is released under the MIT license.
See the LICENSE file for more info.
