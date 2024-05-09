module Scenes.Home.AllLayers exposing (..)

import Lib.Scene.Base exposing (SceneInitData(..))
import Scenes.Home.LayerSettings exposing (LayerList, addLayer)
import Scenes.Home.Main.Export as Main



-- Add your layers below


allLayers : LayerList
allLayers =
    always (always [])
        |> addLayer Main.initLayer



-- |> addUserLayer User.initLayer User.tr
