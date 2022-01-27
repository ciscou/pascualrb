program functions;

function pow(base, exponent: Integer): Integer;
var i: Integer;
begin
  pow := 1;
  i := 0;
  while i < exponent do
  begin
    pow := pow * base;
    i := i + 1
  end;
end;

begin
  writeln(pow(pow(3, 2), 2))
end.
