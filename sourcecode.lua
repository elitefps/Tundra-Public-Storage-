--[[

__________    ____________________  _______  ______  _________ 
___    |_ |  / /__  ____/__  __ \ \/ /__  / / /_  / / /__  __ ) \     THANKS FOR USING AVERYHUB
__  /| |_ | / /__  __/  __  /_/ /_  /__  /_/ /_  / / /__  __  |  \    CREATED BY: elitefps_ on discord
_  ___ |_ |/ / _  /___  _  _, _/_  / _  __  / / /_/ / _  /_/ /    \   SPECIAL THANKS TO THE DEVELOPERS OF BLEKLIB!
/_/  |_|____/  /_____/  /_/ |_| /_/  /_/ /_/  \____/  /_____/      \  RELEASED: October 31st of 2023, Last Updated: 06/11/2024 9:50PM

--]]

-- [ AVERYHUB ]


if not game:IsLoaded() then
    game.Loaded:Wait()
end

local httpRequest
do
    if syn and syn.request then
        httpRequest = syn.request
    elseif http_request then
        httpRequest = http_request
    elseif http and http.request then
        httpRequest = http.request
    elseif request then
        httpRequest = request
    else
        warn("[tundra.wtf] No HTTP request function available")
    end
end

-- Define the Signal class for custom event handling
local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

-- Check if a given value is a signal
function Signal.isSignal(value)
    return type(value) == "table" and getmetatable(value) == Signal
end

-- Create a new signal instance
function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindableEvent = Instance.new("BindableEvent")
    self._argMap = {}
    self._source = ENABLE_TRACEBACK and debug.traceback() or ""

    self._bindableEvent.Event:Connect(function(key)
        self._argMap[key] = nil
        if not self._bindableEvent and not next(self._argMap) then
            self._argMap = nil
        end
    end)

    return self
end

-- Fire the signal with given arguments
function Signal:Fire(...)
    if not self._bindableEvent then
        warn(("Signal is already destroyed. %s"):format(self._source))
        return
    end
    local args = table.pack(...)
    local key = game:GetService("HttpService"):GenerateGUID(false)
    self._argMap[key] = args
    self._bindableEvent:Fire(key)
end

-- Connect a handler function to the signal
function Signal:Connect(handler)
    assert(type(handler) == "function", "Handler must be a function")
-->
    return self._bindableEvent.Event:Connect(function(key)
        local args = self._argMap[key]
        if args then
            handler(table.unpack(args, 1, args.n))
        else
            error("Missing argument data, possibly due to reentrance.")
        end
    end)
end 

-- Wait for the signal to be fired and return the arguments
function Signal:Wait()
    local key = self._bindableEvent.Event:Wait()
    local args = self._argMap[key]
    if args then
        return table.unpack(args, 1, args.n)
    else
        error("Missing argument data, possibly due to reentrance.")
    end
end

-- Destroy the signal and clean up
function Signal:Destroy()
    if self._bindableEvent then
        self._bindableEvent:Destroy()
        self._bindableEvent = nil
    end
    setmetatable(self, nil)
end

-- Fetch data using the determined HTTP request function
local function fetchData(url)
    if httpRequest then
        local response = httpRequest({
            Url = url,
            Method = "GET"
        })
        if response and response.Body then
            return game:GetService("HttpService"):JSONDecode(response.Body)
        else
            warn("[tundra.wtf] Failed to fetch data from:", url)
        end
    else
        warn("[tundra.wtf] HTTP request function is not available")
    end
end

-- List of services to initialize
local services = {
    "Players", "HttpService", "RunService", "RbxAnalyticsService", "Lighting", "MaterialService",
    "NetworkClient", "ReplicatedFirst", "ReplicatedStorage", "ServerScriptService", "ServerStorage",
    "StarterGui", "StarterPack", "Workspace", "Debris", "VirtualUser", "VirtualInputManager", "UserInputService"
}

