program foo_bar;

var
  foo, bar, res: Integer;

begin
  foo := 3 * 4 + 6 / 2;
  bar := -420 / 10 + 3 * 4;

  if foo < bar then begin
    res := 1
  end else begin
    res := 0
  end
end.
