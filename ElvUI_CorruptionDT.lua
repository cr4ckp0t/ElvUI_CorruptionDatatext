-------------------------------------------------------------------------------
-- ElvUI Corruption Datatext By Crackpot (US, Thrall)
-------------------------------------------------------------------------------
local E, _, V, P, G = unpack(ElvUI) --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = LibStub("AceLocale-3.0"):GetLocale("ElvUI_CorruptionDT", false)
local EP = LibStub("LibElvUIPlugin-1.0")
local DT = E:GetModule("DataTexts")

-- local api cache
local ipairs = ipairs
local join = string.join
local max = math.max
local match = string.match
local sort = table.sort
local strsplit = strsplit
local tonumber = tonumber
local tostring = tostring

local GetCorruption = _G["GetCorruption"]
local GetCorruptionResistance = _G["GetCorruptionResistance"]
local GetInventorySlotInfo = _G["GetInventorySlotInfo"]
local GetInventoryItemLink = _G["GetInventoryItemLink"]
local ToggleFrame = _G["ToggleFrame"]

local enteredFrame = false
local displayString = ""
local lastPanel
local hexColor = ""
local rgbColor = {}

local slotNames = {
    "HeadSlot", -- [1]
    "NeckSlot", -- [2]
    "ShoulderSlot", -- [3]
    "ShirtSlot", -- [4]
    "ChestSlot", -- [5]
    "WaistSlot", -- [6]
    "LegsSlot", -- [7]
    "FeetSlot", -- [8]
    "WristSlot", -- [9]
    "HandsSlot", -- [10]
    "Finger0Slot", -- [11]
    "Finger1Slot", -- [12]
    "Trinket0Slot", -- [13]
    "Trinket1Slot", -- [14]
    "BackSlot", -- [15]
    "MainHandSlot", -- [16]
    "SecondaryHandSlot", -- [17]
    "TabardSlot",
    "AmmoSlot"
}

local ranks = {
	["6483"] = {L["Avoidant"], L["I"], 315607},
    ["6484"] = {L["Avoidant"], L["II"], 315608},
    ["6485"] = {L["Avoidant"], L["III"], 315609},
    ["6474"] = {L["Expedient"], L["I"], 315544},
    ["6475"] = {L["Expedient"], L["II"], 315545},
    ["6476"] = {L["Expedient"], L["III"], 315546},
    ["6471"] = {L["Masterful"], L["I"], 315529},
    ["6472"] = {L["Masterful"], L["II"], 315530},
    ["6473"] = {L["Masterful"], L["III"], 315531},
    ["6480"] = {L["Severe"], L["I"], 315554},
    ["6481"] = {L["Severe"], L["II"], 315557},
    ["6482"] = {L["Severe"], L["III"], 315558},
    ["6477"] = {L["Versatile"], L["I"], 315549},
    ["6478"] = {L["Versatile"], L["II"], 315552},
    ["6479"] = {L["Versatile"], L["III"], 315553},
    ["6493"] = {L["Siphoner"], L["I"], 315590},
    ["6494"] = {L["Siphoner"], L["II"], 315591},
    ["6495"] = {L["Siphoner"], L["III"], 315592},
    ["6437"] = {L["Strikethrough"], L["I"], 315277},
    ["6438"] = {L["Strikethrough"], L["II"], 315281},
    ["6439"] = {L["Strikethrough"], L["III"], 315282},
    ["6555"] = {L["Racing Pulse"], L["I"], 318266},
    ["6559"] = {L["Racing Pulse"], L["II"], 318492},
    ["6560"] = {L["Racing Pulse"], L["III"], 318496},
    ["6556"] = {L["Deadly Momentum"], L["I"], 318268},
    ["6561"] = {L["Deadly Momentum"], L["II"], 318493},
    ["6562"] = {L["Deadly Momentum"], L["III"], 318497},
    ["6558"] = {L["Surging Vitality"], L["I"], 318270},
    ["6565"] = {L["Surging Vitality"], L["II"], 318495},
    ["6566"] = {L["Surging Vitality"], L["III"], 318499},
    ["6557"] = {L["Honed Mind"], L["I"], 318269},
    ["6563"] = {L["Honed Mind"], L["II"], 318494},
    ["6564"] = {L["Honed Mind"], L["III"], 318498},
    ["6549"] = {L["Echoing Void"], L["I"], 318280},
    ["6550"] = {L["Echoing Void"], L["II"], 318485},
    ["6551"] = {L["Echoing Void"], L["III"], 318486},
    ["6552"] = {L["Infinite Stars"], L["I"], 318274},
    ["6553"] = {L["Infinite Stars"], L["II"], 318487},
    ["6554"] = {L["Infinite Stars"], L["III"], 318488},
    ["6547"] = {L["Ineffable Truth"], L["I"], 318303},
    ["6548"] = {L["Ineffable Truth"], L["II"], 318484},
    ["6537"] = {L["Twilight Devastation"], L["I"], 318276},
    ["6538"] = {L["Twilight Devastation"], L["II"], 318477},
    ["6539"] = {L["Twilight Devastation"], L["III"], 318478},
    ["6543"] = {L["Twisted Appendage"], L["I"], 318481},
    ["6544"] = {L["Twisted Appendage"], L["II"], 318482},
    ["6545"] = {L["Twisted Appendage"], L["III"], 318483},
    ["6540"] = {L["Void Ritual"], L["I"], 318286},
    ["6541"] = {L["Void Ritual"], L["II"], 318479},
    ["6542"] = {L["Void Ritual"], L["III"], 318480},
    ["6573"] = {L["Gushing Wound"], "", 318272},
    ["6546"] = {L["Glimpse of Clarity"], "", 318239},
    ["6571"] = {L["Searing Flames"], "", 318293},
    ["6572"] = {L["Obsidian Skin"], "", 316651},
    ["6567"] = {L["Devour Vitality"], "", 318294},
    ["6568"] = {L["Whispered Truths"], "", 316780},
    ["6570"] = {L["Flash of Insight"], "", 318299},
    ["6569"] = {L["Lash of the Void"], "", 317290},
}

