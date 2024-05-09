module Messenger.Scene.Loader exposing (..)

{-| Query whether a scene exists
-}

import Messenger.Base exposing (Env)
import Messenger.Model exposing (Model)
import Messenger.Scene.Scene exposing (MAbsScene, MConcreteScene, abstract)


type alias SceneStorage localstorage scenemsg =
    Env () localstorage -> scenemsg -> MAbsScene localstorage scenemsg


sceneInit : MConcreteScene data localstorage scenemsg -> SceneStorage localstorage scenemsg
sceneInit conscene =
    abstract conscene


existScene : String -> List ( String, SceneStorage localstorage scenemsg ) -> Bool
existScene i scenes =
    let
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
getScene : String -> List ( String, SceneStorage localstorage scenemsg ) -> Maybe (SceneStorage localstorage scenemsg)
getScene i scenes =
    List.head <|
        List.map (\( _, s ) -> s) <|
            List.filter (\( x, _ ) -> x == i) scenes


{-| loadScene
-}
loadScene : Maybe (SceneStorage localstorage scenemsg) -> Env () localstorage -> scenemsg -> Model localstorage scenemsg -> Model localstorage scenemsg
loadScene scenest env smsg model =
    case scenest of
        Just s ->
            { model | currentScene = s env smsg }

        Nothing ->
            model


{-| loadSceneByName
-}
loadSceneByName : String -> List ( String, (SceneStorage localstorage scenemsg) ) -> Env () localstorage -> scenemsg -> Model localstorage scenemsg -> Model localstorage scenemsg
loadSceneByName name scenes env smsg model =
    let
        newModel =
            loadScene (getScene name scenes) env smsg model

        gd =
            newModel.currentGlobalData
    in
    { newModel | currentGlobalData = { gd | currentScene = name } }
