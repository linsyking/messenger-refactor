module Messenger.GeneralModel exposing (..)

{-|


# General Model

General model is designed to be an abstract interface of layers, components, game components, etc..

@docs GeneralModel
@docs viewModelList

-}

import Canvas exposing (Renderable)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Scene exposing (SceneOutputMsg)


type MsgBase othermsg sommsg
    = SOMMsg sommsg
    | OtherMsg othermsg


type Msg othertar msg sommsg
    = Parent (MsgBase msg sommsg)
    | Other othertar msg


{-| General Model.

This has a name field.

-}
type alias ConcreteGeneralModel data env event tar msg ren bdata sommsg =
    { init : env -> msg -> ( data, bdata )
    , update : env -> event -> data -> bdata -> ( ( data, bdata ), List (Msg tar msg sommsg), ( env, Bool ) )
    , updaterec : env -> msg -> data -> bdata -> ( ( data, bdata ), List (Msg tar msg sommsg), env )
    , view : env -> data -> bdata -> ren
    , matcher : data -> bdata -> tar -> Bool
    }


type alias UnrolledAbstractGeneralModel env event tar msg ren bdata sommsg =
    { update : env -> event -> ( AbstractGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), ( env, Bool ) )
    , updaterec : env -> msg -> ( AbstractGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), env )
    , view : env -> ren
    , matcher : tar -> Bool
    , baseData : bdata
    }


type AbstractGeneralModel env event tar msg ren bdata sommsg
    = Roll (UnrolledAbstractGeneralModel env event tar msg ren bdata sommsg)


unroll : AbstractGeneralModel env event tar msg ren bdata sommsg -> UnrolledAbstractGeneralModel env event tar msg ren bdata sommsg
unroll (Roll un) =
    un


abstract : ConcreteGeneralModel data env event tar msg ren bdata sommsg -> env -> msg -> AbstractGeneralModel env event tar msg ren bdata sommsg
abstract conmodel initEnv initMsg =
    let
        abstractRec : data -> bdata -> AbstractGeneralModel env event tar msg ren bdata sommsg
        abstractRec data base =
            let
                updates : env -> event -> ( AbstractGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), ( env, Bool ) )
                updates env event =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.update env event data base
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                updaterecs : env -> msg -> ( AbstractGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), env )
                updaterecs env msg =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.updaterec env msg data base
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                views : env -> ren
                views env =
                    conmodel.view env data base

                matchers : tar -> Bool
                matchers =
                    conmodel.matcher data base

                baseDatas : bdata
                baseDatas =
                    base
            in
            Roll
                { update = updates
                , updaterec = updaterecs
                , view = views
                , matcher = matchers
                , baseData = baseDatas
                }

        ( init_d, init_bd ) =
            conmodel.init initEnv initMsg
    in
    abstractRec init_d init_bd


type alias MConcreteGeneralModel data common localstorage tar msg bdata scenemsg =
    ConcreteGeneralModel data (Env common localstorage) WorldEvent tar msg Renderable bdata (SceneOutputMsg scenemsg localstorage)


type alias MAbstractGeneralModel common localstorage tar msg bdata scenemsg =
    AbstractGeneralModel (Env common localstorage) WorldEvent tar msg Renderable bdata (SceneOutputMsg scenemsg localstorage)


type alias MConCreteGeneralModelwithoutBData data common localstorage tar msg scenemsg =
    { init : Env common localstorage -> msg -> data
    , update : Env common localstorage -> WorldEvent -> data -> ( data, List (Msg tar msg (SceneOutputMsg scenemsg localstorage)), ( Env common localstorage, Bool ) )
    , updaterec : Env common localstorage -> msg -> data -> ( data, List (Msg tar msg (SceneOutputMsg scenemsg localstorage)), Env common localstorage )
    , view : Env common localstorage -> data -> Renderable
    , matcher : data -> tar -> Bool
    }


addEmptyBData : MConCreteGeneralModelwithoutBData data common localstorage tar msg scenemsg -> MConcreteGeneralModel data common localstorage tar msg () scenemsg
addEmptyBData mconnoB =
    { init = \env msg -> ( mconnoB.init env msg, () )
    , update =
        \env evt data () ->
            let
                ( resData, resMsg, resEnv ) =
                    mconnoB.update env evt data
            in
            ( ( resData, () ), resMsg, resEnv )
    , updaterec =
        \env msg data () ->
            let
                ( resData, resMsg, resEnv ) =
                    mconnoB.updaterec env msg data
            in
            ( ( resData, () ), resMsg, resEnv )
    , view = \env data () -> mconnoB.view env data
    , matcher = \data () tar -> mconnoB.matcher data tar
    }


{-| View model list.
-}
viewModelList : Env common localstorage -> List (MAbstractGeneralModel common localstorage tar msg bdata scenemsg) -> List Renderable
viewModelList env models =
    List.reverse <| List.map (\model -> (unroll model).view env) models
