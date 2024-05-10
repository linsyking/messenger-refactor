module Components.Portable.A exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractPortableComponent, ConcretePortableComponent, genComponent, translatePortableComponent)
import Messenger.GeneralModel exposing (Msg)
import Messenger.Scene.Scene exposing (SceneOutputMsg)
import Messenger.GeneralModel exposing (Msg(..))
import Messenger.GeneralModel exposing (MsgBase(..))
import Components.Portable.PTest exposing (..)


{-| Initializer
-}
init : Env () localstorage -> ComponentMsg -> Data
init env initMsg =
    {}


{-| Updater
-}
update : Env () localstorage -> WorldEvent -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), ( Env () localstorage, Bool ) )
update env evnt d =
    ( d, [], ( env, False ) )


updaterec : Env () localstorage -> ComponentMsg -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), Env () localstorage )
updaterec env msg d =
     case msg of
        IntMsg x ->
            let
                test =
                    Debug.log "A" x
            in
            ( d, [ Other "B" (IntMsg (x - 1)) , ( Parent <| OtherMsg <| IntMsg x) , ( Other "B" (IntMsg (x + 1) )) ], env )

        _ ->
            ( d, [], env )


{-| Renderer
-}
view : Env () localstorage -> Data -> ( Renderable, Int )
view env d =
    ( empty, 0 )


matcher : Data -> ComponentTarget -> Bool
matcher d tar =
    tar == "A"


pTestcon : ConcretePortableComponent Data localstorage ComponentTarget ComponentMsg
pTestcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Exported component
-}
pTest : Env () localstorage -> ComponentMsg -> AbstractPortableComponent localstorage ComponentTarget ComponentMsg
pTest =
    genComponent <| translatePortableComponent pTestcon
