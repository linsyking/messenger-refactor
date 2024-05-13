module Scenes.Test_SOMMsg.Layer.Model exposing
    ( Data
    , init
    , update, updaterec
    , view
    , matcher
    , layer
    )

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs Data
@docs init
@docs update, updaterec
@docs view
@docs matcher
@docs layer

-}

import Canvas exposing (group)
import Lib.Base exposing (..)
import Lib.UserData exposing (UserData)
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Render.Sprite exposing (renderSprite)
import Messenger.Render.Text exposing (renderText)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import Messenger.Scene.Transitions.Base exposing (genTransition, nullTransition)
import Messenger.Scene.Transitions.Fade exposing (fadeInWithRenderable)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


{-| Data

Data type for layer **Layer** in **Test\_SOMMsg**

-}
type alias Data =
    {}


{-| init

init function for layer **Layer** in **Test\_SOMMsg**

-}
init : LayerInit SceneCommonData UserData LayerMsg Data
init env initMsg =
    case initMsg of
        Init v ->
            {}

        _ ->
            {}


{-| update

update function for layer **Layer** in **Test\_SOMMsg**

-}
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


{-| updaterec

recursively update function for layer **Layer** in **Test\_SOMMsg**

-}
updaterec : LayerUpdateRec SceneCommonData UserData Target LayerMsg SceneMsg Data
updaterec env msg data =
    ( data, [], env )


{-| view

view function for layer **Layer** in **Test\_SOMMsg**

-}
view : LayerView SceneCommonData UserData Data
view env data =
    group []
        [ renderSprite env.globalData [] ( 0, 0 ) ( 1920, 0 ) "blobcat"
        , renderText env.globalData 40 env.globalData.currentScene "Courier New" ( 600, 0 )
        ]


{-| matcher

matcher function for layer **Layer** in **Test\_SOMMsg**

-}
matcher : Matcher Data Target
matcher data tar =
    tar == "layer"


{-| concrete layer
-}
layercon : ConcreteLayer Data SceneCommonData UserData Target LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| layer

generator function to generate an abstract layer for layer **Layer** in **Test\_SOMMsg**

-}
layer : LayerStorage SceneCommonData UserData Target LayerMsg SceneMsg
layer =
    genLayer layercon
