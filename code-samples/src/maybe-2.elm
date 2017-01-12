divide : number -> number -> Maybe Float
divide x y =
    if y == 0 then
        Nothing
    else
        Just (x / y)

divide 4 2 -- Just 2
divide 4 0 -- Nothing

List.head [1, 2, 3] -- Just 1
List.head []        -- Nothing
