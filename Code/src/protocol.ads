
with MicroBit.Radio; use MicroBit.Radio;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;

package Protocol is
   Frequency : constant := 2416;
   Group     : constant := 37;

   subtype Direction is MicroBit.MotorDriver.Car.Direction;

   subtype Speed_Value is Natural range 0 .. 4095;

   function Decode (D : RadioData) return Direction;

   function Encode
     (Dir : Direction; Speed : Speed_Value) return RadioData;

   procedure Send (Dir : Direction; Speed : Speed_Value);

end Protocol;

