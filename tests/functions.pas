program functions;

function square(n: Integer): Integer;
begin
  square := n * n
end;

begin
  writeln(square(square(3)))
end.
