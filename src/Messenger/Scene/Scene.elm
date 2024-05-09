module Messenger.Scene.Scene exposing (..)

import Canvas exposing (Renderable)
import Messenger.Audio.Base exposing (AudioOption)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Transitions.Base exposing (Transition)


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


type alias MConcreteScene data localstorage scenemsg =
    ConcreteScene data (Env () localstorage) WorldEvent Renderable scenemsg


type alias MAbsScene localstorage scenemsg =
    AbsScene (Env () localstorage) WorldEvent Renderable scenemsg


unroll : AbsScene env event ren scenemsg -> UnrolledAbsScene env event ren scenemsg
unroll (Roll un) =
    un


abstract : ConcreteScene data env event ren scenemsg -> env -> scenemsg -> AbsScene env event ren scenemsg
abstract conmodel initEnv initMsg =
    let
        abstractRec data =
            let
                updates : env -> event -> ( AbsScene env event ren scenemsg, List (SceneOutputMsg scenemsg), env )
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

genRawScene : MConcreteScene data localstorage scenemsg -> (Env () localstorage) -> scenemsg -> MAbsScene localstorage scenemsg
genRawScene conraw initEnv initMsg =
    abstract conraw initEnv initMsg

type alias LayeredModel cdata =
    { commonData : cdata 
    , layers : List MAbsLayer --TODO: Layer type
    }

genScene : MConcreteScene (LayeredModel cdata) localstorage scenemsg -> (Env () localstorage) -> scenemsg -> MAbsScene localstorage scenemsg
genScene conscene initEnv initMsg = 
    abstract conscene initEnv initMsg

{-| Remove common data from environment.

Useful when sending message to a component.

-}
noCommonData : Env cdata localstorage -> Env () localstorage
noCommonData env =
    { globalData = env.globalData
    , commonData = ()
    }


{-| Add the common data back.
-}
addCommonData : cdata -> Env () localstorage -> Env cdata localstorage 
addCommonData commonData env =
    { globalData = env.globalData
    , commonData = commonData
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
