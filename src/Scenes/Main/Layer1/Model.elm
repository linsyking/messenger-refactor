module Scenes.Main.Layer1.Model exposing (..)

import Base exposing (..)
import Canvas exposing (Renderable, empty)
import Components.Portable.PTest as PTest
import Components.User.Base as User
import Components.User.UTest as UTest
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Component.Component exposing (AbstractComponent, AbstractPortableComponent, preViewComponents, viewComponents)
import Messenger.GeneralModel exposing (Msg)
import Messenger.Layer.Layer exposing (AbstractLayer, ConcreteLayer, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg, noCommonData)
import Scenes.Main.LayerBase exposing (..)


type alias Data =
    { pcomps : List (AbstractPortableComponent LocalStorage PTest.ComponentTarget PTest.ComponentMsg)
    , ucomps : List (AbstractComponent SceneCommonData LocalStorage User.ComponentTarget User.ComponentMsg User.BaseData SceneMsg)
    }


init : Env SceneCommonData LocalStorage -> LayerMsg -> Data
init env initMsg =
    case initMsg of
        Init v ->
            Data
                [ PTest.pTest (noCommonData env) (PTest.Init { initVal = v.initVal }) ]
                [ UTest.uTest env (User.Init { initVal = "hello", initBase = v.initVal }) ]

        _ ->
            Data [] []


update : Env SceneCommonData LocalStorage -> WorldEvent -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), ( Env SceneCommonData LocalStorage, Bool ) )
update env evt data =
    ( data, [], ( env, False ) )


updaterec : Env SceneCommonData LocalStorage -> LayerMsg -> Data -> ( Data, List (Msg Target LayerMsg (SceneOutputMsg SceneMsg LocalStorage)), Env SceneCommonData LocalStorage )
updaterec env msg data =
    ( data, [], env )


view : Env SceneCommonData LocalStorage -> Data -> Renderable
view env data =
    viewComponents <| (preViewComponents (noCommonData env) data.pcomps ++ preViewComponents env data.ucomps)


matcher : Data -> Target -> Bool
matcher data tar =
    tar == "layer1"


layer1con : ConcreteLayer Data SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1con =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


layer1 : Env SceneCommonData LocalStorage -> LayerMsg -> AbstractLayer SceneCommonData LocalStorage Target LayerMsg SceneMsg
layer1 =
    genLayer layer1con
