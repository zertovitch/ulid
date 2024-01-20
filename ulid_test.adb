with Ada.Text_IO;
with ULID;

procedure ULID_Test is

  use Ada.Text_IO, ULID;

  procedure Check_Monotonicity (monotonic : Boolean; title : String) is
    old, current : ULID_Number;
    gen : Random_Generator;
    non_monotonic_counter : Natural := 0;
    iterations : constant := 10_000;
  begin
    Reset (gen);  --  Randomize
    old := 0;
    for i in 1 .. iterations loop
      if monotonic then
        current := ULID.Generate_Monotonic (old, gen);
      else
        current := ULID.Generate (gen);
      end if;
      if current <= old then
        non_monotonic_counter := non_monotonic_counter + 1;
      end if;
      old := current;
    end loop;
    Put_Line
      ("  Non-monotonic occurrences of " & title & " . :" &
       non_monotonic_counter'Image & " of" &
       iterations'Image);
  end Check_Monotonicity;

  procedure Demo is
    gen : Random_Generator;
  begin
    Put_Line ("Demo (just a few ULID's):");
    Reset (gen);  --  Randomize
    for i in 1 .. 10 loop
      Put_Line ("  " & ULID.Generate (gen));
    end loop;
    New_Line;
  end Demo;

begin
  Put_Line ("Testing monotonicity:");
  Check_Monotonicity (False, "ULID.Generate . . . . .");
  Check_Monotonicity (True,  "ULID.Generate_Monotonic");
  New_Line;
  Demo;
  Put ("Press Return");
  Skip_Line;
end ULID_Test;
