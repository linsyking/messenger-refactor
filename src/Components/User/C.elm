module Components.User.C exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Component.PortableComponent exposing (ConcretePortableComponent, PortableComponentInit, PortableComponentStorageGeneral, PortableComponentStorageSpecific, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView, genPortableComponentGeneral, genPortableComponentSpecific)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg)


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
    | CInit InitData
    | CIntMsg Int


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
        ( d, [ Parent <| OtherMsg <| CIntMsg 100, Other "uTest" (CIntMsg 3) ], ( env, False ) )

    else
        ( d, [], ( env, False ) )


updaterec : PortableComponentUpdateRec Data userdata ComponentTarget ComponentMsg
updaterec env msg d =
    case msg of
        CIntMsg x ->
            let
                test =
                    Debug.log "C" x
            in
            if x > 0 && x < 10 then
                ( d, [ Parent <| OtherMsg <| CIntMsg 0 ], env )

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
    tar == "C"


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
pTestSpecific : PortableComponentStorageSpecific cdata userdata ComponentTarget ComponentMsg gtar gmsg bdata scenemsg
pTestSpecific =
    genPortableComponentSpecific pTestcon


pTestGeneral : PortableComponentStorageGeneral cdata userdata ComponentTarget ComponentMsg gtar gmsg
pTestGeneral =
    genPortableComponentGeneral pTestcon
