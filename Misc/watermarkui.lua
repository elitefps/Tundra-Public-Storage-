-- Version: 3.2

-- Instances:

local wtrmrk = Instance.new("ScreenGui")
local hi = Instance.new("Frame")
local brand = Instance.new("TextLabel")
local gamer = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local snapline = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local gimma = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")
local snapline_2 = Instance.new("Frame")
local UICorner_4 = Instance.new("UICorner")

--Properties:


wtrmrk.Name = "wtrmrk"
wtrmrk.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")


hi.Name = "hi"
hi.Parent = wtrmrk
hi.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hi.BorderColor3 = Color3.fromRGB(0, 0, 0)
hi.BorderSizePixel = 0
hi.Position = UDim2.new(0.00858085789, 0, 0.0136815924, 0)
hi.Size = UDim2.new(0, 261, 0, 28)


brand.Name = "brand"
brand.Parent = hi
brand.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
brand.BackgroundTransparency = 1.000
brand.Position = UDim2.new(-0.0755174458, 0, -0.129032269, 0)
brand.Size = UDim2.new(0, 299, 0, 35)
brand.Font = Enum.Font.Code
brand.Text = "tundra.wtf / build 2.6 | FPS 240 | MS 0."
brand.TextColor3 = Color3.fromRGB(255, 255, 255)
brand.TextSize = 11
brand.TextStrokeColor3 = Color3.fromRGB(89, 89, 89)
brand.TextStrokeTransparency = 0.400
brand.TextWrapped = true


gamer.Name = "game"
gamer.Parent = hi
gamer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
gamer.BorderColor3 = Color3.fromRGB(0, 0, 0)
gamer.BorderSizePixel = 0
gamer.Position = UDim2.new(0, 0, 1.10714281, 0)
gamer.Size = UDim2.new(0, 87, 0, 17)

UICorner.CornerRadius = UDim.new(0, 3)
UICorner.Parent = gamer


snapline.Name = "snapline"
snapline.Parent = gamer
snapline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
snapline.BorderColor3 = Color3.fromRGB(0, 0, 0)
snapline.BorderSizePixel = 0
snapline.Size = UDim2.new(0, 2, 0, 17)

UICorner_2.Parent = snapline


gimma.Name = "gimma"
gimma.Parent = gamer
gimma.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gimma.BackgroundTransparency = 1.000
gimma.BorderColor3 = Color3.fromRGB(0, 0, 0)
gimma.BorderSizePixel = 0
gimma.Position = UDim2.new(-1.46205258, 0, -0.540796638, 0)
gimma.Size = UDim2.new(0, 334, 0, 35)
gimma.Font = Enum.Font.Code
gimma.Text = "Universal"
gimma.TextColor3 = Color3.fromRGB(255, 255, 255)
gimma.TextSize = 11
gimma.TextStrokeColor3 = Color3.fromRGB(89, 89, 89)
gimma.TextStrokeTransparency = 0.400
gimma.TextWrapped = true

UICorner_3.CornerRadius = UDim.new(0, 3)
UICorner_3.Parent = hi


snapline_2.Name = "snapline"
snapline_2.Parent = hi
snapline_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
snapline_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
snapline_2.BorderSizePixel = 0
snapline_2.Size = UDim2.new(0, 2, 0, 28)


UICorner_4.CornerRadius = UDim.new(0, 3)
UICorner_4.Parent = snapline_2

-- Scripts:
-- REWRITE
