-------------------------------------------------------------------------------
-- ElvUI Corruption Datatext By Crackpotx (US, Lightbringer)
-------------------------------------------------------------------------------
local E, _, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = LibStub("AceLocale-3.0"):GetLocale("ElvUI_CorruptionDT", false)
local EP = LibStub("LibElvUIPlugin-1.0")
local DT = E:GetModule("DataTexts")

-- local api cache
local join = string.join
local max = math.max
local sort = table.sort

local GetCorruption = _G["GetCorruption"]
local GetCorruptionResistance = _G["GetCorruptionResistance"]
local ToggleFrame = _G["ToggleFrame"]

local enteredFrame = false
local displayString = ""
local lastPanel
local hexColor = ""

local function OnEnter(self)
	DT:SetupTooltip(self)
	GameTooltip_SetBackdropStyle(DT.tooltip, GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM);
	
	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = math.max(corruption - corruptionResistance, 0);

	GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_DESCRIPTION, NORMAL_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(DT.tooltip);
	GameTooltip_AddColoredDoubleLine(DT.tooltip, CORRUPTION_TOOLTIP_LINE, corruption, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, false);
	GameTooltip_AddColoredDoubleLine(DT.tooltip, CORRUPTION_RESISTANCE_TOOLTIP_LINE, corruptionResistance, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, false);
	GameTooltip_AddColoredDoubleLine(DT.tooltip, TOTAL_CORRUPTION_TOOLTIP_LINE, totalCorruption, CORRUPTION_COLOR, CORRUPTION_COLOR, false);
	GameTooltip_AddBlankLineToTooltip(DT.tooltip);

	local corruptionEffects = GetNegativeCorruptionEffectInfo();
	sort(corruptionEffects, function(a, b) return a.minCorruption < b.minCorruption end);

	for i = 1, #corruptionEffects do
		local corruptionInfo = corruptionEffects[i];

		if i > 1 then
			GameTooltip_AddBlankLineToTooltip(DT.tooltip);
		end

		-- We only show 1 effect above the player's current corruption.
		local lastEffect = (corruptionInfo.minCorruption > totalCorruption);

		GameTooltip_AddColoredLine(DT.tooltip, CORRUPTION_EFFECT_HEADER:format(corruptionInfo.name, corruptionInfo.minCorruption), lastEffect and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR, false);
		GameTooltip_AddColoredLine(DT.tooltip, corruptionInfo.description, lastEffect and GRAY_FONT_COLOR or CORRUPTION_COLOR, true, 10);

		if lastEffect then
			break;
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
	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = max(corruption - corruptionResistance, 0);
	self.text:SetFormattedText(displayString, E.db.corruptdt.display == "resist" and L["Resistance"] or L["Corruption"], E.db.corruptdt.display == "total" and totalCorruption or E.db.corruptdt.display == "base" and corruption or corruptionResistance)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "|cffffffff%s:|r", " ", hex, "%s|r")
	hexColor = ("%02x%02x%02x"):format(r * 255, g * 255, b * 255) or "ffffff"

	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

P["corruptdt"] = {
	["display"] = "total",
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
		set = function(info, value) E.db.corruptdt[info[#info]] = value; DT:LoadDataTexts() end,
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
		}
	}
end

EP:RegisterPlugin(..., InjectOptions)
DT:RegisterDatatext("Corruption", {"PLAYER_ENTERING_WORLD", "COMBAT_RATING_UPDATE", "SPELL_TEXT_UPDATE"}, OnEvent, nil, OnClick, OnEnter, OnLeave)