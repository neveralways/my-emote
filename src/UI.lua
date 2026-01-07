local addonName, addonTable = ...

-- ============================================================================
-- CONFIGURACIÓN DEL MENÚ RADIAL
-- ============================================================================
local WHEEL_CONFIG = {
    radius = 120,                    -- Radio del menú
    innerRadius = 30,                -- Radio interior (zona muerta central)
    bgColor = {0.1, 0.1, 0.1, 0.85}, -- Color de fondo (R, G, B, Alpha)
    highlightColor = {0.3, 0.6, 1, 0.6}, -- Color del highlight (azul)
    lineColor = {0.8, 0.8, 0.8, 0.9},    -- Color de las líneas divisorias
    lineThickness = 2,               -- Grosor de las líneas
    textColor = {1, 1, 1, 1},        -- Color del texto
    selectedTextColor = {1, 0.82, 0, 1}, -- Color del texto seleccionado (dorado)
    maxEmotes = 12,                  -- Máximo de emotes permitidos
    animDuration = 0.15,             -- Duración de animación de apertura
}

-- Función para cargar configuración guardada
local function loadSavedConfig()
    if MyEmoteSettings then
        if MyEmoteSettings.wheelRadius then
            WHEEL_CONFIG.radius = MyEmoteSettings.wheelRadius
        end
        if MyEmoteSettings.bgOpacity then
            WHEEL_CONFIG.bgColor[4] = MyEmoteSettings.bgOpacity
        end
        if MyEmoteSettings.lineThickness then
            WHEEL_CONFIG.lineThickness = MyEmoteSettings.lineThickness
        end
    end
end

-- ============================================================================
-- FRAME PRINCIPAL
-- ============================================================================
local wheel = CreateFrame("Frame", "MyEmoteFrame", UIParent)
wheel:SetFrameStrata("DIALOG")
wheel:SetFrameLevel(100)
wheel:Hide()

-- Elementos visuales
local segments = {}          -- Texturas de segmentos
local dividerLines = {}      -- Líneas divisorias
local labels = {}            -- Etiquetas de texto
local backgroundCircle       -- Círculo de fondo
local backgroundMask         -- Máscara circular (reutilizable)
local highlightWedge         -- Textura de highlight para el segmento seleccionado
local highlightLines = {}    -- Líneas del highlight
local centerText             -- Texto del centro para cerrar
local centerCircle           -- Círculo central
local currentEmotes = {}     -- Emotes actuales
local selectedSegment = nil  -- Segmento actualmente seleccionado

-- ============================================================================
-- FUNCIONES UTILITARIAS
-- ============================================================================
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

    -- Limitar a máximo de emotes
    if #selectedEmotes > WHEEL_CONFIG.maxEmotes then
        local limited = {}
        for i = 1, WHEEL_CONFIG.maxEmotes do
            limited[i] = selectedEmotes[i]
        end
        selectedEmotes = limited
    end

    table.sort(selectedEmotes)
    return selectedEmotes
end

-- Calcula el ángulo desde el centro hacia el cursor (en radianes)
local function getAngleFromCenter()
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / uiScale, cursorY / uiScale
    
    local centerX, centerY = wheel:GetCenter()
    if not centerX or not centerY then return nil, 0 end
    
    local dx = cursorX - centerX
    local dy = cursorY - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)
    
    return angle, distance
end

-- Obtiene el índice del segmento basado en el ángulo
local function getSegmentFromAngle(angle, numSegments)
    if numSegments == 0 then return nil end
    if numSegments == 1 then return 1 end
    
    -- Ajustar ángulo para que el primer segmento esté arriba (90°)
    local adjustedAngle = angle + math.pi / 2
    if adjustedAngle < 0 then
        adjustedAngle = adjustedAngle + 2 * math.pi
    end
    
    local segmentAngle = (2 * math.pi) / numSegments
    local segment = math.floor(adjustedAngle / segmentAngle) + 1
    
    if segment > numSegments then segment = 1 end
    return segment
