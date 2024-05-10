module Main exposing (..)

import Base exposing (..)
import Browser.Events exposing (Visibility(..))
import Dict
import Messenger.Base exposing (GlobalData)
import Messenger.UI exposing (Output, genMain)
import Messenger.UI.Init exposing (emptyInternalData)
import Messenger.UserConfig exposing (UserConfig)
import Scenes.AllScenes exposing (allScenes)
import Time exposing (millisToPosix)



-- Testing Messenger


initGlobalData : LocalStorage -> GlobalData LocalStorage
initGlobalData storage =
    { internalData = emptyInternalData
    , currentTimeStamp = millisToPosix 0
    , sceneStartTime = 0
    , globalTime = 0
    , volume = 0.5
    , windowVisibility = Visible
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
    { initScene = "Main"
    , initSceneMsg = Nothing
    , virtualSize = { width = 800, height = 600 }
    , debug = False
    , background = Messenger.UserConfig.transparentBackground
    , initGlobalData = initGlobalData
    , saveGlobalData = saveGlobalData
    , allTexture = []
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
