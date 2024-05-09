module Messenger.GeneralModel exposing
    ( viewModelList, viewModelArray
    , AbsGeneralModel(..), ConcreteGeneralModel, UnrolledAbsGeneralModel, abstract
    )

{-|


# General Model

General model is designed to be an abstract interface of scenes, layers, components, game components, etc..

  - a: data type
  - b: environment type
  - c: message type
  - d: target type
  - e: render type
  - f: event type

@docs GeneralModel
@docs viewModelList, viewModelArray

-}

import Array exposing (Array)
import Messenger.Scene exposing (MsgBase)


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
    { update : env -> bdata -> event -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), ( env, Bool ) )
    , updaterec : env -> bdata -> msg -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), env )
    , view : env -> bdata -> ren
    , matcher : bdata -> tar -> Bool
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
        abstractRec data baseInit =
            let
                updates : env -> bdata -> event -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), ( env, Bool ) )
                updates env baseData event =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.update env event data baseData
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                updaterecs : env -> bdata -> msg -> ( AbsGeneralModel env event tar msg ren bdata scenemsg, List (Msg tar msg scenemsg), env )
                updaterecs env baseData msg =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.updaterec env msg data baseData
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                views : env -> bdata -> ren
                views env baseData =
                    conmodel.view env data baseData

                matchers : bdata -> tar -> Bool
                matchers baseData =
                    conmodel.matcher data baseData

                baseDatas : bdata
                baseDatas =
                    baseInit
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


{-| View model list.
-}
viewModelList : b -> List (AbsGeneralModel b c d e f) -> List e
viewModelList env models =
    List.map (\model -> (unroll model).view env) models


{-| View model array.
-}
viewModelArray : b -> Array (AbsGeneralModel b c d e f) -> List e
viewModelArray env models =
    Array.toList models
        |> List.map (\model -> (unroll model).view env)
