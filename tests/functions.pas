program functions;

function pow(base, exponent: Integer): Integer;
var i, res: Integer;
begin
  res := 1;
  i := 0;
  while i < exponent do
  begin
    res := res * base;
    i := i + 1
  end;
  return res
end;

function square(n: Integer): Integer;
begin
  return pow(n, 2);
end;

begin
  writeln(square(square(3)))
end.