-- Table to store the initialized services
local serviceTable = {}
do
    local success, err = pcall(function()
        for _, serviceName in ipairs(services) do
            serviceTable[serviceName] = game:GetService(serviceName)
        end
    end)

    if not success then
        warn("Error initializing services: " .. err)
        return
    end
end

-- Local variables for frequently used services and player information
local Players = serviceTable["Players"]
local LocalPlayer = Players.LocalPlayer
local Workspace = serviceTable["Workspace"]
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local userId = LocalPlayer.UserId
local playerName = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName
local initTime = tick()

-- Whitelist of users (this should ideally be fetched from an external service or configuration)
local Whitelist = {
    {Username = "SennieJack", UserId = 1840165873},
    {Username = "IShowGreatnessX", UserId = 4910911611},
    {Username = "bbldrizzaeyyy", UserId = 6132123189},
}

-- Format time in seconds to a human-readable string
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d hours, %02d minutes, %02d seconds", hours, minutes, secs)
end

-- Log errors and send them to a Discord webhook
local function logError(message)
    local errorMessage = string.format("[%s] Error: %s", os.date(), message)
    warn(errorMessage)

    local elapsedTime = tick() - initTime
    local formattedTime = formatTime(elapsedTime)
    local tickTime = string.format("%.4f", elapsedTime)

    local url = "https://discord.com/api/webhooks/1160270579757219920/dvTelZUlIgMs4DE23o8YUKiZYcpkIoqLm2K3Aq9fOcma7ubjqwuaG04NZSe6MiW9e3L_"
    local data = {
        content = "",
        embeds = {
            {
                title = "tundra.wtf | Backend Error",
                description = string.format("**Error Code 404**\n%s\n**Time to initialize:** %s\n**Tick time:** %s\n**Used at:** %s\n**Experience:** %s", errorMessage, formattedTime, tickTime, os.date(), game.Name),
                footer = { text = "tundra.wtf" },
                type = "rich",
                color = tonumber("00000"),
                thumbnail = {
                    url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)
                }
            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)
    local headers = { ["Content-Type"] = "application/json" }
    local requestTable = { Url = url, Body = newdata, Method = "POST", Headers = headers }
    httpRequest(requestTable)
end

-- Send a Discord webhook with initialization details
local function sendDiscordWebhook()
    local elapsedTime = tick() - initTime
    local formattedTime = formatTime(elapsedTime)
    local tickTime = string.format("%.4f", elapsedTime)

    local url = "https://discord.com/api/webhooks/1160270579757219920/dvTelZUlIgMs4DE23o8YUKiZYcpkIoqLm2K3Aq9fOcma7ubjqwuaG04NZSe6MiW9e3L_"
    local data = {
        content = "",
        embeds = {
            {
                title = "tundra.wtf | Backend Initialization",
                description = string.format("**In-game Username:** %s\n**Time to initialize:** %s\n**Tick time:** %s\n**Used at:** %s\n**Experience:** %s", playerName, formattedTime, tickTime, os.date(), game.Name),
                footer = { text = "tundra.wtf" },
                type = "rich",
                color = tonumber("00000"),
                thumbnail = {
                    url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)
                }
            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)
    local headers = { ["Content-Type"] = "application/json" }
    local requestTable = { Url = url, Body = newdata, Method = "POST", Headers = headers }
    httpRequest(requestTable)
end

-- Check if a player is whitelisted
local function isWhitelisted(player)
    local playerName = player.Name
    local displayName = player.DisplayName
    local userId = player.UserId

    for _, entry in ipairs(Whitelist) do
        if (entry.Username == playerName or entry.Username == displayName) and entry.UserId == userId then
            return true
        end
    end
    return false
end

-- Kick non-whitelisted players
Players.PlayerAdded:Connect(function(player)
    if not isWhitelisted(player) then
        player:Kick("You are not whitelisted!")
    else
        print("[tundra.wtf] Whitelisted player joined:", player.Name)
    end
end)

local function generateRandomString(length)
    local chars = {}
    for i = 1, length do
        chars[i] = string.char(math.random(97, 122)) -- ASCII values for lowercase letters
    end
    return table.concat(chars)
end

local function fakeScript()
    local scriptName = generateRandomString(10) .. ".lua"
    local scriptContent = "print('Executing fake script: " .. scriptName .. "')"
    local fakeScript = Instance.new("Script")
    fakeScript.Name = scriptName
    fakeScript.Source = scriptContent
    fakeScript.Parent = game:GetService("ServerScriptService")

    wait(1)
    local success, err = pcall(function()
        loadstring(scriptContent)()
    end)
    if not success then
        logError("Failed to execute fake script: " .. err)
    end
end

-- Debug API Testing Script
if not debug then
    print("Debug API not found, skipping checks.")
    return
end

local function safeAssert(call, errMsg)
    assert(not pcall(call), errMsg)
end

-- Test stack functions
if debug.getstack then
    print("Testing debug.getstack...")

    safeAssert(function() debug.getstack(1, 0) end, "getstack must be one-based")
    safeAssert(function() debug.getstack(1, -1) end, "getstack must not allow negative numbers")
    safeAssert(function() local size = #debug.getstack(1); debug.getstack(1, size + 1) end, "getstack must check bounds (use L->ci->top)")

    if newcclosure then
        safeAssert(function() newcclosure(function() debug.getstack(2, 1) end)() end, "getstack must not allow reading the stack from C functions")
    end
else
    print("debug.getstack not found, skipping checks.")
end

-- Test setstack functions
if debug.setstack then
    print("Testing debug.setstack...")

    safeAssert(function() debug.setstack(1, 0, nil) end, "setstack must be one-based")
    safeAssert(function() debug.setstack(1, -1, nil) end, "setstack must not allow negative numbers")
    safeAssert(function() local size = #debug.getstack(1); debug.setstack(1, size + 1, "") end, "setstack must check bounds (use L->ci->top)")

    if newcclosure then
        safeAssert(function() newcclosure(function() debug.setstack(2, 1, nil) end)() end, "setstack must not allow C functions to have stack values set")
    end

    safeAssert(function()
        local a = 1
        debug.setstack(1, 1, true)
        print(a)
    end, "setstack must check if the target type is the same (block writing stack if the source type does not match the target type)")
else
    print("debug.setstack not found, skipping checks.")
end

-- Test upvalue functions
if debug.getupvalues and debug.getupvalue and debug.setupvalue then
    print("Testing debug.getupvalue(s)/setupvalue...")

    local upvalue = 1
    local function x()
        print(upvalue)
        upvalue = 124
    end

    -- Ensure setupvalue checks upvalue bounds
    safeAssert(function() debug.setupvalue(x, 2, nil) end, "setupvalue must check upvalue bounds (use cl->nupvals)")
    
    -- Ensure setupvalue does not allow C functions to have upvalues set
    safeAssert(function() debug.setupvalue(game.GetChildren, 1, nil) end, "setupvalue must not allow C functions to have upvalues set")
else
    print("debug.getupvalue(s)/setupvalue not found, skipping checks.")
end

-- Test protos functions
if debug.getprotos then
    print("Testing debug.getprotos...")
else
    print("debug.getprotos not found, skipping checks.")
end

-- Clean up player data when they leave the game
local function cleanUpPlayer(player)
    if player.Character then
        player.Character:Destroy()
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    cleanUpPlayer(player)
end)

local exampleSignal = Signal.new()

exampleSignal:Connect(function(...)
    print("Signal fired with arguments:", ...)
end)

wait(2)
exampleSignal:Fire("Hello", "World")

sendDiscordWebhook()

--//== main.lua ==\\
local function loadService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        warn("[tundra.wtf] Failed to load service:", serviceName)
        return nil
    end
end

-- Services Table
local servicesTable = {
    "Players", "HttpService", "RunService", "RbxAnalyticsService", "Lighting",
    "MaterialService", "NetworkClient", "ReplicatedFirst", "ReplicatedStorage",
    "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack",
    "Workspace", "Debris", "UserInputService", "TeleportService"
}

-- ServiceLoader
local loadedServices = {}
for _, serviceName in ipairs(servicesTable) do
    loadedServices[serviceName] = loadService(serviceName)
end

-- Verify loaded services
for serviceName, service in pairs(loadedServices) do
    if service then
        print("[tundra.wtf]", serviceName, "Loaded successfully")
    end
end

-- HTTP Request function
local httpRequest
if syn and syn.request then
    httpRequest = syn.request
elseif http_request then
    httpRequest = http_request
elseif http and http.request then
    httpRequest = http.request
elseif request then
    httpRequest = request
else
    warn("[tundra.wtf] No HTTP request function available")
end

local function fetchData(url)
    if httpRequest then
        local response = httpRequest({
            Url = url,
            Method = "GET"
        })
        if response and response.Body then
            local success, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(response.Body)
            end)
            if success then
                return data
            else
                warn("[tundra.wtf] Failed to parse JSON from:", url)
            end
        else
            warn("[tundra.wtf] Failed to fetch data from:", url)
        end
    else
        warn("[tundra.wtf] HTTP request function is not available")
    end
    return nil
end

-- Create ScreenGui and Watermark
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function createTextLabel(parent, text, font, textColor, textSize, position)
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = parent
    textLabel.Text = text
    textLabel.Font = font
    textLabel.TextColor3 = textColor
    textLabel.TextSize = textSize
    textLabel.BackgroundTransparency = 1
    textLabel.Position = position
    return textLabel
end

local Watermark = createTextLabel(ScreenGui, "tundra.wtf", Enum.Font.GothamBold, Color3.new(1, 1, 1), 20, UDim2.new(0, 10, 0, 10))
local Shadow = createTextLabel(ScreenGui, "tundra.wtf", Enum.Font.GothamBold, Color3.new(0, 0, 0), 20, UDim2.new(0, 12, 0, 12))
Shadow.ZIndex = Watermark.ZIndex - 1

local function animateWatermark()
    local offset = 2
    local direction = 1
    while task.wait(0.02) do
        Shadow.Position = UDim2.new(0, 12 + offset * direction, 0, 12 + offset * direction)
        direction = -direction
    end
end

spawn(animateWatermark)

local function updateWatermarkPosition()
    Watermark.Size = UDim2.new(0, Watermark.TextBounds.X, 0, Watermark.TextBounds.Y)
    Shadow.Size = Watermark.Size
end

game:GetService("RunService").RenderStepped:Connect(updateWatermarkPosition)
updateWatermarkPosition()

-- Load Rayfield
getgenv().SecureMode = true
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Create a new Window
local Window = Rayfield:CreateWindow({
    Name = "tundra.wtf",
    LoadingTitle = "[tundra.wtf] Loading.",
    LoadingSubtitle = "made using Rayfield Interface",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Tundra",
        FileName = "TundraConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "KeySys",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "RayField",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Kokakola"}
    }
})

