function f_FMB_SLA_Init()
    f_FMB_UTL_SendMsg("loading slash cmds")
    SLASH_FMB_SendMsg1 = "/FMB_SendMsg"
    SLASH_FMB_SendMsg2 = "/FMB_SendMsg"
	SlashCmdList["FMB_SendMsg"] = f_FMB_UTL_SendMsg

    SLASH_FMB_Cast1 = "/FMB_Cast"
    SLASH_FMB_Cast2 = "/FMB_Cast"
	SlashCmdList["FMB_Cast"] = function(i_args)
        local l_args, l_nbArgs, l_z_reset
        l_args, l_nbArgs = f_FMB_UTL_SplitStr(i_args, ",", 2)
        if (l_nbArgs == 2) then
            if (l_args[1] == "SpellStopCasting") then
                l_z_reset = true
            else
                l_z_reset = false
            end
            f_FMB_SPL_Cast(l_args[0], l_z_reset)
        else
            if (l_nbArgs == 1) then
                f_FMB_SPL_Cast(i_args, false)
            else
                f_FMT_UTL_Debug("/FMB_Cast: Format error: " .. i_args)
            end
        end
    end

    SLASH_FMB_CastSequence1 = "/FMB_CastSequence"
    SLASH_FMB_CastSequence2 = "/FMB_CastSequ"
	SlashCmdList["FMB_CastSequence"] = f_FMB_SPL_CastSequenceWrapper

    SLASH_FMB_RemoteScript1 = "/FMB_RemoteScript"
    SLASH_FMB_RemoteScript2 = "/FMB_RemoteScript"
	SlashCmdList["FMB_RemoteScript"] = f_FMB_EVT_RemoteScript

    SLASH_FMB_FindNearestEnemy1 = "/FMB_FindNearestEnemy"
    SLASH_FMB_FindNearestEnemy2 = "/FMB_FindNearestEnemy"
	SlashCmdList["FMB_FindNearestEnemy"] = function(id) f_FMB_TAR_FindNearestenemy(tonumber(id)) end

    SLASH_FMB_StartCombat1 = "/FMB_StartCombat"
    SLASH_FMB_StartCombat2 = "/FMB_StartCombat"
	SlashCmdList["FMB_StartCombat"] = f_FMB_SPL_StartCombat

    SLASH_FMB_InitToonChainCast1 = "/FMB_ITCC"
    SLASH_FMB_InitToonChainCast2 = "/FMB_InitToonChainCast"
	SlashCmdList["FMB_InitToonChainCast"] =
    function(i_args)
        local l_args, l_nbArgs
        l_args, l_nbArgs = f_FMB_UTL_SplitStr(i_args, ",", 3)
        if l_nbArgs ~= 3 then
            f_FMT_UTL_Debug("/FMB_InitToonChainCast: Format error: " .. i_args)
        else
            f_FMB_SPL_InitToonChainCast(l_args[0], l_args[1], l_args[2])
        end
    end

    SLASH_FMB_ToonChainCast1 = "/FMB_ToonChainCast"
    SLASH_FMB_ToonChainCast2 = "/FMB_ToonChainCast"
	SlashCmdList["FMB_ToonChainCast"] = f_FMB_SPL_ToonChainCast
end
