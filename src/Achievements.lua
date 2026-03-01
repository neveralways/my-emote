MyEmoteData = MyEmoteData or {
    emoteCount = 0
}

function checkAchievements()
    if MyEmoteData.emoteCount == 100 then
        local L = MyEmoteL
        print(L["ACHIEVEMENT_100"])
    end
end

function addEmoteCount()
    MyEmoteData.emoteCount = MyEmoteData.emoteCount + 1
    checkAchievements()
end

