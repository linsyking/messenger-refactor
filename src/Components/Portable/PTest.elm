module Components.Portable.PTest exposing (..)

{-| Component specific initialization (constructor)
-}

import Components.Portable.A as A
import Components.Portable.B as B
import Messenger.Component.Component exposing (PortableMsgCodec, PortableTarCodec)


type alias InitData =
    {}


{-| Component specific messages (interface)
-}
type GComponentMsg
    = Null
    | Init InitData
    | IntMsg Int


type alias GComponentTarget =
    String


aMsgCodec : PortableMsgCodec A.ComponentMsg GComponentMsg
aMsgCodec =
    { encode =
        \gmsg ->
            case gmsg of
                Init x ->
                    A.AInit x

                IntMsg n ->
                    A.AIntMsg n

                Null ->
                    A.Null
    , decode =
        \smsg ->
            case smsg of
                A.AIntMsg n ->
                    IntMsg n

                _ ->
                    Null
    }


aTarCodec : PortableTarCodec A.ComponentTarget GComponentTarget
aTarCodec =
    PortableTarCodec identity identity


bMsgCodec : PortableMsgCodec B.ComponentMsg GComponentMsg
bMsgCodec =
    { encode =
        \gmsg ->
            case gmsg of
                Init x ->
                    B.BInit x

                IntMsg n ->
                    B.BIntMsg n

                Null ->
                    B.Null
    , decode =
        \smsg ->
            case smsg of
                B.BIntMsg n ->
                    IntMsg n

                _ ->
                    Null
    }


bTarCodec : PortableTarCodec B.ComponentTarget GComponentTarget
bTarCodec =
    PortableTarCodec identity identity
