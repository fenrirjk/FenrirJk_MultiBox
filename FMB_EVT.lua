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

    SendAddonMessage("FenrirJk's multiboxing canal RemoteScript", f_FMB_UTL_Trim(l_args[0]) .. ":" .. f_FMB_UTL_Trim(l_args[1]), "PARTY")
end

function f_FMB_EVT_OnEvent()
    if (event == "CHAT_MSG_ADDON") and (arg1 == "FenrirJk's multiboxing canal RemoteScript") then
        local l_args, l_nbArgs = f_FMB_UTL_SplitStr(arg2, ":", 2)
        if l_nbArgs ~= 2 then
            f_FMT_UTL_Debug("f_FMB_EVT_OnEvent: Format error: " .. arg2)
        end

        if l_args[0] == "PARTY" or l_args[0] == UnitName("PLAYER") then
            RunScript(l_args[1])
        end
    end

    if (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
    end
end