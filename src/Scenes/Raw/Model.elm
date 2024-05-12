module Scenes.Raw.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Canvas
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)


{-| Scene data
-}
type alias Data =
    {}


{-| Init function for the scene.

Add all the layers with their init msg here.

-}
sceneInit : RawSceneInit Data UserData SceneMsg
sceneInit env msg =
    {}


sceneUpdate : RawSceneUpdate Data UserData SceneMsg
sceneUpdate env msg data =
    ( data, [], env )


sceneView : RawSceneView UserData Data
sceneView env data =
    Canvas.empty


scenecon : MConcreteScene Data UserData SceneMsg
scenecon =
    { init = sceneInit
    , update = sceneUpdate
    , view = sceneView
    }


{-| Generate an abstract scnene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genRawScene scenecon
