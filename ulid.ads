--  Ada Implementation of ULID.
--
--  ULID = Universally Unique Lexicographically Sortable Identifier
--
--  Specification of ULID can be found here: https://github.com/ulid/spec .
--
--  A ULID is a combination of 48-bit time stamp (most significant part),
--  with a millisecond accuracy, and a 80-bit random number
--  (least significant part), totalling 128 bits, that is 16 bytes (octets).
--
--  Legal licensing note:
--
--  Copyright (c) 2024 Gautier de Montmollin
--
--  Permission is hereby granted, free of charge, to any person obtaining a
--  copy of this software and associated documentation files (the "Software"),
--  to deal in the Software without restriction, including without limitation
--  the rights to use, copy, modify, merge, publish, distribute, sublicense,
--  and/or sell copies of the Software, and to permit persons to whom the
--  Software is furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--  DEALINGS IN THE SOFTWARE.
--
--  NB: this is the MIT License, as found 12-Sep-2013 on the site
--  http://www.opensource.org/licenses/mit-license.php
--
------------------------------------------------------------------------------

with Ada.Calendar.Time_Zones;
with Ada.Numerics.Discrete_Random;
with Interfaces;

package ULID is

  type ULID_Number is mod 2 ** 128;

  --------------------------------
  --  ULID text representation  --
  --------------------------------

  --  Encode a number in the Base32 format (Crockford variant).
  --  Example of output: 01J80P3NJDN0Y5YX7D05421X0G
  --
  function Encode (Code : ULID_Number) return String;

  --  Encode a number in the usual UUID 8-4-4-4-12 format.
  --  Example of output:     01920161-d64d-5a3e-589e-c45df155547b
  --  Often it's bracketed: {01920161-d64d-5a3e-589e-c45df155547b}
  --
  function Encode_as_8_4_4_4_12 (Code : in ULID_Number) return String;

  --  Decode a ULID/UUID from Base32 format (Crockford variant)
  --  or from "8-4-4-4-12" format, possibly bracketed with "{...}".
  --
  function Decode (Text : String) return ULID_Number;

  ------------------------------
  --  ULID number generation  --
  ------------------------------

  --  The decentralized pseudo-random generator allows for concurrent
  --  calls (several Ada tasks calling `Generate` at the same time).
  --
  type Random_Generator is limited private;

  procedure Reset (Generator : Random_Generator);  --  Randomize.

  procedure Reset (Generator : Random_Generator; Seed : Integer);

  --------------------------------------------------------------------
  --  The `Generate` function is task-safe (hence, the `Generator`  --
  --  parameter), and you can optionally set a time zone offset.    --
  --------------------------------------------------------------------
  --
  function Generate
    (Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return ULID_Number;

  -------------------------------------------------------
  --  This is the main function of the ULID package:   --
  --  return a ULID code as a string in its canonical  --
  --  form (Base32, Crockford variant).                --
  -------------------------------------------------------
  --
  function Generate
    (Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return String
  is
  (Encode (Generate (Generator, Leap_Second, Offset)));

  ---------------------------------------------------------
  --  With Generate_Monotonic we ensure a larger value   --
  --  than the previously generated number.              --
  ---------------------------------------------------------
  --
  function Generate_Monotonic
    (Previous    : ULID_Number;
     Generator   : Random_Generator;
     Leap_Second : Boolean := False;
     Offset      : Ada.Calendar.Time_Zones.Time_Offset := 0)
  return ULID_Number;

  ------------------------------------------------------
  --  Network Byte Order representation (big-endian)  --
  ------------------------------------------------------

  subtype Byte is Interfaces.Unsigned_8;

  type Byte_Array is array (1 .. 16) of Byte;

  function Network_Byte_Order (Code : ULID_Number) return Byte_Array;

  Invalid_Text : exception;

private

  type Random_Range is range 0 .. 2 ** 80 - 1;

  package Random_Numbers is
    new Ada.Numerics.Discrete_Random (Random_Range);

  type Random_Generator is new Random_Numbers.Generator;

end ULID;
