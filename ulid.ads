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
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.
--
--  NB: this is the MIT License, as found 12-Sep-2013 on the site
--  http://www.opensource.org/licenses/mit-license.php
--
-------------------------------------------------------------------------------------

with Ada.Calendar.Time_Zones;
with Ada.Numerics.Discrete_Random;

package ULID is

  type ULID_Number is mod 2 ** 128;

  --  Encode a number in the Base32 format (Crockford variant).
  --
  function Encode (Code : ULID_Number) return String;

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

private

  type Random_Range is range 0 .. 2 ** 80 - 1;

  package Random_Numbers is
    new Ada.Numerics.Discrete_Random (Random_Range);

  type Random_Generator is new Random_Numbers.Generator;

end ULID;
