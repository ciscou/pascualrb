program bubblesort;

var
  i, j, tmp, size: Integer;
  arr: Array[0..9] of Integer;


begin
  arr[0] := 1;
  arr[1] := 42;
  arr[2] := 69;
  arr[3] := -3;
  arr[4] := 222;
  arr[5] := 17;
  arr[6] := -23;
  arr[7] := 15;
  arr[8] := 33;
  arr[9] := 0;

  i := 9;

  while i > 0 do
  begin
    j := 0;

    while j < i do
    begin
      if arr[j] > arr[j + 1] then begin
        tmp := arr[j];
        arr[j] := arr[j + 1]
        arr[j + 1] := tmp;
      end else begin
      end;

      j := j + 1
    end

    i := i - 1
  end

  i := 0;

  while i < 10 do begin
    writeln(arr[i]);

    i := i + 1
  end
end.
