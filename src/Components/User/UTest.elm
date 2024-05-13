module Components.User.UTest exposing (..)

import Canvas exposing (Renderable, empty)
import Components.User.Base exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, UserEvent)
import Messenger.Component.Component exposing (AbstractComponent, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg)
import Messenger.Scene.Scene exposing (SceneOutputMsg)
import Scenes.Main.LayerBase exposing (SceneCommonData)


type alias Data =
    String


{-| Initializer
-}
init : Env SceneCommonData UserData -> ComponentMsg -> ( Data, BaseData )
init env initMsg =
    case initMsg of
        Init v ->
            ( v.initVal, v.initBase )

        _ ->
            ( "", 0 )


{-| Updater
-}
update : Env SceneCommonData UserData -> UserEvent -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg ComponentTarget ComponentMsg (SceneOutputMsg SceneMsg UserData)), ( Env SceneCommonData UserData, Bool ) )
update env evnt d bd =
    ( ( d, bd ), [], ( env, False ) )


updaterec : Env SceneCommonData UserData -> ComponentMsg -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg ComponentTarget ComponentMsg (SceneOutputMsg SceneMsg UserData)), Env SceneCommonData UserData )
updaterec env msg d bd =
    ( ( d, bd ), [], env )


{-| Renderer
-}
view : Env SceneCommonData UserData -> Data -> BaseData -> ( Renderable, Int )
view env d bd =
    let
        _ =
            -- (hello, 1)
            Debug.log "uTest" ( d, bd )
    in
    ( empty, 0 )


matcher : Data -> BaseData -> ComponentTarget -> Bool
matcher d bd tar =
    tar == "portable"


uTestcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
uTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
uTest : Env SceneCommonData UserData -> ComponentMsg -> AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
uTest =
    genComponent uTestcon
