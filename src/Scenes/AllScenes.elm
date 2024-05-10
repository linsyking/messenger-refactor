module Scenes.AllScenes exposing (..)

import Base exposing (..)
import Messenger.Scene.Loader exposing (SceneStorage)
import Scenes.Main.Model exposing (mainScene)


allScenes : List ( String, SceneStorage LocalStorage SceneMsg )
allScenes =
    [ ( "Main", mainScene ) ]
