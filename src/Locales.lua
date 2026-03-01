-- =============================================================================
-- MyEmote - Locales.lua
-- Supported: esES / esMX (Spanish), everything else falls back to English.
-- Usage: local L = MyEmoteL
-- =============================================================================

MyEmoteL = {}
local L = MyEmoteL

local locale = GetLocale()
local isSpanish = (locale == "esES" or locale == "esMX")

if isSpanish then
    -- Radial menu
    L["MAX_EMOTES_REACHED"]   = "Máximo 12 emotes permitidos en el menú radial."
    L["SECTION_RADIAL"]       = "Configuración del Menú Radial"
    L["SECTION_RADIAL_DESC"]  = "Personaliza la apariencia del menú circular de emotes (máx. 12 emotes)"
    L["SLIDER_RADIUS"]        = "Tamaño del menú"
    L["SLIDER_OPACITY"]       = "Opacidad del fondo"
    L["SLIDER_LINE"]          = "Grosor de líneas"
    -- Emote selection
    L["SECTION_EMOTES"]       = "Seleccionar Emotes"
    L["SECTION_EMOTES_DESC"]  = "Selecciona hasta 12 emotes para mostrar en el menú radial"
    L["EMOTES_COUNTER"]       = "Emotes seleccionados: %s%d/12|r"
    -- Profile management (panel)
    L["SECTION_PROFILES"]     = "Gestión de Perfiles"
    L["SECTION_PROFILES_DESC"]= "Guarda y carga configuraciones compartidas entre personajes."
    L["PROFILE_ACTIVE"]       = "Perfil activo: |cffffd700%s|r"
    L["PROFILE_NONE"]         = "ninguno"
    L["PROFILE_NAME_LABEL"]   = "Nombre del perfil:"
    L["PROFILE_SELECT_LABEL"] = "Seleccionar perfil:"
    L["PROFILE_SAVE_BTN"]     = "Guardar perfil"
    L["PROFILE_LOAD_BTN"]     = "Cargar perfil"
    L["PROFILE_DELETE_BTN"]   = "Eliminar perfil"
    L["PROFILE_SELECT_FIRST"] = "Selecciona un perfil de la lista."
    -- Profile engine messages
    L["PROFILE_NO_NAME"]        = "Indica un nombre para el perfil."
    L["PROFILE_SAVED"]          = "Perfil '%s' guardado."
    L["PROFILE_NO_NAME_LOAD"]   = "Indica un nombre de perfil para cargar."
    L["PROFILE_NOT_FOUND"]      = "El perfil '%s' no existe."
    L["PROFILE_LOADED"]         = "Perfil '%s' cargado."
    L["PROFILE_NO_NAME_DELETE"] = "Indica un nombre de perfil para eliminar."
    L["PROFILE_DELETED"]        = "Perfil '%s' eliminado."
    -- Misc
    L["EMOTE_COUNT"]         = "Has usado %d emotes!"
    L["ACHIEVEMENT_100"]     = "¡Has conseguido 100 emotes!"
else
    -- Radial menu
    L["MAX_EMOTES_REACHED"]   = "Maximum 12 emotes allowed in the radial menu."
    L["SECTION_RADIAL"]       = "Radial Menu Settings"
    L["SECTION_RADIAL_DESC"]  = "Customize the appearance of the emote wheel (max. 12 emotes)"
    L["SLIDER_RADIUS"]        = "Menu size"
    L["SLIDER_OPACITY"]       = "Background opacity"
    L["SLIDER_LINE"]          = "Line thickness"
    -- Emote selection
    L["SECTION_EMOTES"]       = "Select Emotes"
    L["SECTION_EMOTES_DESC"]  = "Select up to 12 emotes to display in the radial menu"
    L["EMOTES_COUNTER"]       = "Selected emotes: %s%d/12|r"
    -- Profile management (panel)
    L["SECTION_PROFILES"]     = "Profile Management"
    L["SECTION_PROFILES_DESC"]= "Save and load configurations shared across characters."
    L["PROFILE_ACTIVE"]       = "Active profile: |cffffd700%s|r"
    L["PROFILE_NONE"]         = "none"
    L["PROFILE_NAME_LABEL"]   = "Profile name:"
    L["PROFILE_SELECT_LABEL"] = "Select profile:"
    L["PROFILE_SAVE_BTN"]     = "Save profile"
    L["PROFILE_LOAD_BTN"]     = "Load profile"
    L["PROFILE_DELETE_BTN"]   = "Delete profile"
    L["PROFILE_SELECT_FIRST"] = "Select a profile from the list."
    -- Profile engine messages
    L["PROFILE_NO_NAME"]        = "Please enter a profile name."
    L["PROFILE_SAVED"]          = "Profile '%s' saved."
    L["PROFILE_NO_NAME_LOAD"]   = "Please enter a profile name to load."
    L["PROFILE_NOT_FOUND"]      = "Profile '%s' does not exist."
    L["PROFILE_LOADED"]         = "Profile '%s' loaded."
    L["PROFILE_NO_NAME_DELETE"] = "Please enter a profile name to delete."
    L["PROFILE_DELETED"]        = "Profile '%s' deleted."
    -- Misc
    L["EMOTE_COUNT"]         = "You have used %d emotes!"
    L["ACHIEVEMENT_100"]     = "You have achieved 100 emotes!"
end
