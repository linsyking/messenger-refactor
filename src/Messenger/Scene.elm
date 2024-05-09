module Messenger.Scene exposing (..)

import Canvas exposing (Renderable)
import Lib.Audio.Base exposing (AudioOption)
import Lib.Scene.Transitions.Base exposing (Transition)
import Messenger.Base exposing (Env, WorldEvent)


type alias ConcreteScene data env event ren scenemsg =
    { init : env -> scenemsg -> data
    , update : env -> event -> data -> ( data, List (SceneOutputMsg scenemsg), env )
    , view : env -> data -> ren
    }


type alias UnrolledAbsScene env event ren scenemsg =
    { update : env -> event -> ( AbsScene env event ren scenemsg, List (SceneOutputMsg scenemsg), env )
    , view : env -> ren
    }


type AbsScene env event ren scenemsg
    = Roll (UnrolledAbsScene env event ren scenemsg)


type alias MConcreteScene data common localstorage scenemsg =
    ConcreteScene data (Env common localstorage) WorldEvent Renderable scenemsg


type alias MAbsScene common localstorage scenemsg =
    AbsScene (Env common localstorage) WorldEvent Renderable scenemsg


unroll : AbsScene env event ren scenemsg -> UnrolledAbsScene env event ren scenemsg
unroll (Roll un) =
    un


abstract : ConcreteScene data env event ren scenemsg -> env -> scenemsg -> AbsScene env event ren scenemsg
abstract conmodel initEnv initMsg =
    let
        abstractRec data =
            let
                updates env event =
                    let
                        ( new_d, new_m, new_e ) =
                            conmodel.update env event data
                    in
                    ( abstractRec new_d, new_m, new_e )

                views : env -> ren
                views env =
                    conmodel.view env data
            in
            Roll
                { update = updates
                , view = views
                }
    in
    abstractRec (conmodel.init initEnv initMsg)


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
