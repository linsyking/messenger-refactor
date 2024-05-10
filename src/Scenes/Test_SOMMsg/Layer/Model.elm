module Scenes.Test_SOMMsg.Layer.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, group)
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (AbstractLayer, ConcreteLayer, genLayer)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), addCommonData, noCommonData)
import Messenger.Scene.Transitions.Base exposing (genTransition, nullTransition)
import Messenger.Scene.Transitions.Fade exposing (fadeInWithRenderable)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


type alias Data =
    {}


init : Env SceneCommonData LocalStorage -> LayerMsg -> Data
init env initMsg =
    case initMsg of
        Init v ->
            {}

        _ ->
            {}


update : Env SceneCommonData LocalStorage -> WorldEvent -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), ( Env SceneCommonData LocalStorage, Bool ) )
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


updaterec : Env SceneCommonData LocalStorage -> LayerMsg -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), Env SceneCommonData LocalStorage )
updaterec env msg data =
    ( data, [], env )


view : Env SceneCommonData LocalStorage -> Data -> Renderable
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 0 ) "blobcat"
        ]


matcher : Data -> Target -> Bool
matcher data tar =
    tar == "layer"


layercon : ConcreteLayer Data SceneCommonData LocalStorage Target LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


layer : Env SceneCommonData LocalStorage -> LayerMsg -> AbstractLayer SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer =
    genLayer layercon
