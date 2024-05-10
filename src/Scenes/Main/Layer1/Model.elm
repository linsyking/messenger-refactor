module Scenes.Main.Layer1.Model exposing (..)

import Base exposing (..)
import Messenger.Base exposing (Env)
import Messenger.Scene.LayeredScene exposing (AbstractLayer, ConcreteLayer)
import Scenes.Main.LayerBase exposing (..)
import Messenger.Base exposing (WorldEvent)
import Messenger.Scene.LayeredScene exposing (genLayer)


init : Env SceneCommonData LocalStorage -> LayerMsg -> ( Int, () )
init _ _ = ( 0, () )

update : (Env SceneCommonData LocalStorage) -> WorldEvent -> Int -> () -> ( ( Int, () ), List (Msg Target msg sommsg), ( Env SceneCommonData LocalStorage, Bool ) )

layer1con : ConcreteLayer Int SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1con =  {
    init = init
    , update = env -> event -> Int -> () -> ( ( Int, () ), List (Msg tar msg sommsg), ( env, Bool ) )
    , updaterec = env -> msg -> Int -> () -> ( ( Int, () ), List (Msg tar msg sommsg), env )
    , view = env -> Int -> () -> ren
    , matcher = Int -> () -> tar -> Bool
}


layer1 : Env SceneCommonData LocalStorage -> LayerMsg -> AbstractLayer SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1 =
    genLayer layer1con
