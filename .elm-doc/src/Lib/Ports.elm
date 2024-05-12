module Lib.Ports exposing
    ( audioPortFromJS, audioPortToJS
    , alert, prompt, promptReceiver, sendInfo
    )

{-|


# Ports

The ports that will be used in the game.

@docs audioPortFromJS, audioPortToJS
@docs alert, prompt, promptReceiver, sendInfo

-}

import Json.Decode as Decode
import Json.Encode as Encode


{-| Port to send user data
-}
sendInfo : String -> Cmd msg
sendInfo a0 = Cmd.none


{-| Port used by audio system
-}
audioPortToJS : Encode.Value -> Cmd msg
audioPortToJS a0 = Cmd.none


{-| Port used by audio system
-}
audioPortFromJS : (Decode.Value -> msg) -> Sub msg
audioPortFromJS a0 = Sub.none


{-| Port to alert
-}
alert : String -> Cmd msg
alert a0 = Cmd.none


{-| Port to prompt
-}
prompt : { name : String, title : String } -> Cmd msg
prompt a0 = Cmd.none


{-| Port to receive prompt
-}
promptReceiver : ({ name : String, result : String } -> msg) -> Sub msg
promptReceiver a0 = Sub.none