end

-- ============================================================================
-- CREACIÓN DE ELEMENTOS VISUALES
-- ============================================================================
local function clearVisualElements()
    -- Limpiar segmentos
    for _, seg in pairs(segments) do
        if type(seg) == "table" and seg.Hide then
            seg:Hide()
            seg:SetParent(nil)
        end
    end
    segments = {}
    
    -- Limpiar líneas
    for _, line in pairs(dividerLines) do
        line:Hide()
    end
    dividerLines = {}
    
    -- Limpiar líneas de highlight
    for _, line in pairs(highlightLines) do
        line:Hide()
    end
    highlightLines = {}
    
    -- Limpiar etiquetas
    for _, label in pairs(labels) do
        label:Hide()
        label:SetParent(nil)
    end
    labels = {}
    
    -- Ocultar fondo (no destruir para reutilizar la máscara)
    if backgroundCircle then
        backgroundCircle:Hide()
    end
    
    -- Ocultar highlight wedge
    if highlightWedge then
        highlightWedge:Hide()
    end
    
    -- Ocultar texto del centro
    if centerText then
        centerText:Hide()
    end
end

-- Crea el fondo circular semi-transparente
local function createBackground()
    if not backgroundCircle then
        backgroundCircle = wheel:CreateTexture(nil, "BACKGROUND")
        backgroundCircle:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        backgroundCircle:SetAllPoints(wheel)
        
        -- Crear máscara circular UNA SOLA VEZ
        if not backgroundMask then
            backgroundMask = wheel:CreateMaskTexture()
            backgroundMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            backgroundMask:SetAllPoints(wheel)
            backgroundCircle:AddMaskTexture(backgroundMask)
        end
    end
    
    -- Actualizar color y mostrar
    backgroundCircle:SetVertexColor(unpack(WHEEL_CONFIG.bgColor))
    backgroundCircle:Show()
end

-- Dibuja las líneas divisorias desde el centro hacia afuera
local function createDividerLines(numSegments)
    if numSegments <= 1 then return end
    
    local radius = WHEEL_CONFIG.radius
    local innerRadius = WHEEL_CONFIG.innerRadius
    local segmentAngle = (2 * math.pi) / numSegments
    
    for i = 1, numSegments do
        local line = wheel:CreateLine(nil, "OVERLAY")
        line:SetThickness(WHEEL_CONFIG.lineThickness)
        line:SetColorTexture(unpack(WHEEL_CONFIG.lineColor))
        
        -- Ángulo de esta línea (empezando desde arriba, entre segmentos)
        local angle = (i - 1) * segmentAngle - math.pi / 2
        
        -- Punto interior
        local innerX = math.cos(angle) * innerRadius
        local innerY = math.sin(angle) * innerRadius
        
        -- Punto exterior
        local outerX = math.cos(angle) * radius
        local outerY = math.sin(angle) * radius
        
        line:SetStartPoint("CENTER", wheel, innerX, innerY)
        line:SetEndPoint("CENTER", wheel, outerX, outerY)
        
        table.insert(dividerLines, line)
    end
end

