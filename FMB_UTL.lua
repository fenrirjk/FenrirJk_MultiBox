function f_FMB_UTL_SendMsg(m)
  DEFAULT_CHAT_FRAME:AddMessage(m);
end

f_FMT_UTL_Log = f_FMB_UTL_SendMsg
f_FMT_UTL_Debug = f_FMB_UTL_SendMsg

function f_FMB_UTL_Trim(i_str)
    local l_start
    local l_end

    l_start = 1
    l_end = strlen(i_str)
    while (strbyte(i_str, l_start) == 32) do l_start = l_start + 1 end
    while (strbyte(i_str, l_end) == 32) do l_end = l_end - 1 end

    return strsub(i_str, l_start, l_end)
end

function f_FMB_UTL_SplitStr(i_str, i_c, i_nbMax)
    local l_split = {}
    local l_idx
    local l_start
    local l_end

    l_idx = 0;

    while true do
        l_start, l_end = strfind(i_str, i_c)
        if l_start == nil then break end
        l_split[l_idx] = strsub(i_str, 1, l_start-1)
        l_idx = l_idx + 1
        i_str = strsub(i_str, l_end+1)
        if i_nbMax ~= nil and i_nbMax-1 == l_idx then break end
    end

    l_split[l_idx] = i_str

    return l_split, l_idx+1
end
