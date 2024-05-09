module Messenger.UI.Update exposing (..)

{-| This is the update function for updating the model.

If you add some SceneOutputMsg, you have to add corresponding updating logic here.

-}
import Messenger.Base exposing (WorldEvent(..))
import Audio


gameUpdate : Event -> Model -> ( Model, Cmd Msg, AudioCmd Msg )
gameUpdate evnt model =
    if List.length (Dict.keys model.currentGlobalData.internalData.sprites) < List.length allTexture then
        -- Still loading assets
        ( model, Cmd.none, Audio.cmdNone )

    else
        let
            oldLocalStorage =
                model.currentGlobalData.localStorage

            ( sdt, som, newenv ) =
                (getCurrentScene model).update { globalData = model.currentGlobalData, t = model.time, commonData = () } model.currentData

            newGD1 =
                newenv.globalData

            timeUpdatedModel =
                case evnt of
                    Event.Tick _ ->
                        -- Tick event needs to update time
                        { model | time = model.time + 1, currentGlobalData = newGD1 }

                    _ ->
                        { model | currentGlobalData = newGD1 }

            newModel =
                updateSceneStartTime { timeUpdatedModel | currentData = sdt }

            ( newmodel, cmds, audiocmds ) =
                List.foldl
                    (\singleSOM ( lastModel, lastCmds, lastAudioCmds ) ->
                        case singleSOM of
                            SOMChangeScene ( tm, s, Nothing ) ->
                                --- Load new scene
                                ( loadSceneByName evnt lastModel s tm
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

                                    oldLS =
                                        oldgd.localStorage

                                    newgd2 =
                                        { oldgd | localStorage = { oldLS | volume = s } }
                                in
                                ( { lastModel | currentGlobalData = newgd2 }, lastCmds, lastAudioCmds )

                            SOMStopAudio name ->
                                ( { lastModel | audiorepo = stopAudio lastModel.audiorepo name }, lastCmds, lastAudioCmds )

                            SOMAlert text ->
                                ( lastModel, lastCmds ++ [ alert text ], lastAudioCmds )

                            SOMPrompt name title ->
                                ( lastModel, lastCmds ++ [ prompt { name = name, title = title } ], lastAudioCmds )
                    )
                    ( newModel, [], [] )
                    som

            newmodel2 =
                case newmodel.transition of
                    Just ( trans, ( d, n ) ) ->
                        if trans.currentTransition == trans.outT then
                            loadSceneByName evnt newmodel d n
                                |> resetSceneStartTime

                        else
                            newmodel

                    Nothing ->
                        newmodel
        in
        ( newmodel2
        , Cmd.batch <|
            if newmodel2.currentGlobalData.localStorage /= oldLocalStorage then
                -- Save local storage
                sendInfo (encodeLSInfo newmodel2.currentGlobalData.localStorage) :: cmds

            else
                cmds
        , Audio.cmdBatch audiocmds
        )


{-| update
DO NOT EDIT THIS UNLESS YOU KNOW WHAT YOU ARE DOING.
This is the update function of the whole game.
You may want to change `gameUpdate` rather than this function.
-}
update : AudioData -> Msg -> Model -> ( Model, Cmd Msg, AudioCmd Msg )
update _ msg model =
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
                gameUpdate (Event.event msg) model

        KeyDown 113 ->
            if debug then
                -- F2
                ( model, prompt { name = "setVolume", title = "Set volume (0-1)" }, Audio.cmdNone )

            else
                gameUpdate (Event.event msg) model

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
            gameUpdate (Event.event msg) { model | currentGlobalData = newGD, transition = newTrans }

        NullEvent ->
            ( model, Cmd.none, Audio.cmdNone )

        _ ->
            gameUpdate (Event.event msg) model
