local L = LibStub("AceLocale-3.0"):GetLocale("FastReshiiWraps", false)
FastReshiiWraps = {}
FastReshiiWraps.mainFrame = CreateFrame("Frame", "FastReshiiWrapsFrame", UIParent)

local _

local function printOperation(operation, command, description)
    print("|cffeded5f" .. operation .. " |cffed5f5f" .. command .. " |r- |cffeda55f".. description .. "|r")
end

-- Öffnet den Talentbaum
local function openTalentTree()
    -- Hinweis: Blizzard ändert/entfernt gelegentlich UI-Methoden. Seit einigen Builds
    -- kann GenericTraitFrame:SetSystemID() fehlen -> dann würde das Addon hart crashen.
    -- Wir fangen das ab und geben eine verständliche Meldung aus.

    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn("Blizzard_GenericTraitUI")
    end
    if type(GenericTraitUI_LoadUI) == "function" then
        GenericTraitUI_LoadUI()
    end

    local frame = _G and _G.GenericTraitFrame
    if not frame then
        print("|cffff5555FRW:|r GenericTraitFrame nicht gefunden. Öffne die Reshii-Wraps UI bitte über den NPC (Hashim in K'aresh).")
        return
    end

    -- Reshii Wraps IDs
    local systemID = 29
    local treeID = 1115

    -- Manche Builds erlauben weiterhin SetTreeID, aber nicht SetSystemID (oder umgekehrt).
    -- Wir versuchen in sicherer Reihenfolge und brechen sauber ab.
    local ok, err

    if type(frame.SetSystemID) == "function" then
        ok, err = pcall(frame.SetSystemID, frame, systemID)
    else
        ok = false
        err = "SetSystemID missing"
    end

    if ok and type(frame.SetTreeID) == "function" then
        ok, err = pcall(frame.SetTreeID, frame, treeID)
    end

    if ok then
        ToggleFrame(frame)
        return
    end

    -- Fallback: Wenn Blizzard die Remote-Öffnung blockt oder Methoden umbenannt wurden,
    -- wollen wir nicht crashten, sondern einen Hinweis geben.
    print("|cffff5555FRW:|r Konnte die Reshii-Wraps UI nicht direkt öffnen (Blizzard-API geändert/gesperrt). Bitte über den NPC (Hashim in K'aresh) öffnen.")
    if err then
        -- optional für Debugging
        print("|cff999999FRW Debug:|r " .. tostring(err))
    end
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
