module Messenger.UI exposing (..)

import Audio
import Messenger.Base exposing (Flags, WorldEvent)
import Messenger.Model exposing (Model, audio)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.UI.Init exposing (init)
import Messenger.UI.Subscription exposing (subscriptions)
import Messenger.UI.Update exposing (update)
import Messenger.UI.View exposing (view)
import Messenger.UserConfig exposing (UserConfig)


type alias Scenes localstorage scenemsg =
    List ( String, SceneStorage localstorage scenemsg )


type alias Input localstorage scenemsg =
    { config : UserConfig localstorage scenemsg
    , allScenes : Scenes localstorage scenemsg
    }


type alias Output localstorage scenemsg =
    Program Flags (Audio.Model WorldEvent (Model localstorage scenemsg)) (Audio.Msg WorldEvent)


main : Input localstorage scenemsg -> Output localstorage scenemsg
main input =
    Audio.elementWithAudio
        { init = init input.config input.allScenes
        , update = update input.config input.allScenes
        , subscriptions = subscriptions input.config
        , view = view input.config
        , audio = audio
        , audioPort = { toJS = audioPortToJS, fromJS = audioPortFromJS }
        }
