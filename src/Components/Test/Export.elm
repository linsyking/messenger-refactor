module Components.Test.Export exposing (initComponent)

{-| Component Export

Write a description here for how to use your component.

@docs initComponent

-}

import Canvas exposing (Renderable)
import Components.ComponentSettings exposing (ComponentT, ComponentType(..), TestData, nullTestData)
import Components.Test.Test exposing (initModel, updateModel, updateModelRec, viewModel)
import Lib.Component.Base exposing (ComponentInitData(..), ComponentMsg, ComponentTarget, DatawithID, addID)
import Lib.Env.Env exposing (Env)


{-| datatoCT
-}
datatoCT : TestData -> ComponentType
datatoCT dt =
    CTestData dt


{-| cttoData
-}
cttoData : ComponentType -> TestData
cttoData ct =
    case ct of
        CTestData x ->
            x

        _ ->
            nullTestData


{-| initComponent
Write a description here for how to initialize your component.
-}
initComponent : Env () -> ComponentInitData -> ComponentT
initComponent e i =
    let
        ( id, ni ) =
            case i of
                ComponentID n ii ->
                    ( n, ii )

                _ ->
                    ( 0, i )

        dt =
            addID id <| datatoCT <| initModel e ni

        upd : Env () -> DatawithID ComponentType -> ( DatawithID ComponentType, List ( ComponentTarget, ComponentMsg ), Env () )
        upd env dtid =
            let
                ( rldt, newmsg, newenv ) =
                    updateModel env <| cttoData dtid.otherdata
            in
            ( addID dtid.uid <| datatoCT rldt, newmsg, newenv )

        updrec : Env () -> ComponentMsg -> DatawithID ComponentType -> ( DatawithID ComponentType, List ( ComponentTarget, ComponentMsg ), Env () )
        updrec env cm dtid =
            let
                ( rldt, newmsg, newenv ) =
                    updateModelRec env cm <| cttoData dtid.otherdata
            in
            ( addID dtid.uid <| datatoCT rldt, newmsg, newenv )

        v : Env () -> DatawithID ComponentType -> Renderable
        v env dtid =
            viewModel env <| cttoData dtid.otherdata
    in
    { name = "Test"
    , data = dt
    , update = upd
    , updaterec = updrec
    , view = v
    }
