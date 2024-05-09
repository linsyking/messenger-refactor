module Messenger.Scene.Scene exposing (..)

import Canvas exposing (Renderable)
import Messenger.Audio.Base exposing (AudioOption)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Transitions.Base exposing (Transition)


type alias ConcreteScene data env event ren scenemsg ls =
    { init : env -> scenemsg -> data
    , update : env -> event -> data -> ( data, List (SceneOutputMsg scenemsg ls), env )
    , view : env -> data -> ren
    }


type alias UnrolledAbsScene env event ren scenemsg ls =
    { update : env -> event -> ( AbsScene env event ren scenemsg ls, List (SceneOutputMsg scenemsg ls), env )
    , view : env -> ren
    }


type AbsScene env event ren scenemsg ls
    = Roll (UnrolledAbsScene env event ren scenemsg ls)


type alias MConcreteScene data localstorage scenemsg =
    ConcreteScene data (Env () localstorage) WorldEvent Renderable scenemsg localstorage


type alias MAbsScene localstorage scenemsg =
    AbsScene (Env () localstorage) WorldEvent Renderable scenemsg localstorage


unroll : AbsScene env event ren scenemsg ls -> UnrolledAbsScene env event ren scenemsg ls
unroll (Roll un) =
    un


abstract : ConcreteScene data env event ren scenemsg ls -> env -> scenemsg -> AbsScene env event ren scenemsg ls
abstract conmodel initEnv initMsg =
    let
        abstractRec data =
            let
                updates : env -> event -> ( AbsScene env event ren scenemsg ls, List (SceneOutputMsg scenemsg ls), env )
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


type SceneOutputMsg scenemsg ls
    = SOMChangeScene ( scenemsg, String, Maybe (Transition ls) )
    | SOMPlayAudio String String AudioOption -- audio name, audio url, audio option
    | SOMAlert String
    | SOMStopAudio String
    | SOMSetVolume Float
    | SOMPrompt String String -- name, title

