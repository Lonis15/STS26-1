package body MicroBit.MotorDriver.Car is

   Calibration : array (Wheel_Id) of Float := (others => 1.0);
   Current     : Direction := Stopped;

   function Cal (W : Wheel_Id; Speed : Speed_Value) return UInt12 is
      (UInt12 (Speed_Value'Min (Speed_Value'Last,
      Natural (Float (Speed) * Calibration (W)))));

   procedure Move (Dir : Direction; Speed : Speed_Value) is
   begin
      case Dir is
         when Forward =>
            Drive_Wheels (rf => (Cal (RF, Speed), 0),
                          rb => (Cal (RB, Speed), 0),
                          lf => (Cal (LF, Speed), 0),
                          lb => (Cal (LB, Speed), 0));
         when Backward =>
            Drive_Wheels (rf => (0, Cal (RF, Speed)),
                          rb => (0, Cal (RB, Speed)),
                          lf => (0, Cal (LF, Speed)),
                          lb => (0, Cal (LB, Speed)));
         when Left =>
            Drive_Wheels (rf => (Cal (RF, Speed), 0),
                          rb => (0, Cal (RB, Speed)),
                          lf => (0, Cal (LF, Speed)),
                          lb => (Cal (LB, Speed), 0));
         when Right =>
            Drive_Wheels (rf => (0, Cal (RF, Speed)),
                          rb => (Cal (RB, Speed), 0),
                          lf => (Cal (LF, Speed), 0),
                          lb => (0, Cal (LB, Speed)));
         when Stopped =>
            Drive_Wheels (rf => (0, 0), rb => (0, 0), lf => (0, 0), lb => (0, 0));
         when Rotating_CW =>
            Drive_Wheels (rf => (0, Cal (RF, Speed)),
                          rb => (0, Cal (RB, Speed)),
                          lf => (Cal (LF, Speed), 0),
                          lb => (Cal (LB, Speed), 0));
         when Rotating_CCW =>
            Drive_Wheels (rf => (Cal (RF, Speed), 0),
                          rb => (Cal (RB, Speed), 0),
                          lf => (0, Cal (LF, Speed)),
                          lb => (0, Cal (LB, Speed)));
      end case;
      Current := Dir;
   end Move;

   procedure Stop is -- kind of optional
   begin
      Move (Stopped, 0);
   end Stop;

   procedure Set_Calibration (W : Wheel_Id; Factor : Float) is
   begin
      Calibration (W) := Float'Max (0.0, Factor); -- we need to make sure we dont get fed negative values
   end Set_Calibration;

   function Current_Direction return Direction is (Current);

   function Is_Moving return Boolean is (Current /= Stopped);
   
end ;