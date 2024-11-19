-- services
local runService = game:GetService("RunService");
local players = game:GetService("Players");
local workspace = game:GetService("Workspace");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;
local viewportSize = camera.ViewportSize;
local container = Instance.new("Folder",
	gethui and gethui() or game:GetService("CoreGui"));

-- locals
local floor = math.floor;
local round = math.round;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;
local clear = table.clear;
local unpack = table.unpack;
local find = table.find;

-- methods
local wtvp = camera.WorldToViewportPoint;
local isA = workspace.IsA;
local getPivot = workspace.GetPivot;
local findFirstChild = workspace.FindFirstChild;
local findFirstChildOfClass = workspace.FindFirstChildOfClass;
local getChildren = workspace.GetChildren;
local toOrientation = CFrame.identity.ToOrientation;
local pointToObjectSpace = CFrame.identity.PointToObjectSpace;
local lerpColor = Color3.new().Lerp;
local min2 = Vector2.zero.Min;
local max2 = Vector2.zero.Max;
local lerp2 = Vector2.zero.Lerp;
local min3 = Vector3.zero.Min;
local max3 = Vector3.zero.Max;

-- constants
local HEALTH_BAR_OFFSET = Vector2.new(5, 0);
local HEALTH_TEXT_OFFSET = Vector2.new(3, 0);
local HEALTH_BAR_OUTLINE_OFFSET = Vector2.new(0, 1);
local NAME_OFFSET = Vector2.new(0, 2);
local DISTANCE_OFFSET = Vector2.new(0, 2);
local VERTICES = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(-1, -1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1),
	Vector3.new(1, -1, 1)
};

-- functions
local function isBodyPart(name)
	return name == "Head" or name:find("Torso") or name:find("Leg") or name:find("Arm");
end

local function getBoundingBox(parts)
	local min, max;
	for i = 1, #parts do
		local part = parts[i];
		local cframe, size = part.CFrame, part.Size;

		min = min3(min or cframe.Position, (cframe - size*0.5).Position);
		max = max3(max or cframe.Position, (cframe + size*0.5).Position);
	end

	local center = (min + max)*0.5;
	local front = Vector3.new(center.X, center.Y, max.Z);
	return CFrame.new(center, front), max - min;
end

local function worldToScreen(world)
	local screen, inBounds = wtvp(camera, world);
	return Vector2.new(screen.X, screen.Y), inBounds, screen.Z;
end

local function calculateCorners(cframe, size)
	local corners = {};
	for i = 1, #VERTICES do
		corners[i] = worldToScreen((cframe + size*0.5*VERTICES[i]).Position);
	end

	local min = min2(viewportSize, unpack(corners));
	local max = max2(Vector2.zero, unpack(corners));
	return {
		corners = corners,
		topLeft = Vector2.new(floor(min.X), floor(min.Y)),
		topRight = Vector2.new(floor(max.X), floor(min.Y)),
		bottomLeft = Vector2.new(floor(min.X), floor(max.Y)),
		bottomRight = Vector2.new(floor(max.X), floor(max.Y))
	};
end

local function rotateVector(vector, radians)
	local c, s = cos(radians), sin(radians);
	return Vector2.new(c*vector.X - s*vector.Y, s*vector.X + c*vector.Y);
end

-- esp object
local EspObject = {};
EspObject.__index = EspObject;

function EspObject.new(player, interface)
	local self = setmetatable({}, EspObject);
	self.player = assert(player, "Missing argument #1 (Player expected)");
	self.interface = assert(interface, "Missing argument #2 (table expected)");
	self:Construct();
	return self;
end

