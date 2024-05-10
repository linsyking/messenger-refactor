module Messenger.Scene.RawScene exposing (..)

import Messenger.Scene.Loader exposing (SceneStorage)
import Messenger.Scene.Scene exposing (MConcreteScene, abstract)


genRawScene : MConcreteScene data ls scenemsg -> SceneStorage ls scenemsg
genRawScene conscene =
    abstract conscene
