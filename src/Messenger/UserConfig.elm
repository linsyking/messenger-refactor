module Messenger.UserConfig exposing (..)

import Canvas exposing (Renderable)
import Messenger.Base exposing (GlobalData)


type alias UserConfig localstorage scenemsg =
    { initScene : String
    , initSceneMsg : scenemsg
    , localStorageEndec :
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
    }


{-| initGlobalData
-}
initGlobalData : UserConfig localstorage scenemsg -> String -> GlobalData localstorage
initGlobalData config lsencoded =
    config.initGlobalData (config.localStorageEndec.decode lsencoded)
