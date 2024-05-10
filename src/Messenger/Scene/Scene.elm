module Messenger.Scene.Scene exposing (..)

import Canvas exposing (Renderable)
import Messenger.Audio.Base exposing (AudioOption)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Transitions.Base exposing (Transition)


type alias ConcreteScene data env event ren scenemsg localstorage =
    { init : env -> Maybe scenemsg -> data
    , update : env -> event -> data -> ( data, List (SceneOutputMsg scenemsg localstorage), env )
    , view : env -> data -> ren
    }


type alias UnrolledAbstractScene env event ren scenemsg localstorage =
    { update : env -> event -> ( AbstractScene env event ren scenemsg localstorage, List (SceneOutputMsg scenemsg localstorage), env )
    , view : env -> ren
    }


type AbstractScene env event ren scenemsg localstorage
    = Roll (UnrolledAbstractScene env event ren scenemsg localstorage)


type alias MConcreteScene data localstorage scenemsg =
    ConcreteScene data (Env () localstorage) WorldEvent Renderable scenemsg localstorage


type alias MAbstractScene localstorage scenemsg =
    AbstractScene (Env () localstorage) WorldEvent Renderable scenemsg localstorage


unroll : AbstractScene env event ren scenemsg localstorage -> UnrolledAbstractScene env event ren scenemsg localstorage
unroll (Roll un) =
    un


abstract : ConcreteScene data env event ren scenemsg localstorage -> env -> Maybe scenemsg -> AbstractScene env event ren scenemsg localstorage
abstract conmodel initEnv initMsg =
    let
        abstractRec data =
            let
                updates : env -> event -> ( AbstractScene env event ren scenemsg localstorage, List (SceneOutputMsg scenemsg localstorage), env )
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


type SceneOutputMsg scenemsg localstorage
    = SOMChangeScene ( Maybe scenemsg, String, Maybe (Transition localstorage) )
    | SOMPlayAudio String String AudioOption -- audio name, audio url, audio option
    | SOMAlert String
    | SOMStopAudio String
    | SOMSetVolume Float
    | SOMPrompt String String -- name, title
    | SOMSaveLocalStorage
