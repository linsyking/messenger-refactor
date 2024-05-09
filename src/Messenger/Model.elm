module Messenger.Model exposing (..)

{-| Model

This is the main model data.

`currentData` and `currentGlobalData` is writable, `currentScene` is readonly, `time` is readonly.

Those data is **not** exposed to the scene.

We only use it in the main update.

TODO

-}

import Audio exposing (Audio, AudioData)
import Messenger.Audio.Base exposing (AudioRepo)
import Messenger.Base exposing (GlobalData)
import Messenger.Scene.Scene exposing (MAbsScene)
import Messenger.Scene.Transitions.Base exposing (Transition)
import Browser.Events exposing (Visibility(..))
import Messenger.Audio.Audio exposing (getAudio)


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



{-| audio

The audio argument needed in the main model.

-}
audio : AudioData -> Model localstorage scenemsg -> Audio
audio ad model =
    Audio.group (getAudio ad model.audiorepo)
        |> Audio.scaleVolume model.currentGlobalData.volume
