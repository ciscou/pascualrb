program prime;

var
  max, num, divisor: Integer;
  is_prime: Boolean;

begin
  max := 100;
  num := 2;

  while num <= max do
  begin
    is_prime := true;
    divisor := 2;

    while is_prime and divisor <= num / 2 do
    begin
      if num mod divisor = 0 then
        is_prime := false
      else
        noop;

      divisor := divisor + 1
    end;

    if is_prime then writeln(num) else noop;

    num := num + 1
  end
end.