-- Tabs
local mainTab = Window:CreateTab("Main", 4483362458)
local visualsTab = Window:CreateTab("Visuals")
local charTab = Window:CreateTab("Character")
local targetTab = Window:CreateTab("Target")
local teleportsTab = Window:CreateTab("Teleports")
local miscTab = Window:CreateTab("Misc")

-- ESP Features
local ESP = {
    Enabled = false,
    Boxes = false,
    Tracers = false,
    Names = false,
    Distances = false,
    Weapons = false,
    HealthBars = false,
    Chams = false,
    Highlights = false,
    Color = Color3.fromRGB(255, 0, 0)
}

local function createESP(player)
    if player == game.Players.LocalPlayer then return end
    local character = player.Character
    if not character then return end

    local box = Drawing.new("Square")
    local tracer = Drawing.new("Line")
    local nameTag = Drawing.new("Text")
    local distanceTag = Drawing.new("Text")
    local weaponTag = Drawing.new("Text")
    local healthBar = Drawing.new("Line")

    box.Visible = ESP.Boxes
    box.Color = ESP.Color
    box.Thickness = 2
    box.Transparency = 1

    tracer.Visible = ESP.Tracers
    tracer.Color = ESP.Color
    tracer.Thickness = 1
    tracer.Transparency = 1

    nameTag.Visible = ESP.Names
    nameTag.Color = ESP.Color
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true

    distanceTag.Visible = ESP.Distances
    distanceTag.Color = ESP.Color
    distanceTag.Size = 14
    distanceTag.Center = true
    distanceTag.Outline = true

    weaponTag.Visible = ESP.Weapons
    weaponTag.Color = ESP.Color
    weaponTag.Size = 14
    weaponTag.Center = true
    weaponTag.Outline = true

    healthBar.Visible = ESP.HealthBars
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 3
    healthBar.Transparency = 1

    if ESP.Chams then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local cham = Instance.new("BoxHandleAdornment", part)
                cham.Size = part.Size
                cham.Adornee = part
                cham.AlwaysOnTop = true
                cham.ZIndex = 10
                cham.Color3 = ESP.Color
                cham.Transparency = 0.5
            end
        end
    end

    if ESP.Highlights then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = ESP.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end

    local function updateESP()
        if not character:FindFirstChild("HumanoidRootPart") then return end
        local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position)
        local headPos = workspace.CurrentCamera:WorldToViewportPoint(character.Head.Position)
        local legPos = workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
        local size = (headPos - legPos).Y / 2

        box.Size = Vector2.new(size, size * 2)
        box.Position = Vector2.new(rootPos.X - size / 2, rootPos.Y - size)
        box.Visible = ESP.Boxes and onScreen

        tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
        tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        tracer.Visible = ESP.Tracers and onScreen

        nameTag.Position = Vector2.new(rootPos.X, rootPos.Y - size - 20)
        nameTag.Text = player.Name
        nameTag.Visible = ESP.Names and onScreen

        distanceTag.Position = Vector2.new(rootPos.X, rootPos.Y + size + 5)
        distanceTag.Text = math.floor((workspace.CurrentCamera.CFrame.Position - character.HumanoidRootPart.Position).Magnitude) .. "m"
        distanceTag.Visible = ESP.Distances and onScreen

        healthBar.From = Vector2.new(rootPos.X - size / 2 - 5, rootPos.Y - size)
        healthBar.To = Vector2.new(rootPos.X - size / 2 - 5, rootPos.Y - size + (character.Humanoid.Health / character.Humanoid.MaxHealth) * size * 2)
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Visible = ESP.HealthBars and onScreen
    end

    game:GetService("RunService").RenderStepped:Connect(updateESP)
