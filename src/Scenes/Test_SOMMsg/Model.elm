module Scenes.Test_SOMMsg.Model exposing (..)

import Base exposing (..)
import Canvas.Settings exposing (Setting)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.LayeredScene exposing (LayeredSceneData, genLayeredScene)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (addCommonData)
import Scenes.Test_SOMMsg.Layer.Model exposing (layer)
import Scenes.Test_SOMMsg.LayerBase exposing (..)


commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


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
        [ layer envcd <| Init {}
        ]
    }


settings : Env () UserData -> WorldEvent -> LayeredSceneData SceneCommonData UserData Target LayerMsg SceneMsg -> List Setting
settings _ _ _ =
    []


mainScene : SceneStorage UserData SceneMsg
mainScene =
    genLayeredScene sceneInit settings
