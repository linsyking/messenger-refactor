module Messenger.Layer.Layer exposing (..)

import Messenger.Base exposing (Env)
import Messenger.GeneralModel exposing (MAbstractGeneralModel, MConCreteGeneralModelwithoutBData, abstract, addEmptyBData)


type alias ConcreteLayer data cdata localstorage tar msg scenemsg =
    MConCreteGeneralModelwithoutBData data cdata localstorage tar msg scenemsg


type alias AbstractLayer cdata localstorage tar msg scenemsg =
    MAbstractGeneralModel cdata localstorage tar msg () scenemsg


genLayer : ConcreteLayer data cdata localstorage tar msg scenemsg -> Env cdata localstorage -> msg -> AbstractLayer cdata localstorage tar msg scenemsg
genLayer conlayer =
    abstract <| addEmptyBData conlayer
