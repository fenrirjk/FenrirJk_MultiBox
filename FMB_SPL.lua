function f_FMB_SPL_Init()
	g_FMB_SPL_Combat = false
    g_FMB_SPL_FirstCombatLoop = false
    g_FMB_SPL_MainToon = nil
end

function f_FMB_SPL_Cast(i_spellname)
    local l_spell

    if g_FMB_PlayerSpells == nil or g_FMB_PlayerSpells[i_spellname] == nil or g_FMB_PlayerMaxRank == nil or g_FMB_PlayerMaxRank[i_spellname] == nil then
        f_FMB_SPL_GetSpellInfo()
    end

    if (strfind(i_spellname, "(") and strfind(i_spellname, ")")) then
        l_spell = g_FMB_PlayerSpells[i_spellname]
    else
        l_spell = g_FMB_PlayerMaxRank[i_spellname]
    end

    if l_spellId == nil then
		f_FMT_UTL_Log("Spell: " .. i_spellname .. " Not found")
        return -1
    end

	local l_start
	local l_duration

	l_start, l_duration = GetSpellCooldown(l_spell.index, BOOKTYPE_SPELL)

	if l_start ~= 0 then
		f_FMT_UTL_Log("Spell: " .. i_spellname .. " not yet ready, will be ready in " .. l_duration - (GetTime() - l_start) .. "s.")
		return l_duration - (GetTime() - l_start)
	end

    CastSpell(l_spell.index, "spell")

    return 0
end

function f_FMB_SPL_CastSequenceWrapper(i_str)
    local l_reset
    local l_spells

    l_args, l_nbArgs = f_FMB_UTL_SplitStr(i_str, ",")
    l_spells = l_args;

    if strfind(l_args[1], "reset") ~= nil then
        tremove(l_spells, 1)
        l_reset, l_nbArgs = f_FMB_UTL_SplitStr(l_args[1], "=", 2)
        if l_nbArgs == 2 then
            l_reset = tonumber(f_FMB_UTL_Trim(l_reset[2]))
        else
            l_reset = nil
        end
    else
        l_reset = nil
    end

    f_FMB_SPL_CastSequence(i_spells, i_reset)
end

function f_FMB_SPL_GetSpellInfo()
	-- Load tables up with spell position by name for a CastSpell that works in scripts
    g_FMB_PlayerSpells = {}
    g_FMB_PlayerMaxRank = {}
    g_FMB_PetSpells = {}
    g_FMB_PetMaxRank = {}
    local l_index = 1
    local l_spell

    while true do
        local l_spellname, l_spellrank = GetSpellName(l_index,1)
        if not l_spellname then break end
        if not l_spellrank then l_spellrank = "" end
        if not IsSpellPassive(l_index,1) then
            l_spell.index = l_index
            if (l_spellname == "Pyroblast") then l_spell.castTime = 7
            else l_spell.castTime = 4
            end
            g_FMB_PlayerSpells[l_spellname.."("..l_spellrank..")"] = l_spell
            g_FMB_PlayerMaxRank[l_spellname] = l_spell
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

function f_FMB_SPL_SetSpellList(i_spells)
    g_FMB_SpellList = i_spells
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

function f_FMB_SPL_CastSequence(i_spells, i_reset)
    local l_target
    local l_spellId
    local l_cpt

    if g_FMB_SPL_MainToon ~= nil then
        AssistByName(g_FMB_SPL_MainToon)
    end

    l_cpt = 1000
    while l_cpt > 0 do
        if (GetRaidTargetIndex("Target") == 8) then break
        else
            TargetNearestEnemy()
            l_cpt = l_cpt - 1
        end
    end

	l_target = UnitName("Target")

	if g_FMB_SPL_Combat == false then
		return
	end

	if UnitAffectingCombat("player") then
		g_FMB_SPL_FirstCombatLoop = true
	else
		if g_FMB_SPL_FirstCombatLoop == true or l_target == nil then
			f_FMB_SPL_StopCombat()
			g_FMB_SPL_CastSequenceCpt = 1
		end
	end

	if g_FMB_SPL_stopCast == true then
		g_FMB_SPL_stopCast = false
		SpellStopCasting()
		return
	end

	if l_target == nil then
		return
	end

    if g_FMB_SPL_previousTarget ~= l_target then
        g_FMB_SPL_CastSequenceCpt = 1
    end

    if i_spells[g_FMB_SPL_CastSequenceCpt] == nil then
        g_FMB_SPL_CastSequenceCpt = 1
    end

    if f_FMB_SPL_Cast(g_CS_spellList[l_spellId]) == 0 then
        g_FMB_SPL_CastSequenceCpt = g_FMB_SPL_CastSequenceCpt + 1
    end

    g_FMB_SPL_previousTarget = l_target
end
