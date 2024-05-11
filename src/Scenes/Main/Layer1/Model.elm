module Scenes.Main.Layer1.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, empty, group)
import Components.Portable.A as A
import Components.Portable.B as B
import Components.Portable.PTest as PTest
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractPortableComponent, updatePortableComponents, updatePortableComponentsWithTarget)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (AbstractLayer, BasicUpdater, ConcreteLayer, Distributor, Handler, LayerInit, LayerMatcher, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import Scenes.Main.LayerBase exposing (..)


type alias Data =
    { components : List (AbstractPortableComponent UserData PTest.GComponentTarget PTest.GComponentMsg)
    }


type alias ComponentMsgPack =
    { components : List (Msg PTest.GComponentTarget PTest.GComponentMsg (SceneOutputMsg () UserData))
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    case initMsg of
        Init v ->
            Data
                [ A.pTest PTest.aMsgCodec PTest.aTarCodec env (PTest.Init {})
                , B.pTest PTest.bMsgCodec PTest.bTarCodec env (PTest.Init {})
                ]

        _ ->
            Data []


handlePComponentMsg : Handler Data SceneCommonData UserData Target LayerMsg SceneMsg PTest.GComponentMsg
handlePComponentMsg env pcompmsg data =
    case pcompmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg (PTest.IntMsg x) ->
            let
                test =
                    Debug.log "layer" x
            in
            ( data, [], env )

        _ ->
            ( data, [], env )


updateEvent : BasicUpdater Data SceneCommonData UserData Target LayerMsg SceneMsg
updateEvent env evt data =
    ( data, [], ( env, False ) )


distributeComponentMsgs : Distributor Data SceneCommonData UserData Target LayerMsg SceneMsg ComponentMsgPack
distributeComponentMsgs env evt data =
    case evt of
        MouseDown x _ ->
            let
                _ =
                    Debug.log "mousedown" x
            in
            ( data, ( [], { components = [ Other "B" <| PTest.IntMsg 66 ] } ), env )

        _ ->
            ( data, ( [], { components = [] } ), env )


update : LayerUpdate SceneCommonData UserData Target LayerMsg SceneMsg Data
update env evt data =
    let
        ( nData, nlMsg, ( nEnv, nBlock ) ) =
            updateEvent env evt data

        ( newData, newcMsg, ( newEnv, newBlock ) ) =
            updatePortableComponents nEnv evt nData.components

        ( newData2, ( newlMsg, compMsgs ), newEnv2 ) =
            distributeComponentMsgs newEnv evt { nData | components = newData }

        ( newData3, newcMsg2, newEnv3 ) =
            updatePortableComponentsWithTarget newEnv2 compMsgs.components newData2.components

        ( newData4, newlMsg2, newEnv4 ) =
            handleComponentMsgs newEnv3 (newcMsg2 ++ newcMsg) { newData2 | components = newData3 } [] handlePComponentMsg
    in
    ( newData4, (Parent <| SOMMsg <| SOMSaveUserData) :: newlMsg2 ++ newlMsg ++ nlMsg, ( newEnv4, newBlock || nBlock ) )


updaterec : LayerUpdateRec SceneCommonData UserData Target LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 1080 ) "blobcat"
        , renderSprite env.globalData [] ( 400, 400 ) ( 400, 0 ) "blobcat"
        , renderText env.globalData 40 env.globalData.currentScene "Courier New" ( 600, 0 )
        ]


matcher : LayerMatcher Data Target
matcher data tar =
    tar == "layer1"


layer1con : ConcreteLayer Data SceneCommonData UserData Target LayerMsg SceneMsg
layer1con =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


layer1 : LayerStorage SceneCommonData UserData Target LayerMsg SceneMsg
layer1 =
    genLayer layer1con
