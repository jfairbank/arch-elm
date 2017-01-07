findDog : String -> Dict String Dog -> Result String Dog
findDog name dogs =
    case Dict.get name dogs of
        Just dog ->
            Ok dog

        Nothing ->
            Err "Couldn't find dog"
