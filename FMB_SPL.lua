function f_FMB_SPL_Init()
	g_FMB_SPL_Combat = false
    g_FMB_SPL_FirstCombatLoop = false
    g_FMB_SPL_NextCastTime = 0
    g_FMB_SPL_ToonChainCast = {}
    g_FMB_SPL_StackCast = {}
end

function f_FMB_SPL_CastWrapper(i_str)
    local l_spell, l_target, l_targetType

    l_spell, l_nbArgs = f_FMB_UTL_SplitStr(i_str, ",")

    l_target = f_FMB_UTL_GetParam(l_spell, "target")
    l_targetType = f_FMB_UTL_GetParam(l_spell, "targetType")
    if (l_reset ~= nil) then l_reset = tonumber(l_reset) end
    if (l_target ~= nil) then l_target = tonumber(l_target) end

    f_FMB_SPL_CastSequence(l_spell[1], l_target, l_targetType)
end

function f_FMB_SPL_Cast(i_spell, i_target, i_targetType)
    local l_spell
	local l_start
	local l_duration

    if g_FMB_SPL_StackCast.spell ~= nil then
        i_spell = g_FMB_SPL_StackCast.spell
        i_target = g_FMB_SPL_StackCast.target
        i_targetType = g_FMB_SPL_StackCast.targetType
        g_FMB_SPL_StackCast.spell = nil
        g_FMB_SPL_StackCast.target = nil
        g_FMB_SPL_StackCast.targetType = nil
    end

    if (i_target ~= nil) and (i_targetType == "friend") then
        f_FMB_TAR_FindNearestFriend(i_target)
    else
        if g_FMB_SPL_Combat == false then return -1 end

        if (i_target ~= nil) then
            f_FMB_TAR_FindNearestEnemy(i_target)
        end
    end

    if g_FMB_PlayerSpells == nil or g_FMB_PlayerSpells[i_spell] == nil then
        f_FMB_SPL_GetSpellInfo()
    end

    l_spell = g_FMB_PlayerSpells[i_spell]

    if l_spell.index == nil then
		f_FMT_UTL_Log("Spell: " .. i_spell .. " Not found")
        return -1
    end

    if GetTime() < g_FMB_SPL_NextCastTime then
		return g_FMB_SPL_NextCastTime - GetTime()
    end

	l_start, l_duration = GetSpellCooldown(l_spell.index, BOOKTYPE_SPELL)

	if l_start ~= 0 then
		return l_duration - (GetTime() - l_start)
	end

    g_FMB_SPL_NextCastTime = GetTime() + l_spell.castTime
    g_FMB_SPL_CurrentSpell = i_spellname
    CastSpell(l_spell.index, BOOKTYPE_SPELL)

    return 0
end

function f_FMB_SPL_StackCastWrapper(i_str)
    local l_spell, l_target, l_targetType

    l_spell, l_nbArgs = f_FMB_UTL_SplitStr(i_str, ",")

    l_target = f_FMB_UTL_GetParam(l_spell, "target")
    l_targetType = f_FMB_UTL_GetParam(l_spell, "targetType")
    if (l_reset ~= nil) then l_reset = tonumber(l_reset) end
    if (l_target ~= nil) then l_target = tonumber(l_target) end

    g_FMB_SPL_StackCast.spell = l_spell[1]
    g_FMB_SPL_StackCast.target = l_target
    g_FMB_SPL_StackCast.targetType = l_targetType
end

function f_FMB_SPL_CastSequenceWrapper(i_str)
    local l_spells, l_reset, l_target, l_targetType

    l_args, l_nbArgs = f_FMB_UTL_SplitStr(i_str, ",")
    l_spells = l_args;

    l_reset = f_FMB_UTL_GetParam(l_args, "reset")
    l_target = f_FMB_UTL_GetParam(l_args, "target")
    l_targetType = f_FMB_UTL_GetParam(l_args, "targetType")
    if (l_reset ~= nil) then l_reset = tonumber(l_reset) end
    if (l_target ~= nil) then l_target = tonumber(l_target) end

    f_FMB_SPL_CastSequence(l_spells, l_reset, l_target, l_targetType)
end

