local MAX_EMOTES = 8
local numberOfEmotesChecked = 0

MyEmoteSettings = MyEmoteSettings or {}
MaxEmoteSettings = MaxEmoteSettings or MAX_EMOTES
emotesCheckButtons = {}

local optionsPanel = CreateFrame("Frame")
optionsPanel.name = "My Emote " .. C_AddOns.GetAddOnMetadata("MyEmote", "Version")

local scrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 3, -60)
scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(SettingsPanel:GetWidth()-18)
scrollChild:SetHeight(1) 

if SettingsPanel then
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
    Settings.RegisterAddOnCategory(category)
end

local titleNumberOfEmotes = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
titleNumberOfEmotes:SetPoint("TOPLEFT", 0, 0)
titleNumberOfEmotes:SetText("Set the number of emotes you want to use")
local numberInput = CreateFrame("EditBox", nil, optionsPanel, "InputBoxTemplate")
numberInput:SetPoint("TOPLEFT", titleNumberOfEmotes, "BOTTOMLEFT", 0, -10)
numberInput:SetSize(50, 20)
numberInput:SetAutoFocus(false)
numberInput:SetNumeric(true)
numberInput:SetMaxLetters(2)

local title = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 0, -50)
title:SetText("Emotes")

local function updateTitleNumberOfEmotes()
    title:SetText("Emotes (" .. numberOfEmotesChecked .. "/" .. MaxEmoteSettings .. ")")
end

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

        if numberOfEmotesChecked > MaxEmoteSettings then
            self:SetChecked(false)
            numberOfEmotesChecked = numberOfEmotesChecked - 1
            print("You can't select more than " .. MaxEmoteSettings .. " emotes.")
        else
            MyEmoteSettings[text] = self:GetChecked() and true or nil
        end

        updateTitleNumberOfEmotes()
    end)

    updateTitleNumberOfEmotes()
end

numberInput:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        local value = tonumber(self:GetText())
        if value then
            MaxEmoteSettings = value
            updateTitleNumberOfEmotes()
        end
    end
end)

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MyEmote" then

        if not MaxEmoteSettings then
            numberInput:SetText(tostring(MAX_EMOTES))
        else
            numberInput:SetText(tostring(MaxEmoteSettings))
        end
        numberInput:SetCursorPosition(0)

        local emoteListTitle = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
        
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
