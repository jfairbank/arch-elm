module Urls exposing (..)


type alias Config =
    { domain : String
    , secure : Bool
    }


devConfig : Config
devConfig =
    { domain = "twitter-stream.dev"
    , secure = False
    }


prodConfig : Config
prodConfig =
    { domain = "twitter-stream.jeremyfairbank.com"
    , secure = True
    }


config : Config
config =
    prodConfig


prefix : String -> String
prefix protocol =
    if config.secure then
        protocol ++ "s://"
    else
        protocol ++ "://"


wsUrl : String
wsUrl =
    (prefix "ws") ++ config.domain


httpUrl : String
httpUrl =
    (prefix "http") ++ config.domain
