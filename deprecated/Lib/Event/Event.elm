module Lib.Event.Event exposing (..)

import Base
import Time


type Event
    = Tick Time.Posix
    | KeyDown Int
    | KeyUp Int
    | MouseDown Int ( Float, Float )
    | MouseUp ( Float, Float )
    | MouseWheel Int
    | NullEvent


event : Base.Msg -> Event
event msg =
    case msg of
        Base.Tick t ->
            Tick t

        Base.KeyDown code ->
            KeyDown code

        Base.KeyUp code ->
            KeyUp code

        Base.MouseWheel n ->
            MouseWheel n

        _ ->
            NullEvent



-- cleanEnv : Env a -> Env a
-- cleanEnv env =
--     { env | msg = NullMsg }
-- patchEnv : Env a -> Env a -> Env a
-- patchEnv old new =
--     { new | msg = old.msg }
