module Lib.UserData exposing
    ( UserData
    , contextSetter
    , decodeUserData
    , encodeUserData
    , popLastScene
    )

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode
import Lib.Base exposing (SceneMsg)
import Messenger.Scene.Scene exposing (SceneContext)


type SceneStack
    = Roll (List (SceneContext UserData SceneMsg))


{-| UserData

`UserData` can store any data in the game.
Users can **save their own global data** and **implement local storage** here.

-}
type alias UserData =
    { sceneStack : SceneStack
    }


unroll : UserData -> List (SceneContext UserData SceneMsg)
unroll storage =
    case storage.sceneStack of
        Roll stack ->
            stack


popLastScene : UserData -> ( Maybe (SceneContext UserData SceneMsg), UserData )
popLastScene storage =
    case unroll storage of
        [] ->
            ( Nothing, storage )

        scene :: rest ->
            ( Just scene, { storage | sceneStack = Roll rest } )


contextSetter : SceneContext UserData SceneMsg -> UserData -> UserData
contextSetter context storage =
    { sceneStack = Roll <| context :: unroll storage
    }


{-| encodeUserData

encoder for the Userdata to store the data you want.

-}
encodeUserData : UserData -> String
encodeUserData storage =
    Encode.encode 0
        (Encode.object
            [--Aadd your data here
             -- Example:
             -- ( "volume", Encode.float storage.volume )
            ]
        )


{-| decodeUserData

decoder for the Userdata to get data from the storage.

-}
decodeUserData : String -> UserData
decodeUserData ls =
    -- Example:
    -- let
    --     vol =
    --         Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) ls)
    -- in
    { sceneStack = Roll []
    }
