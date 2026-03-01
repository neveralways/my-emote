-- =============================================================================
-- MyEmote - Profiles.lua
-- Sistema de perfiles: guarda y restaura configuraciones entre personajes.
-- MyEmoteProfiles  → SavedVariables (cuenta, compartido entre personajes)
-- MyEmoteActiveProfile → SavedVariablesPerCharacter (qué perfil usa este alt)
-- =============================================================================

MyEmoteProfiles = MyEmoteProfiles or { profiles = {} }
MyEmoteActiveProfile = MyEmoteActiveProfile or nil
local L = MyEmoteL

-- Copia superficial de una tabla de ajustes (claves string → boolean/number/nil)
local function copySettings(src)
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = v
    end
    return copy
end

--- Guarda MyEmoteSettings como un perfil con el nombre dado.
function MyEmote_Profiles_Save(name)
    if not name or name == "" then
        print("|cffff6600MyEmote:|r " .. L["PROFILE_NO_NAME"])
        return
    end
    MyEmoteProfiles.profiles[name] = copySettings(MyEmoteSettings)
    MyEmoteActiveProfile = name
    print("|cff00ff00MyEmote:|r " .. string.format(L["PROFILE_SAVED"], name))
end

--- Carga un perfil guardado en MyEmoteSettings y refresca la UI de config.
function MyEmote_Profiles_Load(name)
    if not name or name == "" then
        print("|cffff6600MyEmote:|r " .. L["PROFILE_NO_NAME_LOAD"])
        return
    end
    if not MyEmoteProfiles.profiles[name] then
        print("|cffff6600MyEmote:|r " .. string.format(L["PROFILE_NOT_FOUND"], name))
        return
    end
    wipe(MyEmoteSettings)
    for k, v in pairs(MyEmoteProfiles.profiles[name]) do
        MyEmoteSettings[k] = v
    end
    MyEmoteActiveProfile = name
    if MyEmote_Config_RefreshUI then
        MyEmote_Config_RefreshUI()
    end
    print("|cff00ff00MyEmote:|r " .. string.format(L["PROFILE_LOADED"], name))
end

--- Elimina un perfil del banco de perfiles.
function MyEmote_Profiles_Delete(name)
    if not name or name == "" then
        print("|cffff6600MyEmote:|r " .. L["PROFILE_NO_NAME_DELETE"])
        return
    end
    if not MyEmoteProfiles.profiles[name] then
        print("|cffff6600MyEmote:|r " .. string.format(L["PROFILE_NOT_FOUND"], name))
        return
    end
    MyEmoteProfiles.profiles[name] = nil
    if MyEmoteActiveProfile == name then
        MyEmoteActiveProfile = nil
    end
    print("|cff00ff00MyEmote:|r " .. string.format(L["PROFILE_DELETED"], name))
end

--- Devuelve una lista ordenada con los nombres de todos los perfiles guardados.
function MyEmote_Profiles_GetList()
    local list = {}
    for name in pairs(MyEmoteProfiles.profiles) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

--- Auto-carga al inicio de sesión:
--- 1) Si existe un perfil activo previo para este personaje, lo carga.
--- 2) Si no, busca un perfil con el nombre del personaje actual.
function MyEmote_Profiles_AutoLoad()
    if MyEmoteActiveProfile and MyEmoteProfiles.profiles[MyEmoteActiveProfile] then
        MyEmote_Profiles_Load(MyEmoteActiveProfile)
        return
    end
    local charName = UnitName("player")
    if charName and MyEmoteProfiles.profiles[charName] then
        MyEmote_Profiles_Load(charName)
    end
end
