with MicroBit.Radio; use MicroBit.Radio;
with HAL; use HAL;

package body Protocol is
   Length         : constant := 4;
   Version        : constant := 12;
   Radio_Protocol : constant := 14;

   Dir_Codes : constant array (Direction) of UInt8 :=
     (Stopped  => 0,
      Forward  => 1,
      Backward => 2,
      Left     => 3,
      Right    => 4,
      Rotating_CCW => 5,
      Rotating_CW => 6);

   Speed_Scale : constant := 16;

   function Decode (D : RadioData) return Direction is
   begin
      for Dir in Direction loop
         if Dir_Codes (Dir) = D.Payload (1) then
            return Dir;
         end if;
      end loop;
      return Stopped;  -- unknown byte: stop
   end Decode;

   function Encode (Dir : Direction; Speed : Speed_Value) return RadioData is
      D : RadioData;
   begin
      D.Length   := Length;
      D.Version  := Version;
      D.Group    := Group;
      D.Protocol := Radio_Protocol;
      D.Payload (1) := Dir_Codes (Dir);
      D.Payload (2) := UInt8 (Speed / Speed_Scale);
      return D;
   end Encode;

   procedure Send (Dir : Direction; Speed : Speed_Value) is
   begin
      Transmit (Encode (Dir, Speed));
   end Send;

end Protocol;