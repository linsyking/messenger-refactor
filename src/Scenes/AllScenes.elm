module Scenes.AllScenes exposing (..)

import Base exposing (..)
import Messenger.Scene.Loader exposing (SceneStorage)
import Scenes.Main.Model as Main
import Scenes.Test_SOMMsg.Model as Test_SOMMsg


allScenes : List ( String, SceneStorage LocalStorage SceneMsg )
allScenes =
    [ ( "Main", Main.mainScene )
    , ( "Test_SOMMsg", Test_SOMMsg.mainScene )
    ]
