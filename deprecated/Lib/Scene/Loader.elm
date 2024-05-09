module Lib.Scene.Loader exposing
    ( getScene, existScene
    , loadScene
    , loadSceneByName
    , getCurrentScene
    )

{-| Scene Loader

@docs getScene, existScene
@docs loadScene
@docs loadSceneByName
@docs getCurrentScene

-}

import Base exposing (Msg)
import Common exposing (Model)
import Lib.Event.Event exposing (Event)
import Lib.Scene.Base exposing (SceneInitData)
import List exposing (head)
import Scenes.AllScenes exposing (allScenes)
import Scenes.SceneSettings exposing (SceneT, nullSceneT)


{-| Query whether a scene exists
-}
existScene : String -> Bool
existScene i =
    let
        scenes =
            allScenes

        tests =
            List.filter (\( x, _ ) -> x == i) scenes
    in
    case List.head tests of
        Just _ ->
            True

        Nothing ->
            False


{-| getScene
-}
getScene : String -> SceneT
getScene i =
    let
        scenes =
            allScenes

        tests =
            List.filter (\( x, _ ) -> x == i) scenes

        head =
            List.head tests
    in
    case head of
        Just ( _, x ) ->
            x

        Nothing ->
            nullSceneT


{-| loadScene
-}
loadScene : Event -> Model -> SceneT -> SceneInitData -> Model
loadScene evnt model cs sid =
    { model
        | currentScene = cs
        , currentData = cs.init { t = model.time, globalData = model.currentGlobalData, msg = msg, commonData = () } sid
    }


{-| loadSceneByName
-}
loadSceneByName : Event -> Model -> String -> SceneInitData -> Model
loadSceneByName evnt model name sid =
    let
        newModel =
            loadScene evnt model (getScene name) sid

        gd =
            newModel.currentGlobalData
    in
    { newModel | currentGlobalData = { gd | currentScene = name } }


{-| getCurrentScene
-}
getCurrentScene : Model -> SceneT
getCurrentScene model =
    model.currentScene
