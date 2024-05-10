module Scenes.Test_SOMMsg.Layer.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, group)
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (AbstractLayer, ConcreteLayer, genLayer)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), addCommonData, noCommonData)
import Messenger.Scene.Transitions.Base exposing (genTransition, nullTransition)
import Messenger.Scene.Transitions.Fade exposing (fadeInWithRenderable)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


type alias Data =
    {}


init : Env SceneCommonData UserData -> LayerMsg -> Data
init env initMsg =
    case initMsg of
        Init v ->
            {}

        _ ->
            {}


update : Env SceneCommonData UserData -> WorldEvent -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg UserData)), ( Env SceneCommonData UserData, Bool ) )
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


updaterec : Env SceneCommonData UserData -> LayerMsg -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg UserData)), Env SceneCommonData UserData )
updaterec env msg data =
    ( data, [], env )


view : Env SceneCommonData UserData -> Data -> Renderable
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 0 ) "blobcat"
        , renderText env.globalData 40 env.globalData.currentScene "Courier New" ( 600, 0 )
        ]


matcher : Data -> Target -> Bool
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


layer : Env SceneCommonData UserData -> LayerMsg -> AbstractLayer SceneCommonData UserData Target LayerMsg SceneMsg
layer =
    genLayer layercon
