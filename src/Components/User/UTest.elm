module Components.User.UTest exposing (..)

import Base exposing (LocalStorage, SceneMsg)
import Canvas exposing (Renderable, empty)
import Components.User.Base exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Messenger.Base exposing (Env, WorldEvent)
import Messenger.Component.Component exposing (AbstractComponent, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg)
import Messenger.Scene.Scene exposing (SceneOutputMsg)
import Scenes.Main.LayerBase exposing (SceneCommonData)


type alias Data =
    String


{-| Initializer
-}
init : Env SceneCommonData LocalStorage -> ComponentMsg -> ( Data, BaseData )
init env initMsg =
    case initMsg of
        Init v ->
            ( v.initVal, v.initBase )

        _ ->
            ( "", 0 )


{-| Updater
-}
update : Env SceneCommonData LocalStorage -> WorldEvent -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg ComponentTarget ComponentMsg (SceneOutputMsg SceneMsg LocalStorage)), ( Env SceneCommonData LocalStorage, Bool ) )
update env evnt d bd =
    ( ( d, bd ), [], ( env, False ) )


updaterec : Env SceneCommonData LocalStorage -> ComponentMsg -> Data -> BaseData -> ( ( Data, BaseData ), List (Msg ComponentTarget ComponentMsg (SceneOutputMsg SceneMsg LocalStorage)), Env SceneCommonData LocalStorage )
updaterec env msg d bd =
    ( ( d, bd ), [], env )


{-| Renderer
-}
view : Env SceneCommonData LocalStorage -> Data -> BaseData -> ( Renderable, Int )
view env d bd =
    ( empty, 0 )


matcher : Data -> BaseData -> ComponentTarget -> Bool
matcher d bd tar =
    tar == "portable"


uTestcon : ConcreteUserComponent Data SceneCommonData LocalStorage ComponentTarget ComponentMsg BaseData SceneMsg
uTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
uTest : Env SceneCommonData LocalStorage -> ComponentMsg -> AbstractComponent SceneCommonData LocalStorage ComponentTarget ComponentMsg BaseData SceneMsg
uTest =
    genComponent uTestcon
