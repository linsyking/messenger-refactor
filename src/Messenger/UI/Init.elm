module Messenger.UI.Init exposing (..)

import Audio exposing (AudioCmd)
import Browser.Events exposing (Visibility(..))
import Canvas
import Dict
import Messenger.Base exposing (Env, Flags, GlobalData, InternalData, WorldEvent(..))
import Messenger.Coordinate.Coordinates exposing (getStartPoint, maxHandW)
import Messenger.Model exposing (Model)
import Messenger.Scene.Loader exposing (SceneStorage, loadSceneByName)
import Messenger.Scene.Scene exposing (AbstractScene(..), MAbstractScene, SceneOutputMsg)
import Messenger.UserConfig exposing (UserConfig)
import Set
import Time exposing (millisToPosix)


emptyScene : MAbstractScene localstorage scenemsg
emptyScene =
    let
        abstractRec _ =
            let
                updates : Env () localstorage -> WorldEvent -> ( MAbstractScene localstorage scenemsg, List (SceneOutputMsg scenemsg localstorage), Env () localstorage )
                updates env _ =
                    ( abstractRec (), [], env )
            in
            Roll
                { update = updates
                , view = \_ -> Canvas.empty
                }
    in
    abstractRec ()


emptyInternalData : InternalData
emptyInternalData =
    { browserViewPort = ( 0, 0 )
    , realHeight = 0
    , realWidth = 0
    , startLeft = 0
    , startTop = 0
    , sprites = Dict.empty
    , virtualWidth = 0
    , virtualHeight = 0
    }


emptyGlobalData : UserConfig localstorage scenemsg -> GlobalData localstorage
emptyGlobalData config =
    { internalData = emptyInternalData
    , currentTimeStamp = millisToPosix 0
    , sceneStartTime = 0
    , globalTime = 0
    , volume = 0.5
    , windowVisibility = Visible
    , mousePos = ( 0, 0 )
    , pressedKeys = Set.empty
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


init : UserConfig localstorage scenemsg -> List ( String, SceneStorage localstorage scenemsg ) -> Flags -> ( Model localstorage scenemsg, Cmd WorldEvent, AudioCmd WorldEvent )
init config scenes flags =
    let
        im =
            initModel config

        ms =
            loadSceneByName config.initScene scenes config.initSceneMsg { im | currentGlobalData = newgd }

        ( gw, gh ) =
            maxHandW oldgd ( flags.windowWidth, flags.windowHeight )

        ( fl, ft ) =
            getStartPoint oldgd ( flags.windowWidth, flags.windowHeight )

        ls =
            config.localStorageCodec.decode flags.info

        oldIT =
            { emptyInternalData
                | virtualWidth = config.virtualSize.width
                , virtualHeight = config.virtualSize.height
            }

        oldgd =
            { initGlobalData | internalData = oldIT }

        newIT =
            { oldIT
                | browserViewPort = ( flags.windowWidth, flags.windowHeight )
                , realWidth = gw
                , realHeight = gh
                , startLeft = fl
                , startTop = ft
            }

        initGlobalData =
            config.initGlobalData ls

        newgd =
            { initGlobalData | currentTimeStamp = Time.millisToPosix flags.timeStamp, localStorage = ls, internalData = newIT, currentScene = config.initScene }
    in
    ( { ms | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )
