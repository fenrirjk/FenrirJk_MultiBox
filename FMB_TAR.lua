function f_FMB_TAR_Init()
    g_FMB_SPL_MainToon = nil
end

function f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, i_z_friend)
    local i_cpt

    i_cpt = 100
    while i_cpt > 0 do
        i_cpt = i_cpt - 1
        if i_z_friend == true then
            TargetNearestFriend()
        else
            TargetNearestEnemy()
        end
        if GetRaidTargetIndex("Target") == i_raidTargetIndex then return end
    end

    ClearTarget()
end

function f_FMB_TAR_FindNearestFriend(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, true)
end

function f_FMB_TAR_FindNearestenemy(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, false)
end
