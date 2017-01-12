module Twitter exposing (..)

import List
import Html exposing (..)
import Html.Attributes exposing (class, src)
import User exposing (userDecoder, User)
import Json.Decode
    exposing
        ( decodeString
        , string
        , bool
        , Decoder
        )
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , optional
        )
import WebSocket exposing (listen)


type alias Tweet =
    { text : String
    , user : User
    , retweeted : Bool
    }


type alias Model =
    List Tweet


type Msg
    = TweetMsg String


tweetDecoder : Decoder Tweet
tweetDecoder =
    decode Tweet
        |> required "text" string
        |> required "user" userDecoder
        |> optional "retweeted" bool False


parseTweet : String -> Result String Tweet
parseTweet =
    decodeString tweetDecoder


initialModel : Model
initialModel =
    []


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


tweetView : Tweet -> Html Msg
tweetView tweet =
    li [ class "tweet" ]
        [ h4 [] [ text tweet.user.screenName ]
        , div [] [ text tweet.text ]
        ]


isRetweet : Tweet -> Bool
isRetweet tweet =
    tweet.retweeted || String.startsWith "RT" tweet.text


tweetsView : Model -> Html Msg
tweetsView =
    List.filter (not << isRetweet)
        >> List.take 50
        >> List.map tweetView
        >> ul [ class "tweets" ]


view : Model -> Html Msg
view tweets =
    div [ class "twitter-stream" ]
        [ h2 [] [ text "Twitter Stream for #codemash" ]
        , tweetsView tweets
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg tweets =
    case msg of
        TweetMsg rawTweet ->
            case parseTweet rawTweet of
                Ok tweet ->
                    ( tweet :: tweets, Cmd.none )

                Err _ ->
                    ( tweets, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    listen "ws://localhost:8081" TweetMsg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
