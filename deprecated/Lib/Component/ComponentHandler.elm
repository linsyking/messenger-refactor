module Lib.Component.ComponentHandler exposing
    ( update, updaterec, match, super, recBody
    , updateComponents, updateComponentswithTarget
    , viewComponent
    )

{-| ComponentHandler deals with components

You can use these functions to handle components.

The mosy commonly used one is the `updateComponents` function, which will update all components recursively.

@docs update, updaterec, match, super, recBody
@docs updateComponents, updateComponentswithTarget
@docs viewComponent

-}

import Base exposing (ObjectTarget(..))
import Canvas exposing (Renderable, group)
import Lib.Component.Base exposing (Component(..), TargetBase(..))
import Lib.Env.Env exposing (Env)
import Lib.Event.Event exposing (Event)
import Messenger.GeneralModel exposing (viewModelList)
import Messenger.Recursion exposing (RecBody)
import Messenger.RecursionList exposing (updateObjects, updateObjectsWithTarget)



-- Below are using the Recursion algorithm to get the update function


{-| RecUpdater
-}
update : Component env event tar cmsg ren -> env -> event  -> ( Component env event tar cmsg ren, List ( tar, cmsg ), env )
update env event comp =
    case comp of
        Unroll cc ->
            cc.update env event


updaterec : env -> cmsg -> Component env event tar cmsg ren -> ( Component env event tar cmsg ren, List ( tar, cmsg ), env )
updaterec env msg comp =
    case comp of
        Unroll cc ->
            cc.updaterec env msg


{-| Matcher
-}
match : Component env event tar cmsg ren -> tar -> Bool
match comp tar =
    case comp of
        Unroll cc ->
            cc.matcher tar


{-| Super
-}
super : tar -> Bool
super tar =
    case tar of
        Parent ->
            True

        _ ->
            False



--- Undo:


{-| Rec body for the component
-}
recBody : RecBody (Component env event tar cmsg ren) cmsg env tar Event
recBody =
    { update = update
    , updaterec = updaterec

    -- , match = match
    , super = super
    }


{-| Update all the components in a list and recursively update the components which have messenges sent.

Return a list of messages sent to the parentlayer.

-}
updateComponents : Env () -> List (Component a) -> ( List (Component a), List ComponentMsg, Env () )
updateComponents env =
    updateObjects recBody env


{-| Update all the components in a list with some tuples of target and msg, then recursively update the components which have messenges sent.

Return a list of messages sent to the parentlayer.

-}
updateComponentswithTarget : Env () -> List ( ComponentTarget, ComponentMsg ) -> List (Component a) -> ( List (Component a), List ComponentMsg, Env () )
updateComponentswithTarget env msg =
    updateObjectsWithTarget recBody env msg


{-| Generate the view of the components
-}
viewComponent : Env () -> List (Component a) -> Renderable
viewComponent env xs =
    group [] <| viewModelList env xs
