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
