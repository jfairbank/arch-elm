case findDog "Tucker" dogs of
    Ok dog ->
        "Got dog " ++ dog.name

    Err error ->
        "Error: '" ++ error ++ "'"
