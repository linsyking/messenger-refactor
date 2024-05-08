module Components.UserComponents.UserCompMsg exposing (..)

{-| Component specific messages (interface)
-}

import Lib.Component.Base exposing (TargetBase)
import Lib.Scene.Base exposing (SceneOutputMsg)


type Msg
    = Null
    | OtherTypeComp
    | SOM SceneOutputMsg
    | Init InitDataT


type alias Target =
    TargetBase UTarget


type UTarget
    = Name String


{-| Component specific initialization (constructor)
-}
type alias InitDataT =
    { val : String }
