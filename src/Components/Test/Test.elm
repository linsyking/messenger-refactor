module Components.Test.Test exposing
    ( initModel
    , updateModel, updateModelRec
    , viewModel
    )

{-| Component

This is a component model module. It should define init, update and view model.

@docs initModel
@docs updateModel, updateModelRec
@docs viewModel

-}

import Canvas exposing (Renderable, empty)
import Components.ComponentSettings exposing (TestData, nullTestData)
import Lib.Component.Base exposing (ComponentInitData(..), ComponentMsg, ComponentMsg_(..), ComponentTarget(..))
import Lib.Env.Env exposing (Env)


{-| Data
-}
type alias Data =
    TestData


{-| NullData
-}
nullData : Data
nullData =
    nullTestData


{-| initModel

Initialize the model.

-}
initModel : Env () -> ComponentInitData -> Data
initModel _ _ =
    nullData


{-| updateModel

Add your component logic to handle Msg here.

-}
updateModel : Env () -> Data -> ( Data, List ( ComponentTarget, ComponentMsg ), Env () )
updateModel env d =
    ( d, [], env )


{-| updateModelRec

Add your component logic to handle ComponentMsg here.

-}
updateModelRec : Env () -> ComponentMsg -> Data -> ( Data, List ( ComponentTarget, ComponentMsg ), Env () )
updateModelRec env _ d =
    ( d, [], env )


{-| viewModel

Change this to your own component view function.

If there is no view function, return Nothing.

-}
viewModel : Env () -> Data -> Renderable
viewModel _ _ =
    empty
