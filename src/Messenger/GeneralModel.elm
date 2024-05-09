module Messenger.GeneralModel exposing (..)

{-|


# General Model

General model is designed to be an abstract interface of layers, components, game components, etc..

@docs GeneralModel
@docs viewModelList

-}

import Canvas exposing (Renderable)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Scene.Scene exposing (MsgBase)


type Msg othertar msg scenemsg
    = Parent (MsgBase msg scenemsg)
    | Other othertar msg


{-| General Model.

This has a name field.

-}
type alias ConcreteGeneralModel data env event tar msg ren bdata scenemsg =
    { init : env -> msg -> ( data, bdata )
    , update : env -> event -> data -> bdata -> ( ( data, bdata ), List (Msg tar msg scenemsg), ( env, Bool ) )
    , updaterec : env -> msg -> data -> bdata -> ( ( data, bdata ), List (Msg tar msg scenemsg), env )
    , view : env -> data -> bdata -> ren
    , matcher : data -> bdata -> tar -> Bool
    }


type alias UnrolledAbsGeneralModel env event tar msg ren bdata scenemsg =
    { update : env -> event -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), ( env, Bool ) )
    , updaterec : env -> msg -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), env )
    , view : env -> ren
    , matcher : tar -> Bool
    , baseData : bdata
    }


type AbsGeneralModel env event tar msg ren bdata scenemsg
    = Roll (UnrolledAbsGeneralModel env event tar msg ren bdata scenemsg)


unroll : AbsGeneralModel env event tar msg ren bdata scenemsg -> UnrolledAbsGeneralModel env event tar msg ren bdata scenemsg
unroll (Roll un) =
    un


abstract : ConcreteGeneralModel data env event tar msg ren bdata scenemsg -> env -> msg -> AbsGeneralModel env event tar msg ren bdata scenemsg
abstract conmodel initEnv initMsg =
    let
        abstractRec : data -> bdata -> AbsGeneralModel env event tar msg ren bdata scenemsg
        abstractRec data base =
            let
                updates : env -> event -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), ( env, Bool ) )
                updates env event =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.update env event data base
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                updaterecs : env -> msg -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), env )
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
    ConcreteGeneralModel data (Env common localstorage) WorldEvent tar msg Renderable bdata scenemsg


type alias MAbsGeneralModel common localstorage tar msg bdata scenemsg =
    AbsGeneralModel (Env common localstorage) WorldEvent tar msg Renderable bdata scenemsg


{-| View model list.
-}
viewModelList : env -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> List ren
viewModelList env models =
    List.map (\model -> (unroll model).view env) models
