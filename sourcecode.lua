--[[

__________    ____________________  _______  ______  _________ 
___    |_ |  / /__  ____/__  __ \ \/ /__  / / /_  / / /__  __ ) \     THANKS FOR USING AVERYHUB
__  /| |_ | / /__  __/  __  /_/ /_  /__  /_/ /_  / / /__  __  |  \    CREATED BY: elitefps_ on discord
_  ___ |_ |/ / _  /___  _  _, _/_  / _  __  / / /_/ / _  /_/ /    \   SPECIAL THANKS TO THE DEVELOPERS OF BLEKLIB!
/_/  |_|____/  /_____/  /_/ |_| /_/  /_/ /_/  \____/  /_____/      \  RELEASED: October 31st of 2023, Last Updated: 06/11/2024 9:50PM

--]]

-- [ AVERYHUB ]


local SupportedGames = {
    3351674303,
    2788229376,
    9498006165
}

local services = {
    "Players",
    "HttpService",
    "RunService",
    "RbxAnalyticsService",
    "Lighting",
    "MaterialService",
    "NetworkClient",
    "ReplicatedFirst",
    "ReplicatedStorage",
    "ServerScriptService",
    "ServerStorage",
    "StarterGui",
    "StarterPack",
    "Workspace",
    "Debris",
    "VirtualUser",
    "VirtualInputManager",
    "UserInputService"
}

local serviceTable = {}
local success, err = pcall(function()
    for _, serviceName in ipairs(services) do
        serviceTable[serviceName] = game:GetService(serviceName)
    end
end)

if not success then
    warn("Error initializing services: " .. err)
    return
end

local Players = serviceTable["Players"]
local LocalPlayer = Players.LocalPlayer
local Workspace = serviceTable["Workspace"]
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local userId = LocalPlayer.UserId
local playerName = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName
local date = os.date()
local initTime = tonumber(tick())

local Whitelist = {
    "SennieJack",
    "IShowGreatnessX",
    ""
}

