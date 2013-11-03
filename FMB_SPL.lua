function f_FMB_SPL_Init()
	g_FMB_SPL_Combat = false
    g_FMB_SPL_FirstCombatLoop = false
    g_FMB_SPL_NextCastTime = 0
    g_FMB_SPL_ToonChainCast = {}
end

function f_FMB_SPL_Cast(i_spellname)
    local l_spell
	local l_start
	local l_duration

    if g_FMB_PlayerSpells == nil or g_FMB_PlayerSpells[i_spellname] == nil then
        f_FMB_SPL_GetSpellInfo()
    end

    l_spell = g_FMB_PlayerSpells[i_spellname]

    if l_spell.index == nil then
		f_FMT_UTL_Log("Spell: " .. i_spellname .. " Not found")
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

function f_FMB_SPL_CastSequenceWrapper(i_str)
    local l_reset
    local l_spells

    l_args, l_nbArgs = f_FMB_UTL_SplitStr(i_str, ",", 2)
    l_spells = l_args;

    if strfind(l_args[0], "reset") ~= nil then
        if l_nbArgs ~= 2 then
            f_FMT_UTL_Log("f_FMB_SPL_CastSequenceWrapper:format error: " .. i_str)
        end

        l_spells = l_args[1]
        l_reset, l_nbArgs = f_FMB_UTL_SplitStr(l_args[0], "=", 2)
        if l_nbArgs == 2 then
            l_reset = tonumber(f_FMB_UTL_Trim(l_reset[1]))
        else
            l_reset = nil
        end
    else
        l_reset = nil
        l_spells = i_str
    end

    l_spells, l_nbArgs = f_FMB_UTL_SplitStr(l_spells, ",")
    f_FMB_SPL_CastSequence(l_spells, l_reset)
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

    g_FMB_SPL_ToonChainCast[i_spell] = { turn = nil, nextToon = nil }
    g_FMB_SPL_ToonChainCast[i_spell].turn = l_turn
    g_FMB_SPL_ToonChainCast[i_spell].nextToon = i_nextToon
end

function f_FMB_SPL_ToonChainCast(i_spell)
    if g_FMB_SPL_ToonChainCast[i_spell].turn == true then
		SpellStopCasting()
        if f_FMB_SPL_Cast(i_spell) == 0 then
            g_FMB_SPL_ToonChainCast[i_spell].turn = false
            f_FMB_EVT_RemoteScript(g_FMB_SPL_ToonChainCast[i_spell].nextToon .. ":g_FMB_SPL_ToonChainCast['" .. i_spell .. "'].turn = true")
        end
    end
end

function f_FMB_SPL_CastSequence(i_spells, i_reset)
    local l_target
    local l_spellId
    local l_cpt

	l_target = UnitName("Target")

	if g_FMB_SPL_Combat == false then
		return
	end

	if UnitAffectingCombat("player") then
		g_FMB_SPL_FirstCombatLoop = true
	else
		if g_FMB_SPL_FirstCombatLoop == true or l_target == nil then
			f_FMB_SPL_StopCombat()
			g_FMB_SPL_CastSequenceCpt = 0
            g_FMB_SPL_ResetCastSequence = GetTime() + i_reset
		end
	end

	if l_target == nil then
		return
	end

    if (g_FMB_SPL_previousTarget ~= l_target)
        or (i_spells[g_FMB_SPL_CastSequenceCpt] == nil)
        or (GetTime() > g_FMB_SPL_ResetCastSequence) then
        g_FMB_SPL_CastSequenceCpt = 0
        g_FMB_SPL_ResetCastSequence = GetTime() + i_reset
    end

    if f_FMB_SPL_Cast(i_spells[g_FMB_SPL_CastSequenceCpt]) == 0 then
        g_FMB_SPL_CastSequenceCpt = g_FMB_SPL_CastSequenceCpt + 1
    end

    g_FMB_SPL_previousTarget = l_target
end