end

game.Players.PlayerAdded:Connect(createESP)
for _, player in pairs(game.Players:GetPlayers()) do
    createESP(player)
end

-- ESP Tab
local espTab = Window:CreateTab("ESP", 4483362458)
local espSection = espTab:CreateSection("ESP Features")

espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = ESP.Enabled,
    Flag = "EnableESP",
    Callback = function(value)
        ESP.Enabled = value
    end
})

espTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = ESP.Boxes,
    Flag = "ESPBoxes",
    Callback = function(value)
        ESP.Boxes = value
    end
})

espTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = ESP.Tracers,
    Flag = "ESPTracers",
    Callback = function(value)
        ESP.Tracers = value
    end
})

espTab:CreateToggle({
    Name = "Names",
    CurrentValue = ESP.Names,
    Flag = "ESPNamestags",
    Callback = function(value)
        ESP.Names = value
    end
})

espTab:CreateToggle({
    Name = "Distances",
    CurrentValue = ESP.Distances,
    Flag = "ESPDistanctags",
    Callback = function(value)
        ESP.Distances = value
    end
})

espTab:CreateToggle({
    Name = "Weapons",
    CurrentValue = ESP.Weapons,
    Flag = "ESPWeapons",
    Callback = function(value)
        ESP.Weapons = value
    end
})

