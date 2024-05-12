module Scenes.Test_SOMMsg.LayerBase exposing
    ( Target
    , SceneCommonData
    , LayerInitData
    , LayerMsg(..)
    )

{-|


# LayerBase

Basic data for the layers in **Test\_SOMMsg**.

@docs Target
@docs SceneCommonData
@docs LayerInitData
@docs LayerMsg

-}


{-| Target

Gerneral Target Type for layers in **Test\_SOMMsg**.

-}
type alias Target =
    String


{-| SceneCommonData

Common data in **Test\_SOMMsg**.

-}
type alias SceneCommonData =
    {}


{-| LayerInitData

Init data for layers in **Test\_SOMMsg**.

-}
type alias LayerInitData =
    {}


{-| LayerMsg

Gerneral meassge for layers in **Test\_SOMMsg**.

-}
type LayerMsg
    = Init LayerInitData
    | Others
