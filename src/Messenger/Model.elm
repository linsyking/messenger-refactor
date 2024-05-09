module Messenger.Model exposing (..)

{-| Model

This is the main model data.

`currentData` and `currentGlobalData` is writable, `currentScene` is readonly, `time` is readonly.

Those data is **not** exposed to the scene.

We only use it in the main update.

TODO

-}

import Audio exposing (Audio, AudioData)
import Lib.Audio.Base exposing (AudioRepo)
import Messenger.Base exposing (GlobalData)
import Messenger.Scene.Scene exposing (MAbsScene)
import Messenger.Scene.Transitions.Base exposing (Transition)


type alias Model localstorage scenemsg =
    { currentScene : MAbsScene localstorage scenemsg
    , currentGlobalData : GlobalData localstorage
    , audiorepo : AudioRepo
    , transition : Maybe ( Transition, ( String, scenemsg ) )
    }


{-| updateSceneStartTime

Add one tick to the scene start time

-}
updateSceneStartTime : Model localstorage scenemsg -> Model localstorage scenemsg
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
resetSceneStartTime : Model localstorage scenemsg -> Model localstorage scenemsg
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
initGlobalData : GlobalData localstorage
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
audio : AudioData -> Model localstorage scenemsg -> Audio
audio ad model =
    Audio.group (getAudio ad model.audiorepo)
        |> Audio.scaleVolume model.currentGlobalData.localStorage.volume