-- Crea el círculo de fondo usando líneas (más compatible)
local function createCircleOutline()
    local radius = WHEEL_CONFIG.radius
    local numPoints = 64  -- Más puntos = círculo más suave
    
    for i = 1, numPoints do
        local line = wheel:CreateLine(nil, "BORDER")
        line:SetThickness(WHEEL_CONFIG.lineThickness)
        line:SetColorTexture(unpack(WHEEL_CONFIG.lineColor))
        
        local angle1 = (i - 1) * (2 * math.pi / numPoints)
        local angle2 = i * (2 * math.pi / numPoints)
        
        local x1 = math.cos(angle1) * radius
        local y1 = math.sin(angle1) * radius
        local x2 = math.cos(angle2) * radius
        local y2 = math.sin(angle2) * radius
        
        line:SetStartPoint("CENTER", wheel, x1, y1)
        line:SetEndPoint("CENTER", wheel, x2, y2)
    end
    
    -- Círculo interior
    local innerRadius = WHEEL_CONFIG.innerRadius
    for i = 1, numPoints do
        local line = wheel:CreateLine(nil, "BORDER")
        line:SetThickness(1)
        line:SetColorTexture(unpack(WHEEL_CONFIG.lineColor))
        
        local angle1 = (i - 1) * (2 * math.pi / numPoints)
        local angle2 = i * (2 * math.pi / numPoints)
        
        local x1 = math.cos(angle1) * innerRadius
        local y1 = math.sin(angle1) * innerRadius
        local x2 = math.cos(angle2) * innerRadius
        local y2 = math.sin(angle2) * innerRadius
        
        line:SetStartPoint("CENTER", wheel, x1, y1)
        line:SetEndPoint("CENTER", wheel, x2, y2)
    end
end

-- Los segmentos ahora solo trackean índices, no hay highlight visual de fondo
local function createSegmentBackgrounds(numSegments)
    -- Simplemente crear tabla de índices, el highlight será solo en el texto
    for i = 1, numSegments do
        segments[i] = { index = i }
    end
end

-- Crea el highlight visual para un segmento usando líneas
local function createHighlightWedge()
    if not highlightWedge then
        highlightWedge = wheel:CreateTexture(nil, "ARTWORK")
        highlightWedge:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        highlightWedge:SetVertexColor(WHEEL_CONFIG.highlightColor[1], WHEEL_CONFIG.highlightColor[2], 
                                      WHEEL_CONFIG.highlightColor[3], 0.25)
        highlightWedge:SetBlendMode("ADD")
    end
    highlightWedge:Hide()
end

-- Actualiza el highlight visual del segmento seleccionado
local function updateHighlightWedge(segmentIndex, numSegments)
    if not highlightWedge or not segmentIndex or numSegments == 0 then
        if highlightWedge then highlightWedge:Hide() end
        for _, line in pairs(highlightLines) do
            line:Hide()
        end
        return
    end
    
    local radius = WHEEL_CONFIG.radius
    local innerRadius = WHEEL_CONFIG.innerRadius
    local segmentAngle = (2 * math.pi) / numSegments
    
    -- Calcular ángulos del segmento
    local startAngle = (segmentIndex - 1) * segmentAngle - math.pi / 2
    local endAngle = segmentIndex * segmentAngle - math.pi / 2
    local midAngle = (startAngle + endAngle) / 2
    
    -- Dibujar líneas del wedge para dar efecto de segmento iluminado
    local numWedgeLines = 12
    for i = 1, numWedgeLines do
        if not highlightLines[i] then
            highlightLines[i] = wheel:CreateLine(nil, "ARTWORK")
            highlightLines[i]:SetThickness(math.max(1, (radius - innerRadius) / numWedgeLines))
        end
        
        local line = highlightLines[i]
        line:SetColorTexture(WHEEL_CONFIG.highlightColor[1], WHEEL_CONFIG.highlightColor[2], 
                             WHEEL_CONFIG.highlightColor[3], 0.2)
        
        -- Distribuir las líneas a través del segmento
        local t = (i - 1) / (numWedgeLines - 1)
        local angle = startAngle + t * segmentAngle
        
        local innerX = math.cos(angle) * innerRadius
        local innerY = math.sin(angle) * innerRadius
        local outerX = math.cos(angle) * radius
        local outerY = math.sin(angle) * radius
        
        line:SetStartPoint("CENTER", wheel, innerX, innerY)
        line:SetEndPoint("CENTER", wheel, outerX, outerY)
        line:Show()
    end
    
    -- Ocultar líneas extra si hay menos segmentos
    for i = numWedgeLines + 1, #highlightLines do
        highlightLines[i]:Hide()
    end
end