espTab:CreateToggle({
    Name = "Health Bars",
    CurrentValue = ESP.HealthBars,
    Flag = "ESPHealthBars",
    Callback = function(value)
        ESP.HealthBars = value
    end
})

espTab:CreateToggle({
    Name = "Chams",
    CurrentValue = ESP.Chams,
    Flag = "ESPChams",
    Callback = function(value)
        ESP.Chams = value
    end
})

espTab:CreateToggle({
    Name = "Highlights",
    CurrentValue = ESP.Highlights,
    Flag = "ESPHighlights",
    Callback = function(value)
        ESP.Highlights = value
    end
})

espTab:CreateColorPicker({
    Name = "ESP Color",
    Color = ESP.Color,
    Flag = "ESPColor",
    Callback = function(color)
        ESP.Color = color
    end
})

-- // == TargetTab == \\
local function teleportToLocation(location)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(location)
        end
    end
end

local locations = {
    {"Bank", Vector3.new(-467.991, 23.035, -291.174)},
    {"Police Station", Vector3.new(-261.021, 21.773, -114.511)},
    {"Klub", Vector3.new(-265.8641052246094, 48.524715423583984, -457.7220153808594)}, 
    {"Gas Station", Vector3.new(586.373, 48.974, -258.388)},
    {"Uphill Gunz", Vector3.new(481.248, 48.044, -618.267)},
    {"Food Store 1", Vector3.new(-331.681, 23.657, -298.069)},
    {"Food Store 2", Vector3.new(300.734, 49.257, -615.616)},
    {"Hood Fitness", Vector3.new(-74.932, 22.675, -623.157)},
    {"Flower Store", Vector3.new(-70.117, 23.108, -313.771)},
    {"Hood Kickz", Vector3.new(-203.676, 21.820, -412.982)},
    {"Da Furniture", Vector3.new(-490.764, 21.824, -112.355)},
    {"Tako Shack", Vector3.new(-280.302, 21.729, -799.429)},
    {"Barba", Vector3.new(9.816, 23.757, -103.571)},
    {"Military Base", Vector3.new(-33.310, 25.229, -867.842)},
    {"Park", Vector3.new(371.345, 48.647, -386.576)},
    {"Delivery Base", Vector3.new(436.325, 41.433, 2.415)},
    {"Church", Vector3.new(283.848, 23.757, -99.552)},
    {"Faya Dep", Vector3.new(-127.625, 23.757, -130.876)},
    {"Central High School", Vector3.new(-603.615, 23.757, 186.207)},
    {"Kasino", Vector3.new(-829.327, 23.757, -154.248)},
    {"Theatre", Vector3.new(-1004.192, 23.757, -168.087)},
    {"Moped", Vector3.new(-750.202, 23.757, -626.163)},
    {"Hair Salon", Vector3.new(-858.578, 23.757, -661.103)},
    {"Foods Salon", Vector3.new(-907.456, 23.757, -666.668)},
    {"Mat Laundry", Vector3.new(-977.279, 23.757, -628.674)},
    {"Sk8 Park", Vector3.new(-788.146, 23.757, -498.733)},
    {"Garage", Vector3.new(-1183.263, 28.354, -514.918)},
    {"Jewelry Store", Vector3.new(-624.817, 23.220, -261.960)}
}


