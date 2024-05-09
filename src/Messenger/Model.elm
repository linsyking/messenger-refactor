module Messenger.Model exposing (..)

{-| Model

This is the main model data.

`currentData` and `currentGlobalData` is writable, `currentScene` is readonly, `time` is readonly.

Those data is **not** exposed to the scene.

We only use it in the main update.

TODO

-}

import Lib.Audio.Base exposing (AudioRepo)
import Lib.Scene.Transitions.Base exposing (Transition)


type alias Model =
    { currentScene : SceneT
    , currentGlobalData : GlobalData
    , audiorepo : AudioRepo
    , transition : Maybe ( Transition, ( String, SceneInitData ) )
    }


{-| updateSceneStartTime

Add one tick to the scene start time

-}
updateSceneStartTime : Model -> Model
updateSceneStartTime m =
    let
        ogd =
            m.currentGlobalData

        ngd =
            { ogd | sceneStartTime = ogd.sceneStartTime + 1 }
    in
    { m | currentGlobalData = ngd }


{-| resetSceneStartTime
Set the scene starttime to 0.
-}
resetSceneStartTime : Model -> Model
resetSceneStartTime m =
    let
        ogd =
            m.currentGlobalData

        ngd =
            { ogd | sceneStartTime = 0 }
    in
    { m | currentGlobalData = ngd }


{-| initGlobalData

Default settings for globaldata

You may add your own global data.

-}
initGlobalData : GlobalData
initGlobalData =
    { internalData =
        { browserViewPort = ( 1920, 1080 )
        , realHeight = 1080
        , realWidth = 1920
        , startLeft = 0
        , startTop = 0
        , sprites = Dict.empty
        }
    , currentTimeStamp = Time.millisToPosix 0
    , sceneStartTime = 0
    , windowVisibility = Visible
    , mousePos = ( 0, 0 )
    , extraHTML = Nothing
    , localStorage = decodeLSInfo ""
    , currentScene = initScene
    }


{-| audio

The audio argument needed in the main model.

-}
audio : AudioData -> Model -> Audio
audio ad model =
    Audio.group (getAudio ad model.audiorepo)
        |> Audio.scaleVolume model.currentGlobalData.localStorage.volume