-- Crea etiquetas de texto para cada segmento
local function createLabels(emotes)
    local numEmotes = #emotes
    local radius = WHEEL_CONFIG.radius
    local innerRadius = WHEEL_CONFIG.innerRadius
    local labelRadius = (radius + innerRadius) / 2 + 10  -- Posición del texto
    local segmentAngle = (2 * math.pi) / numEmotes
    
    for i, emote in ipairs(emotes) do
        local label = wheel:CreateFontString(nil, "OVERLAY")
        
        -- Ángulo central del segmento (empezando desde arriba)
        local angle = (i - 1) * segmentAngle - math.pi / 2 + segmentAngle / 2
        
        local x = math.cos(angle) * labelRadius
        local y = math.sin(angle) * labelRadius
        
        -- Establecer la fuente ANTES de SetText
        label:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        label:SetTextColor(unpack(WHEEL_CONFIG.textColor))
        label:SetShadowOffset(2, -2)
        label:SetShadowColor(0, 0, 0, 1)
        label:SetJustifyH("CENTER")
        label:SetJustifyV("MIDDLE")
        
        label:SetPoint("CENTER", wheel, "CENTER", x, y)
        label:SetText(emote)
        
        labels[i] = label
    end
end

-- Crea el texto en el centro indicando que se puede cerrar
local function createCenterText()
    if not centerText then
        centerText = wheel:CreateFontString(nil, "OVERLAY")
        centerText:SetPoint("CENTER", wheel, "CENTER", 0, 0)
        centerText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
        centerText:SetText("×")
        centerText:SetTextColor(0.9, 0.3, 0.3, 0.8)
        centerText:SetShadowOffset(2, -2)
        centerText:SetShadowColor(0, 0, 0, 1)
        centerText:SetJustifyH("CENTER")
        centerText:SetJustifyV("MIDDLE")
    end
    
    centerText:Show()
end

