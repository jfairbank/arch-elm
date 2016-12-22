module Main exposing (..)

import Profile
import Twitter
import Html exposing (..)


type alias Model =
    { profile : Profile.Model
    , twitter : Twitter.Model
    }


type Msg
    = ProfileMsg Profile.Msg
    | TwitterMsg Twitter.Msg


initialModel : Model
initialModel =
    { profile = Profile.initialModel
    , twitter = Twitter.initialModel
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ Html.map ProfileMsg (Profile.view model.profile)
        , hr [] []
        , Html.map TwitterMsg (Twitter.view model.twitter)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProfileMsg subMsg ->
            let
                ( newProfile, cmd ) =
                    Profile.update subMsg model.profile
            in
                ( { model
                    | profile = newProfile
                  }
                , Cmd.map ProfileMsg cmd
                )

        TwitterMsg subMsg ->
            let
                ( newTwitter, cmd ) =
                    Twitter.update subMsg model.twitter
            in
                ( { model
                    | twitter = newTwitter
                  }
                , Cmd.map TwitterMsg cmd
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map TwitterMsg (Twitter.subscriptions model.twitter)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
