module Messenger.Component.Component exposing (..)

import Canvas exposing (Renderable, group)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (AbstractGeneralModel, ConcreteGeneralModel, Msg(..), MsgBase(..), abstract, unroll)
import Messenger.Recursion exposing (updateObjects, updateObjectsWithTarget)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), addCommonData, noCommonData)


type alias ConcreteUserComponent data cdata userdata tar msg bdata scenemsg =
    ConcreteGeneralModel data (Env cdata userdata) WorldEvent tar msg ( Renderable, Int ) bdata (SceneOutputMsg scenemsg userdata)


type alias ConcretePortableComponent data userdata tar msg =
    { init : Env () userdata -> msg -> data
    , update : Env () userdata -> WorldEvent -> data -> ( data, List (Msg tar msg (SceneOutputMsg () userdata)), ( Env () userdata, Bool ) )
    , updaterec : Env () userdata -> msg -> data -> ( data, List (Msg tar msg (SceneOutputMsg () userdata)), Env () userdata )
    , view : Env () userdata -> data -> ( Renderable, Int )
    , matcher : data -> tar -> Bool
    }


translatePortableComponent : ConcretePortableComponent data userdata tar msg -> PortableMsgCodec msg gmsg -> PortableTarCodec tar gtar -> ConcreteUserComponent data () userdata gtar gmsg () ()
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


type alias MsgDecoder specifictar specificmsg generaltar generalmsg som =
    Msg specifictar specificmsg som -> Msg generaltar generalmsg som


type alias PortableMsgCodec specificmsg generalmsg =
    { encode : generalmsg -> specificmsg
    , decode : specificmsg -> generalmsg
    }


type alias PortableTarCodec specifictar generaltar =
    { encode : generaltar -> specifictar
    , decode : specifictar -> generaltar
    }


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


type alias AbstractComponent cdata userdata tar msg bdata scenemsg =
    AbstractGeneralModel (Env cdata userdata) WorldEvent tar msg ( Renderable, Int ) bdata (SceneOutputMsg scenemsg userdata)


type alias AbstractPortableComponent userdata tar msg =
    AbstractComponent () userdata tar msg () ()


genComponent : ConcreteUserComponent data cdata userdata tar msg bdata scenemsg -> Env cdata userdata -> msg -> AbstractComponent cdata userdata tar msg bdata scenemsg
genComponent concomp =
    abstract concomp


genPortableComponent : ConcretePortableComponent data userdata tar msg -> PortableMsgCodec msg gmsg -> PortableTarCodec tar gtar -> Env cdata userdata -> gmsg -> AbstractPortableComponent userdata gtar gmsg
genPortableComponent conpcomp mcodec tcodec env =
    abstract (translatePortableComponent conpcomp mcodec tcodec) <| noCommonData env


updateComponents : Env cdata userdata -> WorldEvent -> List (AbstractComponent cdata userdata tar msg bdata scenemsg) -> ( List (AbstractComponent cdata userdata tar msg bdata scenemsg), List (MsgBase msg (SceneOutputMsg scenemsg userdata)), ( Env cdata userdata, Bool ) )
updateComponents env evt comps =
    updateObjects env evt comps


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


updateComponentsWithTarget : Env cdata userdata -> List (Msg tar msg (SceneOutputMsg scenemsg userdata)) -> List (AbstractComponent cdata userdata tar msg bdata scenemsg) -> ( List (AbstractComponent cdata userdata tar msg bdata scenemsg), List (MsgBase msg (SceneOutputMsg scenemsg userdata)), Env cdata userdata )
updateComponentsWithTarget env msgs comps =
    updateObjectsWithTarget env msgs comps


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


viewComponents : Env cdata userdata -> List (AbstractComponent cdata userdata tar msg bdata scenemsg) -> Renderable
viewComponents env compls =
    let
        previews =
            List.map (\comp -> (unroll comp).view env) compls
    in
    group [] <|
        List.map (\( r, _ ) -> r) <|
            List.sortBy (\( _, n ) -> n) previews
