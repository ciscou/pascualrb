program fib;

var
  a: Integer;
  b: Integer;
  c: Integer;
  d: Integer;

begin
  a := 0;
  b := 1;
  c := 26;

  while c > 0 do begin
    d := a;
    a := a + b;
    b := d;
    c := c - 1;

    writeln(a)
  end
end.
