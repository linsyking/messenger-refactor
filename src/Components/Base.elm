module Components.Base exposing (..)

-- import Base exposing (ObjectTarget)
-- import Components.PortableComponents.Portable as Portable
-- import Components.UserComponents.UserCompMsg as UserCompMsg
-- import Lib.Scene.Base exposing (SceneOutputMsg)
-- {-| User defined component message type
-- -}
-- type ComponentMsg
--     = PortableCompMsg Portable.Msg
--     | UserCompMsg UserCompMsg.Msg
--     | SOM SceneOutputMsg
--     | OtherMsg
-- {-| Transfer function: From user defined message to component self-defined message
-- -}
-- portableMsgDecoder : ComponentMsg -> Maybe Portable.Msg
-- portableMsgDecoder msg =
--     case msg of
--         PortableCompMsg m ->
--             Just m
--         _ ->
--             Nothing
-- portableMsgEncoder : Portable.Msg -> ComponentMsg
-- portableMsgEncoder msg =
--     case msg of
--         Portable.SOM m ->
--             SOM m
--         other ->
--             PortableCompMsg other
