port module Lib.Ports exposing
    ( audioPortFromJS, audioPortToJS, prompt, promptReceiver, sendInfo
    , alert
    )

{-|


# Ports

The ports that will be used in the game.

@docs lert, audioPortFromJS, audioPortToJS, prompt, promptReceiver, sendInfo

-}

import Json.Decode as Decode
import Json.Encode as Encode


port sendInfo : String -> Cmd msg


port audioPortToJS : Encode.Value -> Cmd msg


port audioPortFromJS : (Decode.Value -> msg) -> Sub msg


port alert : String -> Cmd msg


port prompt : { name : String, title : String } -> Cmd msg


port promptReceiver : ({ name : String, result : String } -> msg) -> Sub msg
