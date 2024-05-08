module Lib.Component.Base exposing (..)

{-|


# Component

Component is designed to have the best flexibility and compability.

You can use component almost anywhere, in layers, in gamecomponents and components themselves.

You have to manually add components in your layer and update them manually.

It is **not** fast to communicate between many components.

Gamecomponents have better speed when communicating with each other. (their message types are built-in)

-}

import Base exposing (ObjectTarget)
import Canvas exposing (Renderable)
import Lib.Env.Env exposing (Env)
import Lib.Scene.Base exposing (MsgBase)
import Messenger.GeneralModel exposing (GeneralModel)


{-| Component

The data entry doesn't have a fixed type, you can use any type you want.

Though this is flexible, it is not convenient to use sometimes.

If your object has many properties that are in common, you should create your own component type.

Examples are [GameComponent](https://github.com/linsyking/Reweave/blob/master/src/Lib/CoreEngine/GameComponent/Base.elm) which has a lot of game related properties.

-}
type TargetBase othertar
    = Parent
    | Other othertar



-- type alias Component env event tar msg ren =
--     TComponent env event (TargetBase tar) msg ren


type Component env event tar msg ren
    = Unroll
        { update : env -> event -> ( Component env event tar msg ren, List ( tar, msg ), env )
        , updaterec : env -> msg -> ( Component env event tar msg ren, List ( tar, msg ), env )
        , view : env -> ren
        , matcher : tar -> Bool
        }


type alias ConcreteComponent data env event tar msg ren =
    { init : env -> msg -> data
    , update : env -> event -> data -> ( data, List ( tar, msg ), env )
    , updaterec : env -> msg -> data -> ( data, List ( tar, msg ), env )
    , view : env -> data -> ren
    , matcher : data -> tar -> Bool
    }



-- type alias ComponentMsg =
--     MsgBase ComponentMsg_
-- type ComponentMsg_
--     = ComponentStringMsg String
--     | ComponentIntMsg Int
--     | ComponentFloatMsg Float
--     | ComponentBoolMsg Bool
--     | ComponentStringDataMsg String ComponentMsg_
--     | ComponentListMsg (List ComponentMsg_)
--     | ComponentComponentTargetMsg ComponentTarget
--     | ComponentNamedMsg ComponentTarget ComponentMsg_
--     | NullComponentMsg
-- TODO: Self


genComp : ConcreteComponent data env event tar msg ren -> env -> msg -> Component env event tar msg ren
genComp concomp initEnv initMsg =
    let
        genCompRec : data -> Component env event tar msg ren
        genCompRec data =
            let
                updates : env -> event -> ( Component env event tar msg ren, List ( tar, msg ), env )
                updates env event =
                    let
                        ( new_d, new_m, new_e ) =
                            concomp.update env event data
                    in
                    ( genCompRec new_d, new_m, new_e )

                updaterecs : env -> msg -> ( Component env event tar msg ren, List ( tar, msg ), env )
                updaterecs env msg =
                    let
                        ( new_d, new_m, new_e ) =
                            concomp.updaterec env msg data
                    in
                    ( genCompRec new_d, new_m, new_e )

                views : env -> ren
                views env =
                    concomp.view env data

                matchers : tar -> Bool
                matchers =
                    concomp.matcher data
            in
            Unroll
                { update = updates
                , updaterec = updaterecs
                , view = views
                , matcher = matchers
                }
    in
    genCompRec (concomp.init initEnv initMsg)
