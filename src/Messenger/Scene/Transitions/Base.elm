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
type alias SingleTrans =
    GlobalData Never -> Renderable -> Float -> Renderable


{-| Null Transition
-}
nullTransition : SingleTrans
nullTransition _ r _ =
    r


{-| Transition has three stages:

1.  From the old scene to the transition scene
2.  Transition scene
3.  From the transition scene to the new scene

-}
type alias Transition =
    { currentTransition : Int
    , outT : Int
    , inT : Int
    , fadeout : SingleTrans
    , fadein : SingleTrans
    }


{-| Generate new transition
-}
genTransition : Int -> Int -> SingleTrans -> SingleTrans -> Transition
genTransition outT inT fadeout fadein =
    { currentTransition = 0
    , outT = outT
    , inT = inT
    , fadeout = fadeout
    , fadein = fadein
    }