local function GetItemSplit(itemLink)
	local itemString = match(itemLink, "item:([%-?%d:]+)")
	local itemSplit = {}
  
	-- Split data into a table
	for _, v in ipairs({strsplit(":", itemString)}) do
		if v == "" then
			itemSplit[#itemSplit + 1] = 0
		else
			itemSplit[#itemSplit + 1] = tonumber(v)
		end
	end
  
	return itemSplit
end

function GetItemCorruption(bonuses)
    if #bonuses > 0 then
        for i, bonus_id in pairs(bonuses) do
            bonus_id = tostring(bonus_id)
			if ranks[bonus_id] ~= nil then
				local _, _, icon, _, _, _ = GetSpellInfo(ranks[bonus_id][3])
                name = ranks[bonus_id][1]
                rank = ranks[bonus_id][2]
                return {
					("%s%s"):format(ranks[bonus_id][1], ranks[bonus_id][2] == "" and "" or (" %s"):format(ranks[bonus_id][2])),
                    icon,
                }
            end
        end
    end
end

local function GetCorruptions()
	local corruptions = {}
    for slotNum=1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slotNum])
        local itemLink = GetInventoryItemLink('player', slotId)
        if itemLink then
            local itemSplit = GetItemSplit(itemLink)
            local bonuses = {}

            for index=1, itemSplit[13] do
                bonuses[#bonuses + 1] = itemSplit[13 + index]
            end

            local corruption = GetItemCorruption(bonuses)
            if corruption then
                corruptions[#corruptions + 1] = corruption
            end
        end
    end

    return corruptions
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	GameTooltip_SetBackdropStyle(DT.tooltip, GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM)
	
	local corruption = GetCorruption()
	local corruptionResistance = GetCorruptionResistance()
	local totalCorruption = max(corruption - corruptionResistance, 0)

	GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR)
	GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_DESCRIPTION, NORMAL_FONT_COLOR)
	GameTooltip_AddBlankLineToTooltip(DT.tooltip)
	GameTooltip_AddColoredDoubleLine(DT.tooltip, CORRUPTION_TOOLTIP_LINE, corruption, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, false)
	GameTooltip_AddColoredDoubleLine(DT.tooltip, CORRUPTION_RESISTANCE_TOOLTIP_LINE, corruptionResistance, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, false)
	--GameTooltip_AddColoredDoubleLine(DT.tooltip, TOTAL_CORRUPTION_TOOLTIP_LINE, totalCorruption, hexColor, hexColor, false)
	DT.tooltip:AddDoubleLine(TOTAL_CORRUPTION_TOOLTIP_LINE, totalCorruption, rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.r, rgbColor.g, rgbColor.b, false)
	GameTooltip_AddBlankLineToTooltip(DT.tooltip)

	local corruptionEffects = GetNegativeCorruptionEffectInfo()
	sort(corruptionEffects, function(a, b) return a.minCorruption < b.minCorruption end)

	for i = 1, #corruptionEffects do
		local corruptionInfo = corruptionEffects[i]

		if i > 1 then
			GameTooltip_AddBlankLineToTooltip(DT.tooltip)
		end

		-- We only show 1 effect above the player's current corruption.
		local lastEffect = (corruptionInfo.minCorruption > totalCorruption)

		GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_EFFECT_HEADER:format(corruptionInfo.name, corruptionInfo.minCorruption), lastEffect and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR, false)
		--GameTooltip_AddColoredLine(DT.tooltip, corruptionInfo.description, lastEffect and GRAY_FONT_COLOR or hexColor, true, 10)	
		if lastEffect then
			GameTooltip_AddColoredLine(DT.tooltip, corruptionInfo.description, GRAY_FONT_COLOR, true, 10)
			break
		else
			DT.tooltip:AddLine(corruptionInfo.description, rgbColor.r, rgbColor.g, rgbColor.b, true, 10)
		end
	end

	if E.db.corruptdt.summary then
		-- add the corruption summary
		-- based on Corruption Tooltips by suspctz
		-- https://www.curseforge.com/wow/addons/corruption-tooltips
		local corruptions = GetCorruptions()
		-- make sure they have corruptions
		if #corruptions > 0 then
			GameTooltip_AddBlankLineToTooltip(DT.tooltip)

			local breakdown = {}
			for i = 1, #corruptions do
				local name = corruptions[i][1]
				local icon = corruptions[i][2]
				local line = ("|T%s:0|t |cff%s%s|r"):format(icon, hexColor, name)
				
				-- for multiple instances of corruptions on gear
				if not breakdown[name] then
					breakdown[name] = {1, line}
				else
					breakdown[name][1] = breakdown[name][1] + 1
				end
			end

			sort(breakdown)
			for name, _ in pairs(breakdown) do
				DT.tooltip:AddLine(("|cff%s%s x %s|r"):format(hexColor, breakdown[name][1], breakdown[name][2]))
			end
		end
	end
	
	DT.tooltip:Show()
