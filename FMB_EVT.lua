function f_FMB_EVT_Init()
    local frame = CreateFrame("Frame");
    frame:SetScript("OnEvent", f_FMB_EVT_OnEvent);
    frame:RegisterEvent("CHAT_MSG_ADDON");
    frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
end

function f_FMB_EVT_RemoteScript(msg)
    local l_args, l_nbArgs = f_FMB_UTL_SplitStr(msg, ":", 2)
    if l_nbArgs ~= 2 then
        f_FMT_UTL_Debug("f_FMB_EVT_RemoteScript: Format error")
    end

    SendAddonMessage("FenrirJk's multiboxing canal RemoteScript", f_FMB_UTL_Trim(l_args[1]) .. ":" .. f_FMB_UTL_Trim(l_args[2]), "PARTY")
end

function f_FMB_EVT_OnEvent()
    local l_args, l_nbArgs

    if (event == "CHAT_MSG_ADDON") and (arg1 == "FenrirJk's multiboxing canal RemoteScript") then
        l_args, l_nbArgs = f_FMB_UTL_SplitStr(arg2, ":", 2)
        if l_nbArgs ~= 2 then
            f_FMT_UTL_Debug("f_FMB_EVT_OnEvent: Format error: " .. arg2)
        end

        if l_args[1] == "PARTY" or l_args[1] == UnitName("PLAYER") then
            f_FMT_UTL_Debug("Running script: " .. l_args[2])
            RunScript(l_args[2])
        end
    end

    if (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
        local l_currentSpell

        l_args, l_nbArgs = f_FMB_UTL_SplitStr(g_FMB_SPL_CurrentSpell, "%(", 2)
        if l_nbArgs == 1 then
            l_currentSpell = g_FMB_SPL_CurrentSpell
        else
            l_currentSpell = l_args[1]
        end

        if (l_currentSpell ~= nil) and (strfind(arg1, l_currentSpell)) and (GetTime() < g_FMB_SPL_NextCastTime) then
            f_FMT_UTL_Debug("f_FMB_EVT_OnEvent: arg1: " .. arg1)
            f_FMT_UTL_Debug("f_FMB_EVT_OnEvent: Fixing cast time of " .. g_FMB_SPL_CurrentSpell .. " to: " .. g_FMB_PlayerSpells[g_FMB_SPL_CurrentSpell].castTime - (g_FMB_SPL_NextCastTime - GetTime())/2)
            g_FMB_PlayerSpells[g_FMB_SPL_CurrentSpell].castTime = g_FMB_PlayerSpells[g_FMB_SPL_CurrentSpell].castTime - (g_FMB_SPL_NextCastTime - GetTime())/2
        end
    end
end