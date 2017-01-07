half : Int -> Maybe Int
half n =
    if n % 2 == 0 then
        Just (n // 2)
    else
        Nothing

half 4 -- Just 2
half 5 -- Nothing

List.head [1, 2, 3] -- Just 1
List.head []        -- Nothing
