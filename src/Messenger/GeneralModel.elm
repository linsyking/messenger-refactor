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


type alias UnrolledAbsGeneralModel env event tar msg ren bdata sommsg =
    { update : env -> event -> ( AbsGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), ( env, Bool ) )
    , updaterec : env -> msg -> ( AbsGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), env )
    , view : env -> ren
    , matcher : tar -> Bool
    , baseData : bdata
    }


type AbsGeneralModel env event tar msg ren bdata sommsg
    = Roll (UnrolledAbsGeneralModel env event tar msg ren bdata sommsg)


unroll : AbsGeneralModel env event tar msg ren bdata sommsg -> UnrolledAbsGeneralModel env event tar msg ren bdata sommsg
unroll (Roll un) =
    un


abstract : ConcreteGeneralModel data env event tar msg ren bdata sommsg -> env -> msg -> AbsGeneralModel env event tar msg ren bdata sommsg
abstract conmodel initEnv initMsg =
    let
        abstractRec : data -> bdata -> AbsGeneralModel env event tar msg ren bdata sommsg
        abstractRec data base =
            let
                updates : env -> event -> ( AbsGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), ( env, Bool ) )
                updates env event =
                    let
                        ( ( new_d, new_bd ), new_m, new_e ) =
                            conmodel.update env event data base
                    in
                    ( abstractRec new_d new_bd, new_m, new_e )

                updaterecs : env -> msg -> ( AbsGeneralModel env event tar msg ren bdata sommsg, List (Msg tar msg sommsg), env )
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


type alias MAbsGeneralModel common localstorage tar msg bdata scenemsg =
    AbsGeneralModel (Env common localstorage) WorldEvent tar msg Renderable bdata (SceneOutputMsg scenemsg localstorage)


{-| View model list.
-}
viewModelList : Env common localstorage -> List (MAbsGeneralModel common localstorage tar msg bdata scenemsg) -> List Renderable
viewModelList env models =
    List.reverse <| List.map (\model -> (unroll model).view env) models
