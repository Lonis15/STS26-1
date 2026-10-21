with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Ultrasonic;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Types; use MicroBit.Types;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;
use MicroBit;

procedure Main is

   package SensorFront is new Ultrasonic (MB_P16, MB_P0);
   package SensorLeft  is new Ultrasonic (MB_P14, MB_P2);
   package SensorRight is new Ultrasonic (MB_P15, MB_P1);

   DistanceF : Distance_cm;
   DistanceL : Distance_cm;
   DistanceR : Distance_cm;

   type Robot_State is
     (Driving,
      Backing_Up,
      Turning_Left,
      Turning_Right);

   Current_State : Robot_State := Driving;

   State_Start : Time;
   Action_Time : constant Time_Span := Milliseconds (500);

begin

   loop

      -- Read sensors every loop
      DistanceF := SensorFront.Read;
      DistanceL := SensorLeft.Read;
      DistanceR := SensorRight.Read;

      case Current_State is

         --------------------------------------------------
         -- NORMAL DRIVING STATE
         --------------------------------------------------
         when Driving =>

            if DistanceF <= 5 and DistanceF > 0 then

               Put_Line ("Too close Front");
               Put_Line ("Front: " & Distance_cm'Image(DistanceF));

               Drive_Wheels
                 (rf => (0, 4095),
                  rb => (0, 4095),
                  lf => (0, 4095),
                  lb => (0, 4095));

               State_Start := Clock;
               Current_State := Backing_Up;

            elsif DistanceL <= 5 and DistanceL > 0 then

               Put_Line ("Too close Left");
               Put_Line ("Left: " & Distance_cm'Image(DistanceL));

               Drive_Wheels
                 (rf => (4095, 0),
                  rb => (4095, 0),
                  lf => (0, 4095),
                  lb => (0, 4095));

               State_Start := Clock;
               Current_State := Turning_Right;

            elsif DistanceR <= 5 and DistanceR > 0 then

               Put_Line ("Too close Right");
               Put_Line ("Right: " & Distance_cm'Image(DistanceR));

               Drive_Wheels
                 (rf => (0, 4095),
                  rb => (0, 4095),
                  lf => (4095, 0),
                  lb => (4095, 0));

               State_Start := Clock;
               Current_State := Turning_Left;

            end if;

         --------------------------------------------------
         -- BACKING UP
         --------------------------------------------------
         when Backing_Up =>

            if Clock - State_Start >= Action_Time then
               Drive (Stop);
               Put_Line ("Finished backing up");
               Current_State := Driving;
            end if;

         --------------------------------------------------
         -- TURNING LEFT
         --------------------------------------------------
         when Turning_Left =>

            if Clock - State_Start >= Action_Time then
               Drive (Stop);
               Put_Line ("Finished left turn");
               Current_State := Driving;
            end if;

         --------------------------------------------------
         -- TURNING RIGHT
         --------------------------------------------------
         when Turning_Right =>

            if Clock - State_Start >= Action_Time then
               Drive (Stop);
               Put_Line ("Finished right turn");
               Current_State := Driving;
            end if;

      end case;

      delay 0.05;

   end loop;

end Main;