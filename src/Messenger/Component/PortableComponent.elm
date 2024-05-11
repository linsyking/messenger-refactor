module Messenger.Component.PortableComponent exposing
    ( AbstractPortableComponent
    , ConcretePortableComponent
    , PortableMsgCodec
    , PortableTarCodec
    , genPortableComponent
    , updatePortableComponents
    , updatePortableComponentsWithTarget
    , translatePortableComponent
    , PortableComponentInit, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView
    , PortableComponentStorage
    )

{-|


## Portable components

These are components that might be provided by an elm package.

There are some limitations for portable components:

  - They don't have the base data
  - They cannot get the common data
  - They cannot change scene
  - You need to set the msg and target type for every dependent portable component
  - You need to provide a codec in the layer to translate the messages and targets

@docs AbstractPortableComponent
@docs ConcretePortableComponent
@docs PortableMsgCodec
@docs PortableTarCodec
@docs genPortableComponent
@docs updatePortableComponents
@docs updatePortableComponentsWithTarget
@docs translatePortableComponent


# Type sugar

@docs PortableComponentInit, PortableComponentUpdate, PortableComponentUpdateRec, PortableComponentView
@docs PortableComponentStorage

-}

import Canvas exposing (Renderable)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..), abstract)
import Messenger.Recursion exposing (updateObjects, updateObjectsWithTarget)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), addCommonData, noCommonData)


{-| Portable component init type sugar
-}
type alias PortableComponentInit msg data =
    Env () () -> msg -> data


{-| Portable component update type sugar
-}
type alias PortableComponentUpdate data tar msg =
    Env () () -> WorldEvent -> data -> ( data, List (Msg tar msg (SceneOutputMsg () ())), ( Env () (), Bool ) )


{-| Portable component updaterec type sugar
-}
type alias PortableComponentUpdateRec data tar msg =
    Env () () -> msg -> data -> ( data, List (Msg tar msg (SceneOutputMsg () ())), Env () () )


{-| Portable component view type sugar
-}
type alias PortableComponentView data =
    Env () () -> data -> ( Renderable, Int )


{-| Portable component storage type sugar
-}
type alias PortableComponentStorage tar gtar msg gmsg =
    PortableMsgCodec msg gmsg -> PortableTarCodec tar gtar -> Env () () -> gmsg -> AbstractPortableComponent () gtar gmsg


{-| ConcretePortableComponent

Used when createing a portable component.

Use `translatePortableComponent` to create a `ConcreteUserComponent` from a `ConcretePortableComponent`.

The `scenemsg` type is replaced by `()` because you cannot send changescene message.

-}
type alias ConcretePortableComponent data tar msg =
    { init : PortableComponentInit msg data
    , update : PortableComponentUpdate data tar msg
    , updaterec : PortableComponentUpdateRec data tar msg
    , view : PortableComponentView data
    , matcher : Matcher data tar
    }


{-| Translate a `ConcretePortableComponent` to a `ConcreteUserComponent`.

This will add an empty basedata (unit) and upcast target and messages to the generalized type.

-}
translatePortableComponent : ConcretePortableComponent data tar msg -> PortableMsgCodec msg gmsg -> PortableTarCodec tar gtar -> ConcreteUserComponent data () () gtar gmsg () ()
translatePortableComponent pcomp msgcodec tarcodec =
    let
        msgMDecoder =
            genMsgDecoder msgcodec tarcodec
    in
    { init = \env gmsg -> ( pcomp.init env <| msgcodec.encode gmsg, () )
    , update =
        \env evt data () ->
            let
                ( resData, resMsg, resEnv ) =
                    pcomp.update env evt data
            in
            ( ( resData, () ), List.map msgMDecoder resMsg, resEnv )
    , updaterec =
        \env gmsg data () ->
            let
                ( resData, resMsg, resEnv ) =
                    pcomp.updaterec env (msgcodec.encode gmsg) data
            in
            ( ( resData, () ), List.map msgMDecoder resMsg, resEnv )
    , view = \env data () -> pcomp.view env data
    , matcher = \data () gtar -> pcomp.matcher data <| tarcodec.encode gtar
    }


{-| Msg decoder
-}
type alias MsgDecoder specifictar specificmsg generaltar generalmsg som =
    Msg specifictar specificmsg som -> Msg generaltar generalmsg som


