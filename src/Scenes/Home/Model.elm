module Scenes.Home.Model exposing (..)

{-| Scene update module

@docs handleLayerMsg
@docs updateModel
@docs viewModel

-}

import Canvas exposing (Renderable)
import Lib.Layer.Base exposing (LayerMsg, LayerMsg_(..))
import Messenger.Audio.Base exposing (AudioOption(..))
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Scene exposing (LayeredModel, MConcreteScene, MsgBase(..), SceneOutputMsg(..), addCommonData, noCommonData)
import Scenes.Home.SceneInit exposing (InitDataT, nullHomeInit)
import Scenes.SceneSettings exposing (SceneInitMsg(..))


{-| Model
-}
type alias Data =
    LayeredModel CommonData


{-| CommonData
Edit your own CommonData here.
-}
type alias CommonData =
    {}


{-| Init CommonData
-}
nullCommonData : CommonData
nullCommonData =
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
    , layers = initAllLayers env layerInitData
    }


{-| handleLayerMsg

Handle Layer Messages

Note that the layer messages with SOMMsg type(directly copy from the component message) will be directly sent to messenger

-}
handleLayerMsg : Env () localstorage -> LayerMsg -> Data -> ( Data, List (SceneOutputMsg SceneInitMsg), Env () localstorage )
handleLayerMsg env msgb model =
    case msgb of
        SOMMsg sommsg ->
            ( model, [ sommsg ], env )

        OtherMsg _ ->
            ( model, [], env )


{-| updateModel

Default update function. Normally you won't change this function.

-}
updateModel : Env () localstorage -> WorldEvent -> Data -> ( Data, List (SceneOutputMsg SceneInitMsg), Env () localstorage )
updateModel env evt model =
    let
        ( newlayers, msgs, ( newenv, _ ) ) =
            --TODO
            updateLayers (addCommonData model.commonData env) evt model.layers

        nmodel =
            { model | commonData = newenv.commonData, layers = newlayers }

        ( newmodel, newmsg, newenv2 ) =
            List.foldl
                (\x ( y, lmsg, cenv ) ->
                    let
                        ( model2, msg2, env2 ) =
                            handleLayerMsg cenv x y
                    in
                    ( model2, lmsg ++ msg2, env2 )
                )
                ( nmodel, [], noCommonData newenv )
                msgs
    in
    ( newmodel, newmsg, newenv2 )


{-| Default view function
-}
viewModel : Env () localstorage -> Data -> Renderable
viewModel env model =
    -- TODO
    viewLayers (addCommonData model.commonData env) model.layers


concreteScene : MConcreteScene Data localstorage SceneInitMsg
concreteScene =
    { init = initModel
    , update = updateModel
    , view = viewModel
    }
