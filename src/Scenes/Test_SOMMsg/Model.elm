module Scenes.Test_SOMMsg.Model exposing (..)

import Lib.Base exposing (..)
import Messenger.Base exposing (Env)
import Messenger.Scene.LayeredScene exposing (LayeredSceneInit, LayeredSceneSettingsFunc, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage, addCommonData)
import Scenes.Test_SOMMsg.Layer.Model exposing (layer)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


sceneInit : LayeredSceneInit SceneCommonData UserData Target LayerMsg SceneMsg
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
        [ layer envcd <| Init {}
        ]
    }


settings : LayeredSceneSettingsFunc SceneCommonData UserData Target LayerMsg SceneMsg
settings _ _ _ =
    []


mainScene : SceneStorage UserData SceneMsg
mainScene =
    genLayeredScene sceneInit settings
