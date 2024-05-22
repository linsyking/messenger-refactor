module Scenes.T2.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Canvas exposing (group)
import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData, contextSetter)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg(..), SceneStorage)
import Messenger.Scene.Transitions.Base exposing (genTransition, nullTransition)
import Messenger.Scene.Transitions.Fade exposing (fadeInBlack, fadeInWithRenderable, fadeOutBlack)
import Messenger.UserConfig exposing (coloredBackground)
import String exposing (fromInt)
import Messenger.Base exposing (loadedResourceNum)
import Messenger.UserConfig exposing (resourceNum)
import Lib.Resources exposing (resources)


{-| Scene data
-}
type alias Data =
    { time : Int
    }


{-| Init function for the scene.

Add all the layers with their init msg here.

-}
init : RawSceneInit Data UserData SceneMsg
init env msg =
    { time = 0
    }


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    case msg of
        Tick _ ->
            ( { data | time = data.time + 1 }, [], env )

        MouseDown 0 _ ->
            ( data, [ SOMChangeScene Nothing "T1" <| Just <| genTransition ( nullTransition, Duration.seconds 0 ) ( fadeInWithRenderable <| view env data, Duration.seconds 1 ) ], env )

        _ ->
            ( data, [], env )


view : RawSceneView UserData Data
view env data =
    group []
        [ coloredBackground Color.white env.globalData
        , renderText env.globalData 40 (fromInt env.globalData.sceneStartTime ++ "; local: " ++ fromInt data.time) "Arial" ( 100, 100 )
        , renderText env.globalData 40 (fromInt (loadedResourceNum env.globalData) ++ "/" ++ fromInt (resourceNum resources)) "Arial" ( 100, 200 )
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
