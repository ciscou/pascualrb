program fact;

var
  a: Integer;
  b: Integer;

begin
  a := 1;
  b := 10;

  while b > 0 do begin
    a := a * b;
    b := b - 1
  end;

  writeln(a)
end.
