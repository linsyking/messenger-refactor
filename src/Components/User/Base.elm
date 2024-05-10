module Components.User.Base exposing (..)

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