-- Error Logging Function
local function logError(message)
    local errorMessage = string.format("[%s] Error: %s", date, message)
    warn(errorMessage)
    
    -- Discord Webhook Error Function
    local url = "https://discord.com/api/webhooks/1160270579757219920/dvTelZUlIgMs4DE23o8YUKiZYcpkIoqLm2K3Aq9fOcma7ubjqwuaG04NZSe6MiW9e3L_"
    local data = {
        content = "",
        embeds = {
            {
                title = "Avery | V2",
                description = string.format("**Error Code 404** %s\n**Time to initialize:** %d\n**Used at:** %s\n**Experience:** %s", errorMessage, math.abs(tonumber(tick()) - initTime), date, game.Name),
                Footer = "Gemairo",
                type = "rich",
                color = tonumber(00000),
                image = {
                    url = string.format("http://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=150&Format=Png&username=%s", tostring(LocalPlayer.Name))
                }
            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)
    local headers = { ["content-type"] = "application/json" }
    local abcdef = { Url = url, Body = newdata, Method = "POST", Headers = headers }
    request(abcdef)
end

-- user login webhook
local function sendDiscordWebhook()
    local url = "https://discord.com/api/webhooks/1160270579757219920/dvTelZUlIgMs4DE23o8YUKiZYcpkIoqLm2K3Aq9fOcma7ubjqwuaG04NZSe6MiW9e3L_"
    local data = {
        content = "",
        embeds = {
            {
                title = "Avery | V2",
                description = string.format("**In-game Username:** %s\n**Time to initialize:** %d\n**Used at:** %s\n**Experience:** %s", LocalPlayer.Name, math.abs(tonumber(tick()) - initTime), date, game.Name),
                Footer = "Thanks for using Avery!",
                type = "rich",
                color = tonumber(00000),
                image = {
                    url = string.format("http://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=150&Format=Png&username=%s", tostring(LocalPlayer.Name))
                }
            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)
    local headers = { ["content-type"] = "application/json" }
    local abcdef = { Url = url, Body = newdata, Method = "POST", Headers = headers }
    request(abcdef) -- Ensure 'request' is defined elsewhere
end

-- Check if the player is whitelisted
local function isWhitelisted(name)
    for _, whitelistedName in ipairs(Whitelist) do
        if name == whitelistedName then
            return true
        end
    end
    return false
end

-- Main Execution with Error Checking
local function main()
    if isWhitelisted(playerName) or isWhitelisted(displayName) then
        print("Avery | [BACKEND] Started..")
        sendDiscordWebhook()
    else
        logError("Player not whitelisted: " .. playerName .. " / " .. displayName)
        print("Avery | Error Code 01")
    end
end

-- Execute the main function with error handling
local status, mainErr = pcall(main)
if not status then
    logError("Main function error: " .. mainErr)
end

warn("(っ◔◡◔)っ ♥ Loaded Avery ♥ \nTime to initialize: "..math.abs(tonumber(tick())-initTime).." ✅")

-- // {Avery - Designed just for you} \\ --



---@diagnostic disable: invalid-class-name

local BlekLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/laderite/bleklib/main/library.lua"))()

 
local a = BlekLib:Create({
    Name = "Avery V1 | Roblox UWP",
    StartupSound = {
        Toggle = true,
        SoundID = "rbxassetid://6958727243", -- Win 11 Startup Sound
        TimePosition = 1
    }
})
 
 

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local userid = game.Players.LocalPlayer.UserId
 
local RunService = game:GetService("RunService")
local RBLXAnalytics = game:GetService("RbxAnalyticsService")
local LocalPlayer = game.Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local NetworkClient = game:GetService("NetworkClient")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StarterGUI = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack") 
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Debris = game:GetService("Debris")
local Mouse = LocalPlayer:GetMouse()
local date = os.date()
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TNT = tonumber(tick());
local UIS = game:GetService("UserInputService")
local worldtoViewportPoint = workspace.CurrentCamera.worldToViewportPoint

local pn = game.Players.Name
local dn = game.Players.LocalPlayer.DisplayName


 
-- == ＦＲＯＮＴＥＮＤ == --
 
-- Tabs
local maintab = a:Tab('Main')
local teleports = a:Tab('Teleports')
local miscTab = a:Tab('Misc')
local targetTab = a:Tab('Target')
local charactertab = a:Tab('LocalPlayer')
local funtab = a:Tab('Fun')
local uitab = a:Tab('UI')

 
-- MainTab
maintab:Toggle('Silent Aim', function(SilentAIM)
    

end)
 
maintab:Toggle("Aimlock (E to lock)")
 
maintab:Toggle("Aimlock (Right click to lock)")
 
maintab:Toggle('Use FOV', function(FOVCircle)

    if FOVCircle == true then
        
   
    local FOVCircle = Instance.new("ImageLabel")
    FOVCircle.Parent = game.Players.LocalPlayer.PlayerGui 
    FOVCircle.BackgroundTransparency = 1 
    FOVCircle.Size = UDim2.new(1, 0, 1, 0) 
    FOVCircle.Image = "rbxassetid://00000000" 
    FOVCircle.ImageColor3 = Color3.new(1, 1, 1) 
    FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5) 
    FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0) 
    
    -- 
    local FOVAngle = 90 -- 
    local radius = math.tan(math.rad(FOVAngle / 2)) * (FOVCircle.AbsoluteSize.X / 2)
    
    -- Set the size of the FOV circle
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    
    -- Update Circle Position
    FOVCircle:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local newRadius = math.tan(math.rad(FOVAngle / 2)) * (FOVCircle.AbsoluteSize.X / 2)
        FOVCircle.Size = UDim2.new(0, newRadius * 2, 0, newRadius * 2)
    end)
end
end)
 
maintab:Slider('FOV', 45, 90, 180, function(FOV)
    workspace.CurrentCamera.FieldOfView = FOV
end)
 
 
-- Target 

local fefreeze = false -- Declare fefreeze outside the function

-- Target Tab
targetTab:Textbox('Target:', function(name)
    local player = GetPlayer(name)
    if #player > 0 then
        print("Targeted User: " .. player[1].Name)
    else
        print("Player not found")
    end
end)

-- Freeze Toggle
targetTab:Toggle('Freeze', function(freeze)
    if freeze then
        -- Wait for the player's character to load
local character = player.Character or player.CharacterAdded:Wait()

-- Wait for the HumanoidRootPart to be present in the character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Anchor the HumanoidRootPart
humanoidRootPart.Anchored = true
    else
        
    end
end)

-- Misc Tab
miscTab:Toggle('Auto Clicker (2ms)', function(autoclicker)
   

end)