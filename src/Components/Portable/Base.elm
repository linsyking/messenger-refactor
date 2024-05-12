module Components.Portable.Base exposing (..)

{-| Component specific initialization (constructor)
-}

import Components.Portable.A as A
import Components.Portable.B as B
import Messenger.Component.PortableComponent exposing (PortableMsgCodec, PortableTarCodec)


{-| Component specific initialization (constructor)
-}
type alias InitData =
    { initVal : Int
    }


{-| Component specific messages (interface)
-}
type ComponentMsg
    = Null
    | Init InitData


type alias ComponentTarget =
    String


aMsgCodec : PortableMsgCodec A.ComponentMsg ComponentMsg
aMsgCodec =
    { encode =
        \gmsg ->
            case gmsg of
                Init x ->
                    A.AInit {}

                Null ->
                    A.Null
    , decode =
        \smsg ->
            case smsg of
                A.AIntMsg n ->
                    Null

                _ ->
                    Null
    }


aTarCodec : PortableTarCodec A.ComponentTarget ComponentTarget
aTarCodec =
    PortableTarCodec identity identity


bMsgCodec : PortableMsgCodec B.ComponentMsg ComponentMsg
bMsgCodec =
    { encode =
        \gmsg ->
            case gmsg of
                Init x ->
                    B.BInit {}

                Null ->
                    B.Null
    , decode =
        \smsg ->
            case smsg of
                B.BIntMsg n ->
                    Null

                _ ->
                    Null
    }


bTarCodec : PortableTarCodec B.ComponentTarget ComponentTarget
bTarCodec =
    PortableTarCodec identity identity
