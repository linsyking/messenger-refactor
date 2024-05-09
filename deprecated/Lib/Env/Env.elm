module Lib.Env.Env exposing
    ( Env
    , noCommonData, addCommonData
    )

{-|


# Env

Provide type support for environment variables.

@docs Env
@docs noCommonData, addCommonData
@docs cleanEnv
@docs patchEnv

-}

import Base exposing (GlobalData, Msg(..))


{-| Normal environment with extra common data.
-}
type alias Env b =
    { globalData : GlobalData
    , t : Int
    , commonData : b
    }


{-| Remove common data from environment.

Useful when sending message to a component.

-}
noCommonData : Env b -> Env ()
noCommonData env =
    { globalData = env.globalData
    , t = env.t
    , commonData = ()
    }


{-| Add the common data back.
-}
addCommonData : b -> Env () -> Env b
addCommonData commonData env =
    { globalData = env.globalData
    , t = env.t
    , commonData = commonData
    }
