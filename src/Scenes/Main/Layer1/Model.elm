module Scenes.Main.Layer1.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, empty, group)
import Components.Portable.A as A
import Components.Portable.B as B
import Components.Portable.PTest as PTest
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Component.Component exposing (AbstractPortableComponent, addSceneMsgtoSOM)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (AbstractLayer, ConcreteLayer, genLayer)
import Messenger.Recursion exposing (updateObjects)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), addCommonData, noCommonData)
import Scenes.Main.LayerBase exposing (..)


type alias Data =
    { components : List (AbstractPortableComponent LocalStorage PTest.ComponentTarget PTest.ComponentMsg)
    }


init : Env SceneCommonData LocalStorage -> LayerMsg -> Data
init env initMsg =
    case initMsg of
        Init v ->
            Data
                [ A.pTest (noCommonData env) (PTest.Init {})
                , B.pTest (noCommonData env) (PTest.Init {})
                ]

        _ ->
            Data []


handlePComponentMsg : Env SceneCommonData LocalStorage -> MsgBase PTest.ComponentMsg (SceneOutputMsg () LocalStorage) -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), Env SceneCommonData LocalStorage )
handlePComponentMsg env pcompmsg data =
    case pcompmsg of
        SOMMsg som ->
            case addSceneMsgtoSOM som of
                Just othersom ->
                    ( data, [ Parent <| SOMMsg othersom ], env )

                Nothing ->
                    ( data, [], env )

        OtherMsg (PTest.IntMsg x) ->
            let
                test =
                    Debug.log "layer" x
            in
            ( data, [], env )

        _ ->
            ( data, [], env )


update : Env SceneCommonData LocalStorage -> WorldEvent -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), ( Env SceneCommonData LocalStorage, Bool ) )
update env evt data =
    let
        ( newData, newMsg, ( newEnv, newBlock ) ) =
            data.components
                |> updateObjects (noCommonData env) evt

        newEnvC =
            addCommonData env.commonData newEnv

        ( newData2, newMsg2, ( newEnv2, newBlock2 ) ) =
            List.foldl
                (\cm ( d, m, ( e, b ) ) ->
                    let
                        ( d2, m2, e2 ) =
                            handlePComponentMsg e cm d
                    in
                    ( d2, m ++ m2, ( e2, b ) )
                )
                ( { components = newData }, [], ( newEnvC, newBlock ) )
                newMsg
    in
    -- if env.globalData.globalTime == 0 then
    --     let
    --         ( newData3, _, _ ) =
    --             updateObjectsWithTarget newEnv [ Other "B" (PTest.IntMsg 100) ] newData2.components
    --     in
    --     ( { components = newData3 }, newMsg2, ( newEnv2, newBlock2 ) )
    -- else
    ( newData2, (Parent <| SOMMsg <| SOMSaveLocalStorage) :: newMsg2, ( newEnv2, newBlock2 ) )


updaterec : Env SceneCommonData LocalStorage -> LayerMsg -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), Env SceneCommonData LocalStorage )
updaterec env msg data =
    ( data, [], env )


view : Env SceneCommonData LocalStorage -> Data -> Renderable
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 1080 ) "blobcat"
        , renderSprite env.globalData [] ( 400, 400 ) ( 400, 0 ) "blobcat"
        , renderText env.globalData 40 env.globalData.currentScene "Courier New" ( 600, 0 )
        ]


matcher : Data -> Target -> Bool
matcher data tar =
    tar == "layer1"


layer1con : ConcreteLayer Data SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1con =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


layer1 : Env SceneCommonData LocalStorage -> LayerMsg -> AbstractLayer SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1 =
    genLayer layer1con
