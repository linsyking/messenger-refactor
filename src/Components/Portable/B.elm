module Components.Portable.B exposing (..)

import Canvas exposing (Renderable, empty)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.Component.Component exposing (AbstractPortableComponent, ConcretePortableComponent, genComponent, translatePortableComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg)
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
    if env.globalData.globalTime == 0 then
        ( d, [Parent <| OtherMsg <| IntMsg 100 , Other "A" (IntMsg 3) ], (env, False) )

    else
        ( d, [], (env, False) )


updaterec : Env () localstorage -> ComponentMsg -> Data -> ( Data, List (Msg ComponentTarget ComponentMsg (SceneOutputMsg () localstorage)), Env () localstorage )
updaterec env msg d =
    case msg of
        IntMsg x ->
            let
                test =
                    Debug.log "B" x
            in
            if x > 0 && x < 10 then
                ( d, [ Other "A" (IntMsg (x * 2)), Parent <| OtherMsg <| IntMsg -100, Other "B" (IntMsg (x * 3)) ], env )

            else
                ( d, [], env )

        _ ->
            ( d, [], env )


{-| Renderer
-}
view : Env () localstorage -> Data -> ( Renderable, Int )
view env d =
    ( empty, 0 )


matcher : Data -> ComponentTarget -> Bool
matcher d tar =
    tar == "B"


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
