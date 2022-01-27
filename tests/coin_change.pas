program coin_change;

function min(a, b: Integer): Integer;
begin
  if a < b then
    min := a
  else
    min := b
end;

var
  coins: Array[0..4] of Integer;
  dp: Array[0..123] of Integer;
  coin, amount, rest: Integer;
  target: Integer;

begin
  target := 123;

  coins[0] := 1;
  coins[1] := 4;
  coins[2] := 7;
  coins[3] := 11;

  amount := 0;
  while amount <= target do
  begin
    dp[amount] := 999999;
    amount := amount + 1
  end;

  dp[0] := 0;

  amount := 1;
  while amount <= target do
  begin
    coin := 0;
    while coin < 4 do
    begin
      rest := amount - coins[coin];
      if rest >= 0 then
        dp[amount] := min(dp[amount], 1 + dp[rest])
      else
        noop;

      coin := coin + 1
    end;

    amount := amount + 1
  end;

  writeln(dp[target]);
end.
