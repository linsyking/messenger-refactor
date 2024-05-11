module Components.Portable.A exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractPortableComponent, ConcretePortableComponent, PortableMsgCodec, PortableTarCodec, genComponent, genPortableComponent, translatePortableComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg, noCommonData)


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
    | AInit InitData
    | AIntMsg Int


type alias ComponentTarget =
    String


{-| Initializer
-}
init : Env () localstorage -> ComponentMsg -> Data
init env initMsg =
    {}


{-| Updater
-}
update : Env () localstorage -> WorldEvent -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), ( Env () localstorage, Bool ) )
update env evnt d =
    ( d, [], ( env, False ) )


updaterec : Env () localstorage -> ComponentMsg -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), Env () localstorage )
updaterec env msg d =
    case msg of
        AIntMsg x ->
            let
                test =
                    Debug.log "A" x
            in
            ( d, [ Other "B" (AIntMsg (x - 1)), Parent <| OtherMsg <| AIntMsg x, Other "B" (AIntMsg (x + 1)) ], env )

        _ ->
            ( d, [], env )


{-| Renderer
-}
view : Env () localstorage -> Data -> ( Renderable, Int )
view env d =
    ( empty, 0 )


matcher : Data -> ComponentTarget -> Bool
matcher d tar =
    tar == "A"


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
pTest : PortableMsgCodec ComponentMsg generalmsg -> PortableTarCodec ComponentTarget generaltar -> Env cdata localstorage -> generalmsg -> AbstractPortableComponent localstorage generaltar generalmsg
pTest =
    genPortableComponent pTestcon
