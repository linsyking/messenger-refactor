module Scenes.Home.UserLayers exposing (..)

import Lib.Layer.Base exposing (AbsLayer, GeneralLayer, LayerMsg)
import Messenger.GeneralModel exposing (AbsGeneralModel(..))



-- a is user defined msg, b is user defined init data


type alias UserLayerTr a =
    { userLayerD : LayerMsg -> Maybe a
    , userLayerE : a -> LayerMsg
    }


genLayer : GeneralLayer a b c -> UserLayerTr c -> AbsLayer b
genLayer gly { userLayerD, userLayerE } =
    let
        genLayerRec ly =
            let
                updates env evt =
                    let
                        ( new_ly, new_msg, new_env ) =
                            gly.update env evt ly
                    in
                    ( genLayerRec new_ly, List.map (\( t, m ) -> ( t, userLayerE m )) new_msg, new_env )

                updaterecs env msg =
                    let
                        transferred =
                            userLayerD msg
                    in
                    case transferred of
                        Nothing ->
                            ( genLayerRec ly, [], env )

                        Just ok_msg ->
                            let
                                ( new_ly, new_msg, new_env ) =
                                    gly.updaterec env ok_msg ly
                            in
                            ( genLayerRec new_ly, List.map (\( t, m ) -> ( t, userLayerE m )) new_msg, new_env )

                views env =
                    gly.view env ly
            in
            Roll
                { name = gly.name
                , update = updates
                , updaterec = updaterecs
                , view = views
                }
    in
    genLayerRec gly.data
