local addonName, addonTable = ...

local optionsPanel
local scrollFrame
local scrollChild
local activeProfileLabel
local profileDropdown
local L = MyEmoteL

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
                print("|cffff6600MyEmote:|r " .. L["MAX_EMOTES_REACHED"])
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

--- Inicializa el dropdown con la lista de perfiles guardados.
local function MyEmote_ProfileDropdown_Init(self, level)
    local profiles = MyEmote_Profiles_GetList()
    for _, name in ipairs(profiles) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.value = name
        info.func = function(btn)
            UIDropDownMenu_SetSelectedValue(self, btn.value)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

--- Refresca los controles del panel de configuración con los valores actuales
--- de MyEmoteSettings. Llamado automáticamente tras cargar un perfil.
function MyEmote_Config_RefreshUI()
    -- Etiqueta de perfil activo
    if activeProfileLabel then
        local name = MyEmoteActiveProfile or L["PROFILE_NONE"]
        activeProfileLabel:SetText(string.format(L["PROFILE_ACTIVE"], name))
    end
    -- Dropdown de perfiles
    if profileDropdown then
        UIDropDownMenu_Initialize(profileDropdown, MyEmote_ProfileDropdown_Init)
        if MyEmoteActiveProfile then
            UIDropDownMenu_SetSelectedValue(profileDropdown, MyEmoteActiveProfile)
        end
    end
    -- Sliders
    local radiusSlider = _G["MyEmoteRadiusSlider"]
    if radiusSlider then
        radiusSlider:SetValue(MyEmoteSettings.wheelRadius or DEFAULT_WHEEL_CONFIG.radius)
    end
    local bgSlider = _G["MyEmoteBgOpacitySlider"]
    if bgSlider then
        bgSlider:SetValue(MyEmoteSettings.bgOpacity or DEFAULT_WHEEL_CONFIG.bgOpacity)
    end
    local lineSlider = _G["MyEmoteLineSlider"]
    if lineSlider then
        lineSlider:SetValue(MyEmoteSettings.lineThickness or DEFAULT_WHEEL_CONFIG.lineThickness)
    end
    -- Casillas de verificación de emotes
    numberOfEmotesChecked = 0
    for text, cb in pairs(emotesCheckButtons) do
        local checked = MyEmoteSettings[text] and true or false
        cb:SetChecked(checked)
        if checked then
            numberOfEmotesChecked = numberOfEmotesChecked + 1
        end
    end
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
    -- SECCIÓN: GESTIÓN DE PERFILES
    -- ========================================================================
    local profilesTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    profilesTitle:SetPoint("TOPLEFT", 20, -20)
    profilesTitle:SetText("|cff00ff00" .. L["SECTION_PROFILES"] .. "|r")

    local profilesDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    profilesDesc:SetPoint("TOPLEFT", 20, -40)
    profilesDesc:SetText(L["SECTION_PROFILES_DESC"])

    activeProfileLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activeProfileLabel:SetPoint("TOPLEFT", 20, -58)
    do
        local activeName = MyEmoteActiveProfile or L["PROFILE_NONE"]
        activeProfileLabel:SetText(string.format(L["PROFILE_ACTIVE"], activeName))
    end

    local nameInputLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameInputLabel:SetPoint("TOPLEFT", 20, -80)
    nameInputLabel:SetText(L["PROFILE_NAME_LABEL"])

    local nameInput = CreateFrame("EditBox", "MyEmoteProfileNameInput", scrollChild, "InputBoxTemplate")
    nameInput:SetPoint("TOPLEFT", 20, -96)
    nameInput:SetSize(180, 20)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(64)
    if MyEmoteActiveProfile then
        nameInput:SetText(MyEmoteActiveProfile)
    end

    local saveBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    saveBtn:SetPoint("LEFT", nameInput, "RIGHT", 8, 0)
    saveBtn:SetSize(100, 22)
    saveBtn:SetText(L["PROFILE_SAVE_BTN"])
    saveBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        MyEmote_Profiles_Save(name)
        MyEmote_Config_RefreshUI()
    end)

    local selectLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    selectLabel:SetPoint("TOPLEFT", 20, -130)
    selectLabel:SetText(L["PROFILE_SELECT_LABEL"])

    profileDropdown = CreateFrame("Frame", "MyEmoteProfileDropdown", scrollChild, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", 5, -148)
    UIDropDownMenu_SetWidth(profileDropdown, 152)
    UIDropDownMenu_Initialize(profileDropdown, MyEmote_ProfileDropdown_Init)

    local loadBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    loadBtn:SetPoint("TOPLEFT", 20, -193)
    loadBtn:SetSize(100, 22)
    loadBtn:SetText(L["PROFILE_LOAD_BTN"])
    loadBtn:SetScript("OnClick", function()
        local name = UIDropDownMenu_GetSelectedValue(profileDropdown)
        if name then
            nameInput:SetText(name)
            MyEmote_Profiles_Load(name)
        else
            print("|cffff6600MyEmote:|r " .. L["PROFILE_SELECT_FIRST"])
        end
    end)

    local deleteBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    deleteBtn:SetPoint("LEFT", loadBtn, "RIGHT", 8, 0)
    deleteBtn:SetSize(100, 22)
    deleteBtn:SetText(L["PROFILE_DELETE_BTN"])
    deleteBtn:SetScript("OnClick", function()
        local name = UIDropDownMenu_GetSelectedValue(profileDropdown)
        if name then
            MyEmote_Profiles_Delete(name)
            UIDropDownMenu_SetSelectedValue(profileDropdown, nil)
            MyEmote_Config_RefreshUI()
        else
            print("|cffff6600MyEmote:|r " .. L["PROFILE_SELECT_FIRST"])
        end
    end)

    -- ========================================================================
    -- SECCIÓN: CONFIGURACIÓN DEL MENÚ RADIAL
    -- ========================================================================
    local sectionTitle = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sectionTitle:SetPoint("TOPLEFT", 20, -235)
    sectionTitle:SetText("|cff00ff00" .. L["SECTION_RADIAL"] .. "|r")
    
    local desc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 20, -255)
    desc:SetText(L["SECTION_RADIAL_DESC"])
    
    -- Sliders de configuración
    local yOffset = -285
    
    -- Radio del menú
    createSlider(scrollChild, "MyEmoteRadiusSlider", L["SLIDER_RADIUS"], 80, 200, 10, 20, yOffset, 
        MyEmoteSettings.wheelRadius or DEFAULT_WHEEL_CONFIG.radius,
        function(value)
            MyEmoteSettings.wheelRadius = value
        end)
    
    yOffset = yOffset - 50
    
    -- Opacidad del fondo
    createSlider(scrollChild, "MyEmoteBgOpacitySlider", L["SLIDER_OPACITY"], 0.3, 1.0, 0.05, 20, yOffset,
        MyEmoteSettings.bgOpacity or DEFAULT_WHEEL_CONFIG.bgOpacity,
        function(value)
            MyEmoteSettings.bgOpacity = value
        end)
    
    yOffset = yOffset - 50
    
    -- Grosor de líneas
    createSlider(scrollChild, "MyEmoteLineSlider", L["SLIDER_LINE"], 1, 5, 1, 20, yOffset,
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
    emotesTitle:SetText("|cff00ff00" .. L["SECTION_EMOTES"] .. "|r")
    
    local emotesDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emotesDesc:SetPoint("TOPLEFT", 20, yOffset - 20)
    emotesDesc:SetText(L["SECTION_EMOTES_DESC"])
    
    -- Contador de emotes seleccionados
    local counterText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    counterText:SetPoint("TOPLEFT", 20, yOffset - 40)
    
    local function updateCounter()
        local color = numberOfEmotesChecked >= 12 and "|cffff0000" or "|cff00ff00"
        counterText:SetText(string.format(L["EMOTES_COUNTER"], color, numberOfEmotesChecked))
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
