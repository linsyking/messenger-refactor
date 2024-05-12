module Scenes.Test_SOMMsg.Layer.Model exposing (..)

import Lib.Base exposing (..)
import Canvas exposing (group)
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (WorldEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import Messenger.Scene.Transitions.Base exposing (genTransition, nullTransition)
import Messenger.Scene.Transitions.Fade exposing (fadeInWithRenderable)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


type alias Data =
    {}


init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    case initMsg of
        Init v ->
            {}

        _ ->
            {}


update : LayerUpdate SceneCommonData UserData Target LayerMsg SceneMsg Data
update env evt data =
    case evt of
        MouseDown _ _ ->
            ( data
            , [ Parent <|
                    SOMMsg <|
                        SOMChangeScene
                            ( Just Null
                            , "Main"
                            , Just <| genTransition 0 30 nullTransition (fadeInWithRenderable <| view env data)
                            )
              , Parent <| SOMMsg <| SOMPlayAudio "biu" "assets/biu.ogg" ALoop
              ]
            , ( env, False )
            )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData Target LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 0 ) "blobcat"
        , renderText env.globalData 40 env.globalData.currentScene "Courier New" ( 600, 0 )
        ]


matcher : Matcher Data Target
matcher data tar =
    tar == "layer"


layercon : ConcreteLayer Data SceneCommonData UserData Target LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


layer : LayerStorage SceneCommonData UserData Target LayerMsg SceneMsg
layer =
    genLayer layercon
