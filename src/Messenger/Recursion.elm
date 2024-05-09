module Messenger.Recursion exposing (updateObjects, updateObjectsWithTarget)

{-|


# RecursionList

List implementation for the recursion algorithm

@docs updateObjects, updateObjectsWithTarget


## Tools

@docs getObjectByIndex, getObjectIndices, getObjectIndex, getObjects, getObject

-}

import Messenger.GeneralModel exposing (AbsGeneralModel, Msg(..), unroll)
import Messenger.Scene.Scene exposing (MsgBase)


{-| Recursively update all the objects in the List
-}
updateObjects : env -> event -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List (MsgBase msg scenemsg), ( env, Bool ) )
updateObjects env evt objs =
    let
        ( newObjs, ( newMsgUnfinished, newMsgFinished ), ( newEnv, newBlock ) ) =
            updateOnce env evt objs

        ( resObj, resMsg, resEnv ) =
            updateRemain newEnv ( newMsgUnfinished, newMsgFinished ) newObjs
    in
    ( resObj, resMsg, ( resEnv, newBlock ) )


{-| Recursively update all the objects in the List, but also uses target
-}
updateObjectsWithTarget : env -> List (Msg tar msg scenemsg) -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List (MsgBase msg scenemsg), env )
updateObjectsWithTarget env msgs objs =
    updateRemain env ( msgs, [] ) objs



-- Below are some helper functions


updateOnce : env -> event -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), ( List (Msg tar msg scenemsg), List (MsgBase msg scenemsg) ), ( env, Bool ) )
updateOnce env evt objs =
    --TODO:
    List.foldr
        (\ele ( lastObjs, ( lastMsgUnfinished, lastMsgFinished ), ( lastEnv, lastBlock ) ) ->
            let
                ( newObj, newMsg, ( newEnv, block ) ) =
                    if lastBlock then
                        (unroll ele).update lastEnv evt

                    else
                        (unroll ele).update lastEnv evt

                newBlock =
                    if not block && lastBlock then
                        False

                    else
                        lastBlock

                finishedMsg =
                    List.filterMap
                        (\m ->
                            case m of
                                Parent x ->
                                    Just x

                                _ ->
                                    Nothing
                        )
                        newMsg

                unfinishedMsg =
                    List.filter
                        (\m ->
                            case m of
                                Parent _ ->
                                    False

                                _ ->
                                    True
                        )
                        newMsg
            in
            ( newObj :: lastObjs, ( lastMsgUnfinished ++ unfinishedMsg, lastMsgFinished ++ finishedMsg ), ( newEnv, newBlock ) )
        )
        ( [], ( [], [] ), env )
        objs


{-| Recursively update remaining objects
-}
updateRemain : env -> ( List (Msg tar msg scenemsg), List (MsgBase msg scenemsg) ) -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List (MsgBase msg scenemsg), env )
updateRemain env ( unfinishedMsg, finishedMsg ) objs =
    if List.isEmpty unfinishedMsg then
        ( objs, finishedMsg, env )

    else
        let
            ( newObjs, ( newUnfinishedMsg, newFinishedMsg ), newEnv ) =
                List.foldr
                    (\ele ( lastObjs, ( lastMsgUnfinished, lastMsgFinished ), lastEnv ) ->
                        let
                            msgMatched =
                                List.filterMap
                                    (\ufmsg ->
                                        case ufmsg of
                                            Parent _ ->
                                                Nothing

                                            Other tar msg ->
                                                if (unroll ele).matcher tar then
                                                    Just msg

                                                else
                                                    Nothing
                                    )
                                    unfinishedMsg
                        in
                        if List.isEmpty msgMatched then
                            -- No need to update
                            ( ele :: lastObjs, ( lastMsgUnfinished, lastMsgFinished ), lastEnv )

                        else
                            -- Need update
                            let
                                -- Update the object with all messages in msgMatched
                                ( newObj, ( newMsgUnfinished, newMsgFinished ), newEnv2 ) =
                                    List.foldl
                                        (\msg ( lastObj2, ( lastMsgUnfinished2, lastMsgFinished2 ), lastEnv2 ) ->
                                            let
                                                ( newEle, newMsgs, newEnv3 ) =
                                                    (unroll lastObj2).updaterec lastEnv2 msg

                                                finishedMsgs =
                                                    List.filterMap
                                                        (\nmsg ->
                                                            case nmsg of
                                                                Parent pmsg ->
                                                                    Just pmsg

                                                                Other _ _ ->
                                                                    Nothing
                                                        )
                                                        newMsgs

                                                unfinishedMsgs =
                                                    List.filter
                                                        (\nmsg ->
                                                            case nmsg of
                                                                Parent _ ->
                                                                    False

                                                                Other _ _ ->
                                                                    True
                                                        )
                                                        newMsgs
                                            in
                                            ( newEle, ( lastMsgUnfinished2 ++ unfinishedMsgs, lastMsgFinished2 ++ finishedMsgs ), newEnv3 )
                                        )
                                        ( ele, ( [], [] ), env )
                                        msgMatched
                            in
                            ( newObj :: lastObjs, ( lastMsgUnfinished ++ newMsgUnfinished, lastMsgFinished ++ newMsgFinished ), newEnv2 )
                    )
                    ( [], ( [], [] ), env )
                    objs
        in
        updateRemain newEnv ( newUnfinishedMsg, finishedMsg ++ newFinishedMsg ) newObjs
