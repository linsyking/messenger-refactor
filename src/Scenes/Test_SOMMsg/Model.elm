module Scenes.Test_SOMMsg.Model exposing (..)

import Base exposing (..)
import Canvas.Settings exposing (Setting)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.LayeredScene exposing (LayeredSceneData, genLayeredScene)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (addCommonData)
import Scenes.Test_SOMMsg.Layer.Model exposing (layer)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


commonDataInit : Env () LocalStorage -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


sceneInit : Env () LocalStorage -> Maybe SceneMsg -> LayeredSceneData SceneCommonData LocalStorage Target LayerMsg SceneMsg
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


settings : Env () LocalStorage -> WorldEvent -> LayeredSceneData SceneCommonData LocalStorage Target LayerMsg SceneMsg -> List Setting
settings _ _ _ =
    []


mainScene : SceneStorage LocalStorage SceneMsg
mainScene =
    genLayeredScene sceneInit settings
