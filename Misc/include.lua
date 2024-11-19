loadstring(game:HttpGet("https://raw.githubusercontent.com/elitefps/Tundra-Public-Storage-/refs/heads/main/utilities/math.lua",true))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/elitefps/Tundra-Public-Storage-/refs/heads/main/Misc/syn%20requests.lua",true))()


local function LS(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        return;
    end
end

local services = {
    "Players", "HttpService", "RunService", "RbxAnalyticsService", "Lighting",
    "MaterialService", "NetworkClient", "ReplicatedFirst", "ReplicatedStorage",
    "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack",
    "Workspace", "Debris", "UserInputService", "TeleportService"
}

local lodeds = {}
for _, serviceName in ipairs(services) do
    lodeds[serviceName] = LS(serviceName)
end

for serviceName, service in pairs(lodeds) do
    if service then
        print("[.sys] | [>]", serviceName, "✓")
    end
end
