module Scenes.Sample.Model exposing
    ( commonDataInit
    , sceneInit
    , settings
    , mainScene
    )

{-| Scene configuration module

@docs commonDataInit
@docs sceneInit
@docs settings
@docs mainScene

-}

import Lib.Base exposing (..)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneInit, LayeredSceneSettingsFunc, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.Sample.Layer.Model exposing (layer)
import Scenes.Sample.LayerBase exposing (..)


{-| commonDataInit

init the commondata used in the scene.

-}
commonDataInit : Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ =
    {}


{-| sceneInit

init function for the scene.

Add all the layers with their init msg here.

-}
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


{-| settings

update the render settings.

-}
settings : LayeredSceneSettingsFunc SceneCommonData UserData Target LayerMsg SceneMsg
settings _ _ _ =
    []


{-| mainScene

generate an abstract scnene.

-}
mainScene : SceneStorage UserData SceneMsg
mainScene =
    genLayeredScene sceneInit settings
