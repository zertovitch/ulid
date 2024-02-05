# ULID-Ada

Implementation of [ULID](https://github.com/ulid/spec/blob/master/README.md)
(Universally Unique Lexicographically Sortable Identifier) in Ada.

In a nutshell, a ULID code is a combination of 48-bit time stamp (most significant part),
with a millisecond accuracy, and a 80-bit random number (least significant part),
totalling 128 bits, that is 16 bytes (octets).

The preferred (canonical) representation of a ULID is in a certain version of the Base32 encoding.

## Usage

The package **`ULID`** provides two functions `Generate`.
One function is a 128-bit number that can be output (for instance) in the UUID format.
One function is a string in the Base32 format (Crockford variant).

The functions are task-safe (several Ada tasks can call `Generate` at the same
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
