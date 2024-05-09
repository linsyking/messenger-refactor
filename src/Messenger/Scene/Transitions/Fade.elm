module Messenger.Scene.Transitions.Fade exposing
    ( fadeIn, fadeOut
    , fadeOutBlack, fadeInBlack
    , fadeOutWithRenderable, fadeInWithRenderable
    )

{-| Fading Effects

@docs fadeIn, fadeOut
@docs fadeOutBlack, fadeInBlack
@docs fadeOutWithRenderable, fadeInWithRenderable

-}

import Canvas exposing (Renderable, group, shapes)
import Canvas.Settings exposing (fill)
import Canvas.Settings.Advanced exposing (alpha)
import Color exposing (Color)
import Messenger.Render.Shape exposing (rect)
import Messenger.Scene.Transitions.Base exposing (SingleTrans)


{-| Fade Out with Color
-}
fadeOut : Color -> SingleTrans a
fadeOut color gd rd v =
    group []
        [ rd
        , shapes [ fill color, alpha v ]
            [ rect gd ( 0, 0 ) ( gd.internalData.virtualWidth, gd.internalData.virtualHeight )
            ]
        ]


{-| Fade In with Color
-}
fadeIn : Color -> SingleTrans a
fadeIn color gd rd v =
    group []
        [ rd
        , shapes [ fill color, alpha (1 - v) ]
            [ rect gd ( 0, 0 ) ( gd.internalData.virtualWidth, gd.internalData.virtualHeight )
            ]
        ]


{-| Fade Out with Black
-}
fadeOutBlack : SingleTrans a
fadeOutBlack =
    fadeOut Color.black


{-| Fade In with Black
-}
fadeInBlack : SingleTrans a
fadeInBlack =
    fadeIn Color.black


{-| Fade Out with Renderable
-}
fadeOutWithRenderable : Renderable -> SingleTrans a
fadeOutWithRenderable renderable _ rd v =
    group []
        [ rd
        , group [ alpha v ]
            [ renderable
            ]
        ]


{-| Fade In with Renderable
-}
fadeInWithRenderable : Renderable -> SingleTrans a
fadeInWithRenderable renderable _ rd v =
    group []
        [ rd
        , group [ alpha (1 - v) ]
            [ renderable
            ]
        ]
