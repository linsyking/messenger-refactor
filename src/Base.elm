module Base exposing (..)

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode

type alias LocalStorage =
    { volume : Float
    , number : Int
    }


encodeLocalStorage : LocalStorage -> String
encodeLocalStorage storage =
    Encode.encode 0
        (Encode.object
            [ ( "volume", Encode.float storage.volume )
            , ( "number", Encode.int storage.number )
            ]
        )


decodeLocalStorage : String -> LocalStorage
decodeLocalStorage ls =
    let
        vol =
            Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) ls)

        number =
            Result.withDefault 0 (decodeString (at [ "number" ] Decode.int) ls)
    in
    LocalStorage vol number


type SceneMsg
    = Null
