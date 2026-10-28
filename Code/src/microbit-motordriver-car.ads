package MicroBit.MotorDriver.Car is
   subtype Speed_Value is Natural range 0 .. 4095;

   type Wheel_Id is (LF, LB, RF, RB);


   -- procedure Test_Wheel (W : Wheel_Id; Speed : Speed_Value; Reverse_Dir : Boolean := False);
   procedure Set_Calibration (W : Wheel_Id; Factor : Float);

   type Direction is (Stopped, Forward, Backward, Left, Right, Rotating_CW, Rotating_CCW);

   procedure Move (Dir : Direction; Speed : Speed_Value);
   procedure Stop;

   function Current_Direction return Direction;
   function Is_Moving return Boolean;

end MicroBit.MotorDriver.Car;