end

local function OnLeave(self)
	DT.tooltip:Hide()
end

local function OnClick(self, button)
	ToggleFrame(_G["CharacterFrame"])
end

local function OnEvent(self, event)
	lastPanel = self
	local corruption = GetCorruption()
	local corruptionResistance = GetCorruptionResistance()
	local totalCorruption = max(corruption - corruptionResistance, 0)
	self.text:SetFormattedText(displayString, E.db.corruptdt.display == "resist" and L["Resistance"] or L["Corruption"], E.db.corruptdt.display == "total" and totalCorruption or E.db.corruptdt.display == "base" and corruption or corruptionResistance)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "|cffffffff%s:|r", " ", hex, "%s|r")
	hexColor = ("%02x%02x%02x"):format(r * 255, g * 255, b * 255) or "ffffff"
	rgbColor = {
		r = r,
		g = g,
		b = b,
	}
	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

P["corruptdt"] = {
	["display"] = "total",
	["summary"] = true,
}

local function InjectOptions()
	if not E.Options.args.Crackpotx then
		E.Options.args.Crackpotx = {
			type = "group",
			order = -2,
			name = L["Plugins by |cff0070deCrackpotx|r"],
			args = {
				thanks = {
					type = "description",
					order = 1,
					name = L["Thanks for using and supporting my work!  -- |cff0070deCrackpotx|r\n\n|cffff0000If you find any bugs, or have any suggestions for any of my addons, please open a ticket at that particular addon's page on CurseForge."],
				},
			},
		}
	elseif not E.Options.args.Crackpotx.args.thanks then
		E.Options.args.Crackpotx.args.thanks = {
			type = "description",
			order = 1,
			name = L["Thanks for using and supporting my work!  -- |cff0070deCrackpotx|r\n\n|cffff0000If you find any bugs, or have any suggestions for any of my addons, please open a ticket at that particular addon's page on CurseForge."],
		}
	end

	-- inject our config into elvui's config window
	E.Options.args.Crackpotx.args.corruptdt= {
		type = "group",
		name = L["Corruption Datatext"],
		get = function(info) return E.db.corruptdt[info[#info]] end,
		set = function(info, value) E.db.corruptdt[info[#info]] = value DT:LoadDataTexts() end,
		args = {
			display = {
				type = "select",
				order = 1,
				name = L["Display Text"],
				desc = L["What corruption based number do you want to display?"],
				values = {
					["total"] = L["Total Corruption"],
					["base"] = L["Base Corruption"],
					["resist"] = L["Corruption Resistance"],
				}
			},
			summary = {
				type = "toggle",
				order = 2,
				name = L["Add Summary"],
				desc = L["Add a corruption summary, similar to Corruption Tooltips by suspctz, to the tooltip."],
			},
		}
	}
end

EP:RegisterPlugin(..., InjectOptions)
DT:RegisterDatatext("Corruption", nil, {"PLAYER_ENTERING_WORLD", "COMBAT_RATING_UPDATE", "SPELL_TEXT_UPDATE"}, OnEvent, nil, OnClick, OnEnter, OnLeave, L["Corruption"])
--DT:RegisterDatatext("Corruption", {"PLAYER_ENTERING_WORLD", "COMBAT_RATING_UPDATE", "SPELL_TEXT_UPDATE"}, OnEvent, nil, OnClick, OnEnter, OnLeave)