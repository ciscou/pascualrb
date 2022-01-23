program pi;

var
  p: Integer;
  i: Integer;
  s: Integer;

begin
  p := 3;
  i := 2;
  s := 1;

  while i < 2000 do
  begin
    p := p + s * 4 / (i * (i + 1) * (i + 2));

    i := i + 2;
    s := -s;
  end;

  writeln(p)
end.
