module Components.Portable.PTest exposing (..)


type alias Data =
    {}


{-| Component specific initialization (constructor)
-}
type alias InitData =
    {}


{-| Component specific messages (interface)
-}
type ComponentMsg
    = Null
    | Init InitData
    | IntMsg Int


type alias ComponentTarget =
    String
