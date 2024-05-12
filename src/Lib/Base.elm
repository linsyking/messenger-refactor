module Lib.Base exposing (..)

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode


type alias UserData =
    { volume : Float
    , number : Int
    }


encodeUserData : UserData -> String
encodeUserData storage =
    Encode.encode 0
        (Encode.object
            [ ( "volume", Encode.float storage.volume )
            , ( "number", Encode.int storage.number )
            ]
        )


decodeUserData : String -> UserData
decodeUserData ls =
    let
        vol =
            Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) ls)

        number =
            Result.withDefault 0 (decodeString (at [ "number" ] Decode.int) ls)
    in
    UserData vol number


type SceneMsg
    = Null
