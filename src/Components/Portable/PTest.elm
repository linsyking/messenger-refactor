module Components.Portable.PTest exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractPortableComponent, ConcretePortableComponent, genComponent, translatePortableComponent)
import Messenger.GeneralModel exposing (Msg)
import Messenger.Scene.Scene exposing (SceneOutputMsg)


type alias Data =
    Int


{-| Component specific initialization (constructor)
-}
type alias InitData =
    { initVal : Int }


{-| Component specific messages (interface)
-}
type ComponentMsg
    = Null
    | Init InitData


type alias ComponentTarget =
    String


{-| Initializer
-}
init : Env () localstorage -> ComponentMsg -> Data
init env initMsg =
    case initMsg of
        Init v ->
            v.initVal

        _ ->
            0


{-| Updater
-}
update : Env () localstorage -> WorldEvent -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), ( Env () localstorage, Bool ) )
update env evnt d =
    case evnt of
        KeyDown key ->
            ( key, [], ( env, False ) )

        _ ->
            ( d, [], ( env, False ) )


updaterec : Env () localstorage -> ComponentMsg -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), Env () localstorage )
updaterec env msg d =
    ( d, [], env )


{-| Renderer
-}
view : Env () localstorage -> Data -> ( Renderable, Int )
view env d =
    let
        _ =
            -- 1
            Debug.log "pTest" d
    in
    ( empty, 0 )


matcher : Data -> ComponentTarget -> Bool
matcher d tar =
    tar == "portable"


pTestcon : ConcretePortableComponent Data localstorage ComponentTarget ComponentMsg
pTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
pTest : Env () localstorage -> ComponentMsg -> AbstractPortableComponent localstorage ComponentTarget ComponentMsg
pTest =
    genComponent <| translatePortableComponent pTestcon
