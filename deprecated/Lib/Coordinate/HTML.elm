module Lib.Coordinate.HTML exposing (genAttribute)

{-|


# HTML Coordinate Lib

This is only useful when you use extraHTML.

@docs genAttribute

-}

import Base exposing (GlobalData)
import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Lib.Coordinate.Coordinates exposing (fixedPosToReal, lengthToReal)


{-| Generate HTML Attributes that has the correct position
-}
genAttribute : GlobalData -> ( Float, Float ) -> ( Float, Float ) -> List (Attribute msg)
genAttribute gd ( x, y ) ( w, h ) =
    let
        ( rx, ry ) =
            fixedPosToReal gd ( x, y )

        ( rw, rh ) =
            ( lengthToReal gd w, lengthToReal gd h )
    in
    [ style "position" "fixed"
    , style "left" (String.fromFloat rx ++ "px")
    , style "top" (String.fromFloat ry ++ "px")
    , style "width" (String.fromFloat rw ++ "px")
    , style "height" (String.fromFloat rh ++ "px")
    ]
