module Scenes.Main.Model exposing (..)

import Canvas.Settings exposing (Setting)
import Lib.Base exposing (..)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, WorldEvent, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneData, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.Main.Layer1.Model exposing (layer1)
import Scenes.Main.LayerBase exposing (..)


commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    { key = "Main" }


sceneInit : Env () UserData -> Maybe SceneMsg -> LayeredSceneData SceneCommonData UserData Target LayerMsg SceneMsg
sceneInit env msg =
    let
        cd =
            commonDataInit env msg

        envcd =
            addCommonData cd env
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ layer1 envcd <| Init { initVal = 1 }
        ]
    }


settings : Env () UserData -> WorldEvent -> LayeredSceneData SceneCommonData UserData Target LayerMsg SceneMsg -> List Setting
settings _ _ _ =
    []


scene : SceneStorage UserData SceneMsg
scene =
    genLayeredScene sceneInit settings