function f_FMB_SPL_GetSpellInfo()
	-- Load tables up with spell position by name for a CastSpell that works in scripts
    g_FMB_PlayerSpells = {}
    g_FMB_PetSpells = {}
    g_FMB_PetMaxRank = {}
    local l_index = 1
    local l_spell

    while true do
        local l_spellname, l_spellrank = GetSpellName(l_index,1)
        if not l_spellname then break end
        if not l_spellrank then l_spellrank = "" end
        if not IsSpellPassive(l_index,1) then
            l_spell = { index = nil, castTime = nil }
            l_spell.index = l_index
            if (l_spellname == "Pyroblast") then
                l_spell.castTime = 7
            else
                l_spell.castTime = 4
            end
            g_FMB_PlayerSpells[l_spellname.."("..l_spellrank..")"] = l_spell
            g_FMB_PlayerSpells[l_spellname] = l_spell
            f_FMT_UTL_Log("Found spell: " .. l_spellname .. ", ID: " .. l_spell.index)
        end
        l_index = l_index+1
    end

    if not HasPetSpells() then return end

    local l_index = 1

    while true do
        local l_spellname, l_spellrank = Getl_spellname(l_index,BOOKTYPE_PET)
        if not l_spellname then break end
        if not l_spellrank then l_spellrank = "" end
        g_FMB_PetSpells[l_spellname.."("..l_spellrank..")"] = l_index
        g_FMB_PetMaxRank[l_spellname] = l_index
        l_index = l_index+1
    end
end

function f_FMB_SPL_StartCombat()
	if g_FMB_SPL_Combat == false then
		g_FMB_SPL_Combat = true
		g_FMB_SPL_FirstCombatLoop = false
	end
end

function f_FMB_SPL_StopCombat()
	if g_CS_combat == true then
		g_FMB_SPL_Combat = false
	end
end

function f_FMB_SPL_SetSpellList(i_spells)
    g_FMB_SpellList = i_spells
end

function f_FMB_SPL_InitToonChainCast(i_turn, i_nextToon, i_spell)
    local l_turn
    if i_turn == "true" then
        l_turn = true
    else
        l_turn = false
    end

    g_FMB_SPL_ToonChainCast[i_spell] = { }
    g_FMB_SPL_ToonChainCast[i_spell].turn = l_turn
    g_FMB_SPL_ToonChainCast[i_spell].nextToon = i_nextToon
end

function f_FMB_SPL_ToonChainCast(i_spell)
    local l_save_g_FMB_SPL_Combat

    if g_FMB_SPL_ToonChainCast[i_spell].turn == true then
		SpellStopCasting()
        l_save_g_FMB_SPL_Combat = g_FMB_SPL_Combat
        g_FMB_SPL_Combat = true
        if f_FMB_SPL_Cast(i_spell,nil,nil) == 0 then
            g_FMB_SPL_ToonChainCast[i_spell].turn = false
            f_FMB_EVT_RemoteScript(g_FMB_SPL_ToonChainCast[i_spell].nextToon .. ":g_FMB_SPL_ToonChainCast['" .. i_spell .. "'].turn = true")
        end
        g_FMB_SPL_Combat = l_save_g_FMB_SPL_Combat
    end
end

function f_FMB_SPL_CastSequence(i_spells, i_reset, i_target, i_targetType)
    local l_target
    local l_spellId
    local l_cpt

    if g_FMB_SPL_StackCast.spell ~= nil then
        f_FMB_SPL_Cast(nil, nil, nil)
        return
    end

	if g_FMB_SPL_Combat == false then
		return
	end

    if (i_target ~= nil) then
        if i_targetType == "friend" then
            f_FMB_TAR_FindNearestFriend(i_target)
        else
            f_FMB_TAR_FindNearestEnemy(i_target)
        end
    end

	l_target = UnitName("Target")

	if UnitAffectingCombat("player") then
		g_FMB_SPL_FirstCombatLoop = true
	else
		if g_FMB_SPL_FirstCombatLoop == true or l_target == nil then
			f_FMB_SPL_StopCombat()
			g_FMB_SPL_CastSequenceCpt = 1
            g_FMB_SPL_ResetCastSequence = GetTime() + i_reset
		end
	end

	if l_target == nil then
		return
	end

    if (g_FMB_SPL_previousTarget ~= l_target)
        or (i_spells[g_FMB_SPL_CastSequenceCpt] == nil)
        or (GetTime() > g_FMB_SPL_ResetCastSequence) then
        g_FMB_SPL_CastSequenceCpt = 1
        g_FMB_SPL_ResetCastSequence = GetTime() + i_reset
    end

    if f_FMB_SPL_Cast(i_spells[g_FMB_SPL_CastSequenceCpt],nil,nil) == 0 then
        g_FMB_SPL_CastSequenceCpt = g_FMB_SPL_CastSequenceCpt + 1
    end

    g_FMB_SPL_previousTarget = l_target
end
