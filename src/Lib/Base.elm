module Lib.Base exposing
    ( UserData
    , encodeUserData, decodeUserData
    , SceneMsg(..)
    )

{-|


# Base

Base module for the game. Set the UserData and SceneMsg here.

@docs UserData
@docs encodeUserData, decodeUserData
@docs SceneMsg

-}

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode


{-| UserData

`UserData` can store any data in the game.
Users can **save their own global data** and **implement local storage** here.

-}
type alias UserData =
    { volume : Float
    , number : Int
    }


{-| encodeUserData

encoder for the Userdata to store the data you want.

-}
encodeUserData : UserData -> String
encodeUserData storage =
    Encode.encode 0
        (Encode.object
            [ ( "volume", Encode.float storage.volume )
            , ( "number", Encode.int storage.number )
            ]
        )


{-| decodeUserData

decoder for the Userdata to get data from the storage.

-}
decodeUserData : String -> UserData
decodeUserData ls =
    let
        vol =
            Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) ls)

        number =
            Result.withDefault 0 (decodeString (at [ "number" ] Decode.int) ls)
    in
    UserData vol number


{-| SceneMsg

`SceneMsg` represents the message type users wants
to send to a scene when switching scenes.

-}
type SceneMsg
    = Null
