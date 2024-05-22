module Scenes.T1.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Canvas exposing (group)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData, popLastScene)
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (UserEvent(..))
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg(..), SceneStorage)


{-| Scene data
-}
type alias Data =
    { name : String
    }


{-| Init function for the scene.

Add all the layers with their init msg here.

-}
init : RawSceneInit Data UserData SceneMsg
init env msg =
    { name = "Blobcat"
    }


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    case msg of
        MouseDown 0 _ ->
            ( data, [ SOMPrompt "name" "Your name" ], env )

        Prompt "name" result ->
            ( { data | name = result }, [], env )

        _ ->
            if env.globalData.sceneStartFrame == 10 then
                ( data, [ SOMPlayAudio 1 "biu" ALoop ], env )

            else if env.globalData.sceneStartFrame == 20 then
                ( data, [ SOMPlayAudio 1 "biu" AOnce ], env )

            else if env.globalData.sceneStartFrame == 30 then
                ( data, [ SOMStopAudio 1, SOMPlayAudio 0 "bgm" AOnce ], env )

            else
                ( data, [], env )


view : RawSceneView UserData Data
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 1080 ) "blobcat"
        , renderText env.globalData 40 data.name "Arial" ( 100, 200 )
        ]


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
