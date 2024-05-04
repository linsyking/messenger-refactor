module Components.ComponentSettings exposing
    ( ComponentType(..)
    , ComponentT
    , TestData, nullTestData
    )

{-| This module stores the data type of all the components, modify the data type of components here.

@docs ComponentType
@docs ComponentT
@docs TestData, nullTestData

-}

import Lib.Component.Base exposing (Component)


{-| Defined Types for Component
-}
type ComponentType
    = CTestData TestData
    | NullComponentData


type alias ComponentT =
    Component ComponentType



--- TestData ---


type alias TestData =
    {}


nullTestData : TestData
nullTestData =
    {}
