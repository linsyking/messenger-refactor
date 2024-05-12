module Components.Portable.A exposing (..)

import Canvas exposing (empty)
import Messenger.Base exposing (WorldEvent(..))
import Messenger.Component.PortableComponent exposing (ConcretePortableComponent, PortableComponentInit, PortableComponentStorageGeneral, PortableComponentStorageSpecific, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView, genPortableComponentGeneral, genPortableComponentSpecific)
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
init : PortableComponentInit userdata ComponentMsg Data
init env initMsg =
    {}


{-| Updater
-}
update : PortableComponentUpdate Data userdata ComponentTarget ComponentMsg
update env evnt d =
    ( d, [], ( env, False ) )


updaterec : PortableComponentUpdateRec Data userdata ComponentTarget ComponentMsg
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
view : PortableComponentView userdata Data
view env d =
    ( empty, 0 )


matcher : Matcher Data ComponentTarget
matcher d tar =
    tar == "A"


pTestcon : ConcretePortableComponent Data userdata ComponentTarget ComponentMsg
pTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
pTestGeneral : PortableComponentStorageGeneral cdata userdata ComponentTarget ComponentMsg gtar gmsg
pTestGeneral =
    genPortableComponentGeneral pTestcon


pTestSpecific : PortableComponentStorageSpecific cdata userdata ComponentTarget ComponentMsg gtar gmsg bdata scenemsg
pTestSpecific =
    genPortableComponentSpecific pTestcon
