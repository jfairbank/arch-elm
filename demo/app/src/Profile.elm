module Profile exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (class, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Urls exposing (httpUrl)
import User exposing (userDecoder, User)


type alias Model =
    { screenName : String
    , profile : Maybe User
    }


type Msg
    = UpdateScreenName String
    | FetchProfile
    | Load (Result Http.Error User)
    | Clear


url : String -> String
url screenName =
    httpUrl ++ "/user/" ++ screenName


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


init : ( Model, Cmd msg )
init =
    ( initialModel, Cmd.none )


loadProfileView : Model -> Html Msg
loadProfileView model =
    div
        [ class "load-profile" ]
        [ h4 [] [ text "Load Profile" ]
        , label [] [ text "Screen Name" ]
        , input
            [ type_ "text"
            , value model.screenName
            , onInput UpdateScreenName
            ]
            []
        , p
            []
            [ button
                [ class "btn btn-default", onClick FetchProfile ]
                [ text "Load" ]
            ]
        ]


displayName : User -> String
displayName user =
    user.name ++ " (@" ++ user.screenName ++ ")"


profileView : User -> Html Msg
profileView user =
    div
        [ class "profile" ]
        [ img [ src user.profileImageUrl ] []
        , div
            []
            [ h3 [] [ text (displayName user) ]
            , div [] [ text user.description ]
            ]
        , button
            [ class "btn btn-default", onClick Clear ]
            [ text "Clear" ]
        ]


view : Model -> Html Msg
view model =
    case model.profile of
        Just profile ->
            div [] [ profileView profile ]

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

        Load result ->
            case result of
                Ok profile ->
                    ( { model
                        | profile = Just profile
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        Clear ->
            ( { model | profile = Nothing }, Cmd.none )


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
