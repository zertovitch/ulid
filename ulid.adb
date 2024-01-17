with Ada.Calendar.Formatting;

package body ULID is

  function Encode (Code : ULID_Number) return String is
    --  Crockford's Base32 (5 bits per symbol):
    crockford : constant String := "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
    result : String (1 .. 26);
    --  ^ The first 10 characters contain a time information (50 bits,
    --    of them 48 are used); the 16 other characters represent a random
    --    number (80 bits).
    x : ULID_Number := Code;
  begin
    for c of reverse result loop
      c := crockford (1 + Integer (x and 31));
      x := x / 32;
    end loop;
    return result;
  end Encode;

  procedure Reset (Generator : Random_Generator) is
  begin
    Random_Numbers.Reset (Random_Numbers.Generator (Generator));
  end Reset;

  procedure Reset (Generator : Random_Generator; Seed : Integer) is
  begin
    Random_Numbers.Reset (Random_Numbers.Generator (Generator), Seed);
  end Reset;

  function Generate
    (Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return ULID_Number
  is
    random_part : constant ULID_Number :=
      ULID_Number
        (Random_Numbers.Random
          (Random_Numbers.Generator (Generator)));
    use Ada.Calendar;
    unix_epoch : constant Time :=
      Ada.Calendar.Formatting.Time_Of
        (1970, 1, 1, 0.0, Leap_Second, Offset);
    time_part : constant ULID_Number :=
      ULID_Number (1000.0 * (Clock - unix_epoch));
  begin
    return time_part * 2 ** 80 + random_part;
  end Generate;

end ULID;
