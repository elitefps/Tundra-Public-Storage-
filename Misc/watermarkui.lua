-- G-T-L
-- Version: 3.2

-- Instances:

local wtrmark = Instance.new("ScreenGui")
local hi = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local brand = Instance.new("TextLabel")
local frr = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local ihatemylife = Instance.new("ImageLabel")

--Properties:

wtrmark.Name = "wtrmark"
wtrmark.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
wtrmark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

hi.Name = "hi"
hi.Parent = wtrmark
hi.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
hi.BorderColor3 = Color3.fromRGB(0, 0, 0)
hi.BorderSizePixel = 0
hi.Position = UDim2.new(0.00396039616, 0, 0.0111940298, 0)
hi.Size = UDim2.new(0, 254, 0, 24)

UICorner.CornerRadius = UDim.new(0, 3)
UICorner.Parent = hi

brand.Name = "brand"
brand.Parent = hi
brand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
brand.BackgroundTransparency = 1.000
brand.BorderColor3 = Color3.fromRGB(0, 0, 0)
brand.BorderSizePixel = 0
brand.Position = UDim2.new(0.265006542, 0, -0.125, 0)
brand.Size = UDim2.new(0, 119, 0, 25)
brand.Font = Enum.Font.Unknown
brand.Text = "tundra.wtf | build 2.6 | FPS: 240 | MS: 100"
brand.TextColor3 = Color3.fromRGB(255, 255, 255)
brand.TextSize = 11.000
brand.TextStrokeTransparency = 0.000

frr.Name = "frr"
frr.Parent = hi
frr.BackgroundColor3 = Color3.fromRGB(117, 117, 117)
frr.BorderColor3 = Color3.fromRGB(0, 0, 0)
frr.BorderSizePixel = 0
frr.Position = UDim2.new(0, 0, 0.935483813, 0)
frr.Size = UDim2.new(0, 254, 0, 2)

UICorner_2.Parent = frr

UIGradient.Color =
    ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
    ColorSequenceKeypoint.new(0.51, Color3.fromRGB(25, 136, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
}
UIGradient.Parent = frr

ihatemylife.Name = "ihatemylife"
ihatemylife.Parent = frr
ihatemylife.AnchorPoint = Vector2.new(0.5, 0.5)
ihatemylife.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ihatemylife.BackgroundTransparency = 1.000
ihatemylife.BorderColor3 = Color3.fromRGB(0, 0, 0)
ihatemylife.BorderSizePixel = 0
ihatemylife.Position = UDim2.new(0.982896924, 0, -9.36290169, 0)
ihatemylife.Rotation = 5.000
ihatemylife.Size = UDim2.new(0, -26, 0, 15)
ihatemylife.Image = "rbxassetid://14187977869"
ihatemylife.ScaleType = Enum.ScaleType.Fit

-- Scripts:

local function IABL_fake_script() -- hi.handler
    local script = Instance.new("LocalScript", hi)

    local brand = script.Parent.brand

    -- CONSTANTS
    local BUILD_VERSION = "2.6"
    local DOMAIN = "tundra.wtf"
    local FPS_INTERVAL = 0.1
    local FRAME_WINDOW = 60

    -- Services
    local RunService = game:GetService("RunService")
    local Player = game.Players.LocalPlayer

    -- FPS Variables
    local frameCount = 0
    local lastTime = tick()
    local fps = 0
    local lastFpsUpdate = os.clock()

    -- Display --
    local function updateUI()
        local ping = Player:GetNetworkPing()

        -- display fps
        local fpsDisplay = (fps > 0 and fps) or "N/A"

        local rp = math.floor(ping + 0.5)

        -- on failure,
        local pingDisplay = (rp >= 0 and rp) or "N/A"

        -- Display
        local statusText =
            string.format("%s | build %s | FPS: %s | MS: %s", DOMAIN, BUILD_VERSION, fpsDisplay, pingDisplay)
        brand.Text = statusText
    end

    -- hard set attributes/properites
    brand.Position = UDim2.new(0.265, 0, -0.125, 0)
    brand.Size = UDim2.new(0, 119, 0, 25)
    brand.Font = Enum.Font.RobotoMono

    -- // decor
    local hi = script.Parent.frr
    local uiGradient = hi:FindFirstChild("UIGradient")
    uiGradient.Parent = hi

    uiGradient.Rotation = 45
    uiGradient.Enabled = true

    -- # attributes
    local gradientTime = 0
    local gradientSpeed = 1
    local color1, color2, color3 = Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255)

    local function ag(dt)
        gradientTime = gradientTime + dt * gradientSpeed
        local sinValue = math.sin(gradientTime)

        local r = (math.sin(gradientTime * 0.7) + 1) / 2
        local g = (math.sin(gradientTime * 0.9) + 1) / 2
        local b = (math.sin(gradientTime * 1.1) + 1) / 2

        color1 = Color3.fromRGB(r * 255, g * 255, b * 255)
        color2 = Color3.fromRGB((1 - r) * 255, (1 - g) * 255, (1 - b) * 255)

        uiGradient.Color = ColorSequence.new(color1, color2)
    end

    RunService.RenderStepped:Connect(
        function(dt)
            frameCount = frameCount + 1
            local currentTime = tick()

            if currentTime - lastTime >= 1 then
                fps = frameCount
                frameCount = 0
                lastTime = currentTime
            end

            local now = os.clock()
            if now - lastFpsUpdate >= FPS_INTERVAL then
                lastFpsUpdate = now
                updateUI()
            end

            ag(dt)
        end
    )
end
coroutine.wrap(IABL_fake_script)()
