module Profile exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (class, src, type_)
import Html.Events exposing (onClick, onInput)
import Result exposing (map, toMaybe, withDefault)
import User exposing (userDecoder, User)


type alias Model =
    { screenName : String
    , profile : Maybe User
    }


type Msg
    = UpdateScreenName String
    | FetchProfile
    | Clear
    | Load (Result Http.Error User)


url : String -> String
url screenName =
    "http://twitter-stream.dev/user/" ++ screenName


userRequest : String -> Http.Request User
userRequest screenName =
    Http.get (url screenName) userDecoder


getUser : String -> Cmd Msg
getUser screenName =
    Http.send Load (userRequest screenName)


initialModel : Model
initialModel =
    { screenName = ""
    , profile = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


loadUserView : Html msg
loadUserView =
    div [] [ text "load profile" ]


profileView : User -> Html Msg
profileView user =
    div
        [ class "profile" ]
        [ img [ src user.profileImageUrl ] []
        , div
            []
            [ h3 [] [ text (user.name ++ " (@" ++ user.screenName ++ ")") ]
            , div [] [ text user.description ]
            ]
        , button [ class "btn btn-default", onClick Clear ] [ text "Clear" ]
        ]


loadProfileView : Model -> Html Msg
loadProfileView model =
    div
        [ class "load-profile" ]
        [ h4 [] [ text "Load Profile" ]
        , label [] [ text "Screen Name" ]
        , input [ type_ "text", onInput UpdateScreenName ] []
        , p
            []
            [ button
                [ class "btn btn-default", onClick FetchProfile ]
                [ text "Load" ]
            ]
        ]


view : Model -> Html Msg
view model =
    case model.profile of
        Just user ->
            div [] [ profileView user ]

        Nothing ->
            div [] [ loadProfileView model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateScreenName screenName ->
            ( { model | screenName = screenName }, Cmd.none )

        FetchProfile ->
            if model.screenName == "" then
                ( model, Cmd.none )
            else
                ( model, getUser model.screenName )

        Clear ->
            ( { model | profile = Nothing }, Cmd.none )

        Load result ->
            case result of
                Ok profile ->
                    ( { model | profile = Just profile }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub msg
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
