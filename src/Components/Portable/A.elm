module Components.Portable.A exposing (..)

import Canvas exposing (empty)
import Messenger.Base exposing (WorldEvent(..))
import Messenger.Component.PortableComponent exposing (ConcretePortableComponent, PortableComponentInit, PortableComponentStorage, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView, genPortableComponent)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))


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
init : PortableComponentInit cdata userdata ComponentMsg Data
init env initMsg =
    {}


{-| Updater
-}
update : PortableComponentUpdate cdata Data userdata scenemsg ComponentTarget ComponentMsg
update env evnt d =
    ( d, [], ( env, False ) )


updaterec : PortableComponentUpdateRec cdata Data userdata scenemsg ComponentTarget ComponentMsg
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
view : PortableComponentView cdata userdata Data
view env d =
    ( empty, 0 )


matcher : Matcher Data ComponentTarget
matcher d tar =
    tar == "A"


pTestcon : ConcretePortableComponent Data cdata userdata ComponentTarget ComponentMsg scenemsg
pTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
pTest : PortableComponentStorage cdata userdata ComponentTarget ComponentMsg gtar gmsg bdata scenemsg
pTest =
    genPortableComponent pTestcon
