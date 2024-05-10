module Messenger.UI.Subscription exposing (..)

import Audio exposing (AudioData)
import Browser.Events exposing (onKeyDown, onKeyUp, onMouseDown, onMouseMove, onMouseUp, onResize, onVisibilityChange)
import Json.Decode as Decode
import Messenger.Base exposing (WorldEvent(..))
import Messenger.Model exposing (Model)
import Messenger.Tools.Browser exposing (promptReceiver)
import Messenger.UserConfig exposing (UserConfig)
import Time


subscriptions : UserConfig localstorage scenemsg -> AudioData -> Model localstorage scenemsg -> Sub WorldEvent
subscriptions config _ _ =
    Sub.batch
        [ Time.every config.timeInterval Tick --- Slow down the fps
        , onKeyDown
            (Decode.map2
                (\x rep ->
                    if not rep then
                        KeyDown x

                    else
                        NullEvent
                )
                (Decode.field "keyCode" Decode.int)
                (Decode.field "repeat" Decode.bool)
            )
        , onKeyUp
            (Decode.map2
                (\x rep ->
                    if not rep then
                        KeyUp x

                    else
                        NullEvent
                )
                (Decode.field "keyCode" Decode.int)
                (Decode.field "repeat" Decode.bool)
            )
        , onResize (\w h -> NewWindowSize ( toFloat w, toFloat h ))
        , onVisibilityChange (\v -> WindowVisibility v)
        , onMouseDown (Decode.map3 (\b x y -> MouseDown b ( x, y )) (Decode.field "button" Decode.int) (Decode.field "clientX" Decode.float) (Decode.field "clientY" Decode.float))
        , onMouseUp (Decode.map2 (\x y -> MouseUp ( x, y )) (Decode.field "clientX" Decode.float) (Decode.field "clientY" Decode.float))
        , onMouseMove (Decode.map2 (\x y -> MouseMove ( x, y )) (Decode.field "clientX" Decode.float) (Decode.field "clientY" Decode.float))
        , promptReceiver (\p -> Prompt p.name p.result)
        ]