function EspObject:Construct()
	self.charCache = {};
	self.childCount = 0;
	self.bin = {};
	self.drawings = {
		box3d = {
			{
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false })
			},
			{
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false }),
				self:create("Line", { Thickness = 1, Visible = false })
			}
		},
		visible = {
			tracerOutline = self:create("Line", { Thickness = 3, Visible = false }),
			tracer = self:create("Line", { Thickness = 1, Visible = false }),
			boxFill = self:create("Square", { Filled = true, Visible = false }),
			boxOutline = self:create("Square", { Thickness = 3, Visible = false }),
			box = self:create("Square", { Thickness = 1, Visible = false }),
			healthBarOutline = self:create("Line", { Thickness = 3, Visible = false }),
			healthBar = self:create("Line", { Thickness = 1, Visible = false }),
			healthText = self:create("Text", { Center = true, Visible = false }),
			name = self:create("Text", { Text = self.player.Name, Center = true, Visible = false }),
			distance = self:create("Text", { Center = true, Visible = false }),
			weapon = self:create("Text", { Center = true, Visible = false }),
		},
		hidden = {
			arrowOutline = self:create("Triangle", { Thickness = 3, Visible = false }),
			arrow = self:create("Triangle", { Filled = true, Visible = false })
		}
	};

	self.renderConnection = runService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime);
		self:Render(deltaTime);
	end);
end

