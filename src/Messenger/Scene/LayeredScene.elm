module Messenger.Scene.LayeredScene exposing (..)

import Canvas exposing (Renderable, group)
import Canvas.Settings exposing (Setting)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (MsgBase(..), viewModelList)
import Messenger.Layer.Layer exposing (AbstractLayer)
import Messenger.Recursion exposing (updateObjects)
import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (SceneOutputMsg, abstract, addCommonData, noCommonData)


type alias LayeredSceneData cdata userdata tar msg scenemsg =
    { renderSettings : List Setting
    , commonData : cdata
    , layers : List (AbstractLayer cdata userdata tar msg scenemsg)
    }


updateLayeredScene : (Env () userdata -> WorldEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> List Setting) -> Env () userdata -> WorldEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> ( LayeredSceneData cdata userdata tar msg scenemsg, List (SceneOutputMsg scenemsg userdata), Env () userdata )
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


viewLayeredScene : Env () userdata -> LayeredSceneData cdata userdata tar msg scenemsg -> Renderable
viewLayeredScene env { renderSettings, commonData, layers } =
    viewModelList (addCommonData commonData env) layers
        |> group renderSettings


genLayeredScene : (Env () userdata -> Maybe scenemsg -> LayeredSceneData cdata userdata tar msg scenemsg) -> (Env () userdata -> WorldEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> List Setting) -> SceneStorage userdata scenemsg
genLayeredScene init settingsFunc =
    abstract
        { init = init
        , update = updateLayeredScene settingsFunc
        , view = viewLayeredScene
        }
