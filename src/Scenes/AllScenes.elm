module Scenes.AllScenes exposing (allScenes)

{-|


# AllScenes

Record all the scenes here

@docs allScenes

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.Main.Model as Main
import Scenes.T1.Model as T1
import Scenes.T2.Model as T2
import Scenes.Test_SOMMsg.Model as Test_SOMMsg


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    [ ( "Main", Main.scene )
    , ( "Test_SOMMsg", Test_SOMMsg.scene )
    , ( "T2", T2.scene )
    , ( "T1", T1.scene )
    ]
