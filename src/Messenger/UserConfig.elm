module Messenger.UserConfig exposing (..)

import Browser.Events exposing (Visibility(..))
import Canvas exposing (Renderable)
import Messenger.Base exposing (GlobalData)
import Messenger.Render.SpriteSheet exposing (SpriteSheet)


type alias UserConfig userdata scenemsg =
    { initScene : String
    , initSceneMsg : Maybe scenemsg
    , globalDataCodec :
        { encode : GlobalData userdata -> String
        , decode : String -> GlobalData userdata
        }
    , virtualSize :
        { width : Float
        , height : Float
        }
    , debug : Bool
    , background : GlobalData userdata -> Renderable
    , allTexture : List ( String, String )
    , allSpriteSheets : SpriteSheet
    , timeInterval : Float
    }


transparentBackground : GlobalData userdata -> Renderable
transparentBackground gd =
    Canvas.clear ( 0, 0 ) gd.internalData.realWidth gd.internalData.realHeight