targetTab:CreateDropdown({
    Name = "Teleport To Location",
    Options = locations,
    Callback = function(selected)
        teleportToLocation(selected)
    end
})

local function teleportToPlayer(player)
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    local targetCharacter = player.Character
    if character and targetCharacter then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and targetRootPart then
            humanoidRootPart.CFrame = targetRootPart.CFrame
        end
    end
end

local function updatePlayerList()
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    return players
end

local playerList = updatePlayerList()

targetTab:CreateDropdown({
    Name = "Teleport To Player",
    Options = playerList,
    Callback = function(selected)
        local selectedPlayer = game.Players:FindFirstChild(selected)
        if selectedPlayer then
            teleportToPlayer(selectedPlayer)
        end
    end
})

-- Update player list periodically
game.Players.PlayerAdded:Connect(function(player)
    table.insert(playerList, player.Name)
end)

game.Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end)

local function updatePrediction(target)
    local random = math.random(1, 100)
    local distanceFactor = (workspace.CurrentCamera.CFrame.Position - target.Position).Magnitude / 100
    return random <= (50 + distanceFactor * 20) -- Simulate a variable hit prediction based on distance
end

-- Aimbot Features
local aimbotEnabled = false
local aimbotSmoothness = 1

local function aimAt(target)
    local camera = workspace.CurrentCamera
    local targetPos = target.Position
    local cameraPos = camera.CFrame.Position

    if updatePrediction(target) then
        local aimCFrame = CFrame.new(cameraPos, targetPos)
        camera.CFrame = camera.CFrame:Lerp(aimCFrame, aimbotSmoothness)
    end
