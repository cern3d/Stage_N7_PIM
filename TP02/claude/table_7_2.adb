procedure Table_7 is
begin
   for I in 1 .. 9 loop
      Put(I, Width => 1);
      Put(" x 7 = ");
      Put(I * 7, Width => 1);
      New_Line;
   end loop;
end Table_7;

--  POUR i allant de 1 à 9 :
--      AFFICHER i + " x 7 = " + (i * 7)
--  FIN POUR