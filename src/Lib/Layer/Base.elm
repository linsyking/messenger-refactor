module Lib.Layer.Base exposing
    ( LayerMsg, LayerMsg_(..)
    , LayerTarget(..)
    , Layer
    , AbsLayer, GeneralLayer
    )

{-| Layer Base

Layer plays a very important role in the game framework.

It is mainly used to seperate different rendering layers.

Using layers can help us deal with different things in different layers.

@docs LayerMsg, LayerMsg_
@docs LayerTarget
@docs Layer

-}

import Base exposing (ObjectTarget)
import Canvas exposing (Renderable)
import Messenger.Audio.Base exposing (AudioOption)
import Lib.Env.Env exposing (Env)
import Lib.Event.Event exposing (Event)
import Lib.Scene.Base exposing (MsgBase)
import Messenger.GeneralModel exposing (AbsGeneralModel, GeneralModel)


{-| Layer

Layer data type.

a is the layer data, b is the common data that shares between layers, c is the init data

-}
type alias GeneralLayer a b c =
    GeneralModel a (Env b) c LayerTarget Renderable Event


type alias Layer a b =
    GeneralLayer a b LayerMsg


type alias AbsLayer b =
    AbsGeneralModel (Env b) LayerMsg LayerTarget Renderable Event


{-| LayerMsg

Add your own data in **LayerMsg\_**

The SOMMsg type is only used to pass the component message

-}
type alias LayerMsg =
    MsgBase LayerMsg_


{-| LayerMsg\_

this message is used when you want scene to deal with the layer message.

Add your own layer messages here.

LayerSoundMsg name path option

Only used in LayerMsg type.

-}
type LayerMsg_
    = LayerStringMsg String
    | LayerIntMsg Int
    | LayerFloatMsg Float
    | LayerStringDataMsg String LayerMsg_
    | LayerSoundMsg String String AudioOption
    | LayerStopSoundMsg String
    | LayerChangeSceneMsg String
    | NullLayerMsg


{-| LayerTarget

You can send message to a layer by using LayerTarget.

LayerParentScene is used to send message to the parent scene of the layer.

LayerName is used to send message to a specific layer.

-}
type LayerTarget
    = Layer ObjectTarget
