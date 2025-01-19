MyEmoteData = MyEmoteData or {
    emoteCount = 0
}

function checkAchievements()
    if MyEmoteData.emoteCount == 100 then
        print("You have achieved 100 emotes!")
    end
end

function addEmoteCount()
    MyEmoteData.emoteCount = MyEmoteData.emoteCount + 1
    checkAchievements()
end

