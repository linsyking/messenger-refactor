module Lib.Layer.LayerHandler exposing
    ( update, updaterec, match, super, recBody
    , updateLayer
    , viewLayer
    )

{-|


# Layer Handler

@docs update, updaterec, match, super, recBody
@docs updateLayer
@docs viewLayer

-}

import Base exposing (ObjectTarget(..))
import Canvas exposing (Renderable, group)
import Lib.Env.Env exposing (Env)
import Lib.Event.Event exposing (Event)
import Lib.Layer.Base exposing (AbsLayer, LayerMsg, LayerTarget(..))
import Messenger.GeneralModel exposing (AbsGeneralModel(..), unroll, viewModelList)
import Messenger.Recursion exposing (RecBody)
import Messenger.RecursionList exposing (updateObjects)


{-| Updater
-}
update : AbsLayer b -> Env b -> Event -> ( AbsLayer b, List ( LayerTarget, LayerMsg ), Env b )
update layer env evt =
    let
        ( newLayer, newMsgs, newEnv ) =
            (unroll layer).update env evt
    in
    ( newLayer, newMsgs, newEnv )


{-| RecUpdater
-}
updaterec : AbsLayer b -> Env b -> LayerMsg -> ( AbsLayer b, List ( LayerTarget, LayerMsg ), Env b )
updaterec layer env lm =
    let
        ( newLayer, newMsgs, newEnv ) =
            (unroll layer).updaterec env lm
    in
    ( newLayer, newMsgs, newEnv )


{-| Matcher
-}
match : AbsLayer b -> LayerTarget -> Bool
match l t =
    case t of
        Layer Parent ->
            False

        Layer (Name n) ->
            n == (unroll l).name

        Layer _ ->
            False


{-| Super
-}
super : LayerTarget -> Bool
super t =
    case t of
        Layer Parent ->
            True

        Layer _ ->
            False


{-| Recbody
-}
recBody : RecBody (AbsLayer b) LayerMsg (Env b) LayerTarget Event
recBody =
    { update = update, updaterec = updaterec, match = match, super = super }


{-| updateLayer

Update all the layers.

-}
updateLayer : Env b -> Event -> List (AbsLayer b) -> ( List (AbsLayer b), List LayerMsg, Env b )
updateLayer env evt =
    updateObjects recBody env evt


{-| viewLayer

Get the view of the layer.

-}
viewLayer : Env b -> List (AbsLayer b) -> Renderable
viewLayer env models =
    group [] <| viewModelList env models
