module Messenger.Scene exposing (..)
import Lib.Scene.Transitions.Base exposing (Transition)
import Lib.Audio.Base exposing (AudioOption)

type alias Scene env event data scenemsg ren=
    { init : env -> scenemsg -> data
    , update : env -> event -> data -> ( data, List (SceneOutputMsg scenemsg), env )
    , view : env -> data -> ren
    }


type SceneOutputMsg scenemsg
    = SOMChangeScene ( scenemsg, String, Maybe Transition )
    | SOMPlayAudio String String AudioOption -- audio name, audio url, audio option
    | SOMAlert String
    | SOMStopAudio String
    | SOMSetVolume Float
    | SOMPrompt String String -- name, title

type MsgBase othermsg scenemsg
    = SOMMsg (SceneOutputMsg scenemsg)
    | OtherMsg othermsg
