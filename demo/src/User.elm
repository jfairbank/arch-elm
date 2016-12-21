module User exposing (..)

import Json.Decode exposing (decodeString, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias User =
    { screenName : String
    , name : String
    , description : String
    , profileImageUrl : String
    }


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "screen_name" string
        |> required "name" string
        |> required "description" string
        |> required "profile_image_url" string
