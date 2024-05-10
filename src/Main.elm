module Main exposing (..)

import Base exposing (..)
import Browser.Events exposing (Visibility(..))
import Dict
import Messenger.Base exposing (GlobalData)
import Messenger.UI exposing (Output, genMain)
import Messenger.UI.Init exposing (emptyInternalData)
import Messenger.UserConfig exposing (UserConfig)
import Scenes.AllScenes exposing (allScenes)
import Set
import Time exposing (millisToPosix)



-- Testing Messenger


emptyKeycodeSet : Set.Set Int
emptyKeycodeSet =
    Set.empty


initGlobalData : LocalStorage -> GlobalData LocalStorage
initGlobalData storage =
    { internalData = emptyInternalData
    , currentTimeStamp = millisToPosix 0
    , sceneStartTime = 0
    , globalTime = 0
    , volume = 0.5
    , windowVisibility = Visible
    , pressedKeys = emptyKeycodeSet
    , mousePos = ( 0, 0 )
    , extraHTML = Nothing
    , localStorage = storage
    , currentScene = ""
    }


saveGlobalData : GlobalData LocalStorage -> LocalStorage
saveGlobalData globalData =
    globalData.localStorage


userConfig : UserConfig LocalStorage SceneMsg
userConfig =
    { initScene = "Test_SOMMsg"
    , initSceneMsg = Nothing
    , virtualSize = { width = 1920, height = 1080 }
    , debug = False
    , background = Messenger.UserConfig.transparentBackground
    , initGlobalData = initGlobalData
    , saveGlobalData = saveGlobalData
    , allTexture =
        [ ( "bg", "assets/bg.jpg" )
        , ( "blobcat", "assets/blobcat.png" )
        ]
    , allSpriteSheets = Dict.empty
    , timeInterval = 15
    , localStorageCodec =
        { encode = encodeLocalStorage
        , decode = decodeLocalStorage
        }
    }


main : Output LocalStorage SceneMsg
main =
    genMain { config = userConfig, allScenes = allScenes }
