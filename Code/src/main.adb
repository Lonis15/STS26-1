with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Ultrasonic;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Types; use MicroBit.Types;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;
with MicroBit.Radio; use MicroBit.Radio;
with HAL; use HAL;
with Protocol; use Protocol;
with DFR0548; use MicroBit;

procedure Main with Priority => 0 is

   package SensorFront is new Ultrasonic (MB_P16, MB_P0);
   package SensorLeft  is new Ultrasonic (MB_P14, MB_P2);
   package SensorRight is new Ultrasonic (MB_P15, MB_P1);

   TxData : RadioData;
   RxData : RadioData;

   DistanceF : Distance_cm;
   DistanceL : Distance_cm;
   DistanceR : Distance_cm;

   
   Remote_Dir : MicroBit.MotorDriver.Car.Direction := Stopped;

   type Car_State is
     (Driving,
      Backing_Up,
      Turning_Left,
      Turning_Right);

   Current_State : Car_State := Driving;

   State_Start : Time;
   Action_Time : constant Time_Span := Milliseconds (500);

   
   Motor_Speed : constant MicroBit.MotorDriver.Car.Speed_Value := 2000;

begin
   TxData.Length   := 4;
   TxData.Version  := 12;
   TxData.Group    := 37;
   TxData.Protocol := 14;

   Setup
     (RadioFrequency => 2416,
      Length         => TxData.Length,
      Version        => TxData.Version,
      Group          => TxData.Group,
      Protocol       => TxData.Protocol);

   StartReceiving;

   Move (Stopped, 0);
   Put_Line ("Car ready");

   loop

      --------------------------------------------------
      -- 1. RECEIVE REMOTE COMMANDS
      --------------------------------------------------
      while DataReady loop
         RxData := Receive;
         Remote_Dir := Decode(RxData);

         Put_Line ("Len=" & UInt8'Image (RxData.Length) &
          " Grp=" & UInt8'Image (RxData.Group) &
          " P1="  & UInt8'Image (RxData.Payload (1)) &
          " P2="  & UInt8'Image (RxData.Payload (2)) &
          " P3="  & UInt8'Image (RxData.Payload (3)) &
          " P4="  & UInt8'Image (RxData.Payload (4)));
      

         --------------------------------------------------
         -- 2. READ ULTRASONIC SENSORS
         --------------------------------------------------
         DistanceF := SensorFront.Read;
         DistanceL := SensorLeft.Read;
         DistanceR := SensorRight.Read;

         --------------------------------------------------
         -- 3. CENTRAL MOTOR CONTROL
         --------------------------------------------------
         case Current_State is

            when Driving =>

               if DistanceF <= 5 and DistanceF > 0 then

                  Put_Line ("Obstacle in front");

                  Move (Backward, Motor_Speed);

                  State_Start := Clock;
                  Current_State := Backing_Up;

               elsif DistanceL <= 5 and DistanceL > 0 then

                  Put_Line ("Obstacle on left");

                  Move (Right, Motor_Speed);

                  State_Start := Clock;
                  Current_State := Turning_Right;

               elsif DistanceR <= 5 and DistanceR > 0 then

                  Put_Line ("Obstacle on right");

                  Move (Left, Motor_Speed);

                  State_Start := Clock;
                  Current_State := Turning_Left;

               else

                  Move (Remote_Dir, Motor_Speed);

               end if;

            --------------------------------------------------
            -- BACKING UP
            --------------------------------------------------
            when Backing_Up =>

               if Clock - State_Start >= Action_Time then
                  Move (Stopped, 0);
                  Put_Line ("Finished backing up");
                  Current_State := Driving;
               end if;

            --------------------------------------------------
            -- TURNING LEFT
            --------------------------------------------------
            when Turning_Left =>

               if Clock - State_Start >= Action_Time then
                  Move (Stopped, 0);
                  Put_Line ("Finished left turn");
                  Current_State := Driving;
               end if;

            --------------------------------------------------
            -- TURNING RIGHT
            --------------------------------------------------
            when Turning_Right =>

               if Clock - State_Start >= Action_Time then
                  Move (Stopped, 0);
                  Put_Line ("Finished right turn");
                  Current_State := Driving;
               end if;

         end case;

         delay 0.05;

      end loop;
   end loop;
   
end Main;
