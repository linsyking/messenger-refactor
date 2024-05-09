module Components.UserComponents.Test exposing (..)

{-| Component specific data
-}

import Canvas exposing (Renderable, empty)
import Components.UserComponents.UserCompMsg exposing (Msg(..), Target, UTarget(..))
import Lib.Component.Base exposing (Component, TargetBase(..), genComp)
import Lib.Env.Env exposing (Env)
import Lib.Event.Event exposing (Event)
import Scenes.Home.LayerBase as Home


type alias Data =
    String


{-| Initializer
-}
initData : Env Home.CommonData -> Msg -> Data
initData env init =
    case init of
        Init data ->
            data.val

        _ ->
            ""


{-| Updater
-}
update : Env Home.CommonData -> Event -> Data -> ( Data, List ( Target, Msg ), Env Home.CommonData )
update env evnt d =
    ( d, [], env )


updaterec : Env Home.CommonData -> Msg -> Data -> ( Data, List ( Target, Msg ), Env Home.CommonData )
updaterec env msg d =
    ( d, [], env )


{-| Renderer
-}
view : Env Home.CommonData -> Data -> Renderable
view env d =
    empty


matcher : Data -> Target -> Bool
matcher d tar =
    case tar of
        Other (Name _) ->
            True

        _ ->
            False


{-| Exported component
-}
comp : Env Home.CommonData -> Msg -> Component (Env Home.CommonData) Event Target Msg Renderable
comp =
    genComp
        { init = initData
        , update = update
        , updaterec = updaterec
        , view = view
        , matcher = matcher
        }



-- decode : ComponentMsg -> Maybe UserCompMsg.Msg
-- decode msg =
--     case msg of
--         UserCompMsg m ->
--             Just m
--         _ ->
--             Nothing
-- encode : UserCompMsg.Msg -> ComponentMsg
-- encode msg =
--     case msg of
--         UserCompMsg.SOM m ->
--             SOM m
--         _ ->
--             OtherMsg
