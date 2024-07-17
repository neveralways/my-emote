local wheel = CreateFrame("Frame", "MyEmoteFrame", UIParent, "BackdropTemplate")
wheel:SetSize(200, 200)
wheel:Hide()

local emotes = {"Wave", "Cheer", "Dance", "Cry", "Rasp", "Train"}
local numEmotes = #emotes
local radius = 80
local buttonSize = 50

for i, emote in ipairs(emotes) do
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
            wheel:Hide()
        end)
    end)
    button.animGroup = animGroup


end

local function ToggleWheel()
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    wheel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale)
    if wheel:IsShown() then
        wheel:Hide()
    else
        for i = 1, numEmotes do
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

_G.ToggleWheel = ToggleWheel
