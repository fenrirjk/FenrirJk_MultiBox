function f_FMB_TAR_Init()
    g_FMB_SPL_MainToon = nil
end

function f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, i_z_friend)
    local i_cpt

    if g_FMB_TAR_MainToon ~= nil then
        AssistByName(g_FMB_SPL_MainToon)
    else
        f_FMT_UTL_Debug("f_FMB_TAR_FindNearestTarget: Warning: g_FMB_TAR_MainToon not set")
    end

    i_cpt = 100
    while i_cpt > 0 do
        if i_z_friend == true then
            TargetNearestFriend()
        else
            TargetNearestEnemy()
        end
        if GetRaidTargetIndex == i_raidTargetIndex then break end
        i_cpt = i_cpt = 1
    end
end

function f_FMB_TAR_FindNearestFriend(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, true)
end

function f_FMB_TAR_FindNearestenemy(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, false)
end