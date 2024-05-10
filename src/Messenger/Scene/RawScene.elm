module Messenger.Scene.RawScene exposing (..)

import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (MConcreteScene, abstract)


genRawScene : MConcreteScene data localstorage scenemsg -> SceneStorage localstorage scenemsg
genRawScene =
    abstract
