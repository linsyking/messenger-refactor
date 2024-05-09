module Messenger.Recursion exposing
    ( updateObjects, updateObjectsWithTarget
    , getObjectByIndex, getObjectIndices, getObjectIndex, getObjects, getObject
    )

{-|


# RecursionList

List implementation for the recursion algorithm

@docs updateObjects, updateObjectsWithTarget


## Tools

@docs getObjectByIndex, getObjectIndices, getObjectIndex, getObjects, getObject

-}

import Messenger.GeneralModel exposing (AbsGeneralModel, Msg(..))
import Messenger.Scene exposing (MsgBase)


{-| Recursively update all the objects in the List
-}
updateObjects :  env  -> event -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List msg, (env, Bool) )
updateObjects env evt objs =
    let
        ( newObjs, ( newMsgUnfinished, newMsgFinished ), newEnv ) =
            updateOnce env evt objs

        ( resObj, resMsg, resEnv ) =
            updateRemain newEnv ( newMsgUnfinished, newMsgFinished ) newObjs
    in
    ( resObj, resMsg, resEnv )


{-| Recursively update all the objects in the List, but also uses target
-}
updateObjectsWithTarget : env -> List (Msg tar msg scenemsg) -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List msg, (env, Bool) )
updateObjectsWithTarget env msgs objs =
    updateRemain env ( msgs, [] ) objs



-- Below are some helper functions


updateOnce :  env -> event -> List (AbsGeneralModel env event tar msg ren bdata scenemsg)-> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), ( List (Msg tar msg scenemsg), List (MsgBase msg scnemsg) ), (env, Bool) )
updateOnce env evt objs =
    List.foldr
        (\ele ( lastObjs, ( lastMsgUnfinished, lastMsgFinished ), (lastEnv, lastBlock) ) ->
            let
                ( newObj, newMsg, (newEnv, block) ) =
                    ele.update lastEnv evt
                newBlock  =
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
            ( newObj :: lastObjs, ( lastMsgUnfinished ++ unfinishedMsg, lastMsgFinished ++ finishedMsg ), (newEnv, newBlock) )
        )
        ( [], ( [], [] ), env )
        objs


{-| Recursively update remaining objects
-}
updateRemain: env -> (List (Msg tar msg scenemsg), List (MsgBase msg scnemsg)) -> List (AbsGeneralModel env event tar msg ren bdata scenemsg) -> ( List (AbsGeneralModel env event tar msg ren bdata scenemsg), List (MsgBase msg scnemsg), (env, Bool))
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
                                                if (unroll ele).matcher (unroll ele).baseData tar then
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
                                                    lastObj2.updaterec lastEnv2 lastObj2.baseData msg

                                                finishedMsgs =
                                                    List.filterMap
                                                        (\nmsg ->
                                                            case nmsg of
                                                                Parent msg ->
                                                                    Just msg
                                                                
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
        updateRemain rec newEnv ( newUnfinishedMsg, finishedMsg ++ newFinishedMsg ) newObjs



