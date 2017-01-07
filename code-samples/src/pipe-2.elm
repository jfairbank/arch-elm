list
  |> List.map ((*) 2)
  |> List.filter ((<) 6)
  |> List.map (\n -> n * n)
