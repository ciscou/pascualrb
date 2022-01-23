program twosum;

var
  cap: Integer;
  nums: Array[0..3] of Integer;
  target: Integer;
  i: Integer;
  j: Integer;

begin
  cap := 4;

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
        noop;

      j := j + 1
    end;

    i := i + 1
  end
end.
