module Components.Portable.B exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.PortableComponent exposing (ConcretePortableComponent, PortableComponentInit, PortableComponentStorage, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView, genPortableComponent)
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
    | BInit InitData
    | BIntMsg Int


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
    if env.globalData.globalTime == 0 then
        ( d, [ Parent <| OtherMsg <| BIntMsg 100, Other "A" (BIntMsg 3) ], ( env, False ) )

    else
        ( d, [], ( env, False ) )


updaterec : PortableComponentUpdateRec cdata Data userdata scenemsg ComponentTarget ComponentMsg
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
view : PortableComponentView cdata userdata Data
view env d =
    ( empty, 0 )


matcher : Matcher Data ComponentTarget
matcher d tar =
    tar == "B"


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
