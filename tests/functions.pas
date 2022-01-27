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

function square(n: Integer): Integer;
begin
  square := pow(n, 2);
end;

begin
  writeln(square(square(3)))
end.
