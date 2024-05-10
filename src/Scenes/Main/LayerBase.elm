module Scenes.Main.LayerBase exposing (..)


type alias Target =
    String


type alias SceneCommonData =
    { key : String
    }


type alias LayerInitData =
    { initVal : Int }


type LayerMsg
    = Init LayerInitData
    | Others
