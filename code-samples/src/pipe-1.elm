list = List.range 1 10
square n = n * n

list
  |> List.map ((*) 2)
  |> List.filter ((<) 6)
  |> List.map square
