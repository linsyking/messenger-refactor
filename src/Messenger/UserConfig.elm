module Messenger.UserConfig exposing (..)

import Canvas exposing (Renderable)
import Messenger.Base exposing (GlobalData)
import Browser.Events exposing (Visibility(..))


type alias UserConfig localstorage scenemsg =
    { initScene : String
    , initSceneMsg : scenemsg
    , localStorageCodec :
        { encode : localstorage -> String
        , decode : String -> localstorage
        }
    , virtualSize :
        { width : Float
        , height : Float
        }
    , debug : Bool
    , background : GlobalData localstorage -> Renderable
    , initGlobalData : localstorage -> GlobalData localstorage
    , allTexture : List ( String, String )
    , timeInterval: Int
    }


{-| initGlobalData
-}
initGlobalData : UserConfig localstorage scenemsg -> String -> GlobalData localstorage
initGlobalData config lsencoded =
    config.initGlobalData (config.localStorageCodec.decode lsencoded)

