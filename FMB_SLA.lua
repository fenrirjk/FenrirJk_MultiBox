function f_FMB_SLA_Init()
    f_FMB_UTL_SendMsg("loading slash cmds")
    SLASH_FMB_SendMsg1 = "/FMB_SendMsg"
    SLASH_FMB_SendMsg2 = "/FMB_SendMsg"
	SlashCmdList["FMB_SendMsg"] = f_FMB_UTL_SendMsg

    SLASH_FMB_Cast1 = "/FMB_Cast"
    SLASH_FMB_Cast2 = "/FMB_Cast"
	SlashCmdList["FMB_Cast"] = f_FMB_SPL_Cast

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
end
