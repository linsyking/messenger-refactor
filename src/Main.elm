module Main exposing (main)

{-|


# Main

Main module for the whole game.

@docs main

-}

import Browser.Events exposing (Visibility(..))
import Color
import Dict
import Lib.Base exposing (..)
import Lib.Ports exposing (alert, audioPortFromJS, audioPortToJS, prompt, promptReceiver, sendInfo)
import Messenger.Base exposing (UserViewGlobalData)
import Messenger.UI exposing (Output, genMain)
import Messenger.UserConfig exposing (UserConfig)
import Scenes.AllScenes exposing (allScenes)



-- Testing Messenger


{-| Initial Globaldata
-}
initGlobalData : String -> UserViewGlobalData UserData
initGlobalData data =
    let
        storage =
            decodeUserData data
    in
    { sceneStartTime = 0
    , globalTime = 0
    , volume = storage.volume
    , canvasAttributes = []
    , extraHTML = Nothing
    , userData = storage
    }


{-| Save Globaldata

save the user data to local storage.

-}
saveGlobalData : UserViewGlobalData UserData -> String
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


{-| User Configuration

Edit user configurations here.

-}
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


{-| Main
-}
main : Output UserData SceneMsg
main =
    genMain { config = userConfig, allScenes = allScenes }
