module Messenger.UI.Init exposing (..)

import Browser.Events exposing (Visibility(..))
import Canvas
import Dict
import Messenger.Base exposing (GlobalData)
import Messenger.Model exposing (Model)
import Messenger.Scene.Scene exposing (AbsScene(..), MAbsScene, SceneOutputMsg)
import Messenger.UserConfig exposing (UserConfig)
import Time exposing (millisToPosix)


emptyScene : MAbsScene localstorage scenemsg
emptyScene =
    let
        abstractRec _ =
            let
                updates : env -> event -> ( AbsScene env event ren scenemsg ls, List (SceneOutputMsg scenemsg ls), env )
                updates env _ =
                    ( abstractRec (), [], env )
            in
            Roll
                { update = updates
                , view = \_ -> Canvas.empty
                }
    in
    abstractRec ()


emptyGlobalData : UserConfig localstorage scenemsg -> GlobalData localstorage
emptyGlobalData config =
    { internalData =
        { browserViewPort = ( 0, 0 )
        , realHeight = 0
        , realWidth = 0
        , startLeft = 0
        , startTop = 0
        , sprites = Dict.empty
        , virtualWidth = 0
        , virtualHeight = 0
        }
    , currentTimeStamp = millisToPosix 0
    , sceneStartTime = 0
    , globalTime = 0
    , volume = 0
    , windowVisibility = Visible
    , mousePos = ( 0, 0 )
    , extraHTML = Nothing
    , localStorage = config.localStorageCodec.decode ""
    , currentScene = ""
    }


initModel : UserConfig localstorage scenemsg -> Model localstorage scenemsg
initModel config =
    { currentScene = emptyScene
    , currentGlobalData = emptyGlobalData config
    , audiorepo = []
    , transition = Nothing
    }
