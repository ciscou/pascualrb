cap := 4;
nums := array(cap);

nums[0] := 2;
nums[1] := 11;
nums[2] := 7;
nums[3] := 15;

target := 9;

i := 0;

while i < cap do
begin
  j := i + 1;

  while j < cap do
  begin
    if nums[i] + nums[j] = target then
    begin
      writeln(i);
      writeln(j)
    end
    else
    begin end;

    j := j + 1
  end;

  i := i + 1
end;
