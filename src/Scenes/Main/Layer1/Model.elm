module Scenes.Main.Layer1.Model exposing (..)

import Canvas exposing (group)
import Components.Portable.A as A
import Components.Portable.B as B
import Components.Portable.Base as PBase
import Components.User.Base as UBase exposing (BaseData)
import Components.User.C as C
import Components.User.UTest exposing (uTest)
import Lib.Base exposing (..)
import Messenger.Base exposing (WorldEvent(..))
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, updateComponentsWithTarget)
import Messenger.Component.PortableComponent exposing (AbstractGeneralPortableComponent, updatePortableComponents, updatePortableComponentsWithTarget)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (BasicUpdater, ConcreteLayer, Distributor, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import Scenes.Main.LayerBase exposing (..)


type alias Data =
    { gcomponents : List (AbstractGeneralPortableComponent UserData PBase.ComponentTarget PBase.ComponentMsg)
    , ucomponents : List (AbstractComponent SceneCommonData UserData UBase.ComponentTarget UBase.ComponentMsg BaseData SceneMsg)
    }


type alias ComponentMsgPack =
    { gcomponents : List (Msg PBase.ComponentTarget PBase.ComponentMsg (SceneOutputMsg () UserData))
    , ucomponents : List (Msg UBase.ComponentTarget UBase.ComponentMsg (SceneOutputMsg SceneMsg UserData))
    }


emptyBData : BaseData
emptyBData =
    0


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    case initMsg of
        Init v ->
            Data
                [ A.pTestGeneral PBase.aTarCodec PBase.aMsgCodec env (PBase.Init { initVal = 1 })
                , B.pTestGernel PBase.bTarCodec PBase.bMsgCodec env (PBase.Init { initVal = 1 })
                ]
                [ C.pTestSpecific UBase.cTarCodec UBase.cMsgCodec emptyBData env (UBase.Init { initVal = "", initBase = 0 })
                , uTest env (UBase.Init { initVal = "", initBase = 0 })
                ]

        _ ->
            Data [] []


handlePComponentMsg : Handler Data SceneCommonData UserData Target LayerMsg SceneMsg PBase.ComponentMsg
handlePComponentMsg env pcompmsg data =
    case pcompmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg (PBase.Init x) ->
            let
                test =
                    Debug.log "layer" x
            in
            ( data, [], env )

        _ ->
            ( data, [], env )


handleUComponentMsg : Handler Data SceneCommonData UserData Target LayerMsg SceneMsg UBase.ComponentMsg
handleUComponentMsg env pcompmsg data =
    case pcompmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg (UBase.Init x) ->
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
            ( data, ( [], { gcomponents = [ Other "B" <| PBase.Init { initVal = 666 } ], ucomponents = [] } ), env )

        _ ->
            ( data, ( [], { gcomponents = [], ucomponents = [] } ), env )


update : LayerUpdate SceneCommonData UserData Target LayerMsg SceneMsg Data
update env evt data =
    let
        --- Step 1
        ( newData1, newlMsg1, ( newEnv1, newBlock1 ) ) =
            updateEvent env evt data

        --- Step 2
        ( newGComps2, newGcMsg2, ( newEnv2_1, newBlock2_1 ) ) =
            updatePortableComponents newEnv1 evt newData1.gcomponents

        ( newUComps2, newUcMsg2, ( newEnv2_2, newBlock2_2 ) ) =
            if newBlock2_1 then
                ( newData1.ucomponents, [], ( newEnv2_1, newBlock2_1 ) )

            else
                updateComponents newEnv2_1 evt newData1.ucomponents

        --- Step 3
        ( newData3, ( newlMsg3, compMsgs ), newEnv3 ) =
            distributeComponentMsgs newEnv2_2 evt { newData1 | gcomponents = newGComps2, ucomponents = newUComps2 }

        --- Step 4
        ( newGComps4, newGcMsg4, newEnv4_1 ) =
            updatePortableComponentsWithTarget newEnv3 compMsgs.gcomponents newData3.gcomponents

        ( newUComps4, newUcMsg4, newEnv4_2 ) =
            updateComponentsWithTarget newEnv4_1 compMsgs.ucomponents newData3.ucomponents

        --- Step 5
        ( newData5_1, newlMsg5_1, newEnv5_1 ) =
            handleComponentMsgs newEnv4_2 (newGcMsg2 ++ newGcMsg4) { newData3 | gcomponents = newGComps4, ucomponents = newUComps4 } (newlMsg1 ++ newlMsg3) handlePComponentMsg

        ( newData5_2, newlMsg5_2, newEnv5_2 ) =
            handleComponentMsgs newEnv5_1 (newUcMsg2 ++ newUcMsg4) newData5_1 newlMsg5_1 handleUComponentMsg
    in
    ( newData5_2, (Parent <| SOMMsg <| SOMSaveUserData) :: newlMsg5_2, ( newEnv5_2, newBlock1 || newBlock2_2 ) )


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
