module Messenger.UI.Update exposing (..)

{-| This is the update function for updating the model.

If you add some SceneOutputMsg, you have to add corresponding updating logic here.

-}

import Audio exposing (AudioCmd, AudioData)
import Dict
import Messenger.Audio.Audio exposing (stopAudio)
import Messenger.Base exposing (Env, WorldEvent(..))
import Messenger.LocalStorage exposing (sendInfo)
import Messenger.Model exposing (Model, resetSceneStartTime, updateSceneTime)
import Messenger.Scene.Loader exposing (SceneStorage, loadSceneByName)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..), unroll)
import Messenger.Tools.Browser exposing (alert, prompt)
import Messenger.UserConfig exposing (UserConfig)


gameUpdate : UserConfig localstorage scenemsg -> List ( String, SceneStorage localstorage scenemsg ) -> WorldEvent -> Model localstorage scenemsg -> ( Model localstorage scenemsg, Cmd WorldEvent, AudioCmd WorldEvent )
gameUpdate config scenes evnt model =
    if List.length (Dict.keys model.currentGlobalData.internalData.sprites) < List.length config.allTexture then
        -- Still loading assets
        ( model, Cmd.none, Audio.cmdNone )

    else
        let
            oldLocalStorage =
                model.currentGlobalData.localStorage

            ( sdt, som, newenv ) =
                (unroll model.currentScene).update (Env model.currentGlobalData ()) evnt

            updatedModel1 =
                { model | currentGlobalData = newenv.globalData, currentScene = sdt }

            timeUpdatedModel =
                case evnt of
                    Tick _ ->
                        -- Tick event needs to update time
                        updateSceneTime updatedModel1

                    _ ->
                        updatedModel1

            ( updatedModel2, cmds, audiocmds ) =
                List.foldl
                    (\singleSOM ( lastModel, lastCmds, lastAudioCmds ) ->
                        case singleSOM of
                            SOMChangeScene ( tm, name, Nothing ) ->
                                --- Load new scene
                                ( loadSceneByName name scenes tm lastModel
                                    |> resetSceneStartTime
                                , lastCmds
                                , lastAudioCmds
                                )

                            SOMChangeScene ( tm, s, Just trans ) ->
                                --- Delayed Loading
                                ( { lastModel | transition = Just ( trans, ( s, tm ) ) }
                                , lastCmds
                                , lastAudioCmds
                                )

                            SOMPlayAudio name path opt ->
                                ( lastModel, lastCmds, lastAudioCmds ++ [ Audio.loadAudio (SoundLoaded name opt) path ] )

                            SOMSetVolume s ->
                                let
                                    oldgd =
                                        lastModel.currentGlobalData

                                    newgd2 =
                                        { oldgd | volume = s }
                                in
                                ( { lastModel | currentGlobalData = newgd2 }, lastCmds, lastAudioCmds )

                            SOMStopAudio name ->
                                ( { lastModel | audiorepo = stopAudio lastModel.audiorepo name }, lastCmds, lastAudioCmds )

                            SOMAlert text ->
                                ( lastModel, lastCmds ++ [ alert text ], lastAudioCmds )

                            SOMPrompt name title ->
                                ( lastModel, lastCmds ++ [ prompt { name = name, title = title } ], lastAudioCmds )
                    )
                    ( timeUpdatedModel, [], [] )
                    som

            updatedModel3 =
                case updatedModel2.transition of
                    Just ( trans, ( name, tm ) ) ->
                        if trans.currentTransition == trans.outT then
                            loadSceneByName name scenes tm updatedModel2
                                |> resetSceneStartTime

                        else
                            updatedModel2

                    Nothing ->
                        updatedModel2
        in
        ( updatedModel3
        , Cmd.batch <|
            if updatedModel3.currentGlobalData.localStorage /= oldLocalStorage then
                -- Save local storage
                sendInfo (config.localStorageCodec.encode updatedModel3.currentGlobalData.localStorage) :: cmds

            else
                cmds
        , Audio.cmdBatch audiocmds
        )


