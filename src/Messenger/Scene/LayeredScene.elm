module Messenger.Scene.LayeredScene exposing (..)

import Canvas exposing (Renderable, group)
import Canvas.Settings exposing (Setting)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (MAbsGeneralModel, MConcreteGeneralModel, viewModelList)
import Messenger.Recursion exposing (updateObjects)
import Messenger.Scene.Scene exposing (MConcreteScene, MsgBase(..), SceneOutputMsg, addCommonData, noCommonData)


type alias ConcreteLayer data common localstorage tar msg scenemsg =
    MConcreteGeneralModel data common localstorage tar msg () scenemsg


type alias AbsLayer common localstorage tar msg scenemsg =
    MAbsGeneralModel common localstorage tar msg () scenemsg


type alias LayeredSceneData cdata ls tar msg scenemsg =
    { renderSettings : List Setting
    , commonData : cdata
    , layers : List (AbsLayer cdata ls tar msg scenemsg)
    }


type alias ConcreteLayeredScene cdata ls tar msg scenemsg =
    MConcreteScene (LayeredSceneData cdata ls tar msg scenemsg) ls scenemsg


updateLayeredScene : (Env () ls -> WorldEvent -> LayeredSceneData cdata ls tar msg scenemsg -> List Setting) -> Env () ls -> WorldEvent -> LayeredSceneData cdata ls tar msg scenemsg -> ( LayeredSceneData cdata ls tar msg scenemsg, List (SceneOutputMsg scenemsg ls), Env () ls )
updateLayeredScene settingsFunc env evt lsd =
    let
        ( newLayers, newMsgs, ( newEnv, _ ) ) =
            updateObjects (addCommonData lsd.commonData env) evt lsd.layers

        som =
            List.filterMap
                (\msg ->
                    case msg of
                        SOMMsg m ->
                            Just m

                        _ ->
                            Nothing
                )
                newMsgs
    in
    ( { renderSettings = settingsFunc env evt lsd, commonData = newEnv.commonData, layers = newLayers }, som, noCommonData newEnv )


viewLayeredScene : Env () ls -> LayeredSceneData cdata ls tar msg scenemsg -> Renderable
viewLayeredScene env { renderSettings, commonData, layers } =
    viewModelList (addCommonData commonData env) layers
        |> group renderSettings


genLayeredScene : (Env () ls -> scenemsg -> LayeredSceneData cdata ls tar msg scenemsg) -> (Env () ls -> WorldEvent -> LayeredSceneData cdata ls tar msg scenemsg -> List Setting) -> ConcreteLayeredScene cdata ls tar msg scenemsg
genLayeredScene init settingsFunc =
    { init = init
    , update = updateLayeredScene settingsFunc
    , view = viewLayeredScene
    }