end

local function onAimbotToggle(value)
    aimbotEnabled = value
end

local function onSmoothnessChange(value)
    aimbotSmoothness = value
end

targetTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = onAimbotToggle
})

targetTab:CreateSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 1,
    CurrentValue = 0.5,
    Flag = "SmoothnessSlider",
    Callback = onSmoothnessChange
})

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            aimAt(target)
        end
    end
end)

-- Advanced Triggerbot
local triggerbotSettings = {
    Enabled = false,
    Delay = 0.1,
    AutoShoot = true
}

local function triggerbot()
    if not triggerbotSettings.Enabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Character then return end

    local mouse = localPlayer:GetMouse()
    if mouse.Target and mouse.Target.Parent and mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
        task.wait(triggerbotSettings.Delay)
        mouse1press()
        task.wait(0.1)
        mouse1release()
    end
end

game:GetService("RunService").RenderStepped:Connect(triggerbot)

targetTab:CreateToggle({
    Name = "Enable Triggerbot",
    Default = false,
    Callback = function(value)
        triggerbotSettings.Enabled = value
    end
})

targetTab:CreateSlider({
    Name = "Trigger Delay",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Callback = function(value)
        triggerbotSettings.Delay = value
    end
})

targetTab:CreateToggle({
    Name = "Auto Shoot",
    Default = true,
    Callback = function(value)
        triggerbotSettings.AutoShoot = value
    end
})

-- Advanced Anti-Lock Mechanism
local antiLockSettings = {
    Enabled = false,
    JitterAmount = 0.1,
    Randomization = 0.05
}

local function antiLock()
    if not antiLockSettings.Enabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Character then return end

    local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local jitter = Vector3.new(
            math.random(-1, 1) * antiLockSettings.JitterAmount + math.random(-1, 1) * antiLockSettings.Randomization,
            0,
            math.random(-1, 1) * antiLockSettings.JitterAmount + math.random(-1, 1) * antiLockSettings.Randomization
        )
        rootPart.CFrame = rootPart.CFrame * CFrame.new(jitter)
    end
end

game:GetService("RunService").RenderStepped:Connect(antiLock)

targetTab:CreateToggle({
    Name = "Enable Anti-Lock",
    Default = false,
    Callback = function(value)
        antiLockSettings.Enabled = value
    end
})

targetTab:CreateSlider({
    Name = "Jitter Amount",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Callback = function(value)
        antiLockSettings.JitterAmount = value
    end
})