{-| Portable Component Message Codec
-}
type alias PortableMsgCodec specificmsg generalmsg =
    { encode : generalmsg -> specificmsg
    , decode : specificmsg -> generalmsg
    }


{-| Portable Component Target Codec
-}
type alias PortableTarCodec specifictar generaltar =
    { encode : generaltar -> specifictar
    , decode : specifictar -> generaltar
    }


{-| Generate a message decoder
-}
genMsgDecoder : PortableMsgCodec specificmsg generalmsg -> PortableTarCodec specifictar generaltar -> MsgDecoder specifictar specificmsg generaltar generalmsg som
genMsgDecoder msgcodec tarcodec sMsgM =
    case sMsgM of
        Parent x ->
            case x of
                OtherMsg othermsg ->
                    Parent <| OtherMsg <| msgcodec.decode othermsg

                SOMMsg som ->
                    Parent <| SOMMsg som

        Other othertar smsg ->
            Other (tarcodec.decode othertar) (msgcodec.decode smsg)


addSceneMsgtoPortable : MsgBase msg (SceneOutputMsg () userdata) -> Maybe (MsgBase msg (SceneOutputMsg scenemsg userdata))
addSceneMsgtoPortable msg =
    case msg of
        SOMMsg sommsg ->
            case sommsg of
                SOMChangeScene _ ->
                    Nothing

                SOMPlayAudio n u o ->
                    Just <| SOMMsg <| SOMPlayAudio n u o

                SOMAlert a ->
                    Just <| SOMMsg <| SOMAlert a

                SOMStopAudio n ->
                    Just <| SOMMsg <| SOMStopAudio n

                SOMSetVolume v ->
                    Just <| SOMMsg <| SOMSetVolume v

                SOMPrompt n t ->
                    Just <| SOMMsg <| SOMPrompt n t

                SOMSaveUserData ->
                    Just <| SOMMsg <| SOMSaveUserData

        OtherMsg othermsg ->
            Just <| OtherMsg othermsg


{-| AbstractPortableComponent

Abstract component with common data, base data, and scene msg set to unit type.

This means you cannot send scene msg from a portable component.

-}
type alias AbstractPortableComponent userdata tar msg =
    AbstractComponent () userdata tar msg () ()


{-| genPortableComponent

Generate abstract portable component from concrete component.

-}
genPortableComponent : ConcretePortableComponent data tar msg -> PortableComponentStorage tar gtar msg gmsg
genPortableComponent conpcomp mcodec tcodec env =
    abstract (translatePortableComponent conpcomp mcodec tcodec) <| noCommonData env


{-| updatePortableComponents

Update a list of abstract portable components.

**you don't need to give a Env without commondata**

-}
updatePortableComponents : Env cdata userdata -> WorldEvent -> List (AbstractPortableComponent userdata tar msg) -> ( List (AbstractPortableComponent userdata tar msg), List (MsgBase msg (SceneOutputMsg scenemsg userdata)), ( Env cdata userdata, Bool ) )
updatePortableComponents env evt pcomps =
    let
        ( newpcomps, newMsg, ( newEnv, newBlock ) ) =
            updateObjects (noCommonData env) evt pcomps

        newEnvC =
            addCommonData env.commonData newEnv

        newMsgfilterd =
            List.filterMap addSceneMsgtoPortable newMsg
    in
    ( newpcomps, newMsgfilterd, ( newEnvC, newBlock ) )


{-| updatePortableComponentsWithTarget

Update a list of abstract portable components with target msgs.

**you don't need to give a Env without commondata**

-}
updatePortableComponentsWithTarget : Env cdata userdata -> List (Msg tar msg (SceneOutputMsg () userdata)) -> List (AbstractPortableComponent userdata tar msg) -> ( List (AbstractPortableComponent userdata tar msg), List (MsgBase msg (SceneOutputMsg scenemsg userdata)), Env cdata userdata )
updatePortableComponentsWithTarget env msgs pcomps =
    let
        ( newpcomps, newMsg, newEnv ) =
            updateObjectsWithTarget (noCommonData env) msgs pcomps

        newEnvC =
            addCommonData env.commonData newEnv

        newMsgfilterd =
            List.filterMap addSceneMsgtoPortable newMsg
    in
    ( newpcomps, newMsgfilterd, newEnvC )
