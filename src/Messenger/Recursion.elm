module Messenger.Recursion exposing
    ( Updater, Matcher, Super
    , RecBody
    )

{-|


# Recursion

This module provides the signature for the updater

@docs Updater, Matcher, Super, Cleaner, Patcher
@docs RecBody

-}


{-| The updater
a: message sender (object)
b: message
c: environment messages
d: target
e: event
-}
type alias Updater a b c d e =
    a -> c -> e -> ( a, List ( d, b ), c )


{-| The recursive updater
-}
type alias RecUpdater a b c d =
    a -> c -> b -> ( a, List ( d, b ), c )


{-| Return true if the target is the sender (second argument)
-}
type alias Matcher a d =
    a -> d -> Bool


{-| Return true if the target is the parent
-}
type alias Super d =
    d -> Bool



-- {-| Clean the environment
-- -}
-- type alias Cleaner c =
--     c -> c
-- {-| Patch the environment
-- -}
-- type alias Patcher c =
--     c -> c -> c


{-| RecBody type.

Pass this as an argument to the updater

-}
type alias RecBody a b c d e =
    { update : Updater a b c d e
    , updaterec : RecUpdater a b c d
    , match : Matcher a d
    , super : Super d
    }
