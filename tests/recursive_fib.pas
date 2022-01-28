program recursive_fib;

function fib(n: Integer): Integer;
begin
  if n <= 2 then
    return 1
  else
    return fib(n-1) + fib(n-2)
end;

begin
  writeln(fib(10));
end.
