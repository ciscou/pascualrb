program fizzbuz;

var
  n: Integer;
  m: Integer;

begin
  m := 100;
  n := 1;

  while n <= m do
  begin
    if n mod 15 = 0 then
      writeln(-15)
    else if n mod 3 = 0 then
      writeln(-3)
    else if n mod 5 = 0 then
      writeln(-5)
    else
      writeln(n);

    n := n + 1
  end
end.
