program minmax;

var
  cap: Integer;
  arr: Array[0..9] of Integer;
  min, max, i: Integer;

begin
  cap := 10;

  arr[0] := 0;
  arr[1] := -1;
  arr[2] := 42;
  arr[3] := 69;
  arr[4] := -420;
  arr[5] := 17;
  arr[6] := 1;
  arr[7] := 23;
  arr[8] := 100;
  arr[9] := 33;

  min := arr[0];
  max := arr[0];

  i := 0;
  while i < cap do
  begin
    if arr[i] < min then min := arr[i] else noop;
    if arr[i] > max then max := arr[i] else noop;

    i := i + 1
  end;

  writeln(min);
  writeln(max)
end.
