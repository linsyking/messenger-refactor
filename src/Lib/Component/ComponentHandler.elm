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
import Lib.Component.Base exposing (Component, ComponentMsg, ComponentTarget(..))
import Lib.Env.Env exposing (Env, cleanEnv, patchEnv)
import Messenger.GeneralModel exposing (viewModelList)
import Messenger.Recursion exposing (RecBody)
import Messenger.RecursionList exposing (updateObjects, updateObjectsWithTarget)



-- Below are using the Recursion algorithm to get the update function


{-| RecUpdater
-}
updaterec : Component a -> Env () -> ComponentMsg -> ( Component a, List ( ComponentTarget, ComponentMsg ), Env () )
updaterec c env ct =
    let
        ( newx, newmsg, newenv ) =
            c.updaterec env ct c.data
    in
    ( { c | data = newx }, newmsg, newenv )


{-| Updater
-}
update : Component a -> Env () -> ( Component a, List ( ComponentTarget, ComponentMsg ), Env () )
update c env =
    let
        ( newx, newmsg, newenv ) =
            c.update env c.data
    in
    ( { c | data = newx }, newmsg, newenv )


{-| Matcher
-}
match : Component a -> ComponentTarget -> Bool
match c ct =
    case ct of
        Component Parent ->
            False

        Component (ID x) ->
            c.data.uid == x

        Component (Name x) ->
            c.name == x


{-| Super
-}
super : ComponentTarget -> Bool
super ct =
    case ct of
        Component Parent ->
            True

        Component _ ->
            False


{-| Rec body for the component
-}
recBody : RecBody (Component a) ComponentMsg (Env ()) ComponentTarget
recBody =
    { update = update
    , updaterec = updaterec
    , match = match
    , super = super
    , clean = cleanEnv
    , patch = patchEnv
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
