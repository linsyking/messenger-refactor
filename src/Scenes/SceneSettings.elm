module Scenes.SceneSettings exposing (..)

{-| This module is generated by Messenger, don't modify this.

@docs SceneDataTypes
@docs SceneT
@docs nullSceneT

-}

import Scenes.Home.SceneInit as HomeInit



type SceneInitMsg
    = HomeInit HomeInit.InitDataT
    | OtherInitMsg
