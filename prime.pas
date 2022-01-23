program prime;

var
  max: Integer;
  num: Integer;
  is_prime: Integer;
  divisor: Integer;

begin
  max := 100;
  num := 2;

  while num <= max do
  begin
    is_prime := 1;
    divisor := 2;

    while is_prime = 1 and divisor <= num / 2 do
    begin
      if num mod divisor = 0 then
        is_prime := 0
      else
      begin end;

      divisor := divisor + 1
    end;

    if is_prime = 1 then writeln(num) else begin end;

    num := num + 1
  end
end.
