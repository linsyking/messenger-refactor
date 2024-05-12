module Scenes.AllScenes exposing (allScenes)

{-|


# AllScenes

Record all the scenes here

@docs allscenes

-}

import Lib.Base exposing (..)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.Main.Model as Main
import Scenes.Test_SOMMsg.Model as Test_SOMMsg


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    [ ( "Main", Main.mainScene )
    , ( "Test_SOMMsg", Test_SOMMsg.mainScene )
    ]
