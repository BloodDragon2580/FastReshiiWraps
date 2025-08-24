local L = LibStub("AceLocale-3.0"):GetLocale("FastReshiiWraps", false)
FastReshiiWraps = {}
FastReshiiWraps.mainFrame = CreateFrame("Frame", "FastReshiiWrapsFrame", UIParent)

local _

local function printOperation(operation, command, description)
    print("|cffeded5f" .. operation .. " |cffed5f5f" .. command .. " |r- |cffeda55f".. description .. "|r")
end

-- Öffnet den Talentbaum
local function openTalentTree()
    C_AddOns.LoadAddOn("Blizzard_GenericTraitUI")
    GenericTraitUI_LoadUI()
    GenericTraitFrame:SetSystemID(29)
    GenericTraitFrame:SetTreeID(1115)
    ToggleFrame(GenericTraitFrame)
end

local function ToggleMinimapButton()
    if FastReshiiWraps.ldbIcon then
        FastReshiiWrapsDB.MinimapButton.hide = not FastReshiiWrapsDB.MinimapButton.hide
        if FastReshiiWrapsDB.MinimapButton.hide then
            FastReshiiWraps.ldbIcon:Hide("FastReshiiWraps")
        else
            FastReshiiWraps.ldbIcon:Show("FastReshiiWraps")
        end
    end
end

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "FastReshiiWraps" then
        if FastReshiiWrapsDB == nil then
            FastReshiiWrapsDB = {}
        end
        if FastReshiiWrapsDB.MinimapButton == nil then
            FastReshiiWrapsDB.MinimapButton = {hide = false,}
        end

        FastReshiiWraps.mainFrame:UnregisterEvent("ADDON_LOADED")

        if FastReshiiWraps.DataBroker then
            FastReshiiWraps.DataBroker:UpdateText()
        end

        local ldbIcon = FastReshiiWraps.DataBroker and LibStub("LibDBIcon-1.0", true)
        if ldbIcon then
            ldbIcon:Register("FastReshiiWraps", FastReshiiWraps.DataBroker, FastReshiiWrapsDB.MinimapButton)
            FastReshiiWraps.ldbIcon = ldbIcon
        end
    end
end

-- Slash Commands
SLASH_FASTRESHII1 = "/frw"
SLASH_FASTRESHII2 = "/fastreshii"
SlashCmdList["FASTRESHII"] = function(msg)
    if msg == "minimap" then
        ToggleMinimapButton()
    else
        print("|cffeded5f=== |cffed5f5fF|cffeda55fast Reshii Wraps |cffeded5f===|r")
        printOperation("/frw", "minimap", "Toggle minimap button")
    end
end

-- DataBroker
local ldb = LibStub("LibDataBroker-1.1")

local dataBroker = ldb:NewDataObject("FastReshiiWraps",
    {
        type = "data source",
        label = "FRW",
        text = "Fast Reshii Wraps",
        icon = 626003
    }
)

function dataBroker.OnClick(self, button)
    openTalentTree()
end

function dataBroker.OnTooltipShow(tt)
    tt:AddLine("Fast Reshii Wraps")
    tt:AddLine(L["Click to open Talent Tree."], 0.2, 1, 0.2, 1)
end

function dataBroker.UpdateText(self)
    self.text = "Fast Reshii Wraps"
end

FastReshiiWraps.DataBroker = dataBroker
FastReshiiWraps.mainFrame:RegisterEvent("ADDON_LOADED")
FastReshiiWraps.mainFrame:SetScript("OnEvent", OnEvent)

SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = ReloadUI
