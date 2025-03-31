local addonName, addonTable = ...

local optionsPanel
local scrollFrame
local scrollChild

local numberOfEmotesChecked = 0
MyEmoteSettings = MyEmoteSettings or {}
emotesCheckButtons = {}

local function createEmoteCheckButton(parent, x, y, text)
    local cbEmote = CreateFrame("CheckButton", "cbEmote" .. text, parent, "ChatConfigCheckButtonTemplate")
    cbEmote:SetPoint("TOPLEFT", x, y)
    _G[cbEmote:GetName() .. 'Text']:SetText(text)
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
        MyEmoteSettings[text] = self:GetChecked() and true or nil
    end)
end

function getNumberOfEmotesChecked()
    return numberOfEmotesChecked
end

function MyEmote_Config_Init()
    optionsPanel = CreateFrame("Frame")
    optionsPanel.name = "My Emote " .. (C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version") or "")

    scrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 3, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

    scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)

    if SettingsPanel then
        scrollChild:SetWidth(SettingsPanel:GetWidth() - 18)
    else
        scrollChild:SetWidth(350)
    end
    scrollChild:SetHeight(1)

    if SettingsPanel then
        local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
        Settings.RegisterAddOnCategory(category)
    end

    local title = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP")
    title:SetText(optionsPanel.name)

    local emoteSet = {}
    
    for i = 1, MAXEMOTEINDEX do
        local token = _G["EMOTE" .. i .. "_TOKEN"]
        if token then
            local norm = token:sub(1,1):upper() .. token:sub(2):lower()
            emoteSet[norm] = true
        end
    end

    for i = 1, #CustomEmotes do
        local emote = CustomEmotes[i]
        if emote then
            local norm = emote:sub(1,1):upper() .. emote:sub(2):lower()
            emoteSet[norm] = true
        end
    end

    local allEmotes = {}
    for norm in pairs(emoteSet) do
        table.insert(allEmotes, norm)
    end

    table.sort(allEmotes)

    for i, emote in ipairs(allEmotes) do
        createEmoteCheckButton(scrollChild, 50, -40 - (i - 1) * 20, emote)
    end

end
