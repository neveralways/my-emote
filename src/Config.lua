local addonName, addonTable = ...

local optionsPanel
local scrollFrame
local scrollChild

local numberOfEmotesChecked = 0
MyEmoteSettings = MyEmoteSettings or {}
emotesCheckButtons = {}

-- Configuración por defecto del menú radial
local DEFAULT_WHEEL_CONFIG = {
    radius = 120,
    innerRadius = 30,
    bgOpacity = 0.85,
    highlightOpacity = 0.6,
    lineThickness = 2,
}

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
            -- Limitar a 12 emotes máximo
            if numberOfEmotesChecked >= 12 then
                self:SetChecked(false)
                print("|cffff6600MyEmote:|r Máximo 12 emotes permitidos en el menú radial.")
                return
            end
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

-- Crear slider para opciones numéricas
local function createSlider(parent, name, label, minVal, maxVal, step, x, y, defaultVal, onChange)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(200)
    
    _G[slider:GetName() .. "Text"]:SetText(label)
    _G[slider:GetName() .. "Low"]:SetText(minVal)
    _G[slider:GetName() .. "High"]:SetText(maxVal)
    
    slider:SetValue(defaultVal)
    
    local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    valueText:SetText(defaultVal)
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        valueText:SetText(value)
        if onChange then onChange(value) end
    end)
    
    return slider
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

    -- ========================================================================
    -- SECCIÓN: CONFIGURACIÓN DEL MENÚ RADIAL
    -- ========================================================================
    local sectionTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sectionTitle:SetPoint("TOPLEFT", 20, -20)
    sectionTitle:SetText("|cff00ff00Configuración del Menú Radial|r")
    
    local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 20, -40)
    desc:SetText("Personaliza la apariencia del menú circular de emotes (máx. 12 emotes)")
    
    -- Sliders de configuración
    local yOffset = -70
    
    -- Radio del menú
    createSlider(scrollChild, "MyEmoteRadiusSlider", "Tamaño del menú", 80, 200, 10, 20, yOffset, 
        MyEmoteSettings.wheelRadius or DEFAULT_WHEEL_CONFIG.radius,
        function(value)
            MyEmoteSettings.wheelRadius = value
        end)
    
    yOffset = yOffset - 50
    
    -- Opacidad del fondo
    createSlider(scrollChild, "MyEmoteBgOpacitySlider", "Opacidad del fondo", 0.3, 1.0, 0.05, 20, yOffset,
        MyEmoteSettings.bgOpacity or DEFAULT_WHEEL_CONFIG.bgOpacity,
        function(value)
            MyEmoteSettings.bgOpacity = value
        end)
    
    yOffset = yOffset - 50
    
    -- Grosor de líneas
    createSlider(scrollChild, "MyEmoteLineSlider", "Grosor de líneas", 1, 5, 1, 20, yOffset,
        MyEmoteSettings.lineThickness or DEFAULT_WHEEL_CONFIG.lineThickness,
        function(value)
            MyEmoteSettings.lineThickness = value
        end)

    -- ========================================================================
    -- SECCIÓN: SELECCIÓN DE EMOTES
    -- ========================================================================
    yOffset = yOffset - 60
    
    local emotesTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    emotesTitle:SetPoint("TOPLEFT", 20, yOffset)
    emotesTitle:SetText("|cff00ff00Seleccionar Emotes|r")
    
    local emotesDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emotesDesc:SetPoint("TOPLEFT", 20, yOffset - 20)
    emotesDesc:SetText("Selecciona hasta 12 emotes para mostrar en el menú radial")
    
    -- Contador de emotes seleccionados
    local counterText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    counterText:SetPoint("TOPLEFT", 20, yOffset - 40)
    
    local function updateCounter()
        local color = numberOfEmotesChecked >= 12 and "|cffff0000" or "|cff00ff00"
        counterText:SetText("Emotes seleccionados: " .. color .. numberOfEmotesChecked .. "/12|r")
    end
    
    yOffset = yOffset - 60

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
        createEmoteCheckButton(scrollChild, 50, yOffset - (i - 1) * 20, emote)
    end
    
    -- Actualizar contador inicial
    C_Timer.After(0.1, updateCounter)
    
    -- Hook para actualizar contador
    local originalOnClick = nil
    for _, cb in pairs(emotesCheckButtons) do
        local oldScript = cb:GetScript("OnClick")
        cb:HookScript("OnClick", function()
            C_Timer.After(0.01, updateCounter)
        end)
        break
    end
end
