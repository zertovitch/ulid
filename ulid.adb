with Ada.Calendar.Formatting;

package body ULID is

  --  Crockford's Base32 (5 bits per symbol):
  crockford : constant String (1 .. 32) := "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

  function Decode (Text : String) return ULID_Number is
    index : Integer;
    reverse_crockford : array (Character) of Integer;
    single_digit : Integer;
    invalid : constant := -1;
    result : ULID_Number := 0;
  begin
    case Text'Length is

      when 26 =>
        reverse_crockford := (others => invalid);
        for i in crockford'Range loop
          reverse_crockford (crockford (i)) := i - 1;
        end loop;
        for c of Text loop
          single_digit := reverse_crockford (c);
          if single_digit = invalid then
            raise Invalid_Text
              with "Error in Crockford's Base32 representation";
          end if;
          result := result * 32 + ULID_Number (single_digit);
        end loop;

      when 36 =>
        index := Text'First;
        for hexa_digit in 1 .. 16 loop
          single_digit :=
            Integer'Value ("16#" & Text (index .. index + 1) & '#');
          index := index + 2;
          if index <= Text'Last and then Text (index) = '-' then
            if index not in  8 + Text'First | 13 + Text'First |
                            18 + Text'First | 23 + Text'First
            then
              raise Invalid_Text
                with "Misplaced dash in 8-4-4-4-12 representation";
            end if;
            index := index + 1;
          end if;
          result := result * 256 + ULID_Number (single_digit);
        end loop;

      when 38 =>
        if Text (Text'First) = '{' and then Text (Text'Last) = '}' then
          return Decode (Text (Text'First + 1 .. Text'Last - 1));
        else
          raise Invalid_Text
            with "Expecting bracketed 8-4-4-4-12 format for 38 characters";
        end if;

      when others =>
        raise Invalid_Text with "Invalid UILD / UUID text representation";
    end case;

    return result;
  end Decode;

  function Encode (Code : ULID_Number) return String is
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

  function Encode_as_8_4_4_4_12 (Code : in ULID_Number) return String is
    result : String (1 .. 36);
    index  : Integer := result'Last;
    base   : constant := 16;
    hexa   : constant String (1 .. base) := "0123456789abcdef";
    work   : ULID_Number := Code;
    b      : Integer;
  begin
    for i in reverse 1 .. 16 loop
      b                  := Integer (work and 255);
      work               := work / 256;
      result (index - 1) := hexa (b  /  base + 1);
      result (index)     := hexa (b mod base + 1);
      index              := index - 2;
      --  Insert dashes
      if i = 5 or else i = 7 or else i = 9 or else i = 11 then
        result (index) := '-';
        index          := index - 1;
      end if;
    end loop;
    return result;
  end Encode_as_8_4_4_4_12;

  procedure Reset (Generator : Random_Generator) is
  begin
    Random_Numbers.Reset (Random_Numbers.Generator (Generator));
  end Reset;

  procedure Reset (Generator : Random_Generator; Seed : Integer) is
  begin
    Random_Numbers.Reset (Random_Numbers.Generator (Generator), Seed);
  end Reset;

  function Generate_Time_Part
    (Leap_Second : Boolean;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset)
  return ULID_Number
  is
    use Ada.Calendar;
    unix_epoch : constant Time :=
      Ada.Calendar.Formatting.Time_Of
        (1970, 1, 1, 0.0, Leap_Second, Offset);
    milliseconds_clock : constant ULID_Number :=
      ULID_Number (1000.0 * (Clock - unix_epoch));
  begin
    return milliseconds_clock * 2 ** 80;
  end Generate_Time_Part;

  function
    Generate_Random_Part (Generator : Random_Generator) return ULID_Number
  is
  begin
    return ULID_Number
      (Random_Numbers.Random
        (Random_Numbers.Generator (Generator)));
  end Generate_Random_Part;

  function Generate
    (Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return ULID_Number
  is
  (Generate_Time_Part (Leap_Second, Offset) +
   Generate_Random_Part (Generator));

  function Generate_Monotonic
    (Previous    : ULID_Number;
     Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return ULID_Number
  is
    --  Mask for erasing the random part:
    mask : constant :=  (2 ** 128 - 1) - (2 ** 80 - 1);
    old_time_part : constant ULID_Number := Previous and mask;
    new_time_part : constant ULID_Number :=
      Generate_Time_Part (Leap_Second, Offset);
  begin
    if new_time_part > old_time_part then
      return new_time_part + Generate_Random_Part (Generator);
    else
      --  New time is not new enough: we increment previous value.
      return Previous + 1;
    end if;
  end Generate_Monotonic;

  function Network_Byte_Order (Code : ULID_Number) return Byte_Array is
    result : Byte_Array;
    rest : ULID_Number := Code;
  begin
    for i in reverse result'Range loop
      result (i) := Byte (rest and 255);
      rest := rest / 256;
    end loop;
    return result;
  end Network_Byte_Order;

end ULID;
