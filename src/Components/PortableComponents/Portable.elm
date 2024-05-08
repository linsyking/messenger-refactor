module Components.PortableComponents.Portable exposing (..)

import Canvas exposing (Renderable, empty)
import Lib.Component.Base exposing (Component, TargetBase(..), genComp)
import Lib.Env.Env exposing (Env)
import Lib.Event.Event exposing (Event)
import Lib.Scene.Base exposing (SceneOutputMsg)


type alias Data =
    Int


{-| Component specific initialization (constructor)
-}
type alias InitDataT =
    { val : Int
    }


{-| Component specific messages (interface)
-}
type Msg
    = Null
    | SOM SceneOutputMsg
    | Init InitDataT


type alias Target =
    TargetBase PTarget


type PTarget
    = Name String


{-| Initializer
-}
initData : Env Never -> Msg -> Data
initData env init =
    case init of
        Init data ->
            data.val

        _ ->
            0


{-| Updater
-}
update : Env Never -> Event -> Data -> ( Data, List ( Target, Msg ), Env Never )
update env evnt d =
    ( d, [], env )


updaterec : Env Never -> Msg -> Data -> ( Data, List ( Target, Msg ), Env Never )
updaterec env msg d =
    ( d, [], env )


{-| Renderer
-}
view : Env Never -> Data -> Renderable
view env d =
    empty


matcher : Data -> Target -> Bool
matcher d tar =
    case tar of
        Other (Name _) ->
            True

        _ ->
            False


{-| Exported component
-}
comp : Env Never -> Msg -> Component (Env Never) Event Target Msg Renderable
comp =
    genComp
        { init = initData
        , update = update
        , updaterec = updaterec
        , view = view
        , matcher = matcher
        }
