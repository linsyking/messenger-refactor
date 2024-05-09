module Messenger.Scene.Transitions.Base exposing
    ( Transition, SingleTrans
    , genTransition, nullTransition
    )

{-|


# Transition Base

@docs Transition, SingleTrans
@docs genTransition, nullTransition

-}

import Canvas exposing (Renderable)
import Messenger.Base exposing (GlobalData)


{-| Single Transition
-}
type alias SingleTrans a =
    GlobalData a -> Renderable -> Float -> Renderable


{-| Null Transition
-}
nullTransition : SingleTrans a
nullTransition _ r _ =
    r


{-| Transition has three stages:

1.  From the old scene to the transition scene
2.  Transition scene
3.  From the transition scene to the new scene

-}
type alias Transition a =
    { currentTransition : Int
    , outT : Int
    , inT : Int
    , fadeout : SingleTrans a
    , fadein : SingleTrans a
    }


{-| Generate new transition
-}
genTransition : Int -> Int -> SingleTrans a -> SingleTrans a -> Transition a
genTransition outT inT fadeout fadein =
    { currentTransition = 0
    , outT = outT
    , inT = inT
    , fadeout = fadeout
    , fadein = fadein
    }