function EspObject:create(class, properties)
	local drawing = Drawing.new(class);
	for property, value in next, properties do
		drawing[property] = value;
	end
	self.bin[#self.bin + 1] = drawing;
	return drawing;
end

function EspObject:Destruct()
	self.renderConnection:Disconnect();

	for _, drawing in next, self.bin do
		drawing:Remove();
	end

	clear(self);
end

function EspObject:Update()
	local interface = self.interface;

	self.options = interface.teamSettings[interface.isFriendly(self.player) and "friendly" or "enemy"];
	self.character = interface.getCharacter(self.player);
	self.health, self.maxHealth = interface.getHealth(self.character);
	self.weapon = interface.getWeapon(self.player);
	self.enabled = self.options.enabled and self.character and not
		(#interface.whitelist > 0 and not find(interface.whitelist, self.player.UserId));

	local head = self.enabled and findFirstChild(self.character, "Head");
	if not head then
		return;
	end

	local _, onScreen, depth = worldToScreen(head.Position);
	self.onScreen = onScreen;
	self.distance = depth;

	if interface.sharedSettings.limitDistance and depth > interface.sharedSettings.maxDistance then
		self.onScreen = false;
	end

	if self.onScreen then
		local cache = self.charCache;
		local children = getChildren(self.character);
		if not cache[1] or self.childCount ~= #children then
			clear(cache);

			for i = 1, #children do
				local part = children[i];
				if isA(part, "BasePart") and isBodyPart(part.Name) then
					cache[#cache + 1] = part;
				end
			end

			self.childCount = #children;
		end

		self.corners = calculateCorners(getBoundingBox(cache));
	elseif self.options.offScreenArrow then
		local _, yaw, roll = toOrientation(camera.CFrame);
		local flatCFrame = CFrame.Angles(0, yaw, roll) + camera.CFrame.Position;
		local objectSpace = pointToObjectSpace(flatCFrame, head.Position);
		local angle = atan2(objectSpace.Z, objectSpace.X);

		self.direction = Vector2.new(cos(angle), sin(angle));
	end
end

-- // update
function EspObject:Render()
	-- Cache frequently used variables
	local onScreen = self.onScreen
	local enabled = self.enabled
	local interface, options = self.interface, self.options
	local visible, hidden, box3d = self.drawings.visible, self.drawings.hidden, self.drawings.box3d
	local corners = self.corners

	-- Quick return if ESP is disabled or off-screen
	if not enabled or not onScreen then
		for _, drawing in pairs(visible) do drawing.Visible = false end
		for _, drawing in pairs(hidden) do drawing.Visible = false end
		return
	end

	-- Box settings
	if options.box then
		local box, boxOutline = visible.box, visible.boxOutline
		local boxPos = corners.topLeft
		local boxSize = corners.bottomRight - corners.topLeft

		box.Visible = true
		box.Position = boxPos
		box.Size = boxSize
		box.Color = options.boxColor[1]
		box.Transparency = options.boxColor[2]

		if options.boxOutline then
			boxOutline.Visible = true
			boxOutline.Position = boxPos
			boxOutline.Size = boxSize
			boxOutline.Color = options.boxOutlineColor[1]
			boxOutline.Transparency = options.boxOutlineColor[2]
		else
			boxOutline.Visible = false
		end
	else
		visible.box.Visible = false
		visible.boxOutline.Visible = false
	end

	-- Box Fill
	if options.boxFill then
		local boxFill = visible.boxFill
		boxFill.Visible = true
		boxFill.Position = corners.topLeft
		boxFill.Size = corners.bottomRight - corners.topLeft
		boxFill.Color = options.boxFillColor[1]
		boxFill.Transparency = options.boxFillColor[2]
	else
		visible.boxFill.Visible = false
	end

	-- Health Bar
	if options.healthBar then
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET
		local healthRatio = math.clamp(self.health / self.maxHealth, 0, 1)

		local healthBar, healthBarOutline = visible.healthBar, visible.healthBarOutline
		healthBar.Visible = true
		healthBar.From = lerp2(barTo, barFrom, healthRatio)
		healthBar.To = barTo
		healthBar.Color = lerpColor(options.dyingColor, options.healthyColor, healthRatio)

		if options.healthBarOutline then
			healthBarOutline.Visible = true
			healthBarOutline.From = barFrom - HEALTH_BAR_OUTLINE_OFFSET
			healthBarOutline.To = barTo + HEALTH_BAR_OUTLINE_OFFSET
			healthBarOutline.Color = options.healthBarOutlineColor[1]
			healthBarOutline.Transparency = options.healthBarOutlineColor[2]
		else
			healthBarOutline.Visible = false
		end
	else
		visible.healthBar.Visible = false
		visible.healthBarOutline.Visible = false
	end

	-- Health Text
	if options.healthText then
		local healthText = visible.healthText
		local barFrom = corners.topLeft - HEALTH_BAR_OFFSET
		local barTo = corners.bottomLeft - HEALTH_BAR_OFFSET
		local healthRatio = math.clamp(self.health / self.maxHealth, 0, 1)

		healthText.Visible = true
		healthText.Text = string.format("%dhp", round(self.health))
		healthText.Size = interface.sharedSettings.textSize
		healthText.Font = interface.sharedSettings.textFont
		healthText.Color = options.healthTextColor[1]
		healthText.Transparency = options.healthTextColor[2]
		healthText.Outline = options.healthTextOutline
		healthText.OutlineColor = options.healthTextOutlineColor
		healthText.Position = lerp2(barTo, barFrom, healthRatio) - healthText.TextBounds * 0.5 - HEALTH_TEXT_OFFSET
	else
		visible.healthText.Visible = false
	end

	-- Name, Distance, Weapon, and Tracer
	self:UpdateText("name", corners.topLeft + corners.topRight, options.name, NAME_OFFSET)
	self:UpdateText("distance", corners.bottomLeft + corners.bottomRight, options.distance, DISTANCE_OFFSET)
	self:UpdateText("weapon", corners.bottomLeft + corners.bottomRight, options.weapon, DISTANCE_OFFSET)

	-- Off-Screen Arrow
	if options.offScreenArrow then
		self:UpdateOffScreenArrow(hidden.arrow, hidden.arrowOutline, options)
	else
		hidden.arrow.Visible = false
		hidden.arrowOutline.Visible = false
	end

	-- 3D Box
	self:Update3DBox(box3d, enabled and options.box3d, corners, options)
end

function EspObject:UpdateText(drawingName, basePosition, option, offset)
	local visible = self.drawings.visible[drawingName]
	if option then
		visible.Visible = true
		visible.Text = drawingName == "distance" and string.format("%d studs", round(self.distance)) or tostring(self[drawingName])
		visible.Size = self.interface.sharedSettings.textSize
		visible.Font = self.interface.sharedSettings.textFont
		visible.Color = self.options[drawingName .. "Color"][1]
		visible.Transparency = self.options[drawingName .. "Color"][2]
		visible.Position = basePosition * 0.5 + offset
	else
		visible.Visible = false
	end
end

function EspObject:UpdateOffScreenArrow(arrow, arrowOutline, options)
	arrow.Visible = true
	arrowOutline.Visible = options.offScreenArrowOutline

	local viewportSize = self.interface.viewportSize
	local position = viewportSize * 0.5 + self.direction * options.offScreenArrowRadius
	arrow.PointA = min2(max2(position, Vector2.one * 25), viewportSize - Vector2.one * 25)
	arrow.PointB = arrow.PointA - rotateVector(self.direction, 0.45) * options.offScreenArrowSize
	arrow.PointC = arrow.PointA - rotateVector(self.direction, -0.45) * options.offScreenArrowSize

	if options.offScreenArrowOutline then
		arrowOutline.PointA = arrow.PointA
		arrowOutline.PointB = arrow.PointB
		arrowOutline.PointC = arrow.PointC
	end
end

function EspObject:Update3DBox(box3d, enabled, corners, options)
	if enabled then
		for i = 1, #box3d do
			local face = box3d[i]
			for _, line in ipairs(face) do
				line.Visible = true
				line.Color = options.box3dColor[1]
				line.Transparency = options.box3dColor[2]
			end
			-- Set positions only once 
			local line1, line2, line3 = face[1], face[2], face[3]
			line1.From, line1.To = corners.corners[i], corners.corners[i == 4 and 1 or i + 1]
			line2.From, line2.To = corners.corners[i == 4 and 1 or i + 1], corners.corners[i == 4 and 5 or i + 5]
			line3.From, line3.To = corners.corners[i == 4 and 5 or i + 5], corners.corners[i == 4 and 8 or i + 4]
		end
	else
		for _, face in ipairs(box3d) do
			for _, line in ipairs(face) do
				line.Visible = false
			end
		end
	end
end

-- instance class
local InstanceObject = {};
InstanceObject.__index = InstanceObject;

function InstanceObject.new(instance, options)
	local self = setmetatable({}, InstanceObject);
	self.instance = assert(instance, "Missing argument #1 (Instance Expected)");
	self.options = assert(options, "Missing argument #2 (table expected)");
	self:Construct();
	return self;
end

function InstanceObject:Construct()
	local options = self.options;
	options.enabled = options.enabled == nil and true or options.enabled;
	options.text = options.text or "{name}";
	options.textColor = options.textColor or { Color3.new(1,1,1), 1 };
	options.textOutline = options.textOutline == nil and true or options.textOutline;
	options.textOutlineColor = options.textOutlineColor or Color3.new();
	options.textSize = options.textSize or 13;
	options.textFont = options.textFont or 2;
	options.limitDistance = options.limitDistance or false;
	options.maxDistance = options.maxDistance or 150;

	self.text = Drawing.new("Text");
	self.text.Center = true;

	self.renderConnection = runService.Heartbeat:Connect(function(deltaTime)
		self:Render(deltaTime);
	end);
end

function InstanceObject:Destruct()
	self.renderConnection:Disconnect();
	self.text:Remove();
end

function InstanceObject:Render()
	local instance = self.instance;
	if not instance or not instance.Parent then
		return self:Destruct();
	end

	local text = self.text;
	local options = self.options;
	if not options.enabled then
		text.Visible = false;
		return;
	end

	local world = getPivot(instance).Position;
	local position, visible, depth = worldToScreen(world);
	if options.limitDistance and depth > options.maxDistance then
		visible = false;
	end

	text.Visible = visible;
	if text.Visible then
		text.Position = position;
		text.Color = options.textColor[1];
		text.Transparency = options.textColor[2];
		text.Outline = options.textOutline;
		text.OutlineColor = options.textOutlineColor;
		text.Size = options.textSize;
		text.Font = options.textFont;
		text.Text = options.text
			:gsub("{name}", instance.Name)
			:gsub("{distance}", round(depth))
			:gsub("{position}", tostring(world));
	end
end

-- interface
local EspInterface = {
	_hasLoaded = false,
	_objectCache = {},
	whitelist = {},
	sharedSettings = {
		textSize = 13,
		textFont = 2,
		limitDistance = false,
		maxDistance = 150,
	},
	teamSettings = {
		enemy = {
			enabled = false,
			box = false,
			boxColor = { Color3.new(1,0,0), 1 },
			boxOutline = true,
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false,
			boxFillColor = { Color3.new(1,0,0), 0.5 },
			healthBar = false,
			healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0),
			healthBarOutline = true,
			healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false,
			healthTextColor = { Color3.new(1,1,1), 1 },
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false,
			box3dColor = { Color3.new(1,0,0), 1 },
			name = false,
			nameColor = { Color3.new(1,1,1), 1 },
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			weapon = false,
			weaponColor = { Color3.new(1,1,1), 1 },
			weaponOutline = true,
			weaponOutlineColor = Color3.new(),
			distance = false,
			distanceColor = { Color3.new(1,1,1), 1 },
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false,
			tracerOrigin = "Bottom",
			tracerColor = { Color3.new(1,0,0), 1 },
			tracerOutline = true,
			tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false,
			offScreenArrowColor = { Color3.new(1,1,1), 1 },
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = { Color3.new(), 1 },
			chams = false,
			chamsVisibleOnly = false,
			chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
			chamsOutlineColor = { Color3.new(1,0,0), 0 },
		},
		friendly = {
			enabled = false,
			box = false,
			boxColor = { Color3.new(0,1,0), 1 },
			boxOutline = true,
			boxOutlineColor = { Color3.new(), 1 },
			boxFill = false,
			boxFillColor = { Color3.new(0,1,0), 0.5 },
			healthBar = false,
			healthyColor = Color3.new(0,1,0),
			dyingColor = Color3.new(1,0,0),
			healthBarOutline = true,
			healthBarOutlineColor = { Color3.new(), 0.5 },
			healthText = false,
			healthTextColor = { Color3.new(1,1,1), 1 },
			healthTextOutline = true,
			healthTextOutlineColor = Color3.new(),
			box3d = false,
			box3dColor = { Color3.new(0,1,0), 1 },
			name = false,
			nameColor = { Color3.new(1,1,1), 1 },
			nameOutline = true,
			nameOutlineColor = Color3.new(),
			weapon = false,
			weaponColor = { Color3.new(1,1,1), 1 },
			weaponOutline = true,
			weaponOutlineColor = Color3.new(),
			distance = false,
			distanceColor = { Color3.new(1,1,1), 1 },
			distanceOutline = true,
			distanceOutlineColor = Color3.new(),
			tracer = false,
			tracerOrigin = "Bottom",
			tracerColor = { Color3.new(0,1,0), 1 },
			tracerOutline = true,
			tracerOutlineColor = { Color3.new(), 1 },
			offScreenArrow = false,
			offScreenArrowColor = { Color3.new(1,1,1), 1 },
			offScreenArrowSize = 15,
			offScreenArrowRadius = 150,
			offScreenArrowOutline = true,
			offScreenArrowOutlineColor = { Color3.new(), 1 },
			chams = false,
			chamsVisibleOnly = false,
			chamsFillColor = { Color3.new(0.2, 0.2, 0.2), 0.5 },
			chamsOutlineColor = { Color3.new(0,1,0), 0 }
		}
	}
};

function EspInterface.AddInstance(instance, options)
	local cache = EspInterface._objectCache;
	if cache[instance] then
		warn("Instance handler already exists.");
	else
		cache[instance] = { InstanceObject.new(instance, options) };
	end
	return cache[instance][1];
end

function EspInterface.Load()
	assert(not EspInterface._hasLoaded, "Esp has already been loaded.");

	local function createObject(player)
		EspInterface._objectCache[player] = {
			EspObject.new(player, EspInterface),
			ChamObject.new(player, EspInterface)
		};
	end

	local function removeObject(player)
		local object = EspInterface._objectCache[player];
		if object then
			for i = 1, #object do
				object[i]:Destruct();
			end

			EspInterface._objectCache[player] = nil;
		end
	end

	for _, player in next, players:GetPlayers() do
		if player ~= localPlayer then
			createObject(player);
		end
	end

	EspInterface.playerAdded = players.PlayerAdded:Connect(createObject);
	EspInterface.playerRemoving = players.PlayerRemoving:Connect(removeObject);
	EspInterface._hasLoaded = true;
end

function EspInterface.Unload()
	assert(EspInterface._hasLoaded, "Esp has not been loaded yet.");

	for _, object in next, EspInterface._objectCache do
		for i = 1, #object do
			object[i]:Destruct();
		end
	end

	EspInterface.playerAdded:Disconnect();
	EspInterface.playerRemoving:Disconnect();
	EspInterface._hasLoaded = false;
end

-- game specific functions
function EspInterface.getWeapon(player)
	return "[ Unarmed ]";
end

function EspInterface.isFriendly(player)
	return player.Team and player.Team == localPlayer.Team;
end

function EspInterface.getCharacter(player)
	return player.Character;
end

function EspInterface.getHealth(character)
	local humanoid = character and findFirstChildOfClass(character, "Humanoid");
	if humanoid then
		return humanoid.Health, humanoid.MaxHealth;
	end
	return 100, 100;
end

return EspInterface;