with Ada.Real_Time;
use Ada.Real_Time;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.MotorDriver;
with MicroBit.MotorDriver.Car; use MicroBit.MotorDriver.Car;
with MicroBit.Radio; use MicroBit.Radio;
with HAL; use HAL;
with Protocol; use Protocol;


procedure Main with Priority => 0 is
   subtype Zero_To_Six is Integer range 0 .. 6;

   TxData : RadioData;
   RxData : RadioData;
   Dir : MicroBit.MotorDriver.Car.Direction;

begin
   TxData.Length := 4;
   TxData.Version := 12;
   TxData.Group := 37;
   TxData.Protocol := 14;

   Put_Line ("Heyyy from begin");

   Setup(RadioFrequency => 2416,
                Length   => TxData.Length,
                Version  => TxData.Version,
                Group    => TxData.Group,
                Protocol => TxData.Protocol);
   StartReceiving;

   Dir := Stopped;

   loop
      while DataReady loop
         RxData := Receive;
         Put_Line ("Len=" & UInt8'Image (RxData.Length) &
          " Grp=" & UInt8'Image (RxData.Group) &
          " P1="  & UInt8'Image (RxData.Payload (1)) &
          " P2="  & UInt8'Image (RxData.Payload (2)) &
          " P3="  & UInt8'Image (RxData.Payload (3)) &
          " P4="  & UInt8'Image (RxData.Payload (4)));
         
         Dir := Decode(RxData);

         if Dir /= Stopped then
            Move (Dir, 2000);
         else
            Move (Stopped, 2000);
         end if;

      end loop;
      
      -- TxData.payload(1) := 42;

      -- Transmit(TxData);
      
      

   end loop;
end Main;
