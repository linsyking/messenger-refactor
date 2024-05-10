module Messenger.Scene.LayeredScene exposing (..)

import Canvas exposing (Renderable, group)
import Canvas.Settings exposing (Setting)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (MsgBase(..), viewModelList)
import Messenger.Layer.Layer exposing (AbstractLayer)
import Messenger.Recursion exposing (updateObjects)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg, abstract, addCommonData, noCommonData)


type alias LayeredSceneData cdata localstorage tar msg scenemsg =
    { renderSettings : List Setting
    , commonData : cdata
    , layers : List (AbstractLayer cdata localstorage tar msg scenemsg)
    }


type alias ConcreteLayeredScene cdata localstorage tar msg scenemsg =
    MConcreteScene (LayeredSceneData cdata localstorage tar msg scenemsg) localstorage scenemsg


updateLayeredScene : (Env () localstorage -> WorldEvent -> LayeredSceneData cdata localstorage tar msg scenemsg -> List Setting) -> Env () localstorage -> WorldEvent -> LayeredSceneData cdata localstorage tar msg scenemsg -> ( LayeredSceneData cdata localstorage tar msg scenemsg, List (SceneOutputMsg scenemsg localstorage), Env () localstorage )
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


viewLayeredScene : Env () localstorage -> LayeredSceneData cdata localstorage tar msg scenemsg -> Renderable
viewLayeredScene env { renderSettings, commonData, layers } =
    viewModelList (addCommonData commonData env) layers
        |> group renderSettings


genLayeredScene : (Env () localstorage -> Maybe scenemsg -> LayeredSceneData cdata localstorage tar msg scenemsg) -> (Env () localstorage -> WorldEvent -> LayeredSceneData cdata localstorage tar msg scenemsg -> List Setting) -> SceneStorage localstorage scenemsg
genLayeredScene init settingsFunc =
    abstract
        { init = init
        , update = updateLayeredScene settingsFunc
        , view = viewLayeredScene
        }
