module Scenes.Main.Layer1.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, empty, group)
import Components.Portable.A as A
import Components.Portable.B as B
import Components.Portable.PTest as PTest
import Components.User.Base as Base exposing (BaseData, ComponentMsg, ComponentTarget)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, updateComponentsWithTarget)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (BasicUpdater, ConcreteLayer, Distributor, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), noCommonData)
import Scenes.Main.LayerBase exposing (..)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    }


type alias ComponentMsgPack =
    { components : List (Msg ComponentTarget ComponentMsg (SceneOutputMsg SceneMsg UserData))
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    case initMsg of
        Init v ->
            Data
                [ A.pTest PTest.aMsgCodec PTest.aTarCodec 0 env (Base.Init { initVal = "", initBase = 1 })
                , B.pTest PTest.bMsgCodec PTest.bTarCodec 0 env (Base.Init { initVal = "", initBase = 1 })
                ]

        _ ->
            Data []


handlePComponentMsg : Handler Data SceneCommonData UserData Target LayerMsg SceneMsg ComponentMsg
handlePComponentMsg env pcompmsg data =
    case pcompmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg (Base.Init x) ->
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
            ( data, ( [], { components = [ Other "B" <| Base.Init { initVal = "", initBase = 1111 } ] } ), env )

        _ ->
            ( data, ( [], { components = [] } ), env )


update : LayerUpdate SceneCommonData UserData Target LayerMsg SceneMsg Data
update env evt data =
    let
        ( nData, nlMsg, ( nEnv, nBlock ) ) =
            updateEvent env evt data

        ( newData, newcMsg, ( newEnv, newBlock ) ) =
            updateComponents nEnv evt nData.components

        ( newData2, ( newlMsg, compMsgs ), newEnv2 ) =
            distributeComponentMsgs newEnv evt { nData | components = newData }

        ( newData3, newcMsg2, newEnv3 ) =
            updateComponentsWithTarget newEnv2 compMsgs.components newData2.components

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


matcher : Matcher Data Target
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
