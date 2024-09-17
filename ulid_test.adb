with Ada.Text_IO;
with ULID;

procedure ULID_Test is

  use Ada.Text_IO, ULID;

  procedure Check_Monotonicity (want_monotonic : Boolean; title : String) is
    old, current : ULID_Number;
    gen : Random_Generator;
    non_monotonic_counter : Natural := 0;
    iterations : constant := 10_000;
  begin
    Reset (gen);  --  Randomize
    old := 0;
    for i in 1 .. iterations loop
      if want_monotonic then
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

  procedure Check_Network_Byte_Order is
    number, check : ULID_Number;
    bytes : Byte_Array;
    gen : Random_Generator;
  begin
    --  Trivial, but we still check it (bugs
    --  occur often in those parts)...
    for i in 1 .. 10 loop
      number := ULID.Generate (gen);
      bytes := Network_Byte_Order (number);
      check := 0;
      for element of bytes loop
        --  Most Significant Byte first
        check := check * 256 + ULID_Number (element);
      end loop;
      if number /= check then
        raise Program_Error with "Hey, check that Big-endian code!";
      end if;
    end loop;
  end Check_Network_Byte_Order;

  procedure Demo is
    gen : Random_Generator;
  begin
    Reset (gen);  --  Randomize
    Put_Line ("Demo (just a few ULID's):");
    for i in 1 .. 10 loop
      Put_Line ("  " & ULID.Generate (gen));
    end loop;
    New_Line;
    Put_Line ("In usual UUID 8-4-4-4-12 format:");
    for i in 1 .. 10 loop
      Put_Line ("  {" & Encode_as_8_4_4_4_12 (ULID.Generate (gen)) & '}');
    end loop;
    New_Line;
  end Demo;

begin
  Check_Network_Byte_Order;
  Put_Line ("Testing monotonicity:");
  Check_Monotonicity (False, "ULID.Generate . . . . .");
  Check_Monotonicity (True,  "ULID.Generate_Monotonic");
  New_Line;
  Demo;
  Put ("Press Return");
  Skip_Line;
end ULID_Test;
