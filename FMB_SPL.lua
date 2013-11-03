function f_FMB_SPL_Init()
	g_FMB_SPL_Combat = false
    g_FMB_SPL_FirstCombatLoop = false
    g_FMB_SPL_NextCastTime = 0
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
		f_FMT_UTL_Log("Spell: " .. i_spellname .. " not yet ready, will be ready in " .. g_FMB_SPL_NextCastTime - GetTime() .. "s.")
        return g_FMB_SPL_NextCastTime - GetTime()
    end

	l_start, l_duration = GetSpellCooldown(l_spell.index, BOOKTYPE_SPELL)

	if l_start ~= 0 then
		f_FMT_UTL_Log("Spell: " .. i_spellname .. " cooldown not yet met, will be met in " .. l_duration - (GetTime() - l_start) .. "s.")
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

function f_FMB_SPL_ToonChainCast(i_name, i_turn, i_next, i_spell)
    local l_context

    l_context.name = i_name
    l_context.turn = i_turn
    l_context.next = i_next
    l_context.spell = i_spell

    return l_context
end

function f_FMB_SPL_ToonChainCast(i_context)
    if i_context.turn then
		SpellStopCasting()
        f_FMB_SPL_Cast(i_context.spell)
        i_context.turn = false
        f_FMB_EVT_RemoteScript(i_context.next .. ":" .. i_context.name .. ".turn = true")
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
			g_FMB_SPL_CastSequenceCpt = 1
		end
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