{-| update : AudioData -> WorldEvent -> Model localstorage scenemsg -> ( Model localstorage scenemsg, Cmd WorldEvent, AudioCmd WorldEvent )
update \_ msg model =
let
gd =
model.currentGlobalData
in
case msg of
TextureLoaded name Nothing ->
( model, alert ("Failed to load sprite " ++ name), Audio.cmdNone )

        TextureLoaded name (Just t) ->
            let
                newgd =
                    case Dict.get name allSpriteSheets of
                        Just sprites ->
                            -- Save all sprites in the spritesheet
                            List.foldl
                                (\( n, s ) lastgd ->
                                    let
                                        ( x, y ) =
                                            s.realStartPoint

                                        ( w, h ) =
                                            s.realSize

                                        newTexture =
                                            Canvas.Texture.sprite { x = x, y = y, width = w, height = h } t

                                        oldIT =
                                            lastgd.internalData

                                        newIT =
                                            { oldIT | sprites = saveSprite oldIT.sprites (name ++ "." ++ n) newTexture }
                                    in
                                    { lastgd | internalData = newIT }
                                )
                                gd
                                sprites

                        Nothing ->
                            let
                                oldIT =
                                    gd.internalData

                                newIT =
                                    { oldIT | sprites = saveSprite oldIT.sprites name t }
                            in
                            { gd | internalData = newIT }
            in
            ( { model | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )

        SoundLoaded name opt result ->
            case result of
                Ok sound ->
                    ( model
                    , Task.perform (PlaySoundGotTime name opt sound) Time.now
                    , Audio.cmdNone
                    )

                Err _ ->
                    ( model
                    , alert ("Failed to load audio " ++ name)
                    , Audio.cmdNone
                    )

        PlaySoundGotTime name opt sound t ->
            ( { model | audiorepo = loadAudio model.audiorepo name sound opt t }, Cmd.none, Audio.cmdNone )

        NewWindowSize t ->
            let
                ( gw, gh ) =
                    maxHandW t

                ( fl, ft ) =
                    getStartPoint t

                oldIT =
                    gd.internalData

                newIT =
                    { oldIT | browserViewPort = t, realWidth = gw, realHeight = gh, startLeft = fl, startTop = ft }

                newgd =
                    { gd | internalData = newIT }
            in
            ( { model | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )

        WindowVisibility v ->
            ( { model | currentGlobalData = { gd | windowVisibility = v } }, Cmd.none, Audio.cmdNone )

        MouseMove ( px, py ) ->
            let
                mp =
                    fromMouseToVirtual gd ( px, py )
            in
            ( { model | currentGlobalData = { gd | mousePos = mp } }, Cmd.none, Audio.cmdNone )

        MouseDown e pos ->
            gameUpdate (Event.MouseDown e <| fromMouseToVirtual model.currentGlobalData pos) model

        MouseUp pos ->
            gameUpdate (Event.MouseUp <| fromMouseToVirtual model.currentGlobalData pos) model

        KeyDown 112 ->
            if debug then
                -- F1
                ( model, prompt { name = "load", title = "Enter the scene you want to load" }, Audio.cmdNone )

            else
                gameUpdate msg model

        KeyDown 113 ->
            if debug then
                -- F2
                ( model, prompt { name = "setVolume", title = "Set volume (0-1)" }, Audio.cmdNone )

            else
                gameUpdate msg model

        Prompt "load" result ->
            if existScene result then
                ( loadSceneByName Event.NullEvent model result NullSceneInitData
                    |> resetSceneStartTime
                , Cmd.none
                , Audio.cmdNone
                )

            else
                ( model, alert "Scene not found!", Audio.cmdNone )

        Prompt "setVolume" result ->
            let
                vol =
                    String.toFloat result
            in
            case vol of
                Just v ->
                    let
                        ls =
                            gd.localStorage

                        newls =
                            { ls | volume = v }

                        newGd =
                            { gd | localStorage = newls }
                    in
                    ( { model | currentGlobalData = newGd }, sendInfo (encodeLSInfo newls), Audio.cmdNone )

                Nothing ->
                    ( model, alert "Not a number", Audio.cmdNone )

        Tick x ->
            let
                newGD =
                    { gd | currentTimeStamp = x }

                trans =
                    model.transition

                newTrans =
                    case trans of
                        Just ( data, sd ) ->
                            if data.currentTransition >= data.inT + data.outT then
                                Nothing

                            else
                                Just ( { data | currentTransition = data.currentTransition + 1 }, sd )

                        Nothing ->
                            trans
            in
            gameUpdate msg { model | currentGlobalData = newGD, transition = newTrans }

        NullEvent ->
            ( model, Cmd.none, Audio.cmdNone )

        _ ->
            gameUpdate msg model

-}
