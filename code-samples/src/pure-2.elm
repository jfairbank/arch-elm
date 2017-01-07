fetchUser id =
    let
        url = "/user/" ++ (toString id)
        request = Http.get url userDecoder
    in
        Http.send LoadUser request
