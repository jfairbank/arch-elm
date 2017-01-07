list = List.range 1 10

List.map (\n -> n * n) (List.filter ((<) 6) (List.map ((*) 2) list))


list
  |> List.map ((*) 2)
  |> List.filter ((<) 6)
  |> List.map (\n -> n * n)
