local addonName, addonTable = ...

local wheel = CreateFrame("Frame", "MyEmoteFrame", UIParent, "BackdropTemplate")
wheel:Hide()

local emoteButtons = {}

local function updateEmotes()
    local selectedEmotes = {}
    for emote, checkButton in pairs(emotesCheckButtons) do
        if checkButton:GetChecked() then
            table.insert(selectedEmotes, emote)
        end
    end

    if #selectedEmotes == 0 then
        selectedEmotes = MyEmoteDefaults
    end

    return selectedEmotes
end

local function clearEmoteButtons()
    for i, button in ipairs(emoteButtons) do
        button:Hide()
        button:SetParent(nil)
        _G["EmoteButton" .. i] = nil
    end
    emoteButtons = {}
end

local function createEmoteButtons(wheel, emotes)
    clearEmoteButtons()

    local numEmotes = #emotes
    local radius = 100
    local buttonSize = 50
    local numberOfEmotesChecked = getNumberOfEmotesChecked()

    if numberOfEmotesChecked > 8 then
        radius = 12 * numberOfEmotesChecked
    end

    if radius > 1000 then
        radius = 400
    end

    for i, emote in ipairs(emotes) do
        wheel:SetSize(radius * 2, radius * 2)
        local button = CreateFrame("Button", "EmoteButton" .. i, wheel, "UIPanelButtonTemplate")
        local transparentTexture = wheel:CreateTexture()
        transparentTexture:SetColorTexture(0, 0, 0, 0)
        button:SetHighlightTexture(transparentTexture)
        button:SetHighlightFontObject(button:GetNormalFontObject())
        button:SetSize(buttonSize, buttonSize)
        
        local angle = (i - 1) * (2 * math.pi / numEmotes)
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        button:SetPoint("CENTER", wheel, "CENTER", 0, 0)
        button:SetText(emote)

        local animGroup = button:CreateAnimationGroup()
        local anim = animGroup:CreateAnimation("Translation")
        anim:SetOffset(x, y)
        anim:SetDuration(0.1)
        anim:SetSmoothing("OUT")

        animGroup:SetScript("OnPlay", function()
            button:SetScript("OnEnter", nil)
            button:SetPoint("CENTER", wheel, "CENTER", 0, 0)
        end)
        animGroup:SetScript("OnFinished", function()
            button:SetPoint("CENTER", wheel, "CENTER", x, y)
            button:SetScript("OnEnter", function()
                DoEmote(string.lower(emote))
                addEmoteCount()
                wheel:Hide()
            end)
        end)
        button.animGroup = animGroup

        table.insert(emoteButtons, button)
    end
end

local function ToggleWheel()
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    wheel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale)
    
    if wheel:IsShown() then
        wheel:Hide()
    else
        local selectedEmotes = updateEmotes()
        createEmoteButtons(wheel, selectedEmotes)
        
        for i = 1, #selectedEmotes do
            local button = _G["EmoteButton" .. i]
            button.animGroup:Stop()
            button.animGroup:Play()
        end
        wheel:Show()
    end
end

wheel:SetScript("OnLeave", function(self)
    wheel:Hide()
end)
wheel:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:Hide()
    end
end)

function MyEmote_UI_Init()
    _G["ToggleWheel"] = ToggleWheel
end
