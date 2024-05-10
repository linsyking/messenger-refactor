module Messenger.Component.Component exposing (..)

import Canvas exposing (Renderable, group)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.GeneralModel exposing (AbstractGeneralModel, ConcreteGeneralModel, Msg, MsgBase, abstract, unroll)
import Messenger.Recursion exposing (updateObjects, updateObjectsWithTarget)
import Messenger.Scene.Scene exposing (SceneOutputMsg)


type alias ConcreteUserComponent data cdata localstorage tar msg bdata scenemsg =
    ConcreteGeneralModel data (Env cdata localstorage) WorldEvent tar msg ( Renderable, Int ) bdata (SceneOutputMsg scenemsg localstorage)


type alias ConcretePortableComponent data localstorage tar msg =
    { init : Env () localstorage -> msg -> data
    , update : Env () localstorage -> WorldEvent -> data -> ( data, List (Msg tar msg (SceneOutputMsg () localstorage)), ( Env () localstorage, Bool ) )
    , updaterec : Env () localstorage -> msg -> data -> ( data, List (Msg tar msg (SceneOutputMsg () localstorage)), Env () localstorage )
    , view : Env () localstorage -> data -> ( Renderable, Int )
    , matcher : data -> tar -> Bool
    }


translatePortableComponent : ConcretePortableComponent data localstorage tar msg -> ConcreteUserComponent data () localstorage tar msg () ()
translatePortableComponent pcomp =
    { init = \env msg -> ( pcomp.init env msg, () )
    , update =
        \env evt data () ->
            let
                ( resData, resMsg, resEnv ) =
                    pcomp.update env evt data
            in
            ( ( resData, () ), resMsg, resEnv )
    , updaterec =
        \env msg data () ->
            let
                ( resData, resMsg, resEnv ) =
                    pcomp.updaterec env msg data
            in
            ( ( resData, () ), resMsg, resEnv )
    , view = \env data () -> pcomp.view env data
    , matcher = \data () tar -> pcomp.matcher data tar
    }


type alias AbstractComponent cdata localstorage tar msg bdata scenemsg =
    AbstractGeneralModel (Env cdata localstorage) WorldEvent tar msg ( Renderable, Int ) bdata (SceneOutputMsg scenemsg localstorage)


type alias AbstractPortableComponent localstorage tar msg =
    AbstractComponent () localstorage tar msg () ()


genComponent : ConcreteUserComponent data cdata localstorage tar msg bdata scenemsg -> Env cdata localstorage -> msg -> AbstractComponent cdata localstorage tar msg bdata scenemsg
genComponent concomp =
    abstract concomp


updateComponents : Env cdata localstorage -> WorldEvent -> List (AbstractComponent cdata localstorage tar msg bdata scenemsg) -> ( List (AbstractComponent cdata localstorage tar msg bdata scenemsg), List (MsgBase msg (SceneOutputMsg scenemsg localstorage)), ( Env cdata localstorage, Bool ) )
updateComponents env evt comps =
    updateObjects env evt comps


updateComponentswithTarget : Env cdata localstorage -> List (Msg tar msg (SceneOutputMsg scenemsg localstorage)) -> List (AbstractComponent cdata localstorage tar msg bdata scenemsg) -> ( List (AbstractComponent cdata localstorage tar msg bdata scenemsg), List (MsgBase msg (SceneOutputMsg scenemsg localstorage)), Env cdata localstorage )
updateComponentswithTarget env msgs comps =
    updateObjectsWithTarget env msgs comps


preViewComponents : Env cdata localstorage -> List (AbstractComponent cdata localstorage tar msg bdata scenemsg) -> List ( Renderable, Int )
preViewComponents env compls =
    List.map (\comp -> (unroll comp).view env) compls


viewComponents : List ( Renderable, Int ) -> Renderable
viewComponents previews =
    group [] <|
        List.map (\( r, _ ) -> r) <|
            List.sortBy (\( _, n ) -> n) previews
