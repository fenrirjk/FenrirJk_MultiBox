function f_FMB_TAR_Init()
    g_FMB_SPL_MainToon = nil
end

function f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, i_z_friend)
    local l_cpt
    local l_AlreadyMetTarget = nil

    l_cpt = 20
    while l_cpt > 0 do
        l_cpt = l_cpt - 1

        if GetRaidTargetIndex("Target") == i_raidTargetIndex then return end

        if i_z_friend == true then
            TargetNearestFriend()
        else
            TargetNearestEnemy()
        end

        if l_AlreadyMetTarget ~= nil then
            if l_AlreadyMetTarget == GetRaidTargetIndex("Target") then break end
        else
            l_AlreadyMetTarget = GetRaidTargetIndex("Target")
        end
    end

    ClearTarget()
end

function f_FMB_TAR_FindNearestFriend(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, true)
end

function f_FMB_TAR_FindNearestenemy(i_raidTargetIndex)
    f_FMB_TAR_FindNearestTarget(i_raidTargetIndex, false)
end
