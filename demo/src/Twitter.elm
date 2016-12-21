module Twitter exposing (..)

import List
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Json.Decode exposing (decodeString, list, string, Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import User exposing (User, userDecoder)
import WebSocket exposing (listen)


type alias Photo =
    { url : String
    }


type alias Entities =
    { photos : List Photo
    }


type alias Tweet =
    { text : String
    , user : User
    , entities : Entities
    }


type alias Model =
    { tweets : List Tweet
    }


type Msg
    = TweetMsg String


url : String
url =
    "ws://twitter-stream.dev"


photoDecoder : Decoder Photo
photoDecoder =
    decode Photo
        |> required "media_url" string


entitiesDecoder : Decoder Entities
entitiesDecoder =
    decode Entities
        |> optional "media" (list photoDecoder) []


tweetDecoder : Decoder Tweet
tweetDecoder =
    decode Tweet
        |> required "text" string
        |> required "user" userDecoder
        |> required "entities" entitiesDecoder


parseTweet : String -> Result String Tweet
parseTweet =
    decodeString tweetDecoder


initialModel : Model
initialModel =
    { tweets = []
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


photoView : Tweet -> Html msg
photoView tweet =
    case tweet.entities.photos of
        [] ->
            text ""

        x :: xs ->
            img [ src x.url ] []


tweetView : Tweet -> Html msg
tweetView tweet =
    li
        [ class "tweet" ]
        [ h4 [] [ text tweet.user.screenName ]
        , div [] [ text tweet.text ]
        , photoView tweet
        ]


tweetsView : List Tweet -> Html msg
tweetsView tweets =
    List.take 10 tweets
        |> List.map tweetView
        |> ul [ class "tweets" ]


twitterStreamView : List Tweet -> Html msg
twitterStreamView tweets =
    div
        [ class "twitter-stream" ]
        [ h2 [] [ text "Twitter Stream for #codemash" ]
        , tweetsView tweets
        ]


view : Model -> Html Msg
view model =
    twitterStreamView model.tweets


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TweetMsg message ->
            case parseTweet message of
                Ok tweet ->
                    ( { model | tweets = tweet :: model.tweets }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    listen url TweetMsg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
