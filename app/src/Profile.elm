module Profile exposing (..)

import Http
import Html exposing (..)
import Json.Decode exposing (string, Decoder)
import Json.Decode.Pipeline exposing (required, decode)
import Html.Events exposing (onClick, onInput)
import Html.Attributes
    exposing
        ( class
        , src
        , type_
        , value
        , disabled
        )


type alias User =
    { screenName : String
    , name : String
    , description : String
    , profileImageUrl : String
    }


type alias Model =
    { screenName : String
    , profile : Maybe User
    }


type Msg
    = UpdateScreenName String
    | FetchUser
    | LoadUser (Result Http.Error User)


initialModel : Model
initialModel =
    Model "" Nothing


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


profileView : User -> Html Msg
profileView user =
    let
        displayName =
            user.name ++ " (@" ++ user.screenName ++ ")"
    in
        div [ class "profile" ]
            [ img [ src user.profileImageUrl ] []
            , div []
                [ h3 [] [ text displayName ]
                , div [] [ text user.description ]
                ]
            ]


loadProfileView : Model -> Html Msg
loadProfileView model =
    div [ class "load-profile" ]
        [ h4 [] [ text "Load Profile" ]
        , label [] [ text "Screen Name" ]
        , input
            [ type_ "text"
            , value model.screenName
            , onInput UpdateScreenName
            ]
            []
        , button
            [ disabled (model.screenName == "")
            , onClick FetchUser
            ]
            [ text "Load" ]
        , p [] [ text model.screenName ]
        ]


view : Model -> Html Msg
view model =
    case model.profile of
        Just user ->
            profileView user

        Nothing ->
            loadProfileView model


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "screen_name" string
        |> required "name" string
        |> required "description" string
        |> required "profile_image_url" string


fetchUser : String -> Cmd Msg
fetchUser screenName =
    let
        url =
            "http://localhost:8081/user/" ++ screenName

        request =
            Http.get url userDecoder
    in
        Http.send LoadUser request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateScreenName screenName ->
            ( { model | screenName = screenName }, Cmd.none )

        FetchUser ->
            ( model, fetchUser model.screenName )

        LoadUser result ->
            case result of
                Ok user ->
                    ( { model | profile = Just user }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
