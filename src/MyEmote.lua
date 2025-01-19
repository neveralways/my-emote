local addonName, addonTable = ...

local eventFrame = CreateFrame("Frame", addonName .. "EventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

addonTable.eventFrame = eventFrame

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local arg1 = ...
        if arg1 == addonName then
            if MyEmote_Config_Init then
                MyEmote_Config_Init()
            end
            if MyEmote_UI_Init then
                MyEmote_UI_Init()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
    end
end)

local function showEmoteCount()
    print("You have used " .. MyEmoteData.emoteCount .. " emotes!")
end

SLASH_MYEMOTE1 = "/myemote"
SlashCmdList["MYEMOTE"] = showEmoteCount