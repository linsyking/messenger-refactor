module Messenger.Layer.Layer exposing (..)

import Canvas exposing (Renderable)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (MAbstractGeneralModel, MConcreteGeneralModel, Msg, abstract)
import Messenger.Scene.Scene exposing (SceneOutputMsg)


type alias ConcreteLayer data cdata localstorage tar msg scenemsg =
    { init : Env cdata localstorage -> msg -> data
    , update : Env cdata localstorage -> WorldEvent -> data -> ( data, List (Msg tar msg (SceneOutputMsg scenemsg localstorage)), ( Env cdata localstorage, Bool ) )
    , updaterec : Env cdata localstorage -> msg -> data -> ( data, List (Msg tar msg (SceneOutputMsg scenemsg localstorage)), Env cdata localstorage )
    , view : Env cdata localstorage -> data -> Renderable
    , matcher : data -> tar -> Bool
    }


type alias AbstractLayer cdata localstorage tar msg scenemsg =
    MAbstractGeneralModel cdata localstorage tar msg () scenemsg


genLayer : ConcreteLayer data cdata localstorage tar msg scenemsg -> Env cdata localstorage -> msg -> AbstractLayer cdata localstorage tar msg scenemsg
genLayer conlayer =
    abstract <| addEmptyBData conlayer


addEmptyBData : ConcreteLayer data cdata localstorage tar msg scenemsg -> MConcreteGeneralModel data cdata localstorage tar msg () scenemsg
addEmptyBData mconnoB =
    { init = \env msg -> ( mconnoB.init env msg, () )
    , update =
        \env evt data () ->
            let
                ( resData, resMsg, resEnv ) =
                    mconnoB.update env evt data
            in
            ( ( resData, () ), resMsg, resEnv )
    , updaterec =
        \env msg data () ->
            let
                ( resData, resMsg, resEnv ) =
                    mconnoB.updaterec env msg data
            in
            ( ( resData, () ), resMsg, resEnv )
    , view = \env data () -> mconnoB.view env data
    , matcher = \data () tar -> mconnoB.matcher data tar
    }
