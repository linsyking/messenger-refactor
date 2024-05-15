module Scenes.T1.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Canvas
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData, popLastScene)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg(..), SceneStorage)


{-| Scene data
-}
type alias Data =
    {}


{-| Init function for the scene.

Add all the layers with their init msg here.

-}
init : RawSceneInit Data UserData SceneMsg
init env msg =
    {}


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    case msg of
        MouseDown 0 _ ->
            let
                gd =
                    env.globalData
            in
            case popLastScene gd.userData of
                ( Just s, newud ) ->
                    let
                        newgd =
                            { gd | userData = newud }
                    in
                    ( data, [ SOMSetContext s ], { env | globalData = newgd } )

                _ ->
                    ( data, [], env )

        _ ->
            ( data, [], env )


view : RawSceneView UserData Data
view env data =
    renderSprite env.globalData [] ( 0, 0 ) ( 1920, 1080 ) "blobcat"


scenecon : MConcreteScene Data UserData SceneMsg
scenecon =
    { init = init
    , update = update
    , view = view
    }


{-| Generate an abstract scnene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genRawScene scenecon
