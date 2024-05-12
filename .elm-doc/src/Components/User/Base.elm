module Components.User.Base exposing (..)

import Components.User.C as C
import Messenger.Component.PortableComponent exposing (PortableMsgCodec, PortableTarCodec)


{-| Component specific initialization (constructor)
-}
type alias InitData =
    { initVal : String
    , initBase : Int
    }


{-| Component specific messages (interface)
-}
type ComponentMsg
    = Null
    | Init InitData


type alias ComponentTarget =
    String


type alias BaseData =
    Int


cMsgCodec : PortableMsgCodec C.ComponentMsg ComponentMsg
cMsgCodec =
    { encode =
        \gmsg ->
            case gmsg of
                Init x ->
                    C.CInit {}

                Null ->
                    C.Null
    , decode =
        \smsg ->
            case smsg of
                C.CIntMsg n ->
                    Null

                _ ->
                    Null
    }


cTarCodec : PortableTarCodec C.ComponentTarget ComponentTarget
cTarCodec =
    PortableTarCodec identity identity
