local frame, events = CreateFrame("Frame"), {}

function events:PLAYER_LOGIN(...)
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end