-- ============================================================================
-- SISTEMA DE HIGHLIGHT
-- ============================================================================
local function updateHighlight(segmentIndex)
    if segmentIndex == selectedSegment then return end
    
    selectedSegment = segmentIndex
    
    -- Resetear todos los labels a color normal
    for i, label in pairs(labels) do
        if label then
            label:SetTextColor(unpack(WHEEL_CONFIG.textColor))
            label:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        end
    end
    
    -- Resaltar el segmento seleccionado (solo cambio de texto)
    if segmentIndex and labels[segmentIndex] then
        labels[segmentIndex]:SetTextColor(unpack(WHEEL_CONFIG.selectedTextColor))
        labels[segmentIndex]:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    end
    
    -- Actualizar el wedge de highlight visual
    updateHighlightWedge(segmentIndex, #currentEmotes)
end

-- ============================================================================
-- LÓGICA PRINCIPAL DEL MENÚ
-- ============================================================================
local function buildWheel(emotes)
    clearVisualElements()
    
    local numEmotes = #emotes
    local size = WHEEL_CONFIG.radius * 2 + 40
    wheel:SetSize(size, size)
    
    -- Crear elementos visuales
    createBackground()
    createSegmentBackgrounds(numEmotes)
    createHighlightWedge()
    createCircleOutline()
    if numEmotes > 1 then
        createDividerLines(numEmotes)
    end
    createLabels(emotes)
    createCenterText()
    
    currentEmotes = emotes
    selectedSegment = nil
end

-- OnUpdate para detectar el segmento bajo el cursor
local function onWheelUpdate(self, elapsed)
    local angle, distance = getAngleFromCenter()
    
    if not angle then return end
    
    local numEmotes = #currentEmotes
    
    -- Detectar si está en el centro para hacer hover en la X
    if distance < WHEEL_CONFIG.innerRadius then
        -- Cursor en el centro - resaltar la X
        if centerText then
            centerText:SetTextColor(1, 0.4, 0.4, 1)
            centerText:SetFont("Fonts\\FRIZQT__.TTF", 28, "OUTLINE")
        end
        updateHighlight(nil)
    -- Solo detectar si está dentro del radio y fuera del centro
    elseif distance >= WHEEL_CONFIG.innerRadius and distance <= WHEEL_CONFIG.radius + 20 then
        -- Restaurar X a estado normal
        if centerText then
            centerText:SetTextColor(0.9, 0.3, 0.3, 0.8)
            centerText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
        end
        local segment = getSegmentFromAngle(angle, numEmotes)
        updateHighlight(segment)
    else
        -- Restaurar X a estado normal
        if centerText then
            centerText:SetTextColor(0.9, 0.3, 0.3, 0.8)
            centerText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
        end
        updateHighlight(nil)
    end
end

-- Ejecutar el emote al hacer click o soltar
local function executeSelectedEmote()
    if selectedSegment and currentEmotes[selectedSegment] then
        local emote = currentEmotes[selectedSegment]
        DoEmote(string.lower(emote))
        if addEmoteCount then
            addEmoteCount()
        end
        wheel:Hide()
        return true
    end
    return false
end

-- ============================================================================
-- ANIMACIÓN DE APERTURA
-- ============================================================================
local animationProgress = 0
local isAnimating = false

local function animateOpen()
    isAnimating = true
    animationProgress = 0
    
    local originalRadius = WHEEL_CONFIG.radius
    WHEEL_CONFIG.radius = 0
    
    local animFrame = CreateFrame("Frame")
    animFrame:SetScript("OnUpdate", function(self, elapsed)
        animationProgress = animationProgress + elapsed / WHEEL_CONFIG.animDuration
        
        if animationProgress >= 1 then
            animationProgress = 1
            isAnimating = false
            self:SetScript("OnUpdate", nil)
        end
        
        -- Easing out
        local t = 1 - (1 - animationProgress) * (1 - animationProgress)
        WHEEL_CONFIG.radius = originalRadius * t
        
        -- Reconstruir la rueda con el nuevo radio
        if wheel:IsShown() then
            buildWheel(currentEmotes)
        end
    end)
end

-- ============================================================================
-- TOGGLE Y EVENTOS
-- ============================================================================
local function ToggleWheel()
    -- Cargar configuración guardada cada vez que se abre
    loadSavedConfig()
    
    local cursorX, cursorY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    
    wheel:ClearAllPoints()
    wheel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / uiScale, cursorY / uiScale)
    
    if wheel:IsShown() then
        wheel:Hide()
    else
        currentEmotes = updateEmotes()
        buildWheel(currentEmotes)
        wheel:Show()
    end
end

-- Eventos del wheel
wheel:SetScript("OnUpdate", onWheelUpdate)

wheel:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        local _, distance = getAngleFromCenter()
        
        -- Si el click está fuera del círculo principal, cerrar
        if distance and distance > WHEEL_CONFIG.radius then
            self:Hide()
            return
        end
        
        -- Si está en el centro (zona de la X), cerrar
        if distance and distance < WHEEL_CONFIG.innerRadius then
            self:Hide()
            return
        end
        
        -- Si está en un segmento válido, ejecutar emote
        if not executeSelectedEmote() then
            self:Hide()
        end
    elseif button == "RightButton" then
        self:Hide()
    end
end)

wheel:SetScript("OnHide", function(self)
    selectedSegment = nil
    clearVisualElements()
end)

-- Cerrar al alejar mucho el cursor
wheel:SetScript("OnLeave", function(self)
    -- Solo cerrar si el cursor está muy lejos
    local _, distance = getAngleFromCenter()
    if distance > WHEEL_CONFIG.radius + 80 then
        self:Hide()
    end
end)

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================
function MyEmote_UI_Init()
    _G["ToggleWheel"] = ToggleWheel
    
    -- Registrar el frame para que responda a la tecla ESC
    tinsert(UISpecialFrames, "MyEmoteFrame")
end
