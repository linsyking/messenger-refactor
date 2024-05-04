module Base exposing
    ( Msg(..)
    , GlobalData
    , Flags
    , LSInfo
    , ObjectTarget(..)
    )

{-| Base module

WARNING: This file should have no dependencies

Otherwise it will cause import-cycles

I storage TMsg here that every scene can use it to transmit data, however, those data can only be Int, Float, Strong, etc.

This message is the GLOBAL scope message. This message limits what messsages you can get inside a scene.

@docs Msg
@docs GlobalData
@docs Flags
@docs LSInfo
@docs ObjectTarget

-}

import Audio
import Browser.Events exposing (Visibility)
import Canvas.Texture exposing (Texture)
import Dict exposing (Dict)
import Html exposing (Html)
import Lib.Audio.Base exposing (AudioOption)
import Time


{-| Msg

This is the msg data for main.

`Tick` records the time.

`KeyDown`, `KeyUp` records the keyboard events

`MouseWheel` records the wheel event for mouse, it can be also used for touchpad

-}
type Msg
    = Tick Time.Posix
    | KeyDown Int
    | KeyUp Int
    | NewWindowSize ( Float, Float )
    | WindowVisibility Visibility
    | SoundLoaded String AudioOption (Result Audio.LoadError Audio.Source)
    | PlaySoundGotTime String AudioOption Audio.Source Time.Posix
    | TextureLoaded String (Maybe Texture)
    | MouseDown Int ( Float, Float )
    | MouseUp ( Float, Float )
    | MouseMove ( Float, Float )
    | MouseWheel Int
    | Prompt String String
    | NullMsg


{-| GlobalData

GD is the data that doesn't change during the game.

It won't be reset if you change the scene.

It is mainly used for display and reading/writing some localstorage data.

`browserViewPort` records the browser size.

`sprites` records all the sprites(images).

`localstorage` records the data that we save in localstorage.

`extraHTML` is used to render extra HTML tags. Be careful to use this.

`windowVisibility` records whether users stay in this tab/window

-}
type alias GlobalData =
    { internalData : InternalData
    , sceneStartTime : Int
    , currentTimeStamp : Time.Posix
    , windowVisibility : Visibility
    , mousePos : ( Float, Float )
    , extraHTML : Maybe (Html Msg)
    , localStorage : LSInfo
    , currentScene : String
    }


type alias InternalData =
    { browserViewPort : ( Float, Float )
    , realWidth : Float
    , realHeight : Float
    , startLeft : Float
    , startTop : Float
    , sprites : Dict String Texture
    }


{-| LSInfo

LocalStorage data

ADD your own localstorage info here.

-}
type alias LSInfo =
    { volume : Float
    }


{-| Flags

The main flags.

Get info from js script

-}
type alias Flags =
    { windowWidth : Float
    , windowHeight : Float
    , timeStamp : Int
    , info : String
    }


type ObjectTarget
    = Parent
    | Name String
    | ID Int
