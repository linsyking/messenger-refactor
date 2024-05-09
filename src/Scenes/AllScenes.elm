module Scenes.AllScenes exposing (..)

{-| This module is generated by Messenger, don't modify this.

This module records all the scenes.

@docs allScenes

-}


import Scenes.Home.SceneInit as HomeInit
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Loader exposing (sceneInit)


{-| allScenes
Add all the scenes here
-}
allScenes : List ( String, SceneStorage )
allScenes =
    [ ( "Home", sceneInit )
    ]

type SceneInitMsg
    = HomeInit HomeInit.InitDataT
