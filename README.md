# ULID-Ada

Implementation of [ULID](https://github.com/ulid/spec/blob/master/README.md) in Ada.

## Usage

The package **`ULID`** provides two functions `Generate`.
One is a 128-bit number that can be output (for instance) in the UUID format.
One is a string in the Base32 format (Crockford variant).

The functions are task-safe (several Ada tasks can call `Generate` at the same time without messing the pseudo-random generator)
and you can optionally set a time zone offset.

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
    Put_Line (Generate (gen));
  end loop;
  Put ("Press Return");
  Skip_Line;
end ULID_Test;
```

## License

ULID-Ada is released under the MIT license. See the LICENSE file for more info.