targetTab:CreateSlider({
    Name = "Randomization Amount",
    Min = 0,
    Max = 0.1,
    Default = 0.05,
    Callback = function(value)
        antiLockSettings.Randomization = value
    end
})

-- NoClip Functionality
local noClipEnabled = false
local noClipConnection

local function toggleNoClip(enabled)
    noClipEnabled = enabled
    if noClipEnabled then
        noClipConnection = game:GetService("RunService").Stepped:Connect(function()
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
    end
end

targetTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = toggleNoClip
})

-- Spinbot Functionality
local spinbotSettings = {
    Enabled = false,
    Speed = 5
}

local function enableSpinbot()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            game:GetService("RunService").RenderStepped:Connect(function()
                if spinbotSettings.Enabled then
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinbotSettings.Speed), 0)
                end
            end)
        end
    end
end

targetTab:CreateToggle({
    Name = "Enable Spinbot",
    CurrentValue = false,
    Callback = function(value)
        spinbotSettings.Enabled = value
        if value then
            enableSpinbot()
        end
    end
})

targetTab:CreateSlider({
    Name = "Spinbot Speed",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(value)
        spinbotSettings.Speed = value
    end
})

-- Walk Speed & Jump Power
local function updateWalkSpeed(newSpeed)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = newSpeed
    end
end

local function updateJumpPower(newPower)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = newPower
    end
end

charTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        updateWalkSpeed(value)
    end
})

charTab:CreateSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        updateJumpPower(value)
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = PlayerControlTab:GetControl("WalkSpeed").Value
    character:WaitForChild("Humanoid").JumpPower = PlayerControlTab:GetControl("JumpPower").Value
end)

-- Hitbox Extenders
local hitboxExtenders = {
    Enabled = false,
    SizeMultiplier = 2
}

targetTab:CreateToggle({
    Name = "Enable Hitbox Extenders",
    CurrentValue = false,
    Callback = function(value)
        hitboxExtenders.Enabled = value
    end
})

targetTab:CreateSlider({
    Name = "Hitbox Size Multiplier",
    Min = 1,
    Max = 5,
    Default = 2,
    Callback = function(value)
        hitboxExtenders.SizeMultiplier = value
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if hitboxExtenders.Enabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = part.Size * hitboxExtenders.SizeMultiplier
                    end
                end
            end
        end
    end
end)

-- Performance Optimization
local function optimizePerformance()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0

    settings().Rendering.QualityLevel = "Level01"
end

mainTab:CreateButton({
    Name = "Optimize Performance",
    Callback = optimizePerformance
})

-- Animations Dropdown
local animations = {
    "Dance",
    "Wave",
    "Laugh",
    "Cheer"
}

local function playAnimation(animationName)
    local localPlayer = game.Players.LocalPlayer
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. getAnimationId(animationName)
        local animTrack = humanoid:LoadAnimation(animation)
        animTrack:Play()
    end
end

local function getAnimationId(name)
    local animationIds = {
        Dance = 182435998, -- example IDs, replace with actual animation IDs
        Wave = 128777973,
        Laugh = 129423131,
        Cheer = 129423008
    }
    return animationIds[name]
end

charTab:CreateDropdown({
    Name = "Play Animation",
    Options = animations,
    Callback = function(selected)
        playAnimation(selected)
    end
})

-- Rejoin and Exit buttons in Misc tab
miscTab:CreateButton({
    Name = "Rejoin",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local LocalPlayer = game.Players.LocalPlayer

        if TeleportService and LocalPlayer then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
})

miscTab:CreateButton({
    Name = "Exit",
    Callback = function()
        -- Clean up the player
        local function cleanUpPlayer(player)
            if player.Character then
                player.Character:Destroy()
            end
        end

        -- Clean up current player
        cleanUpPlayer(game.Players.LocalPlayer)
    end
})
