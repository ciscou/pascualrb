program if_else;

var
  x: Integer;
  y: Integer;
  z: Integer;

begin
  if x < 2 then begin
    if x = 0 then
      writeln(1)
    else
      writeln(2)
    end
  else begin
    writeln(3)
  end;

  if x = 0 and y = 0 and not (z > 0) then
    writeln(42)
  else
  begin end
end.
