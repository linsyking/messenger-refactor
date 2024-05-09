module Messenger.UserConfig exposing (..)

import Browser.Events exposing (Visibility(..))
import Canvas exposing (Renderable)
import Messenger.Base exposing (GlobalData)
import Messenger.Render.SpriteSheet exposing (SpriteSheet)


type alias UserConfig localstorage scenemsg =
    { initScene : String
    , initSceneMsg : Maybe scenemsg
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
    , saveGlobalData : GlobalData localstorage -> localstorage
    , allTexture : List ( String, String )
    , allSpriteSheets : SpriteSheet
    , timeInterval : Float
    }


{-| initGlobalData
-}
initGlobalData : UserConfig localstorage scenemsg -> String -> GlobalData localstorage
initGlobalData config lsencoded =
    config.initGlobalData (config.localStorageCodec.decode lsencoded)
