with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Table_7 is
begin
   for I in 1 .. 9 loop
      Put(I, Width => 1);
      Put(" x 7 = ");
      Put(I * 7, Width => 2);
      New_Line;
   end loop;
end Table_7;