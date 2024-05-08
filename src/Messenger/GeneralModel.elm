module Messenger.GeneralModel exposing
    ( GeneralModel
    , viewModelList, viewModelArray
    , AbsGeneralModel(..), UnrolledAbsGeneralModel, abstract, unroll
    )

{-|


# General Model

General model is designed to be an abstract interface of scenes, layers, components, game components, etc..

  - a: data type
  - b: environment type
  - c: message type
  - d: target type
  - e: render type
  - f: event type

@docs GeneralModel
@docs viewModelList, viewModelArray

-}

import Array exposing (Array)


{-| General Model.

This has a name field.

-}
type alias GeneralModel a b c d e f =
    { name : String
    , data : a
    , update : b -> f -> a -> ( a, List ( d, c ), b )
    , updaterec : b -> c -> a -> ( a, List ( d, c ), b )
    , view : b -> a -> e
    }


type alias UnrolledAbsGeneralModel b c d e f =
    { name : String
    , update : b -> f -> ( AbsGeneralModel b c d e f, List ( d, c ), b )
    , updaterec : b -> c -> ( AbsGeneralModel b c d e f, List ( d, c ), b )
    , view : b -> e
    }


type AbsGeneralModel b c d e f
    = Roll (UnrolledAbsGeneralModel b c d e f)


unroll : AbsGeneralModel b c d e f -> UnrolledAbsGeneralModel b c d e f
unroll (Roll un) =
    un


abstract : GeneralModel a b c d e f -> AbsGeneralModel b c d e f
abstract model =
    let
        update env evt =
            let
                ( newData, newMsg, newEnv ) =
                    model.update env evt model.data
            in
            ( abstract { model | data = newData }, newMsg, newEnv )

        updaterec env msg =
            let
                ( newData, newMsg, newEnv ) =
                    model.updaterec env msg model.data
            in
            ( abstract { model | data = newData }, newMsg, newEnv )

        view env =
            model.view env model.data
    in
    Roll
        { name = model.name
        , update = update
        , updaterec = updaterec
        , view = view
        }


{-| View model list.
-}
viewModelList : b -> List (AbsGeneralModel b c d e f) -> List e
viewModelList env models =
    List.map (\model -> (unroll model).view env) models


{-| View model array.
-}
viewModelArray : b -> Array (AbsGeneralModel b c d e f) -> List e
viewModelArray env models =
    Array.toList models
        |> List.map (\model -> (unroll model).view env)
