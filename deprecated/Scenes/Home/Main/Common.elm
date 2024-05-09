module Scenes.Home.Main.Common exposing (Model, nullModel, Env)

{-| Common module

@docs Model, nullModel, Env

-}

import Lib.Env.Env as Env
import Scenes.Home.LayerBase exposing (CommonData)


{-| Model
Add your own data here.
-}
type alias Model =
    {}


{-| nullModel
-}
nullModel : Model
nullModel =
    {}


{-| Convenient type alias for the environment
-}
type alias Env =
    Env.Env CommonData
