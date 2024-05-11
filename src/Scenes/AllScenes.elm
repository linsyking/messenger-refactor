module Scenes.AllScenes exposing (..)

import Base exposing (..)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.Main.Model as Main
import Scenes.Test_SOMMsg.Model as Test_SOMMsg


allScenes : AllScenes UserData SceneMsg
allScenes =
    [ ( "Main", Main.mainScene )
    , ( "Test_SOMMsg", Test_SOMMsg.mainScene )
    ]
