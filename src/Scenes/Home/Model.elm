module Scenes.Home.Model exposing (..)

{-| Scene update module

@docs handleLayerMsg
@docs updateModel
@docs viewModel

-}

import Canvas exposing (Renderable)
import Messenger.Audio.Base exposing (AudioOption(..))
import Lib.Layer.Base exposing (LayerMsg, LayerMsg_(..))
import Lib.Layer.LayerHandler exposing (updateLayer, viewLayer)
import Scenes.Home.Common exposing (Model)
import Scenes.Home.LayerBase exposing (CommonData)
import Messenger.Base exposing (Env)
import Scenes.AllScenes exposing (SceneInitMsg)
import Scenes.AllScenes exposing (SceneInitMsg(..))
import Messenger.Scene.Scene exposing (LayeredModel)

{-| Model
-}
type alias Data =
    LayeredModel CommonData


{-| Init Data
-}
type alias InitDataT =
    {}

{-| Null HomeInit data
-}
nullHomeInit : InitDataT
nullHomeInit =
    {}

initCommonData : Env () localstorage -> InitDataT -> CommonData
initCommonData _ _ =
    nullCommonData

{-| Initialize the model
-}
initModel : Env () localstorage -> SceneInitMsg -> Data
initModel env init =
    let
        layerInitData =
            case init of
                HomeInit x ->
                    x

                _ ->
                    nullHomeInit
    in
    { commonData = initCommonData env layerInitData
    , layers = allLayers env layerInitData
    }

{-| handleLayerMsg

Handle Layer Messages

Note that the layer messages with SOMMsg type(directly copy from the component message) will be directly sent to messenger

-}
handleLayerMsg : Env CommonData -> LayerMsg -> Model -> ( Model, List SceneOutputMsg, Env CommonData )
handleLayerMsg env msgb model =
    case msgb of
        OtherMsg lmsg ->
            case lmsg of
                LayerSoundMsg name path opt ->
                    ( model, [ SOMPlayAudio name path opt ], env )

                LayerStopSoundMsg name ->
                    ( model, [ SOMStopAudio name ], env )

                LayerChangeSceneMsg name ->
                    ( model, [ SOMChangeScene ( NullSceneInitData, name, Nothing ) ], env )

                _ ->
                    ( model, [], env )

        SOMMsg sommsg ->
            ( model, [ sommsg ], env )


{-| updateModel

Default update function. Normally you won't change this function.

-}
updateModel : Env () -> Event -> Model -> ( Model, List SceneOutputMsg, Env () )
updateModel env evt model =
    let
        ( newdata, msgs, newenv ) =
            updateLayer (addCommonData model.commonData env) evt model.layers

        nmodel =
            { model | commonData = newenv.commonData, layers = newdata }

        ( newmodel, newsow, newgd2 ) =
            List.foldl
                (\x ( y, lmsg, cgd ) ->
                    let
                        ( model2, msg2, env2 ) =
                            handleLayerMsg cgd x y
                    in
                    ( model2, lmsg ++ msg2, env2 )
                )
                ( nmodel, [], newenv )
                msgs
    in
    ( newmodel, newsow, noCommonData newgd2 )


{-| Default view function
-}
viewModel : Env () -> Model -> Renderable
viewModel env model =
    viewLayer (addCommonData model.commonData env) model.layers
