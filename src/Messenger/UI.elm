module Messenger.UI exposing (..)

import Audio
import Messenger.Base exposing (Flags, WorldEvent)
import Messenger.Model exposing (Model)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.UserConfig exposing (UserConfig)


type alias Scenes localstorage scenemsg=
    List ( String, SceneStorage localstorage scenemsg )


type alias Input localstorage scenemsg =
    { config : UserConfig localstorage scenemsg
    , allScenes : Scenes localstorage scenemsg
    }


type alias Output localstorage scenemsg=
    Program Flags (Audio.Model WorldEvent (Model localstorage scenemsg)) (Audio.Msg WorldEvent)
