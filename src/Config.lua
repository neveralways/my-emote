local MAX_EMOTES = 8
local numberOfEmotesChecked = 0

MyEmoteSettings = MyEmoteSettings or {}
emotesCheckButtons = {}

local optionsPanel = CreateFrame("Frame")
optionsPanel.name = "My Emote " .. C_AddOns.GetAddOnMetadata("MyEmote", "Version")

local scrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 3, -4)
scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(SettingsPanel:GetWidth()-18)
scrollChild:SetHeight(1) 

if SettingsPanel then
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
    Settings.RegisterAddOnCategory(category)
end

local title = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText(optionsPanel.name)

local function createEmoteCheckButton(parent, x, y, text)
    local cbEmote = CreateFrame("CheckButton", "cbEmote" .. text, parent, "ChatConfigCheckButtonTemplate")
    cbEmote:SetPoint("TOPLEFT", x, y)
    getglobal(cbEmote:GetName() .. 'Text'):SetText(text);
    emotesCheckButtons[text] = cbEmote

    if MyEmoteSettings[text] then
        cbEmote:SetChecked(true)
        numberOfEmotesChecked = numberOfEmotesChecked + 1
    end

    cbEmote:SetScript("OnClick", function(self)
        if self:GetChecked() then
            numberOfEmotesChecked = numberOfEmotesChecked + 1
        else
            numberOfEmotesChecked = numberOfEmotesChecked - 1
        end

        if numberOfEmotesChecked > MAX_EMOTES then
            self:SetChecked(false)
            numberOfEmotesChecked = numberOfEmotesChecked - 1
            print("You can't select more than " .. MAX_EMOTES .. " emotes.")
        else
            MyEmoteSettings[text] = self:GetChecked() and true or nil
        end
    end)
end

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MyEmote" then
        local emoteListTitle = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 0, 0)
        title:SetText("Emotes")
        
        for i, emote in ipairs(EmoteList) do
            emoteTextNormalised = emote:sub(1, 1):upper() .. emote:sub(2):lower()
            createEmoteCheckButton(scrollChild, 50, -20 * i, emoteTextNormalised)
        end
        
        local numberOfEmotes = #EmoteList
        
        for i, emote in ipairs(TextEmoteSpeechList) do
            emoteTextNormalised = emote:sub(1, 1):upper() .. emote:sub(2):lower()
            createEmoteCheckButton(scrollChild, 50, -20 * (i + numberOfEmotes), emoteTextNormalised)
        end
    end
end

optionsPanel:SetScript("OnEvent", OnEvent)
optionsPanel:RegisterEvent("ADDON_LOADED")
