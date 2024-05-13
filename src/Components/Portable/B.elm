module Components.Portable.B exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, UserEvent(..))
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
    | BInit InitData
    | BIntMsg Int


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
    if env.globalData.globalTime == 0 then
        ( d, [ Parent <| OtherMsg <| BIntMsg 100, Other "A" (BIntMsg 3) ], ( env, False ) )

    else
        ( d, [], ( env, False ) )


updaterec : PortableComponentUpdateRec Data userdata ComponentTarget ComponentMsg
updaterec env msg d =
    case msg of
        BIntMsg x ->
            let
                test =
                    Debug.log "B" x
            in
            if x > 0 && x < 10 then
                ( d, [ Parent <| OtherMsg <| BIntMsg -100 ], env )

            else
                ( d, [], env )

        _ ->
            ( d, [], env )


{-| Renderer
-}
view : PortableComponentView userdata Data
view env d =
    ( empty, 0 )


matcher : Matcher Data ComponentTarget
matcher d tar =
    tar == "B"


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
pTestGernel : PortableComponentStorageGeneral cdata userdata ComponentTarget ComponentMsg gtar gmsg
pTestGernel =
    genPortableComponentGeneral pTestcon


pTestSpecific : PortableComponentStorageSpecific cdata userdata ComponentTarget ComponentMsg gtar gmsg bdata scenemsg
pTestSpecific =
    genPortableComponentSpecific pTestcon
