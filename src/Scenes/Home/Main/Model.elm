module Scenes.Home.Main.Model exposing
    ( initModel
    , updateModel, updateModelRec
    , viewModel
    )

{-| Model module

@docs initModel
@docs updateModel, updateModelRec
@docs viewModel

-}

import Canvas exposing (Renderable, empty)
import Lib.Layer.Base exposing (LayerMsg, LayerTarget(..))
import Scenes.Home.Main.Common exposing (Env, Model, nullModel)
import Scenes.Home.SceneInit exposing (HomeInit)


{-| initModel
Add components here
-}
initModel : Env -> HomeInit -> Model
initModel _ _ =
    nullModel


{-| updateModel
Default update function

Add your logic to handle msg here

-}
updateModel : Env -> Model -> ( Model, List ( LayerTarget, LayerMsg ), Env )
updateModel env model =
    ( model, [], env )


{-| updateModelRec
Default update function

Add your logic to handle LayerMsg here

-}
updateModelRec : Env -> LayerMsg -> Model -> ( Model, List ( LayerTarget, LayerMsg ), Env )
updateModelRec env _ model =
    ( model, [], env )


{-| viewModel
Default view function

If you don't have components, remove viewComponent.

If you have other elements than components, add them after viewComponent.

-}
viewModel : Env -> Model -> Renderable
viewModel _ _ =
    empty
