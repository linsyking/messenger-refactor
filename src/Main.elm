module Main exposing (..)

import Browser.Events exposing (Visibility(..))
import Color
import Dict
import Lib.Base exposing (..)
import Lib.Ports exposing (alert, audioPortFromJS, audioPortToJS, prompt, promptReceiver, sendInfo)
import Messenger.Base exposing (GlobalData)
import Messenger.UI exposing (Output, genMain)
import Messenger.UI.Init exposing (emptyInternalData)
import Messenger.UserConfig exposing (UserConfig)
import Ports exposing (..)
import Scenes.AllScenes exposing (allScenes)
import Set
import Time exposing (millisToPosix)



-- Testing Messenger


initGlobalData : String -> GlobalData UserData
initGlobalData data =
    let
        storage =
            decodeUserData data
    in
    { internalData = emptyInternalData
    , currentTimeStamp = millisToPosix 0
    , sceneStartTime = 0
    , globalTime = 0
    , volume = storage.volume
    , windowVisibility = Visible
    , pressedKeys = Set.empty
    , pressedMouseButtons = Set.empty
    , canvasAttributes = []
    , mousePos = ( 0, 0 )
    , extraHTML = Nothing
    , userData = storage
    , currentScene = ""
    }


saveGlobalData : GlobalData UserData -> String
saveGlobalData globalData =
    let
        oldls =
            globalData.userData

        newls =
            { oldls
                | volume = globalData.volume
            }
    in
    encodeUserData newls


userConfig : UserConfig UserData SceneMsg
userConfig =
    { initScene = "Test_SOMMsg"
    , initSceneMsg = Nothing
    , virtualSize = { width = 1920, height = 1080 }
    , debug = True
    , background = Messenger.UserConfig.coloredBackground Color.black
    , allTexture =
        [ ( "blobcat", "assets/blobcat.png" )
        ]
    , allSpriteSheets = Dict.empty
    , timeInterval = 15
    , globalDataCodec =
        { encode = saveGlobalData
        , decode = initGlobalData
        }
    , ports =
        { sendInfo = sendInfo
        , audioPortToJS = audioPortToJS
        , audioPortFromJS = audioPortFromJS
        , alert = alert
        , prompt = prompt
        , promptReceiver = promptReceiver
        }
    }


main : Output UserData SceneMsg
main =
    genMain { config = userConfig, allScenes = allScenes }
