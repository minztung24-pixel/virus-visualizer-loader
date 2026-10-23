do
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local env = type(getgenv) == "function" and getgenv() or _G
local previousKeys = {"__giftPlayerWeaponPicker", "__giftPlayerWeaponFX", "__giftPlayerNativeWeapon", "__giftPlayerWeaponSkin", "__giftPlayerExactAvatar", "__giftPlayerStableRoomMoon", "__giftPlayerR6GaitAura", "__giftPlayerV8R6AdidasFix", "__giftPlayerV8V24RigFix", "__giftPlayerV8SkinAdidas", "__giftPlayerV8FaceAdidas", "__giftPlayerPanelV26Safe", "__giftPlayerPanelV26Fixed"}
for version = 26, 9, -1 do previousKeys[#previousKeys+1] = "__giftPlayerPanelV" .. version end
for _, key in ipairs(previousKeys) do
    local previous = env[key]
    if previous and type(previous.stop) == "function" then pcall(function() previous.stop(true) end) end
    env[key] = nil
end
for _, key in ipairs({"__giftPlayerPanelV8", "__giftPlayerPanelV7", "__giftPlayerPanelV6", "__giftPlayerPanelV5", "__giftPlayerPanelV4", "__giftPlayerPanelV2", "__giftPlayerPanel"}) do
    local old = env[key]
    if old and type(old.stop) == "function" then old.stop(true) end
end
if env.__giftPlayerHideState and type(env.__giftPlayerHideState.stop) == "function" then
    env.__giftPlayerHideState.stop()
end
if type(env.__giftPlayerHideStop) == "function" then env.__giftPlayerHideStop() end
if env.__giftPlayerListMask then
    for _, connection in ipairs(env.__giftPlayerListMask) do connection:Disconnect() end
    env.__giftPlayerListMask = nil
end
-- Call from a LocalScript for a local visual only. The blue check uses the
-- Roblox client texture; it does not change account verification.
-- Required api fields: Instance, UDim2, Color3, Enum, and TweenService.
-- UDim, TweenInfo, Vector2, Vector3, and ColorSequence are Roblox globals.
-- RunService is not needed.

local function createDeveloperNameplate(api)
	assert(type(api) == "table", "createDeveloperNameplate requires an api table")
	for _, field in ipairs({ "Instance", "UDim2", "Color3", "Enum", "TweenService" }) do
		assert(api[field] ~= nil, "createDeveloperNameplate requires api." .. field)
	end

	local Instance = api.Instance
	local UDim = api.UDim or UDim
	local UDim2 = api.UDim2
	local Color3 = api.Color3
	local Enum = api.Enum
	local TweenInfo = api.TweenInfo or TweenInfo
	local Vector2 = api.Vector2 or Vector2
	local Vector3 = api.Vector3 or Vector3
	local ColorSequence = api.ColorSequence or ColorSequence
	local ColorSequenceKeypoint = api.ColorSequenceKeypoint or ColorSequenceKeypoint
	local TweenService = api.TweenService

	local palette = {
		blue = { text = Color3.fromRGB(0, 162, 255), accent = Color3.fromRGB(58, 158, 255), surface = Color3.fromRGB(12, 31, 59) },
		sky = { text = Color3.fromRGB(132, 215, 255), accent = Color3.fromRGB(132, 215, 255), surface = Color3.fromRGB(17, 40, 60) },
		red = { text = Color3.fromRGB(255, 104, 119), accent = Color3.fromRGB(255, 99, 112), surface = Color3.fromRGB(57, 19, 32) },
		yellow = { text = Color3.fromRGB(255, 213, 77), accent = Color3.fromRGB(255, 209, 74), surface = Color3.fromRGB(54, 41, 18) },
	}
	local entries = {}
	local enabled = true
	local colorKey = "blue"
	local shineDirection = "right"
	local height = 0.75
	local size = 1
	local destroyed = false
	local feature = {}
	local function textGradient(key)
		local base = palette[key].text
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, base),
			ColorSequenceKeypoint.new(0.37, base),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.63, base),
			ColorSequenceKeypoint.new(1, base),
		})
	end
	local function playShine(entry)
		if entry.shineTween then entry.shineTween:Cancel() end
		local start = shineDirection == "right" and -1.3 or 1.3
		entry.gradient.Offset = Vector2.new(start, 0)
		entry.shineTween = TweenService:Create(entry.gradient,
			TweenInfo.new(2.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 1.2),
			{ Offset = Vector2.new(-start, 0) })
		entry.shineTween:Play()
	end

	local function getAnchor(model)
		local root = model:FindFirstChild("HumanoidRootPart", true)
		if root and root:IsA("BasePart") then
			return root, false
		end
		local head = model:FindFirstChild("Head", true)
		if head and head:IsA("BasePart") then
			return head, true
		end
		return nil, false
	end

	local function remove(key)
		local entry = entries[key]
		if not entry then
			return
		end
		entries[key] = nil
		if entry.destroying then
			entry.destroying:Disconnect()
		end
		if entry.shineTween then entry.shineTween:Cancel() end
		entry.gui:Destroy()
	end

	local function makeCheck(gui)
		local badge = Instance.new("ImageLabel")
		badge.Name = "DecorativeBlueCheck"
		badge.BackgroundTransparency = 1
		badge.BorderSizePixel = 0
		badge.Position = UDim2.fromScale(0.82, 0.15)
		badge.Size = UDim2.fromScale(0.13, 0.70)
		badge.Image = "rbxasset://textures/ui/VerifiedBadgeNameIcon.png"
		badge.ImageColor3 = Color3.fromRGB(255, 255, 255)
		badge.ImageTransparency = 0
		badge.ScaleType = Enum.ScaleType.Fit
		badge.ZIndex = 10
		badge.Visible = true
		badge.Parent = gui
	end

	local function updateHeight(entry)
		local anchor = entry.anchor
		local lift = anchor.Size.Y * 0.5 + 0.85 + height
		if not entry.isHead then
			local head = entry.model:FindFirstChild("Head", true)
			if head and head:IsA("BasePart") then
				lift = math.max(lift, head.Position.Y + head.Size.Y * 0.5
					- anchor.Position.Y + 0.85 + height)
			end
		end
		entry.gui.StudsOffsetWorldSpace = Vector3.new(0, lift, 0)
	end

	function feature:Attach(model, key)
		if destroyed then
			return nil
		end
		assert(key ~= nil, "Attach requires a key")
		assert(model and model:IsA("Model"), "Attach requires a Model")

		local anchor, isHead = getAnchor(model)
		if not anchor then
			return nil
		end
		local old = entries[key]
		if old and old.model == model and old.anchor == anchor and old.gui.Parent == anchor then
			updateHeight(old)
			return old.gui
		end
		remove(key)

		local gui = Instance.new("BillboardGui")
		gui.Name = "LocalDeveloperNameplate"
		gui.Adornee = anchor
		gui.AlwaysOnTop = true
		gui.LightInfluence = 0
		gui.MaxDistance = 90
		gui.Size = UDim2.fromScale(3.2 * size, 0.64 * size)
		gui.Enabled = enabled

		local plate = Instance.new("Frame")
		plate.Name = "Plate"
		plate.BackgroundColor3 = palette[colorKey].surface
		plate.BackgroundTransparency = 1
		plate.BorderSizePixel = 0
		plate.ClipsDescendants = false
		plate.Size = UDim2.fromScale(1, 1)
		plate.Parent = gui

		local stroke = Instance.new("UIStroke")
		stroke.Name = "AccentStroke"
		stroke.Color = palette[colorKey].accent
		stroke.Thickness = 1.5
		stroke.Transparency = 1
		stroke.Parent = plate

		local label = Instance.new("TextLabel")
		label.Name = "DeveloperText"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.Text = "Developer"
		label.TextColor3 = palette[colorKey].text
		label.TextStrokeColor3 = Color3.fromRGB(5, 12, 27)
		label.TextStrokeTransparency = 0.2
		label.TextScaled = true
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Position = UDim2.fromScale(0.05, 0)
		label.Size = UDim2.fromScale(0.72, 1)
		label.Parent = plate
		local gradient = Instance.new("UIGradient")
		gradient.Name = "TextShine"
		gradient.Color = textGradient(colorKey)
		gradient.Rotation = 16
		gradient.Parent = label

		makeCheck(gui)
		gui.Parent = anchor

		local entry = { model = model, anchor = anchor, isHead = isHead, gui = gui, stroke = stroke,
			plate = plate, label = label, gradient = gradient }
		entries[key] = entry
		updateHeight(entry)
		entry.destroying = model.Destroying:Connect(function()
			remove(key)
		end)
		playShine(entry)
		return gui
	end

	function feature:Detach(key)
		remove(key)
	end

	function feature:SetEnabled(value)
		assert(type(value) == "boolean", "SetEnabled requires a boolean")
		if destroyed then
			return
		end
		enabled = value
		for _, entry in pairs(entries) do
			entry.gui.Enabled = value
		end
	end

	function feature:SetColor(newColorKey)
		assert(palette[newColorKey] ~= nil, "SetColor accepts only blue, sky, red, or yellow")
		if destroyed then
			return
		end
		colorKey = newColorKey
		for _, entry in pairs(entries) do
			entry.plate.BackgroundColor3 = palette[colorKey].surface
			entry.stroke.Color = palette[colorKey].accent
			entry.label.TextColor3 = palette[colorKey].text
			entry.gradient.Color = textGradient(colorKey)
		end
	end

	function feature:SetShineDirection(direction)
		assert(direction == "right" or direction == "left", "Shine direction must be right or left")
		if destroyed or shineDirection == direction then return end
		shineDirection = direction
		for _, entry in pairs(entries) do playShine(entry) end
	end

	function feature:SetHeight(value)
		assert(type(value) == "number", "SetHeight requires a number")
		if destroyed then return end
		height = math.clamp(value, 0, 3)
		for _, entry in pairs(entries) do updateHeight(entry) end
	end

	function feature:SetSize(value)
		assert(type(value) == "number", "SetSize requires a number")
		if destroyed then return end
		size = math.clamp(value, 0.7, 1.6)
		for _, entry in pairs(entries) do
			entry.gui.Size = UDim2.fromScale(3.2 * size, 0.64 * size)
		end
	end

	function feature:Destroy()
		if destroyed then
			return
		end
		destroyed = true
		for key in pairs(entries) do
			remove(key)
		end
	end

	return feature
end

local function createVisualizerSettings(api)
    local file="THT_Item_Visualizer_"..tostring(api.placeId)..".json"
    local data={version=1,hideRoom=true,username="",avatar="",weapon="",
        pack="",moon=false,developer=false,developerColor="blue",
        developerShineDirection="right",developerHeight=0.75,developerSize=1,
        page="avatar",collapsed=false}
    local disk=type(api.readfile)=="function" and type(api.writefile)=="function"
    local raw
    if disk then
        local ok,value=pcall(api.readfile,file)
        if ok and type(value)=="string" then raw=value end
    end
    if not raw and api.env then raw=api.env.__THTItemVisualizerSettings end
    if type(raw)=="string" then
        local ok,value=pcall(function() return api.http:JSONDecode(raw) end)
        if ok and type(value)=="table" and value.version==1 then
            if type(value.hideRoom)=="boolean" then data.hideRoom=value.hideRoom end
            if type(value.username)=="string" and #value.username<=40
                and (value.username=="" or value.username:match("^[%w_]+$")) then data.username=value.username end
            if type(value.avatar)=="string" and #value.avatar<=40
                and (value.avatar=="" or value.avatar:match("^[%w_]+$")) then data.avatar=value.avatar end
            if type(value.weapon)=="string" and #value.weapon<=40
                and value.weapon:match("^[%w_]*$") then data.weapon=value.weapon end
            if value.pack=="community" or value.pack=="aura" then data.pack=value.pack end
            if type(value.moon)=="boolean" then data.moon=value.moon end
            if type(value.developer)=="boolean" then data.developer=value.developer end
            if value.developerColor=="blue" or value.developerColor=="sky" or value.developerColor=="red"
                or value.developerColor=="yellow" then data.developerColor=value.developerColor end
            if value.developerShineDirection=="right" or value.developerShineDirection=="left" then
                data.developerShineDirection=value.developerShineDirection end
            if type(value.developerHeight)=="number" and value.developerHeight==value.developerHeight then
                data.developerHeight=math.clamp(value.developerHeight,0,3) end
            if type(value.developerSize)=="number" and value.developerSize==value.developerSize then
                data.developerSize=math.clamp(value.developerSize,0.7,1.6) end
            if value.page=="avatar" or value.page=="weapons" or value.page=="effects" or value.page=="clone" then data.page=value.page end
            if type(value.collapsed)=="boolean" then data.collapsed=value.collapsed end
        end
    end
    local function save()
        local ok,encoded=pcall(function() return api.http:JSONEncode(data) end)
        if not ok then return false end
        if api.env then api.env.__THTItemVisualizerSettings=encoded end
        if not disk then return false end
        local written=pcall(api.writefile,file,encoded)
        return written
    end
    return data,save,disk,file
end

local settings,saveSettings,settingsPersistent=createVisualizerSettings({
    http=game:GetService("HttpService"),placeId=game.PlaceId,
    readfile=readfile,writefile=writefile,env=env})
local persistSettings
local state: any = {
    alive = true, hideRoom = settings.hideRoom, connections = {},
    giftTitles = setmetatable({}, {__mode = "k"}),
    targets = setmetatable({}, {__mode = "k"}), avatarToken = 0,
    statusSerial = 0,
    avatarBusy = false, originalAppearance = nil,
}
env.__giftPlayerWeaponPicker = state

local function on(signal, callback)
    local connection = signal:Connect(function(...)
        if state.alive then callback(...) end
    end)
    state.connections[#state.connections + 1] = connection
    return connection
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius)
    item.Parent = parent
end

local function makeText(parent, value, x, y, width, height, size, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    item.Text = value
    item.TextColor3 = color
    item.TextSize = size
    item.Font = Enum.Font.GothamBold
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextTruncate = Enum.TextTruncate.AtEnd
    item.Position = UDim2.fromOffset(x, y)
    item.Size = UDim2.fromOffset(width, height)
    item.ZIndex = parent.ZIndex + 1
    item.Parent = parent
    return item
end

local function makeButton(parent, value, x, y, width, height, color)
    local item = Instance.new("TextButton")
    item.Text = value
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.TextSize = 13
    item.Font = Enum.Font.GothamBold
    item.AutoButtonColor = true
    item.BorderSizePixel = 0
    item.BackgroundColor3 = color
    item.Position = UDim2.fromOffset(x, y)
    item.Size = UDim2.fromOffset(width, height)
    item.ZIndex = parent.ZIndex + 1
    item.Parent = parent
    corner(item, 8)
    return item
end
local ui=Instance.new("ScreenGui")
ui.Name="THTItemVisualizer"; ui.ResetOnSpawn=false; ui.IgnoreGuiInset=true
ui.DisplayOrder=10000; ui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local theme={surface=Color3.fromRGB(20,22,31),card=Color3.fromRGB(35,38,52),
    edge=Color3.fromRGB(66,66,89),purple=Color3.fromRGB(115,86,255),
    text=Color3.fromRGB(241,241,250),muted=Color3.fromRGB(152,156,180)}
local function themeStroke(parent,color,transparency)
    local stroke=Instance.new("UIStroke"); stroke.Color=color or theme.edge
    stroke.Thickness=1; stroke.Transparency=transparency or 0; stroke.Parent=parent
end
local panel=Instance.new("Frame"); panel.Name="Controls"
panel.Size=UDim2.fromOffset(360,548); panel.Position=UDim2.new(1,-374,0,54)
panel.BackgroundColor3=theme.surface; panel.BorderSizePixel=0; panel.ZIndex=20
panel.ClipsDescendants=true; panel.Parent=ui; corner(panel,12); themeStroke(panel,Color3.fromRGB(100,87,147),.15)
for row=0,9 do for column=0,7 do
    local dot=Instance.new("Frame"); dot.Size=UDim2.fromOffset(2,2)
    dot.Position=UDim2.fromOffset(20+column*44,62+row*44)
    dot.BackgroundColor3=Color3.fromRGB(95,92,132); dot.BackgroundTransparency=.88
    dot.BorderSizePixel=0; dot.ZIndex=20; dot.Parent=panel
end end
local header=Instance.new("Frame"); header.Name="Header"
header.Size=UDim2.fromOffset(360,44); header.BackgroundColor3=Color3.fromRGB(29,31,43)
header.BorderSizePixel=0; header.ZIndex=21; header.Parent=panel; corner(header,12)
local headerGradient=Instance.new("UIGradient")
headerGradient.Color=ColorSequence.new(Color3.fromRGB(34,35,51),Color3.fromRGB(24,26,36)); headerGradient.Parent=header
local logo=makeButton(header,"T",10,9,27,27,theme.purple); logo.AutoButtonColor=false; logo.TextSize=15
makeText(header,"THT ITEM VISUALIZER",45,10,196,25,13,theme.text)
local badge=makeText(header,"LOCAL",246,14,43,18,9,Color3.fromRGB(191,180,255))
badge.BackgroundTransparency=0; badge.BackgroundColor3=Color3.fromRGB(53,43,89); corner(badge,6)
badge.TextXAlignment=Enum.TextXAlignment.Center
local collapseButton=makeButton(header,"-",296,10,24,24,Color3.fromRGB(43,46,62))
local closeButton=makeButton(header,"X",326,10,24,24,Color3.fromRGB(43,46,62))
local body=Instance.new("Frame"); body.Name="MenuBody"
body.BackgroundTransparency=1; body.Position=UDim2.fromOffset(0,44)
body.Size=UDim2.fromOffset(360,504); body.ZIndex=21; body.Parent=panel
local pages,tabs={},{}
local openWeaponPicker
local usernameBox
local function showMenuPage(id)
    for key,page in pairs(pages) do page.Visible=key==id end
    for key,tab in pairs(tabs) do
        tab.BackgroundColor3=key==id and theme.purple or Color3.fromRGB(39,42,57)
        tab.TextColor3=key==id and theme.text or theme.muted
    end
end
for index,entry in ipairs({{"avatar","AVATAR"},{"weapons","VŨ KHÍ"},{"effects","HIỆU ỨNG"},{"clone","BẢN SAO"}}) do
    local id=entry[1]
    local tab=makeButton(body,entry[2],10+(index-1)*84,8,80,31,theme.card)
    tab.Name="Tab_"..id; tab.TextSize=10; tabs[id]=tab
    local page=Instance.new(id=="effects" and "ScrollingFrame" or "Frame"); page.Name="Page_"..id
    page.BackgroundTransparency=1; page.Position=UDim2.fromOffset(10,52)
    page.Size=UDim2.fromOffset(340,394); page.ZIndex=22; page.Parent=body; pages[id]=page
    if id=="effects" then
        page.BorderSizePixel=0; page.ScrollBarThickness=4
        page.ScrollBarImageColor3=Color3.fromRGB(124,103,199)
        page.CanvasSize=UDim2.fromOffset(0,785)
        page.ScrollingDirection=Enum.ScrollingDirection.Y
    end
    on(tab.MouseButton1Click,function()
        usernameBox:ReleaseFocus(false)
        showMenuPage(id)
        settings.page=id; persistSettings()
        if id=="weapons" and openWeaponPicker then openWeaponPicker() end
    end)
end
local avatarPage,effectsPage,weaponPage=pages.avatar,pages.effects,pages.weapons
state.CloneHostPage=pages.clone
local function section(parent,label,y)
    local accent=Instance.new("Frame"); accent.BorderSizePixel=0
    accent.BackgroundColor3=theme.purple; accent.Position=UDim2.fromOffset(0,y+3)
    accent.Size=UDim2.fromOffset(3,12); accent.ZIndex=parent.ZIndex+1; accent.Parent=parent; corner(accent,2)
    makeText(parent,label,10,y,326,18,10,Color3.fromRGB(165,147,255))
end
local function surface(parent,y,height)
    local card=Instance.new("Frame"); card.BackgroundColor3=theme.card
    card.BackgroundTransparency=.1; card.BorderSizePixel=0; card.Position=UDim2.fromOffset(0,y)
    card.Size=UDim2.fromOffset(340,height); card.ZIndex=parent.ZIndex+1; card.Parent=parent
    corner(card,8); themeStroke(card,theme.edge,.45); return card
end
section(avatarPage,"NGƯỜI CHƠI",0)
local roomCard=surface(avatarPage,25,62)
makeText(roomCard,"Ẩn người trong room",12,9,233,22,12,theme.text)
makeText(roomCard,"Quản lý danh sách người chơi",12,32,233,18,10,theme.muted)
local hideToggle=makeButton(roomCard,"BẬT",264,16,64,29,Color3.fromRGB(57,161,112))
section(avatarPage,"NGOẠI HÌNH ROBLOX",106)
usernameBox=Instance.new("TextBox"); usernameBox.Name="AvatarUsername"
usernameBox.PlaceholderText="Nhập username Roblox"; usernameBox.Text=""; usernameBox.ClearTextOnFocus=false
usernameBox.TextColor3=theme.text; usernameBox.PlaceholderColor3=theme.muted
usernameBox.TextSize=12; usernameBox.Font=Enum.Font.Gotham
usernameBox.BackgroundColor3=Color3.fromRGB(30,33,45); usernameBox.BorderSizePixel=0
usernameBox.Position=UDim2.fromOffset(0,132); usernameBox.Size=UDim2.fromOffset(340,36)
usernameBox.ZIndex=23; usernameBox.Parent=avatarPage; corner(usernameBox,7); themeStroke(usernameBox,theme.edge,.2)
local applyButton=makeButton(avatarPage,"Apply avatar",0,179,166,34,theme.purple)
local restoreButton=makeButton(avatarPage,"Khôi phục",174,179,166,34,theme.card)
makeText(avatarPage,"Nhập username rồi bấm Apply avatar.",0,220,340,19,11,theme.muted)
section(avatarPage,"VŨ KHÍ",262)
local weaponPickerButton=makeButton(avatarPage,"Chọn vũ khí…",0,289,340,34,theme.purple)
local scanWeaponButton=makeButton(avatarPage,"Quét mẫu game",0,348,340,31,theme.card)
makeText(avatarPage,"Đọc lại các mẫu vũ khí và hiệu ứng đã tải.",0,378,340,16,10,theme.muted)
section(effectsPage,"GÓI CHUYỂN ĐỘNG",0)
local communityCard=surface(effectsPage,28,86)
makeText(communityCard,"COMMUNITY",12,9,310,21,12,theme.text)
local adidasButton=makeButton(communityCard,"adidas Community: TẮT",12,43,316,31,Color3.fromRGB(69,58,94))
local auraCard=surface(effectsPage,128,86)
makeText(auraCard,"AURA",12,9,310,21,12,theme.text)
local auraButton=makeButton(auraCard,"adidas Aura: TẮT",12,43,316,31,Color3.fromRGB(69,58,94))
section(effectsPage,"HIỆU ỨNG NHÂN VẬT",238)
local moonCard=surface(effectsPage,266,86)
makeText(moonCard,"MOONBLOOM TRAIL",12,9,310,21,12,theme.text)
local moonButton=makeButton(moonCard,"Moonbloom Trail: TẮT",12,43,316,31,Color3.fromRGB(69,58,94))
makeText(effectsPage,"Bấm lại gói đang chọn để tắt.",0,365,340,20,11,theme.muted)
section(effectsPage,"DANH HIỆU NHÂN VẬT",396)
local developerCard=surface(effectsPage,423,338)
makeText(developerCard,"Developer  •  tích xanh",12,9,316,21,12,theme.text)
local developerToggle=makeButton(developerCard,"Developer: TẮT",12,37,316,32,Color3.fromRGB(69,58,94))
local developerColors={}
for index,entry in ipairs({{"blue","XANH ĐẬM",Color3.fromRGB(0,140,235)},
    {"sky","XANH TRỜI",Color3.fromRGB(79,190,255)},
    {"red","ĐỎ",Color3.fromRGB(231,72,83)},
    {"yellow","VÀNG",Color3.fromRGB(239,181,54)}}) do
    local button=makeButton(developerCard,entry[2],12+(index-1)*79,79,73,31,entry[3])
    button.TextSize=9
    if entry[1]=="sky" or entry[1]=="yellow" then
        button.TextColor3=Color3.fromRGB(24,30,42)
    end
    developerColors[entry[1]]=button
end
makeText(developerCard,"HƯỚNG VỆT SÁNG",12,121,316,18,10,theme.muted)
local shineRightButton=makeButton(developerCard,"TRÁI → PHẢI",12,145,152,31,theme.card)
local shineLeftButton=makeButton(developerCard,"PHẢI → TRÁI",176,145,152,31,theme.card)
shineRightButton.TextSize=11; shineLeftButton.TextSize=11
makeText(developerCard,"ĐỘ CAO TRÊN ĐẦU",12,188,316,18,10,theme.muted)
local heightDownButton=makeButton(developerCard,"−",12,211,69,32,theme.card)
local heightValue=makeText(developerCard,"",91,213,155,27,13,theme.text)
heightValue.TextXAlignment=Enum.TextXAlignment.Center
local heightUpButton=makeButton(developerCard,"+",258,211,70,32,theme.card)
makeText(developerCard,"CỠ CHỮ",12,250,316,18,10,theme.muted)
local sizeDownButton=makeButton(developerCard,"−",12,273,69,32,theme.card)
local sizeValue=makeText(developerCard,"",91,275,155,27,13,theme.text)
sizeValue.TextXAlignment=Enum.TextXAlignment.Center
local sizeUpButton=makeButton(developerCard,"+",258,273,70,32,theme.card)
makeText(developerCard,"Hiện trên người thật và bản sao • chỉ máy bạn",12,315,316,18,10,theme.muted)
local woodButton=makeButton(weaponPage,"Gậy gỗ / hình gốc",0,364,340,30,theme.card)
local statusBar=Instance.new("Frame"); statusBar.Name="StatusBar"
statusBar.BackgroundColor3=Color3.fromRGB(27,29,40); statusBar.BorderSizePixel=0
statusBar.Position=UDim2.fromOffset(10,466); statusBar.Size=UDim2.fromOffset(340,27)
statusBar.ZIndex=22; statusBar.Parent=body; corner(statusBar,7)
makeText(statusBar,"•",8,4,12,18,13,Color3.fromRGB(154,129,255))
local status=makeText(statusBar,"Sẵn sàng",24,4,306,19,10,theme.muted)
showMenuPage(settings.page)
usernameBox.Text=settings.username
ui.Parent=playerGui
badge.Text=settingsPersistent and "SAVE" or "RAM"
persistSettings=function()
    badge.Text=saveSettings() and "SAVE" or "RAM"
end

local function setStatus(message)
    state.statusSerial = state.statusSerial + 1
    status.Text = message
end

local developerNameplate=createDeveloperNameplate({
    Instance=Instance, UDim2=UDim2, Color3=Color3, Enum=Enum,
    TweenService=game:GetService("TweenService"), RunService=RunService,
})
developerNameplate:SetColor(settings.developerColor)
developerNameplate:SetShineDirection(settings.developerShineDirection)
developerNameplate:SetHeight(settings.developerHeight)
developerNameplate:SetSize(settings.developerSize)
developerNameplate:SetEnabled(settings.developer)
local hiddenNameHumanoids={}
local function restoreDefaultNames()
    for humanoid,displayType in pairs(hiddenNameHumanoids) do
        if humanoid.Parent then humanoid.DisplayDistanceType=displayType end
        hiddenNameHumanoids[humanoid]=nil
    end
end
local function hideDefaultName(model)
    local humanoid=model and model:FindFirstChildOfClass("Humanoid")
    if humanoid and hiddenNameHumanoids[humanoid]==nil then
        hiddenNameHumanoids[humanoid]=humanoid.DisplayDistanceType
        humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    end
end
local function refreshDeveloperReal()
    local camera=game:GetService("Workspace").CurrentCamera
    local display=camera and camera:FindFirstChild("GiftPlayerV8BodyDisplay")
    local model=display and display:IsA("Model") and display:FindFirstChild("Head")
        and display or localPlayer.Character
    if model then developerNameplate:Attach(model,"real")
    else developerNameplate:Detach("real") end
    restoreDefaultNames()
    if settings.developer then
        hideDefaultName(localPlayer.Character)
        hideDefaultName(model)
    end
end
state.SetDeveloperCloneModel=function(model)
    if model then developerNameplate:Attach(model,"clone")
    else developerNameplate:Detach("clone") end
end
local developerColorStrokes={}
local developerColorLabels={blue="XANH ĐẬM",sky="XANH TRỜI",red="ĐỎ",yellow="VÀNG"}
for key,button in pairs(developerColors) do
    local stroke=Instance.new("UIStroke")
    stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    stroke.Color=Color3.fromRGB(255,255,255)
    stroke.Parent=button
    developerColorStrokes[key]=stroke
end
local function paintDeveloperControls()
    developerToggle.Text=settings.developer and "Developer: BẬT" or "Developer: TẮT"
    developerToggle.BackgroundColor3=settings.developer
        and Color3.fromRGB(57,161,112) or Color3.fromRGB(69,58,94)
    for key,button in pairs(developerColors) do
        local selected=settings.developerColor==key
        button.Text=(selected and "✓ " or "")..developerColorLabels[key]
        local stroke=developerColorStrokes[key]
        stroke.Thickness=selected and 2 or 1
        stroke.Transparency=selected and 0 or .72
    end
    shineRightButton.BackgroundColor3=settings.developerShineDirection=="right"
        and theme.purple or theme.card
    shineLeftButton.BackgroundColor3=settings.developerShineDirection=="left"
        and theme.purple or theme.card
    heightValue.Text=string.format("+%.2f studs",settings.developerHeight)
    heightDownButton.BackgroundColor3=settings.developerHeight<=0 and theme.card or theme.purple
    heightUpButton.BackgroundColor3=settings.developerHeight>=3 and theme.card or theme.purple
    sizeValue.Text=string.format("%d%%",math.floor(settings.developerSize*100+0.5))
    sizeDownButton.BackgroundColor3=settings.developerSize<=0.7 and theme.card or theme.purple
    sizeUpButton.BackgroundColor3=settings.developerSize>=1.6 and theme.card or theme.purple
end
on(developerToggle.MouseButton1Click,function()
    settings.developer=not settings.developer
    developerNameplate:SetEnabled(settings.developer)
    refreshDeveloperReal()
    paintDeveloperControls(); persistSettings()
    setStatus(settings.developer and "Đã bật danh hiệu Developer cục bộ" or "Đã tắt danh hiệu Developer")
end)
for key,button in pairs(developerColors) do
    on(button.MouseButton1Click,function()
        settings.developerColor=key
        developerNameplate:SetColor(key)
        paintDeveloperControls(); persistSettings()
        setStatus("Đã chọn màu Developer: "..developerColorLabels[key])
    end)
end
on(shineRightButton.MouseButton1Click,function()
    settings.developerShineDirection="right"
    developerNameplate:SetShineDirection("right")
    paintDeveloperControls(); persistSettings()
end)
on(shineLeftButton.MouseButton1Click,function()
    settings.developerShineDirection="left"
    developerNameplate:SetShineDirection("left")
    paintDeveloperControls(); persistSettings()
end)
local function changeDeveloperHeight(delta)
    settings.developerHeight=math.clamp(math.floor((settings.developerHeight+delta)*4+0.5)/4,0,3)
    developerNameplate:SetHeight(settings.developerHeight)
    paintDeveloperControls(); persistSettings()
    setStatus(string.format("Độ cao Developer: +%.2f studs",settings.developerHeight))
end
on(heightDownButton.MouseButton1Click,function() changeDeveloperHeight(-0.25) end)
on(heightUpButton.MouseButton1Click,function() changeDeveloperHeight(0.25) end)
local function changeDeveloperSize(delta)
    settings.developerSize=math.clamp(math.floor((settings.developerSize+delta)*10+0.5)/10,0.7,1.6)
    developerNameplate:SetSize(settings.developerSize)
    paintDeveloperControls(); persistSettings()
    setStatus(string.format("Cỡ chữ Developer: %d%%",math.floor(settings.developerSize*100+0.5)))
end
on(sizeDownButton.MouseButton1Click,function() changeDeveloperSize(-0.1) end)
on(sizeUpButton.MouseButton1Click,function() changeDeveloperSize(0.1) end)
paintDeveloperControls()
refreshDeveloperReal()

local function paintToggle()
    hideToggle.Text = state.hideRoom and "BẬT" or "TẮT"
    hideToggle.BackgroundColor3 = state.hideRoom and Color3.fromRGB(57, 161, 112) or Color3.fromRGB(71, 66, 88)
end

local dragging, dragStart, panelStart
on(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        panelStart = panel.Position
    end
end)
on(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
on(UserInputService.InputChanged, function(input)
    if dragging and dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + delta.X, panelStart.Y.Scale, panelStart.Y.Offset + delta.Y)
    end
end)
on(collapseButton.MouseButton1Click, function()
    body.Visible = not body.Visible
    panel.Size = UDim2.fromOffset(360, body.Visible and 548 or 44)
    collapseButton.Text = body.Visible and "-" or "+"
    settings.collapsed=not body.Visible; persistSettings()
end)
if settings.collapsed then
    body.Visible=false
    panel.Size=UDim2.fromOffset(360,44)
    collapseButton.Text="+"
end
local function isText(x)
    return x:IsA("TextLabel") or x:IsA("TextButton") or x:IsA("TextBox")
end
local function isGiftTitle(x)
    return isText(x) and x.Text:lower():find("gift player", 1, true) ~= nil
end
local function hasQuery(record)
    for box in pairs(record.searchBoxes) do
        if box.Parent and box.Text:find("%S") then return true end
    end
    return false
end
local function updateList(record, reveal)
    local list = record.list
    if not list.Parent then return end
    if state.hideRoom and not hasQuery(record) then
        if list.Visible then list.Visible = false end
    elseif reveal and not list.Visible then
        list.Visible = true
    end
end
local function watchSearchBox(record, box)
    if record.searchBoxes[box] or not box:IsA("TextBox") then return end
    record.searchBoxes[box] = true
    on(box:GetPropertyChangedSignal("Text"), function()
        updateList(record, true)
    end)
    updateList(record, true)
end
local function registerList(list, panelRoot)
    if list:IsDescendantOf(ui) or state.targets[list] then return end
    local record = {list = list, panelRoot = panelRoot, searchBoxes = setmetatable({}, {__mode = "k"})}
    state.targets[list] = record
    for _, x in ipairs(panelRoot:GetDescendants()) do
        if x:IsA("TextBox") then watchSearchBox(record, x) end
    end
    on(list:GetPropertyChangedSignal("Visible"), function()
        if state.hideRoom and not hasQuery(record) and list.Visible then list.Visible = false end
    end)
    updateList(record, true)
end
local function resolveTitle(title)
    if not title.Parent or title:IsDescendantOf(ui) or not isGiftTitle(title) then return end
    local parent = title.Parent
    local firstList, firstRoot
    while parent and parent ~= playerGui do
        if parent:IsA("GuiObject") then
            local list = parent:FindFirstChildWhichIsA("ScrollingFrame", true)
            if list then
                if not firstList then firstList, firstRoot = list, parent end
                for _, x in ipairs(parent:GetDescendants()) do
                    if x:IsA("TextBox") then
                        registerList(firstList, parent)
                        return
                    end
                end
            end
        end
        parent = parent.Parent
    end
    if firstList then registerList(firstList, firstRoot) end
end
local function rememberTitle(x)
    if isGiftTitle(x) and not x:IsDescendantOf(ui) then
        state.giftTitles[x] = true
        resolveTitle(x)
    end
end
local function scanForTitles()
    for _, x in ipairs(playerGui:GetDescendants()) do
        if isText(x) then rememberTitle(x) end
    end
end
local function hasLiveTitle()
    for title in pairs(state.giftTitles) do
        if title.Parent then return true end
    end
    return false
end
local function queueTitleScan()
    if state.scanQueued or hasLiveTitle() then return end
    state.scanQueued = true
    local elapsed = os.clock() - (state.lastTitleScan or 0)
    task.delay(math.max(0.35, 1 - elapsed), function()
        state.scanQueued = false
        if state.alive then
            state.lastTitleScan = os.clock()
            scanForTitles()
        end
    end)
end
on(playerGui.DescendantAdded, function(x)
    if x:IsDescendantOf(ui) then return end
    if isGiftTitle(x) then
        rememberTitle(x)
    elseif x:IsA("ScrollingFrame") then
        local relevant = false
        for title in pairs(state.giftTitles) do
            local screen = title.Parent and title:FindFirstAncestorOfClass("ScreenGui")
            if screen and x:IsDescendantOf(screen) then relevant = true; break end
        end
        if relevant and not state.resolveQueued then
            state.resolveQueued = true
            task.defer(function()
                state.resolveQueued = false
                if not state.alive then return end
                for title in pairs(state.giftTitles) do
                    if title.Parent then resolveTitle(title) end
                end
            end)
        end
    elseif x:IsA("TextBox") then
        for list, record in pairs(state.targets) do
            if list.Parent and x:IsDescendantOf(record.panelRoot) then
                watchSearchBox(record, x)
            end
        end
    end
    if not hasLiveTitle() and (x:IsA("ScreenGui")
        or (x:IsA("TextLabel") and (x.Name:lower():find("title", 1, true)
            or x.Name:lower():find("header", 1, true)))) then
        queueTitleScan()
    end
end)
scanForTitles()
local function setRealListVisible(visible)
    for list, record in pairs(state.targets) do
        if list.Parent then
            if visible then
                if not list.Visible then list.Visible = true end
            else
                updateList(record, false)
            end
        end
    end
end
local function createV8Additions(api)
    local extras = {generation = 0, enabled = false, pending = nil, bank = nil, activePack = nil}
    local packs = {
        community = {name="Community", assets={idle=126354114956642, walk=106810508343012,
            run=124765145869332, jump=115715495289805, fall=93993406355955,
            climb=123695349157584, swim=106537993816942}},
        aura = {name="Aura", assets={idle=73137983344853, walk=75183215343859,
            run=123973978164540, jump=129527230938281, fall=99457463463495,
            climb=140398319728398, swim=119007025452432}},
    }
    local poses = {"idle", "walk", "run", "jump", "fall", "climb", "swim"}
    local cache = {}
    local function destroy(item)
        if item then pcall(function() item:Destroy() end) end
    end
    function extras:ApplyFace(snapshot, sourceHead, head, description)
        if not sourceHead or not head then error("Không tải được đầu của avatar") end
        local folder = api.Instance.new("Folder")
        folder.Name = "GiftPlayerV8Face"
        snapshot.added[#snapshot.added + 1] = folder
        local visual = sourceHead:Clone()
        if description then
            if description.HeadColor then visual.Color = description.HeadColor end
            if (description.Head or 0) == 0 and (description.Face or 0) == 0 then
                local face = visual:FindFirstChild("face") or visual:FindFirstChild("Face")
                if not face then face = api.Instance.new("Decal"); face.Name = "face"; face.Parent = visual end
                face.Texture = "rbxasset://textures/face.png"
            end
        end
        visual.Name = "VisualHead"
        visual.Parent = folder
        for _, item in ipairs(visual:GetDescendants()) do
            if item:IsA("JointInstance") or item:IsA("Constraint")
                or item:IsA("WeldConstraint") or item:IsA("BaseScript")
                or item:IsA("ModuleScript") or item:IsA("BasePart") then
                item:Destroy()
            end
        end
        visual.Anchored = false
        visual.CanCollide = false
        visual.CanTouch = false
        visual.CanQuery = false
        visual.Massless = true
        visual.LocalTransparencyModifier = 0
        visual.CFrame = head.CFrame
        local weld = api.Instance.new("Weld")
        weld.Name = "GiftPlayerV8FaceWeld"
        weld.Part0, weld.Part1 = visual, head
        weld.C0, weld.C1 = api.CFrame.new(), api.CFrame.new()
        weld.Parent = visual
        snapshot.faceOriginal = {head = head, transparency = head.Transparency}
        folder.Parent = snapshot.character
        head.Transparency = 1
    end

    function extras:RestoreFace(snapshot)
        local saved = snapshot and snapshot.faceOriginal
        if saved then
            pcall(function() saved.head.Transparency = saved.transparency end)
            snapshot.faceOriginal = nil
        end
    end

    local function release(bank)
        if not bank or bank.closed then return end
        bank.closed = true
        for _, connection in ipairs(bank.connections) do connection:Disconnect() end
        for _, entry in ipairs(bank.resources) do
            pcall(function() entry.track:Stop(0.15) end)
        end
        api.task.spawn(function()
            api.task.wait(0.2)
            for _, entry in ipairs(bank.resources) do
                destroy(entry.track)
                destroy(entry.animation)
            end
        end)
    end

    function extras:Disable()
        self.generation = self.generation + 1
        self.enabled = false
        self.activePack = nil
        release(self.pending)
        release(self.bank)
        self.pending, self.bank = nil, nil
        api.onToggle(false, false)
    end

    local function resolve(id)
        if cache[id] then return cache[id] end
        local objects = api.getObjects("rbxassetid://" .. tostring(id))
        local clip
        for _, object in ipairs(objects) do
            if object:IsA("Animation") and object.AnimationId ~= "" then
                clip = clip or object.AnimationId
            end
            for _, child in ipairs(object:GetDescendants()) do
                if child:IsA("Animation") and child.AnimationId ~= "" then
                    clip = clip or child.AnimationId
                end
            end
            destroy(object)
        end
        if not clip then error("Không lấy được clip adidas " .. tostring(id)) end
        cache[id] = clip
        return clip
    end

    function extras:Enable(packKey)
        packKey = packKey or "community"
        local pack = packs[packKey]
        if not pack then api.onStatus("Gói animation không tồn tại"); return end
        if self.pending and self.pending.packKey == packKey then return end
        if self.enabled and self.activePack == packKey and not self.pending then return end
        release(self.pending)
        self.pending = nil
        local character = api.player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            api.onStatus("Chờ nhân vật xuất hiện")
            return
        end
        if humanoid.RigType ~= api.Enum.HumanoidRigType.R15 then
            api.onStatus("adidas cần R15; rig game hiện là R6")
            return
        end
        if api.canAnimate and not api.canAnimate() then
            api.onStatus("adidas cần bộ thân R15; đang hiển thị R6")
            return
        end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then api.onStatus("Chưa có Animator của game"); return end
        self.generation = self.generation + 1
        local token = self.generation
        local bank: any = {packKey=packKey, tracks = {}, resources = {}, connections = {}, currentPose = nil}
        self.pending = bank
        api.onToggle(self.enabled, true, self.activePack, packKey)
        api.onStatus("Đang tải adidas " .. pack.name .. "...")
        local function valid()
            return api.isActive() and not bank.closed
                and (self.bank == bank or self.pending == bank and self.generation == token)
                and api.player.Character == character and humanoid.Parent == character
                and humanoid.Health > 0 and animator.Parent == humanoid
        end
        api.task.spawn(function()
            local ok, problem = pcall(function()
                for _, pose in ipairs(poses) do
                    local clip = resolve(pack.assets[pose])
                    if not valid() then return end
                    local animation = api.Instance.new("Animation")
                    animation.AnimationId = clip
                    local loaded, track = pcall(function() return animator:LoadAnimation(animation) end)
                    if not loaded then destroy(animation); error(track) end
                    if not valid() then destroy(track); destroy(animation); return end
                    bank.resources[#bank.resources + 1] = {track = track, animation = animation}
                    bank.tracks[pose] = track
                    track.Priority = pose == "idle" and api.Enum.AnimationPriority.Idle
                        or api.Enum.AnimationPriority.Movement
                    track.Looped = pose ~= "jump"
                end
                local deadline = api.clock() + 5
                while valid() do
                    local count = 0
                    for _, pose in ipairs(poses) do
                        if bank.tracks[pose].Length > 0 then count = count + 1 end
                    end
                    if count == #poses then return end
                    if api.clock() >= deadline then error("adidas chỉ tải được " .. count .. "/7") end
                    api.task.wait(0.05)
                end
            end)
            if not valid() then release(bank); return end
            if not ok then
                release(bank)
                if self.pending == bank then self.pending = nil end
                api.onToggle(self.enabled, false, self.activePack)
                api.onStatus("Không tải được " .. pack.name .. ": " .. tostring(problem):gsub("^.-:%d+:%s*", ""):sub(1,65))
                return
            end
            local function update()
                if not valid() then self:Disable(); return end
                local pose, speed
                local cloneMotion = api.getCloneMotion and api.getCloneMotion()
                local mode = humanoid:GetState().Name
                if cloneMotion then
                    -- The real Humanoid is intentionally stationary while the
                    -- local copy moves. Drive the selected pack with the copy's
                    -- motion so its visual pose does not remain on idle.
                    if not cloneMotion.grounded then
                        pose = cloneMotion.airState == "jump" and "jump" or "fall"
                    elseif (cloneMotion.speed or 0) > 0.5
                        and (cloneMotion.amount or 0) > 0.025 then
                        local horizontal = cloneMotion.speed
                        pose = horizontal >= 12 and "run" or "walk"
                        speed = math.clamp(horizontal / (pose == "run" and 16 or 8), 0.1, 3)
                    else
                        pose = "idle"
                    end
                elseif mode == "Jumping" then pose = "jump"
                elseif mode == "Freefall" then
                    pose = bank.jumpUntil and api.clock() < bank.jumpUntil and "jump" or "fall"
                elseif mode == "Climbing" then
                    pose = "climb"
                    local root = character:FindFirstChild("HumanoidRootPart")
                    speed = root and root.AssemblyLinearVelocity.Y / 5 or 1
                elseif mode == "Swimming" then
                    pose = "swim"
                    speed = humanoid.MoveDirection.Magnitude > 0.05 and 1 or 0
                elseif mode == "Running" or mode == "RunningNoPhysics"
                    or mode == "Landed" then
                    if humanoid.MoveDirection.Magnitude <= 0.05 then pose = "idle"
                    else
                        local root = character:FindFirstChild("HumanoidRootPart")
                        local v = root and root.AssemblyLinearVelocity
                        local horizontal = v and math.sqrt(v.X*v.X + v.Z*v.Z) or humanoid.WalkSpeed
                        pose = horizontal >= 12 and "run" or "walk"
                        speed = math.clamp(horizontal / (pose == "run" and 16 or 8), 0.1, 3)
                    end
                end
                if pose ~= bank.currentPose then
                    local old = bank.currentPose and bank.tracks[bank.currentPose]
                    if old then old:Stop(0.15) end
                    bank.currentPose = pose
                    if pose then bank.tracks[pose]:Play(0.15, 1, speed or 1) end
                elseif pose and bank.tracks[pose].Looped and not bank.tracks[pose].IsPlaying then
                    bank.tracks[pose]:Play(0.15, 1, speed or 1)
                end
                if pose and speed and (bank.speedTrack ~= bank.tracks[pose]
                    or not bank.lastSpeed or math.abs(speed-bank.lastSpeed) >= .01) then
                    bank.tracks[pose]:AdjustSpeed(speed)
                    bank.speedTrack, bank.lastSpeed = bank.tracks[pose], speed
                end
            end
            local previous = self.bank
            bank.jumpUntil = previous and previous.jumpUntil
            self.pending, self.bank, self.enabled, self.activePack = nil, bank, true, packKey
            bank.connections[#bank.connections + 1] = humanoid.StateChanged:Connect(function(_, nextState)
                if nextState.Name == "Jumping" then
                    bank.jumpUntil = api.clock() + 0.3
                    local old = bank.currentPose and bank.tracks[bank.currentPose]
                    if old then old:Stop(0.05) end
                    bank.currentPose = nil
                    bank.tracks.jump:Play(0.1, 1, 1)
                    bank.currentPose = "jump"
                elseif nextState.Name == "Landed" or nextState.Name == "Running"
                    or nextState.Name == "Swimming" or nextState.Name == "Climbing" then
                    bank.jumpUntil = nil
                end
            end)
            bank.connections[#bank.connections + 1] = api.RunService.Heartbeat:Connect(function()
                local updated, err = pcall(update)
                if not updated then self:Disable(); api.onStatus("adidas lỗi: " .. tostring(err):sub(1, 65)) end
            end)
            update()
            if not valid() then release(previous); return end
            if previous and previous.currentPose == bank.currentPose and bank.currentPose then
                local oldTrack, newTrack = previous.tracks[bank.currentPose], bank.tracks[bank.currentPose]
                local phase = oldTrack.Length > 0 and (oldTrack.TimePosition or 0) / oldTrack.Length or 0
                newTrack.TimePosition = math.clamp(phase * newTrack.Length,0,math.max(0,newTrack.Length-.01))
            end
            release(previous)
            api.onToggle(true, false, packKey)
            api.onStatus("adidas " .. pack.name .. " / 7/7")
        end)
    end
    return extras
end
local function createR6Locomotion(api, model, humanoid, character, isCurrent)
    local driver: any = {closed = false, ready = false, resources = {}, tracks = {}}
    local ids = {idle = 180435571, walk = 180426354, jump = 125750702,
        fall = 180436148, climb = 180436334}
    local controller = api.Instance.new("AnimationController")
    controller.Name = "R6VisualLocomotion"
    controller.Parent = model
    local animator = api.Instance.new("Animator")
    animator.Parent = controller
    local function current()
        return not driver.closed and isCurrent() and humanoid.Parent == character
            and humanoid.Health > 0 and model.Parent ~= nil
    end
    local function stopPose(fade)
        if driver.active then driver.active:Stop(fade == nil and 0.15 or fade) end
        driver.active, driver.pose = nil, nil
    end
    function driver:Destroy()
        if self.closed then return end
        self.closed = true
        if self.jumpConnection then self.jumpConnection:Disconnect() end
        for _, entry in ipairs(self.resources) do
            pcall(function() entry.track:Stop(0); entry.track:Destroy() end)
            entry.animation:Destroy()
        end
        controller:Destroy()
    end
    driver.jumpConnection = humanoid.StateChanged:Connect(function(_, nextState)
        if nextState.Name == "Jumping" then driver.jumpUntil = api.clock() + .3
        elseif nextState.Name == "Landed" then driver.jumpUntil = nil end
    end)
    api.task.spawn(function()
        local ok, problem = pcall(function()
            for pose, id in pairs(ids) do
                if not current() then return end
                local animation = api.Instance.new("Animation")
                animation.AnimationId = "rbxassetid://" .. id
                local loaded, track = pcall(function() return animator:LoadAnimation(animation) end)
                if not loaded then animation:Destroy(); error(track) end
                if not current() then track:Destroy(); animation:Destroy(); return end
                driver.resources[#driver.resources+1] = {track=track, animation=animation}
                driver.tracks[pose] = track
                track.Looped = pose ~= "jump"
                track.Priority = pose == "idle" and api.Enum.AnimationPriority.Idle or api.Enum.AnimationPriority.Movement
            end
            local deadline = api.clock() + 5
            while current() do
                local ready = true
                for _, track in pairs(driver.tracks) do if track.Length <= 0 then ready = false end end
                if ready then driver.ready = true; return end
                if api.clock() >= deadline then error("Chưa tải đủ clip chuyển động R6") end
                api.task.wait(.05)
            end
        end)
        if not ok and current() then
            driver:Destroy()
            if api.onStatus then api.onStatus(tostring(problem):sub(1,90)) end
        end
    end)
    function driver:Step()
        if not current() or not self.ready then return false end
        if api.getCloneMotion and api.getCloneMotion() then stopPose(0); return false end
        if api.isAdidasActive() then stopPose(); return false end
        local state = humanoid:GetState().Name
        local root = character:FindFirstChild("HumanoidRootPart")
        local v = root and root.AssemblyLinearVelocity
        local speed = v and math.sqrt(v.X*v.X + v.Z*v.Z) or 0
        if speed < .1 then speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed end
        local pose, rate = "idle", 1
        if state == "Jumping" or state == "Freefall" and self.jumpUntil and api.clock() < self.jumpUntil then pose = "jump"
        elseif state == "Freefall" then pose = "fall"
        elseif state == "Climbing" then pose = "climb"; rate = v and v.Y / 12 or 1
        elseif state == "Swimming" then pose = speed > .1 and "walk" or "idle"; rate = math.max(.1,speed/14.5)
        elseif state == "Running" or state == "RunningNoPhysics" or state == "Landed" then
            if speed > .5 then pose = "walk"; rate = math.clamp(speed/14.5,.1,3) end
        elseif state ~= "Seated" then stopPose(); return false end
        local track = self.tracks[pose]
        if self.active ~= track then
            stopPose(); self.active, self.pose = track, pose
            track:Play(.15,1,rate)
        elseif track.Looped and not track.IsPlaying then track:Play(.15,1,rate) end
        if self.speedTrack ~= track or not self.lastSpeed or math.abs(rate-self.lastSpeed) >= .01 then
            track:AdjustSpeed(rate)
            self.speedTrack, self.lastSpeed = track, rate
        end
        return true
    end
    return driver
end
-- Use the displayed avatar's own walk/run clips when available. The Animator
-- lives only on a local visual model, never on the physical player character.
local function animationAssetId(value)
    local id = tostring(value or ""):match("%d+")
    return id and tonumber(id) and tonumber(id) > 0 and id or nil
end

local function resolveCloneClips(source, description, rig)
    local defaults = rig == "R6" and {walk = "180426354", run = "180426354",
        jump = "125750702", fall = "180436148"}
        or {walk = "507777826", run = "507767714",
            jump = "507765000", fall = "507767968"}
    local animate = source and source:FindFirstChild("Animate")
    local function fromAnimate(pose)
        local group = animate and animate:FindFirstChild(pose)
        local clip = group and group:FindFirstChildWhichIsA("Animation", true)
        return clip and animationAssetId(clip.AnimationId)
    end
    local walk = fromAnimate("walk")
        or rig == "R15" and animationAssetId(description and description.WalkAnimation)
        or defaults.walk
    local run = fromAnimate("run")
        or rig == "R15" and animationAssetId(description and description.RunAnimation)
        or defaults.run
    local jump = fromAnimate("jump")
        or rig == "R15" and animationAssetId(description and description.JumpAnimation)
        or defaults.jump
    local fall = fromAnimate("fall")
        or rig == "R15" and animationAssetId(description and description.FallAnimation)
        or defaults.fall
    return {walk = walk, run = run, fallbackWalk = defaults.walk,
        fallbackRun = defaults.run, jump = jump, fall = fall,
        fallbackJump = defaults.jump, fallbackFall = defaults.fall, rig = rig}
end

local function createCloneClipDriver(api, model, ids, isCurrent)
    local driver = {closed = false, ready = false, tracks = {}, resources = {}}
    local controller = model:FindFirstChildOfClass("Humanoid")
        or model:FindFirstChildOfClass("AnimationController")
    local ownsController = not controller
    if not controller then
        controller = api.Instance.new("AnimationController")
        controller.Name = "LocalCloneLocomotion"
        controller.Parent = model
    end
    local animator = controller:FindFirstChildOfClass("Animator")
    local ownsAnimator = not animator
    if not animator then
        animator = api.Instance.new("Animator")
        animator.Parent = controller
    end
    local function current()
        return not driver.closed and isCurrent() and model:IsDescendantOf(api.Workspace)
    end
    local function stopPose(fade)
        if driver.active then driver.active:Stop(fade or 0) end
        driver.active, driver.pose = nil, nil
    end
    function driver:Destroy()
        if self.closed then return end
        self.closed = true
        stopPose()
        for _, resource in ipairs(self.resources) do
            pcall(function() resource.track:Stop(0); resource.track:Destroy() end)
            resource.animation:Destroy()
        end
        if ownsController then controller:Destroy()
        elseif ownsAnimator then animator:Destroy() end
    end
    local function loadClip(primary, fallback, pose)
        local candidates = {primary}
        if fallback ~= primary then candidates[#candidates + 1] = fallback end
        for _, id in ipairs(candidates) do
            if not current() then return nil end
            local animation = api.Instance.new("Animation")
            animation.AnimationId = "rbxassetid://" .. id
            local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
            if ok and track then
                local deadline = api.clock() + 3
                while current() and track.Length <= 0 and api.clock() < deadline do
                    api.task.wait(0.05)
                end
                if current() and track.Length > 0 then
                    track.Looped = pose ~= "jump"
                    track.Priority = api.Enum.AnimationPriority.Movement
                    driver.resources[#driver.resources + 1] = {track = track, animation = animation}
                    return track
                end
                pcall(function() track:Destroy() end)
            end
            animation:Destroy()
        end
        return nil
    end
    api.task.spawn(function()
        local walk = loadClip(ids.walk, ids.fallbackWalk, "walk")
        if not current() then return end
        driver.tracks.walk = walk
        if walk then
            driver.tracks.run = ids.run == ids.walk and walk
                or loadClip(ids.run, ids.fallbackRun, "run") or walk
            driver.ready = current()
            if current() then driver.tracks.jump = loadClip(ids.jump, ids.fallbackJump, "jump") end
            if current() then driver.tracks.fall = loadClip(ids.fall, ids.fallbackFall, "fall") end
        end
    end)
    function driver:Step(motion)
        if not current() or not self.ready or not motion then return false end
        local speed = tonumber(motion.speed) or 0
        if motion.grounded and ((motion.amount or 0) < 0.025 or speed < 0.5) then
            stopPose()
            return false
        end
        local pose = not motion.grounded and (motion.airState == "jump" and "jump" or "fall")
            or speed >= 12 and "run" or "walk"
        local track = self.tracks[pose]
        if not track then stopPose(); return false end
        local nominal = ids.rig == "R6" and 14.5
            or self.tracks.run == self.tracks.walk and 16
            or pose == "run" and 16 or 8
        local rate = (pose == "jump" or pose == "fall") and 1
            or math.clamp(speed / nominal, 0.1, 3.5)
        if self.active ~= track then
            stopPose(0.14)
            self.active, self.pose = track, pose
            track:Play(0.14, 1, rate)
        elseif pose ~= "jump" and not track.IsPlaying then
            track:Play(0.14, 1, rate)
        end
        if self.speedTrack ~= track or not self.lastSpeed
            or math.abs(rate - self.lastSpeed) >= 0.02 then
            track:AdjustSpeed(rate)
            self.speedTrack, self.lastSpeed = track, rate
        end
        return track.IsPlaying or pose == "jump" and self.active == track
    end
    return driver
end
-- Animate only the local display body. The physical character keeps its normal
-- position and Humanoid state while the controlled copy supplies a gait clock.
local function cloneDisplayGait(name, motion, CFrame)
    if not motion then
        return CFrame.new()
    end
    if not motion.grounded then
        if name == "LeftUpperLeg" or name == "Left Leg" then
            return CFrame.Angles(-0.27, 0, 0)
        elseif name == "RightUpperLeg" or name == "Right Leg" then
            return CFrame.Angles(0.15, 0, 0)
        elseif name == "LeftUpperArm" or name == "Left Arm" then
            return motion.holdingLimb == "LeftArm" and CFrame.new() or CFrame.Angles(-0.18, 0, 0)
        elseif name == "RightUpperArm" or name == "Right Arm" then
            return motion.holdingLimb == "RightArm" and CFrame.new() or CFrame.Angles(-0.18, 0, 0)
        end
        return CFrame.new()
    end
    if (motion.amount or 0) < 0.025 then return CFrame.new() end
    local amount = math.clamp(motion.amount, 0, 1)
    local stride = math.sin(motion.phase or 0) * amount
    local bend = math.max(0, math.cos(motion.phase or 0)) * amount
    if name == "LeftUpperLeg" or name == "Left Leg" then
        return CFrame.Angles(stride * 0.42, 0, 0)
    elseif name == "RightUpperLeg" or name == "Right Leg" then
        return CFrame.Angles(-stride * 0.42, 0, 0)
    elseif name == "LeftLowerLeg" then
        return CFrame.Angles(bend * 0.28, 0, 0)
    elseif name == "RightLowerLeg" then
        return CFrame.Angles(math.max(0, -math.cos(motion.phase or 0)) * amount * 0.28, 0, 0)
    elseif name == "LeftUpperArm" or name == "Left Arm" then
        if motion.holdingLimb == "LeftArm" then return CFrame.new() end
        return CFrame.Angles(-stride * 0.28, 0, 0)
    elseif name == "RightUpperArm" or name == "Right Arm" then
        if motion.holdingLimb == "RightArm" then return CFrame.new() end
        return CFrame.Angles(stride * 0.28, 0, 0)
    end
    return CFrame.new()
end

local function createV8BodyDisplay(api)
    local display = {}
    local groups = {Head = "Head", Torso = "Torso", UpperTorso = "Torso", LowerTorso = "Torso",
        ["Left Arm"] = "LeftArm", ["Right Arm"] = "RightArm", ["Left Leg"] = "LeftLeg", ["Right Leg"] = "RightLeg",
        LeftUpperArm = "LeftArm", LeftLowerArm = "LeftArm", LeftHand = "LeftArm",
        RightUpperArm = "RightArm", RightLowerArm = "RightArm", RightHand = "RightArm",
        LeftUpperLeg = "LeftLeg", LeftLowerLeg = "LeftLeg", LeftFoot = "LeftLeg",
        RightUpperLeg = "RightLeg", RightLowerLeg = "RightLeg", RightFoot = "RightLeg"}
    local counterparts = {Torso = "LowerTorso", LowerTorso = "Torso", UpperTorso = "Torso",
        ["Left Arm"] = "LeftUpperArm", ["Right Arm"] = "RightUpperArm",
        ["Left Leg"] = "LeftUpperLeg", ["Right Leg"] = "RightUpperLeg",
        LeftUpperArm = "Left Arm", RightUpperArm = "Right Arm",
        LeftUpperLeg = "Left Leg", RightUpperLeg = "Right Leg"}
    local r6PoseParts = {Torso = "UpperTorso", Head = "Head",
        ["Left Arm"] = "LeftUpperArm", ["Right Arm"] = "RightUpperArm",
        ["Left Leg"] = "LeftUpperLeg", ["Right Leg"] = "RightUpperLeg"}
    local r15PoseParts = {LowerTorso = "Torso", Head = "Head",
        LeftUpperArm = "Left Arm", RightUpperArm = "Right Arm",
        LeftUpperLeg = "Left Leg", RightUpperLeg = "Right Leg"}

    function display:CanUse(description)
        for _, key in ipairs({"Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            if (description[key] or 0) <= 0 then return false end
        end
        if (description.Shirt or 0) > 0 or (description.GraphicTShirt or 0) > 0 then return false end
        if (description.Pants or 0) > 0 and (description.Head or 0) == 0 then return false end
        return true
    end

    local function convertR6(model)
        local names = {[api.Enum.BodyPart.Torso] = "Torso", [api.Enum.BodyPart.LeftArm] = "Left Arm",
            [api.Enum.BodyPart.RightArm] = "Right Arm", [api.Enum.BodyPart.LeftLeg] = "Left Leg",
            [api.Enum.BodyPart.RightLeg] = "Right Leg"}
        for _, item in ipairs(model:GetChildren()) do
            if item:IsA("CharacterMesh") then
                local part = model:FindFirstChild(names[item.BodyPart] or "")
                if part and part:IsA("Part") and tonumber(item.MeshId) and tonumber(item.MeshId) > 0 then
                    local mesh = part:FindFirstChildOfClass("SpecialMesh") or api.Instance.new("SpecialMesh")
                    mesh.MeshType = api.Enum.MeshType.FileMesh
                    mesh.MeshId = "rbxassetid://" .. tostring(item.MeshId)
                    local texture = tonumber(item.OverlayTextureId) or 0
                    if texture <= 0 then texture = tonumber(item.BaseTextureId) or 0 end
                    mesh.TextureId = texture > 0 and "rbxassetid://" .. tostring(texture) or ""
                    mesh.Parent = part
                end
                item:Destroy()
            end
        end
    end

    function display:Restore(snapshot)
        local body = snapshot and snapshot.bodyDisplay
        if not body then return end
        snapshot.bodyDisplay = nil
        if body.renderName then api.RunService:UnbindFromRenderStep(body.renderName) end
        for _, connection in ipairs(body.connections) do connection:Disconnect() end
        if body.cloneDriver then body.cloneDriver:Destroy() end
        if body.r6Driver then body.r6Driver:Destroy() end
        body.model:Destroy()
        for _, entry in ipairs(body.saved) do
            pcall(function() entry[1].Transparency = entry[2] end)
        end
    end

    function display:Apply(source, snapshot, description)
        local model = source:Clone()
        local body: any = {model = model, saved = {}, connections = {}}
        snapshot.bodyDisplay = body
        model.Name = "GiftPlayerV8BodyDisplay"
        local renderer = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if not renderer or not root then error("Bộ thân nguồn chưa tải đủ") end
        local rig = renderer.RigType.Name
        local cloneClipIds = resolveCloneClips(source, description, rig)
        local retargetR15 = description.forceFullRig and rig == "R15"
            and snapshot.humanoid.RigType == api.Enum.HumanoidRigType.R6
        convertR6(model)
        for _, part in ipairs(model:GetChildren()) do
            local group = groups[part.Name]
            if group and part:IsA("BasePart") and description[group .. "Color"] then
                part.Color = description[group .. "Color"]
            end
        end
        local head = model:FindFirstChild("Head")
        if head and (description.Head or 0) == 0 and (description.Face or 0) == 0 then
            local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
            if not face then face = api.Instance.new("Decal"); face.Name = "face"; face.Parent = head end
            face.Texture = "rbxasset://textures/face.png"
        end
        local lowest
        for _, part in ipairs(model:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") and part.Transparency < 0.99 then
                local y = root.CFrame:ToObjectSpace(part.CFrame).Y - part.Size.Y / 2
                if not lowest or y < lowest then lowest = y end
            end
        end
        if not lowest then error("Bộ thân không có hình học hiển thị") end
        body.floorDistance = -lowest
        body.rig = rig
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("AnimationConstraint") then
                local a, b = item.Part0, item.Part1
                if a and b and a:IsDescendantOf(model) and b:IsDescendantOf(model) then
                    local motor = api.Instance.new("Motor6D")
                    motor.Name = item.Name
                    motor.Part0, motor.Part1 = a, b
                    motor.C0, motor.C1 = item.C0, item.C1
                    motor.Transform = item.Transform
                    motor.Parent = item.Parent
                end
                item:Destroy()
            end
        end
        -- Classic clothing only renders while a Humanoid is a sibling of
        -- Shirt/Pants. Layered clothing also needs its rig for wrapping.
        -- Keep the renderer passive for those avatars; plain body packages
        -- retain the previous renderer-free path and its established poses.
        local needsClothingRenderer = false
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("Shirt") or item:IsA("Pants")
                or item:IsA("ShirtGraphic") or item:IsA("WrapLayer") then
                needsClothingRenderer = true
                break
            end
        end
        if needsClothingRenderer then
            renderer.EvaluateStateMachine = false
            renderer.AutomaticScalingEnabled = false
            renderer.AutoRotate = false
            renderer.RequiresNeck = false
            renderer.BreakJointsOnDeath = false
            renderer.DisplayDistanceType = api.Enum.HumanoidDisplayDistanceType.None
            renderer.DisplayName = ""
            -- Generated models can carry an Animator that keeps writing the
            -- same joints which sync() positions each frame. Clothing only
            -- needs the Humanoid; clone locomotion creates its own Animator.
            local oldAnimator = renderer:FindFirstChildOfClass("Animator")
            if oldAnimator then oldAnimator:Destroy() end
            body.renderer = renderer
        else
            renderer:Destroy()
        end
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("Tool") or item:IsA("BaseScript") or item:IsA("ModuleScript")
                or item:IsA("BodyMover") or item:IsA("Constraint") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.CanCollide, item.CanTouch, item.CanQuery = false, false, false
                item.Massless = true
                item.Anchored = true
                item.LocalTransparencyModifier = 0
            elseif item:IsA("JointInstance") then
                if (item.Part0 and not item.Part0:IsDescendantOf(model))
                    or (item.Part1 and not item.Part1:IsDescendantOf(model)) then item:Destroy() end
            end
        end
        local identity = api.CFrame.new()
        local rootRest = root.CFrame
        local links, freeParts, remaining = {}, {}, {}
        local known = {[root] = true}
        local realByChild = {}
        for _, joint in ipairs(snapshot.character:GetDescendants()) do
            if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint"))
                and joint.Part1 and joint.Part1.Parent == snapshot.character then
                realByChild[joint.Part1.Name] = joint
            end
        end
        for _, joint in ipairs(model:GetDescendants()) do
            if joint:IsA("JointInstance") and joint.Part0 and joint.Part1 then
                remaining[#remaining+1] = joint
            end
        end
        while #remaining > 0 do
            local progress = false
            for index = #remaining, 1, -1 do
                local joint = remaining[index]
                local a, b = joint.Part0, joint.Part1
                if known[a] or known[b] then
                    if not (known[a] and known[b]) then
                        local forward = known[a] == true
                        local child = forward and b or a
                        local posePart = rig == "R6" and snapshot.humanoid.RigType == api.Enum.HumanoidRigType.R15
                            and snapshot.character:FindFirstChild(r6PoseParts[child.Name] or "")
                        if retargetR15 and r15PoseParts[child.Name] then
                            posePart = snapshot.character:FindFirstChild(r15PoseParts[child.Name])
                        end
                        links[#links+1] = {joint = joint, a = a, b = b, forward = forward,
                            c0 = joint.C0, c1 = joint.C1, i0 = joint.C0:Inverse(), i1 = joint.C1:Inverse(),
                            r0 = joint.C0.Rotation:Inverse(), r1 = joint.C1.Rotation,
                            posePart = posePart, childName = child.Name,
                            real = realByChild[child.Name] or realByChild[counterparts[child.Name] or ""]}
                        known[child] = true
                    end
                    table.remove(remaining, index)
                    progress = true
                end
            end
            if not progress then break end
        end
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and not known[part] then
                freeParts[#freeParts+1] = {part, rootRest:ToObjectSpace(part.CFrame)}
            end
        end
        local function sync(restPose)
            local realRoot = snapshot.character:FindFirstChild("HumanoidRootPart")
            local humanoid = snapshot.humanoid
            if not realRoot or humanoid.Parent ~= snapshot.character then return end
            -- Track changes to the game's real rig height. A cached value can
            -- leave the visual feet floating when HipHeight changes.
            local driverDistance = humanoid.HipHeight + realRoot.Size.Y / 2
            if humanoid.RigType == api.Enum.HumanoidRigType.R6 then
                local leg = snapshot.character:FindFirstChild("Left Leg")
                driverDistance = driverDistance + (leg and leg.Size.Y or 2)
            end
            root.CFrame = realRoot.CFrame * api.CFrame.new(0, body.floorDistance - driverDistance, 0)
            local cloneMotion = not restPose and api.getCloneMotion and api.getCloneMotion()
            -- The selected pack animates the physical R15 rig even when the
            -- displayed avatar is R6. Retarget those live joint rotations to
            -- the display instead of replacing them with default R6 clips.
            local packMotion = cloneMotion
                and humanoid.RigType == api.Enum.HumanoidRigType.R15
                and api.isPackActive and api.isPackActive()
            if cloneMotion and not packMotion and not body.cloneDriver
                and model:IsDescendantOf(api.Workspace) then
                body.cloneDriver = createCloneClipDriver({Instance=api.Instance, Enum=api.Enum,
                    Workspace=api.Workspace, task=task, clock=os.clock}, model, cloneClipIds,
                    function() return snapshot.bodyDisplay == body end)
            elseif (not cloneMotion or packMotion) and body.cloneDriver then
                body.cloneDriver:Destroy()
                body.cloneDriver = nil
            end
            local nativeR6 = not restPose and body.r6Driver and body.r6Driver:Step()
            local nativeClone = body.cloneDriver and body.cloneDriver:Step(cloneMotion)
            for _, entry in ipairs(links) do
                local transform = not restPose and not retargetR15 and entry.real
                    and entry.real.Transform.Rotation or identity
                if nativeClone and entry.joint:IsA("Motor6D") then
                    -- Preserve the authored limb pose. Only suppress root
                    -- translation, which can lift a tiny 3D skin off the floor.
                    local clipTransform = entry.joint.Transform
                    transform = (entry.childName == "Torso" or entry.childName == "LowerTorso"
                        or entry.childName == "UpperTorso") and clipTransform.Rotation
                        or clipTransform
                elseif nativeR6 and entry.joint:IsA("Motor6D") then
                    transform = entry.joint.Transform
                elseif not restPose and entry.posePart and entry.posePart.Parent == snapshot.character
                    and entry.joint:IsA("Motor6D") then
                    local desired = entry.posePart.CFrame.Rotation
                    local rotation0 = entry.forward and entry.a.CFrame.Rotation or desired
                    local rotation1 = entry.forward and desired or entry.b.CFrame.Rotation
                    transform = entry.r0 * rotation0:Inverse() * rotation1 * entry.r1
                end
                if entry.joint:IsA("Motor6D") then
                    if cloneMotion and not nativeClone and not packMotion then
                        transform = transform * cloneDisplayGait(entry.childName, cloneMotion, api.CFrame)
                    end
                    if not nativeR6 and not nativeClone or cloneMotion and not nativeClone then
                        entry.joint.Transform = transform
                    end
                else transform = identity end
                if entry.forward then
                    entry.b.CFrame = entry.a.CFrame * entry.c0 * transform * entry.i1
                else
                    entry.a.CFrame = entry.b.CFrame * entry.c1 * transform:Inverse() * entry.i0
                end
            end
            for _, entry in ipairs(freeParts) do
                entry[1].CFrame = root.CFrame * entry[2]
            end
        end
        sync(true)
        local lowestFoot, lowestBody
        for _, part in ipairs(model:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") and part.Transparency < 0.99 then
                local cf = root.CFrame:ToObjectSpace(part.CFrame)
                local extent = (math.abs(cf.RightVector.Y) * part.Size.X
                    + math.abs(cf.UpVector.Y) * part.Size.Y + math.abs(cf.LookVector.Y) * part.Size.Z) / 2
                local bottom = cf.Y - extent
                lowestBody = lowestBody and math.min(lowestBody, bottom) or bottom
                if part.Name == "LeftFoot" or part.Name == "RightFoot"
                    or part.Name == "Left Leg" or part.Name == "Right Leg" then
                    lowestFoot = lowestFoot and math.min(lowestFoot, bottom) or bottom
                end
            end
        end
        body.floorDistance = -(lowestFoot or lowestBody)
        model:SetAttribute("VisualFloorDistance", body.floorDistance)
        sync()
        local camera = api.Workspace.CurrentCamera
        if not camera then error("Camera chưa sẵn sàng") end
        for _, part in ipairs(snapshot.character:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") then
                body.saved[#body.saved+1] = {part, part.Transparency}
                part.Transparency = 1
            end
        end
        model.Parent = camera
        if rig == "R6" and api.createR6Driver then
            body.r6Driver = api.createR6Driver(model, snapshot.humanoid, snapshot.character, function()
                return snapshot.bodyDisplay == body
            end)
        end
        body.renderName = "GiftPlayerV8VisualBody"
        api.RunService:BindToRenderStep(body.renderName,
            api.Enum.RenderPriority.Character.Value + 2, function()
            local ok, problem = pcall(function()
                local currentCamera = api.Workspace.CurrentCamera
                if currentCamera and model.Parent ~= currentCamera then model.Parent = currentCamera end
                sync()
            end)
            if not ok then
                self:Restore(snapshot)
                api.onFailure(snapshot, problem)
            end
        end)
        return rig
    end
    return display
end
local function createRoomR6Locomotion(api, model, humanoid, character, isCurrent)
    local driver: any = {closed = false, ready = false, resources = {}, tracks = {}}
    local ids = {idle = 180435571, walk = 180426354, jump = 125750702,
        fall = 180436148, climb = 180436334}
    local controller = model:FindFirstChildOfClass("Humanoid")
    local ownsController = not controller
    if not controller then
        controller = api.Instance.new("AnimationController")
        controller.Name = "R6VisualLocomotion"
        controller.Parent = model
    end
    local animator = controller:FindFirstChildOfClass("Animator") or api.Instance.new("Animator")
    animator.Parent = controller
    local function current()
        return not driver.closed and isCurrent() and humanoid.Parent == character
            and humanoid.Health > 0 and model.Parent ~= nil
    end
    local function stopPose(fade)
        if driver.active then driver.active:Stop(fade == nil and 0.15 or fade) end
        driver.active, driver.pose = nil, nil
    end
    function driver:Destroy()
        if self.closed then return end
        self.closed = true
        if self.jumpConnection then self.jumpConnection:Disconnect() end
        for _, entry in ipairs(self.resources) do
            pcall(function() entry.track:Stop(0); entry.track:Destroy() end)
            entry.animation:Destroy()
        end
        if ownsController then controller:Destroy() end
    end
    driver.jumpConnection = humanoid.StateChanged:Connect(function(_, nextState)
        if nextState.Name == "Jumping" then driver.jumpUntil = api.clock() + .3
        elseif nextState.Name == "Landed" then driver.jumpUntil = nil end
    end)
    api.task.spawn(function()
        local ok, problem = pcall(function()
            for pose, id in pairs(ids) do
                if not current() then return end
                local animation = api.Instance.new("Animation")
                animation.AnimationId = "rbxassetid://" .. id
                local loaded, track = pcall(function() return animator:LoadAnimation(animation) end)
                if not loaded then animation:Destroy(); error(track) end
                if not current() then track:Destroy(); animation:Destroy(); return end
                driver.resources[#driver.resources+1] = {track=track, animation=animation}
                driver.tracks[pose] = track
                track.Looped = pose ~= "jump"
                track.Priority = pose == "idle" and api.Enum.AnimationPriority.Idle or api.Enum.AnimationPriority.Movement
            end
            local deadline = api.clock() + 5
            while current() do
                local ready = true
                for _, track in pairs(driver.tracks) do if track.Length <= 0 then ready = false end end
                if ready then driver.ready = true; return end
                if api.clock() >= deadline then error("Chưa tải đủ clip chuyển động R6") end
                api.task.wait(.05)
            end
        end)
        if not ok and current() then
            driver:Destroy()
            if api.onStatus then api.onStatus(tostring(problem):sub(1,90)) end
        end
    end)
    function driver:Step()
        if not current() or not self.ready then return false end
        if api.getCloneMotion and api.getCloneMotion() then stopPose(0); return false end
        if api.isAdidasActive() then stopPose(); return false end
        local state = humanoid:GetState().Name
        local root = character:FindFirstChild("HumanoidRootPart")
        local v = root and root.AssemblyLinearVelocity
        local speed = v and math.sqrt(v.X*v.X + v.Z*v.Z) or 0
        if speed < .1 then speed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed end
        local pose, rate = "idle", 1
        if state == "Jumping" or state == "Freefall" and self.jumpUntil and api.clock() < self.jumpUntil then pose = "jump"
        elseif state == "Freefall" then pose = "fall"
        elseif state == "Climbing" then pose = "climb"; rate = v and v.Y / 12 or 1
        elseif state == "Swimming" then pose = speed > .1 and "walk" or "idle"; rate = math.max(.1,speed/14.5)
        elseif state == "Running" or state == "RunningNoPhysics" or state == "Landed" then
            if speed > .5 then pose = "walk"; rate = math.clamp(speed/14.5,.1,3) end
        elseif state ~= "Seated" then stopPose(); return false end
        local track = self.tracks[pose]
        if self.active ~= track then
            stopPose(); self.active, self.pose = track, pose
            track:Play(.15,1,rate)
        elseif track.Looped and not track.IsPlaying then track:Play(.15,1,rate) end
        if self.speedTrack ~= track or not self.lastSpeed or math.abs(rate-self.lastSpeed) >= .01 then
            track:AdjustSpeed(rate)
            self.speedTrack, self.lastSpeed = track, rate
        end
        return true
    end
    return driver
end
local function createRoomBodyDisplay(api)
    local display = {}
    local groups = {Head = "Head", Torso = "Torso", UpperTorso = "Torso", LowerTorso = "Torso",
        ["Left Arm"] = "LeftArm", ["Right Arm"] = "RightArm", ["Left Leg"] = "LeftLeg", ["Right Leg"] = "RightLeg",
        LeftUpperArm = "LeftArm", LeftLowerArm = "LeftArm", LeftHand = "LeftArm",
        RightUpperArm = "RightArm", RightLowerArm = "RightArm", RightHand = "RightArm",
        LeftUpperLeg = "LeftLeg", LeftLowerLeg = "LeftLeg", LeftFoot = "LeftLeg",
        RightUpperLeg = "RightLeg", RightLowerLeg = "RightLeg", RightFoot = "RightLeg"}
    local counterparts = {Torso = "LowerTorso", LowerTorso = "Torso", UpperTorso = "Torso",
        ["Left Arm"] = "LeftUpperArm", ["Right Arm"] = "RightUpperArm",
        ["Left Leg"] = "LeftUpperLeg", ["Right Leg"] = "RightUpperLeg",
        LeftUpperArm = "Left Arm", RightUpperArm = "Right Arm",
        LeftUpperLeg = "Left Leg", RightUpperLeg = "Right Leg"}
    local r6PoseParts = {Torso = "UpperTorso", Head = "Head",
        ["Left Arm"] = "LeftUpperArm", ["Right Arm"] = "RightUpperArm",
        ["Left Leg"] = "LeftUpperLeg", ["Right Leg"] = "RightUpperLeg"}

    function display:Restore(snapshot)
        local body = snapshot and snapshot.bodyDisplay
        if not body then return end
        snapshot.bodyDisplay = nil
        for _, connection in ipairs(body.connections) do connection:Disconnect() end
        if body.cloneDriver then body.cloneDriver:Destroy() end
        if body.r6Driver then body.r6Driver:Destroy() end
        body.model:Destroy()
        for _, entry in ipairs(body.saved) do
            pcall(function() entry[1].Transparency = entry[2] end)
        end
    end

    function display:Apply(source, snapshot, description)
        local model = source:Clone()
        local body: any = {model = model, saved = {}, connections = {}}
        snapshot.bodyDisplay = body
        model.Name = "GiftPlayerV8BodyDisplay"
        local renderer = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if not renderer or not root then error("Bộ thân nguồn chưa tải đủ") end
        local rig = renderer.RigType.Name
        local cloneClipIds = resolveCloneClips(source, description, rig)
        renderer.EvaluateStateMachine = false
        renderer.AutomaticScalingEnabled = false
        renderer.AutoRotate = false
        renderer.RequiresNeck = false
        renderer.BreakJointsOnDeath = false
        renderer.DisplayDistanceType = api.Enum.HumanoidDisplayDistanceType.None
        renderer.DisplayName = ""
        body.renderer = renderer
        for _, part in ipairs(model:GetChildren()) do
            local group = groups[part.Name]
            if not description.fromLive and group and part:IsA("BasePart") and description[group .. "Color"] then
                part.Color = description[group .. "Color"]
            end
        end
        local head = model:FindFirstChild("Head")
        if not description.fromLive and head and (description.Head or 0) == 0 and (description.Face or 0) == 0 then
            local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
            if not face then face = api.Instance.new("Decal"); face.Name = "face"; face.Parent = head end
            face.Texture = "rbxasset://textures/face.png"
        end
        local lowest
        for _, part in ipairs(model:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") and part.Transparency < 0.99 then
                local y = root.CFrame:ToObjectSpace(part.CFrame).Y - part.Size.Y / 2
                if not lowest or y < lowest then lowest = y end
            end
        end
        if not lowest then error("Bộ thân không có hình học hiển thị") end
        body.floorDistance = -lowest
        body.rig = rig
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("AnimationConstraint") then
                local a, b = item.Part0, item.Part1
                if a and b and a:IsDescendantOf(model) and b:IsDescendantOf(model) then
                    local motor = api.Instance.new("Motor6D")
                    motor.Name = item.Name
                    motor.Part0, motor.Part1 = a, b
                    motor.C0, motor.C1 = item.C0, item.C1
                    motor.Transform = item.Transform
                    motor.Parent = item.Parent
                end
                item:Destroy()
            end
        end
        for _, item in ipairs(model:GetDescendants()) do
            if item:IsA("Tool") or item:IsA("BaseScript") or item:IsA("ModuleScript") or item:IsA("BillboardGui")
                or item:IsA("BodyMover") or item:IsA("Constraint") then
                item:Destroy()
            elseif item:IsA("BasePart") then
                item.CanCollide, item.CanTouch, item.CanQuery = false, false, false
                item.Massless = true
                item.Anchored = true
                item.LocalTransparencyModifier = 0
            elseif item:IsA("JointInstance") then
                if (item.Part0 and not item.Part0:IsDescendantOf(model))
                    or (item.Part1 and not item.Part1:IsDescendantOf(model)) then item:Destroy() end
            end
        end
        local identity = api.CFrame.new()
        local rootRest = root.CFrame
        root.Transparency = 1
        local links, freeParts, remaining = {}, {}, {}
        local known = {[root] = true}
        local realByChild = {}
        for _, joint in ipairs(snapshot.character:GetDescendants()) do
            if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint"))
                and joint.Part1 and joint.Part1.Parent == snapshot.character then
                realByChild[joint.Part1.Name] = joint
            end
        end
        for _, joint in ipairs(model:GetDescendants()) do
            if joint:IsA("JointInstance") and joint.Part0 and joint.Part1 then
                remaining[#remaining+1] = joint
            end
        end
        while #remaining > 0 do
            local progress = false
            for index = #remaining, 1, -1 do
                local joint = remaining[index]
                local a, b = joint.Part0, joint.Part1
                if known[a] or known[b] then
                    if not (known[a] and known[b]) then
                        local forward = known[a] == true
                        local child = forward and b or a
                        local posePart = rig == "R6" and snapshot.humanoid.RigType == api.Enum.HumanoidRigType.R15
                            and snapshot.character:FindFirstChild(r6PoseParts[child.Name] or "")
                        links[#links+1] = {joint = joint, a = a, b = b, forward = forward,
                            c0 = joint.C0, c1 = joint.C1, i0 = joint.C0:Inverse(), i1 = joint.C1:Inverse(),
                            r0 = joint.C0.Rotation:Inverse(), r1 = joint.C1.Rotation,
                            posePart = posePart, childName = child.Name,
                            real = realByChild[child.Name] or realByChild[counterparts[child.Name] or ""]}
                        known[child] = true
                    end
                    table.remove(remaining, index)
                    progress = true
                end
            end
            if not progress then break end
        end
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and not known[part] then
                freeParts[#freeParts+1] = {part, rootRest:ToObjectSpace(part.CFrame)}
            end
        end
        local function sync(restPose)
            local realRoot = snapshot.character:FindFirstChild("HumanoidRootPart")
            local humanoid = snapshot.humanoid
            if not realRoot or humanoid.Parent ~= snapshot.character then return end
            local driverDistance = humanoid.HipHeight + realRoot.Size.Y / 2
            if humanoid.RigType == api.Enum.HumanoidRigType.R6 then
                local leg = snapshot.character:FindFirstChild("Left Leg")
                driverDistance = driverDistance + (leg and leg.Size.Y or 2)
            end
            root.CFrame = realRoot.CFrame * api.CFrame.new(0, body.floorDistance - driverDistance, 0)
            local cloneMotion = not restPose and api.getCloneMotion and api.getCloneMotion()
            -- R6 display bodies also inherit the active pack's live R15 pose.
            local packMotion = cloneMotion
                and humanoid.RigType == api.Enum.HumanoidRigType.R15
                and api.isPackActive and api.isPackActive()
            if cloneMotion and not packMotion and not body.cloneDriver
                and model:IsDescendantOf(api.Workspace) then
                body.cloneDriver = createCloneClipDriver({Instance=api.Instance, Enum=api.Enum,
                    Workspace=api.Workspace, task=task, clock=os.clock}, model, cloneClipIds,
                    function() return snapshot.bodyDisplay == body end)
            elseif (not cloneMotion or packMotion) and body.cloneDriver then
                body.cloneDriver:Destroy()
                body.cloneDriver = nil
            end
            local nativeR6 = not restPose and body.r6Driver and body.r6Driver:Step()
            local nativeClone = body.cloneDriver and body.cloneDriver:Step(cloneMotion)
            for _, entry in ipairs(links) do
                local transform = not restPose and entry.real and entry.real.Transform.Rotation or identity
                if nativeClone and entry.joint:IsA("Motor6D") then
                    local clipTransform = entry.joint.Transform
                    transform = (entry.childName == "Torso" or entry.childName == "LowerTorso"
                        or entry.childName == "UpperTorso") and clipTransform.Rotation
                        or clipTransform
                elseif nativeR6 and entry.joint:IsA("Motor6D") then
                    transform = entry.joint.Transform
                elseif not restPose and entry.posePart and entry.posePart.Parent == snapshot.character
                    and entry.joint:IsA("Motor6D") then
                    local desired = entry.posePart.CFrame.Rotation
                    local rotation0 = entry.forward and entry.a.CFrame.Rotation or desired
                    local rotation1 = entry.forward and desired or entry.b.CFrame.Rotation
                    transform = entry.r0 * rotation0:Inverse() * rotation1 * entry.r1
                end
                if entry.joint:IsA("Motor6D") then
                    if cloneMotion and not nativeClone and not packMotion then
                        transform = transform * cloneDisplayGait(entry.childName, cloneMotion, api.CFrame)
                    end
                    if not nativeR6 and not nativeClone or cloneMotion and not nativeClone then
                        entry.joint.Transform = transform
                    end
                else transform = identity end
                if entry.forward then
                    entry.b.CFrame = entry.a.CFrame * entry.c0 * transform * entry.i1
                else
                    entry.a.CFrame = entry.b.CFrame * entry.c1 * transform:Inverse() * entry.i0
                end
            end
            for _, entry in ipairs(freeParts) do
                entry[1].CFrame = root.CFrame * entry[2]
            end
        end
        sync(true)
        local lowestFoot, lowestBody
        for _, part in ipairs(model:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") and part.Transparency < 0.99 then
                local cf = root.CFrame:ToObjectSpace(part.CFrame)
                local extent = (math.abs(cf.RightVector.Y) * part.Size.X
                    + math.abs(cf.UpVector.Y) * part.Size.Y + math.abs(cf.LookVector.Y) * part.Size.Z) / 2
                local bottom = cf.Y - extent
                lowestBody = lowestBody and math.min(lowestBody, bottom) or bottom
                if part.Name == "LeftFoot" or part.Name == "RightFoot"
                    or part.Name == "Left Leg" or part.Name == "Right Leg" then
                    lowestFoot = lowestFoot and math.min(lowestFoot, bottom) or bottom
                end
            end
        end
        body.floorDistance = -(lowestFoot or lowestBody)
        model:SetAttribute("VisualFloorDistance", body.floorDistance)
        sync()
        local camera = api.Workspace.CurrentCamera
        if not camera then error("Camera chưa sẵn sàng") end
        for _, part in ipairs(snapshot.character:GetChildren()) do
            if groups[part.Name] and part:IsA("BasePart") then
                body.saved[#body.saved+1] = {part, part.Transparency}
                part.Transparency = 1
            end
        end
        model.Parent = camera
        if rig == "R6" and api.createR6Driver then
            body.r6Driver = api.createR6Driver(model, snapshot.humanoid, snapshot.character, function()
                return snapshot.bodyDisplay == body
            end)
        end
        body.connections[#body.connections+1] = api.RunService.RenderStepped:Connect(function()
            local ok, problem = pcall(function()
                local currentCamera = api.Workspace.CurrentCamera
                if currentCamera and model.Parent ~= currentCamera then model.Parent = currentCamera end
                sync()
            end)
            if not ok then
                self:Restore(snapshot)
                api.onFailure(snapshot, problem)
            end
        end)
        return rig
    end
    return display
end
local function createMoonbloomNative(api)
    local effect: any={enabled=false,objects={},cloneObjects={},generation=0,alive=true}
    local clock=api.clock or os.clock
    local fxClasses={Trail=true,Beam=true,ParticleEmitter=true,PointLight=true,SpotLight=true,SurfaceLight=true,
        Fire=true,Smoke=true,Sparkles=true}
    local function own(item) effect.objects[#effect.objects+1]=item; return item end
    local function clear()
        for _,item in ipairs(effect.objects) do item:Destroy() end
        effect.objects={}
    end
    local function clearClone()
        if effect.cloneRender then effect.cloneRender:Disconnect(); effect.cloneRender=nil end
        for _,item in ipairs(effect.cloneObjects) do item:Destroy() end
        effect.cloneObjects={}
        effect.cloneAttachedRoot=nil
    end
    local function ownClone(item)
        effect.cloneObjects[#effect.cloneObjects+1]=item
        return item
    end
    function effect:Disable()
        self.generation+=1; self.pending=nil
        if self.render then self.render:Disconnect(); self.render=nil end
        clearClone()
        clear(); self.enabled=false
        if api.onToggle then api.onToggle(false) end
    end
    local function isMoon(item)
        if item.Name:lower():gsub("[^%w]",""):find("moonbloom",1,true) then return true end
        local ok,attrs=pcall(function() return item:GetAttributes() end)
        if ok then for key,value in pairs(attrs) do
            if type(value)=="string" and key:lower():find("name",1,true)
                and value:lower():gsub("[^%w]",""):find("moonbloom",1,true) then return true end
        end end
        return false
    end
    local function contents(template)
        local result,stack={}, {template}
        local hasTrail=false
        while #stack>0 do
            local item=table.remove(stack); result[#result+1]=item
            if #result>2048 or item:IsA("Humanoid") then return nil end
            if item:IsA("Trail") or item:IsA("Beam") or item:IsA("ParticleEmitter") then hasTrail=true end
            for _,child in ipairs(item:GetChildren()) do stack[#stack+1]=child end
        end
        return hasTrail and result or nil
    end
    local function findTemplate(token)
        if effect.template and effect.template.Parent and contents(effect.template) then return effect.template end
        local stack={}
        if api.playerGui then stack[#stack+1]=api.playerGui end
        stack[#stack+1]=api.ReplicatedStorage
        if api.Players then
            local ok,players=pcall(function() return api.Players:GetPlayers() end)
            if ok then for _,player in ipairs(players) do
                if player~=api.player and player.Character then stack[#stack+1]=player.Character end
            end end
        end
        local count,start=0,clock()
        while #stack>0 and count<14000 and clock()-start<2.5 do
            if not effect.alive or effect.generation~=token then return nil end
            local item=table.remove(stack); count+=1
            if isMoon(item) and contents(item) then effect.template=item; return item end
            for _,child in ipairs(item:GetChildren()) do stack[#stack+1]=child end
            if count%120==0 then api.task.wait() end
        end
        return nil
    end
    local function copyTemplate(template,root,track,bindRender)
        local own=track
        local all=contents(template)
        if not all then error("Mẫu Moonbloom không có hiệu ứng gốc") end
        local reference=template:IsA("BasePart") and template or template:IsA("Model") and template.PrimaryPart
        if not reference then
            for _,item in ipairs(all) do
                if item:IsA("BasePart") then reference=item; break end
                if (item:IsA("Trail") or item:IsA("Beam")) and item.Attachment0 then
                    local parent=item.Attachment0.Parent
                    if parent and parent:IsA("BasePart") then reference=parent; break end
                end
            end
        end
        if not reference then
            local parent=template.Parent
            while parent and parent~=api.ReplicatedStorage do
                if parent:IsA("BasePart") then reference=parent; break end
                parent=parent.Parent
            end
        end
        local origin=reference and reference.CFrame
        local nativeParts,partMap={},{}
        local model
        for _,source in ipairs(all) do
            if source:IsA("BasePart") then
                if #nativeParts>=128 then error("Mẫu Moonbloom quá lớn") end
                if not model then model=own(api.Instance.new("Model")); model.Name="NativeMoonbloomModel" end
                local part=source:Clone(); part.Parent=model
                for _,child in ipairs(part:GetDescendants()) do
                    if not (child:IsA("DataModelMesh") or child:IsA("SurfaceAppearance")
                        or child:IsA("Decal") or child:IsA("Texture") or child:IsA("Bone")) then child:Destroy() end
                end
                part.Anchored=true; part.Massless=true; part.LocalTransparencyModifier=0
                part.CanCollide,part.CanTouch,part.CanQuery=false,false,false
                partMap[source]=part
                nativeParts[#nativeParts+1]={part=part,offset=origin and origin:ToObjectSpace(source.CFrame) or source.CFrame}
            end
        end
        if model then
            local function sync()
                if not root.Parent then return end
                local camera=api.Workspace.CurrentCamera
                if camera and model.Parent~=camera then model.Parent=camera end
                for _,entry in ipairs(nativeParts) do entry.part.CFrame=root.CFrame*entry.offset end
            end
            sync()
            bindRender(api.RunService.RenderStepped:Connect(sync))
        end
        local mapped,copied={},0
        local function attachment(source)
            if not source then return nil end
            if mapped[source] then return mapped[source] end
            local item=own(api.Instance.new("Attachment")); item.Name="NativeMoonbloomAttachment"
            item.CFrame=origin and origin:ToObjectSpace(source.WorldCFrame) or source.CFrame
            item.Parent=root; mapped[source]=item
            return item
        end
        local center
        for _,source in ipairs(all) do
            if fxClasses[source.ClassName] then
                local item=own(source:Clone())
                for _,child in ipairs(item:GetChildren()) do child:Destroy() end
                item.Name="NativeMoonbloom"..source.ClassName
                if source:IsA("Trail") or source:IsA("Beam") then
                    local a,b=attachment(source.Attachment0),attachment(source.Attachment1)
                    if not a or not b then error("Moonbloom gốc thiếu attachment") end
                    item.Attachment0,item.Attachment1=a,b; item.Parent=root
                elseif source.Parent and (source.Parent:IsA("Attachment") or source.Parent:IsA("Bone")) then
                    item.Parent=attachment(source.Parent)
                elseif source.Parent and partMap[source.Parent] then
                    item.Parent=partMap[source.Parent]
                else
                    if not center then center=own(api.Instance.new("Attachment")); center.Name="NativeMoonbloomCenter"; center.Parent=root end
                    item.Parent=center
                end
                item.Enabled=true
                copied+=1
            end
        end
        return copied>0
    end
    function effect:SetCloneRoot(root)
        if self.cloneAttachedRoot==root and root and root.Parent then return end
        self.cloneRoot=root
        clearClone()
        if not root or not root.Parent or not self.enabled or not self.template or not self.template.Parent then return end
        local ok,result=pcall(function()
            return copyTemplate(self.template,root,ownClone,function(connection)
                self.cloneRender=connection
            end)
        end)
        if ok and result then
            self.cloneAttachedRoot=root
        else
            clearClone()
            warn("[Moonbloom clone] "..tostring(result))
        end
    end
    function effect:Enable()
        self:Disable()
        local character=api.player.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local h=character and character:FindFirstChildOfClass("Humanoid")
        if not root or not h or h.Health<=0 then api.onStatus("Chờ nhân vật rồi bật Moonbloom"); return end
        local token=self.generation; self.pending=token
        api.onStatus("Đang tìm Moonbloom gốc trong game...")
        api.task.delay(4,function()
            if self.alive and self.pending==token and self.generation==token then
                self:Disable(); api.onStatus("Moonbloom: chưa tìm thấy mẫu gốc")
            end
        end)
        api.task.spawn(function()
            local ok,template=pcall(function() return findTemplate(token) end)
            if not self.alive or self.generation~=token then return end
            self.pending=nil
            if not ok or not template then
                api.onStatus("Chưa có Moonbloom gốc / bấm Quét mẫu game"); return
            end
            if api.player.Character~=character or h.Health<=0 then self:Disable(); return end
            local copied,result=pcall(function()
                return copyTemplate(template,root,own,function(connection)
                    self.render=connection
                end)
            end)
            if not copied or not result then
                self:Disable(); api.onStatus("Moonbloom gốc lỗi: "..tostring(result):sub(1,55)); return
            end
            self.enabled=true
            if self.cloneRoot then self:SetCloneRoot(self.cloneRoot) end
            if api.onToggle then api.onToggle(true) end
            api.onStatus("Moonbloom / hiệu ứng gốc trong game")
        end)
    end
    function effect:Destroy()
        if not self.alive then return end
        self.alive=false; self:Disable()
        self.cloneRoot=nil
        if self.respawn then self.respawn:Disconnect() end
    end
    effect.respawn=api.player.CharacterAdded:Connect(function() effect:Disable() end)
    return effect
end
local function renderWeaponThumbnail(api,prepared,parent,options)
    local hotbar=options and options.hotbar
    local outlined=hotbar and prepared.fallbackOutline
    local root
    local created={}
    if outlined then
        root=api.Instance.new("Frame")
        root.Name="OutlinedWeaponIcon"
        root.BackgroundTransparency=1
        root.BorderSizePixel=0
        root.ClipsDescendants=true
        root.Size=api.UDim2.fromScale(1,1)
        root.ZIndex=parent.ZIndex+1
        root.Parent=parent
    end
    local function draw(offsetX,offsetY,silhouette)
        local view=api.Instance.new("ViewportFrame")
        created[#created+1]=view
        view.Name=silhouette and "WeaponOutline" or "NativeWeaponThumbnail"
        view.BackgroundTransparency=1
        view.BorderSizePixel=0
        view.Size=api.UDim2.fromScale(1,1)
        if silhouette then view.Position=api.UDim2.fromOffset(offsetX,offsetY) end
        view.ZIndex=(root or parent).ZIndex+(silhouette and 1 or 2)
        view.Ambient=api.Color3.fromRGB(silhouette and 0 or 210,silhouette and 0 or 210,silhouette and 0 or 210)
        view.LightColor=api.Color3.fromRGB(silhouette and 0 or 255,silhouette and 0 or 255,silhouette and 0 or 255)
        local model=prepared.model:Clone()
        model.Name="ThumbnailWeapon"
        for _,item in ipairs(model:GetDescendants()) do
            if item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam")
                or item:IsA("Light") or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles") then
                item:Destroy()
            elseif silhouette then
                if item:IsA("SurfaceAppearance") or item:IsA("Decal") or item:IsA("Texture") then
                    item:Destroy()
                elseif item:IsA("BasePart") then
                    item.Color=api.Color3.fromRGB(0,0,0)
                    pcall(function() item.TextureID="" end)
                elseif item:IsA("SpecialMesh") then
                    item.TextureId=""
                end
            end
        end
        model.Parent=view
        local box,size=model:GetBoundingBox()
        local camera=api.Instance.new("Camera")
        camera.FieldOfView=32
        local radius=math.max(size.X,size.Y,size.Z,.1)/2
        local roll=hotbar and prepared.hotbarRoll or 0
        local padding=hotbar and 1.1 or 1.35
        local distance=radius/math.tan(math.rad(camera.FieldOfView/2))*padding
        local target=box.Position
        local normalization=hotbar and math.sqrt(.55*.55+.13*.13+1) or 1
        camera.CFrame=api.CFrame.lookAt(target+api.Vector3.new(distance*.55/normalization,distance*.13/normalization,distance/normalization),target)
        if roll~=0 and api.CFrame.Angles then camera.CFrame=camera.CFrame*api.CFrame.Angles(0,0,math.rad(roll)) end
        camera.Parent=view
        view.CurrentCamera=camera
        view.Parent=root or parent
        return view
    end
    local ok,result=pcall(function()
        if outlined then
            for x=-1,1 do for y=-1,1 do
                if x~=0 or y~=0 then draw(x,y,true) end
            end end
        end
        return draw(0,0,false)
    end)
    if not ok then
        if root then root:Destroy() end
        for _,view in ipairs(created) do view:Destroy() end
        error(result)
    end
    return root or result
end
local function createWeaponPickerLocal(api)
    local manager = {alive=true, generation=0, mode=nil, saved={}, characterConnections={}, cache={}, pendingToken=nil}
    local definitions={
    {id="wood",name="Gậy mặc định",detail="Hình gậy gốc",themes={},exact={},forms={}},
    {id="katana",name="Katana hồng",detail="Cherry Blossom",fallbackOutline=true,
        indexThemes={"cherryblossom","sakura"},
        themes={"cherryblossom","sakura","pinkkatana","cherrykatana"},
        exact={"katana","cherryblossomkatana","sakurasword"},forms={"katana","sword","blade"}},
    {id="hammer",name="Búa cây",detail="Enchanted Forest",
        themes={"enchantedforest","foresthammer","forestmallet","treehammer","naturehammer","woodlandhammer"},
        exact={"foresthammer","enchantedhammer","treehammer"},forms={"hammer","mallet"}},
    {id="lightdarkstaff",name="Light Drak Staff",detail="Light / Dark",fallbackOutline=true,preferEffects=true,
        indexThemes={"lightdark","heavenandhell","angelsanddemons"},
        themes={"lightdarkstaff","lightdrakstaff","lightanddarkstaff","lightdark","lightdrak"},
        exact={"lightdarkstaff","lightdrakstaff","lightanddarkstaff"},forms={"staff"}},
    {id="titanaxe",name="Rìu Titan Temple",detail="Titan Temple",fallbackOutline=true,
        indexThemes={"titantemple"},
        themes={"titantemple","titanaxe","titansaxe","titanbattleaxe"},
        exact={"titanaxe","titansaxe","titanbattleaxe"},forms={"axe","battleax"}},
}
    local names,byId={},{}
    for _,definition in ipairs(definitions) do names[definition.id]=definition.name; byId[definition.id]=definition end
    function manager:GetDefinitions() return definitions end
    local function normalized(value) return tostring(value):lower():gsub("[^%w]","") end
    local function matches(value, words)
        for _,word in ipairs(words) do if value:find(word,1,true) then return true end end
        return false
    end
    local function listen(signal, callback) return signal:Connect(callback) end
    local function notify(message) if api.onStatus then api.onStatus(message) end end
    local function selection(busy)
        if api.onSelection then api.onSelection(manager.mode,busy) end
    end
    local identity = api.CFrame.new()
    local function isFood(tool)
        return matches(normalized(tool.Name),{"egg","potion","food","seed","crate","petfood","hatch"})
    end
    local function isWeapon(tool)
        return matches(normalized(tool.Name),{"bat","club","stick","sword","katana","hammer","weapon","swing"})
    end
    local function handleOf(tool)
        local handle = tool:FindFirstChild("Handle")
        return handle and handle:IsA("BasePart") and handle or nil
    end
    local function numericAttribute(item, name)
        local ok,value=pcall(function() return item:GetAttribute(name) end)
        return ok and type(value)=="number" and value or nil
    end
    local function isFX(item)
        return item:IsA("Trail") or item:IsA("Beam") or item:IsA("ParticleEmitter")
            or item:IsA("Light") or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles")
    end
local function installWeaponHotbarOverlay(api,manager)
    local entries,watchers={},{}
    local pending=false
    function manager:ClearOverlay()
        for _,connection in ipairs(watchers) do connection:Disconnect() end
        watchers={}; pending=false
        for _,entry in ipairs(entries) do
            entry.view:Destroy()
            if entry.host then entry.host:Destroy() end
            pcall(function() entry.image.ImageTransparency=entry.transparency end)
            for _,saved in ipairs(entry.locks) do pcall(function() saved.item.Visible=saved.visible end) end
        end
        if self.hotbarLayer then self.hotbarLayer:Destroy(); self.hotbarLayer=nil end
        entries={}; self.overlayPrepared=nil; self.hotbarMatched=0
    end
    local function hotbar(image)
        local ancestor=image.Parent
        for _=1,7 do
            if not ancestor then break end
            local name=ancestor.Name:lower()
            if name:find("hotbar",1,true) or name:find("backpack",1,true) then return true end
            ancestor=ancestor.Parent
        end
        return false
    end
    local function isIcon(image)
        local name=image.Name:lower()
        for _,word in ipairs({"lock","shadow","background","border","glow","gradient","placeholder"}) do
            if name:find(word,1,true) then return false end
        end
        return true
    end
    local function ownerOf(image)
        local owner=image.Parent
        for _=1,5 do
            if not owner then return image.Parent end
            if owner.Name:lower():find("hotbar",1,true) then return image.Parent end
            if owner:IsA("GuiButton") or owner.Name:match("^%d+$") or owner.Name:lower():match("^slot%d+$") then return owner end
            local count=0
            for _,child in ipairs(owner:GetChildren()) do
                count+=1
                if count>40 then break end
                if child:IsA("ObjectValue") or child.Name=="ToolName" then return owner end
            end
            owner=owner.Parent
        end
        return image.Parent
    end
    local function boundToTool(owner,tool)
        local children=owner:GetDescendants()
        for index,item in ipairs(children) do
            if index>80 then break end
            if item:IsA("ObjectValue") and item.Value and item.Value:IsA("Tool") then return item.Value==tool end
        end
        if owner.Name==tool.Name then return true end
        for _,key in ipairs({"ToolName","ItemName"}) do
            local ok,value=pcall(function() return owner:GetAttribute(key) end)
            if ok and value==tool.Name then return true end
        end
        local count=0
        for _,item in ipairs(children) do
            count+=1; if count>80 then break end
            if item:IsA("ObjectValue") and item.Value==tool then return true end
            if item:IsA("TextLabel") and item.Name=="ToolName" and item.Text==tool.Name then return true end
        end
        return false
    end
    local function otherTool(owner,tool)
        for index,item in ipairs(owner:GetDescendants()) do
            if index>80 then break end
            if item:IsA("ObjectValue") and item.Value and item.Value:IsA("Tool") then return item.Value~=tool end
            if item:IsA("TextLabel") and item.Name=="ToolName" and item.Text~="" then return item.Text~=tool.Name end
        end
        return false
    end
    local function hideLocks(entry)
        if entry.owner.Name:lower():find("hotbar",1,true) or entry.owner.Name:lower():find("backpack",1,true) then return end
        for _,item in ipairs(entry.owner:GetDescendants()) do
            if (item:IsA("ImageLabel") or item:IsA("ImageButton")) and item.Name:lower():find("lock",1,true) then
                local saved=false
                for _,previous in ipairs(entry.locks) do if previous.item==item then saved=true; break end end
                if not saved then entry.locks[#entry.locks+1]={item=item,visible=item.Visible} end
                item.Visible=false
            end
        end
    end
    local function getPixelLayer(coreGui)
        if manager.hotbarLayer then return manager.hotbarLayer end
        local layer=api.Instance.new("ScreenGui")
        layer.Name="THTWeaponHotbarLayer"; layer.ResetOnSpawn=false
        layer.IgnoreGuiInset=false; layer.DisplayOrder=10001
        if api.Enum and api.Enum.ScreenInsets then layer.ScreenInsets=api.Enum.ScreenInsets.CoreUISafeInsets end
        if api.Enum and api.Enum.ZIndexBehavior then layer.ZIndexBehavior=api.Enum.ZIndexBehavior.Sibling end
        local parent=coreGui or api.overlayRoot and api.overlayRoot.Parent or api.playerGui
        local ok,problem=pcall(function() layer.Parent=parent end)
        if not ok then layer:Destroy(); error(problem) end
        manager.hotbarLayer=layer
        return layer
    end
    function manager:HotbarDiagnostics()
        local lines={self.hotbarReport or "not selected"}
        local function rect(item)
            local position,size=item and item.AbsolutePosition,item and item.AbsoluteSize
            return position and size and string.format("(%.1f,%.1f) %.1fx%.1f",position.X,position.Y,size.X,size.Y) or "layout pending"
        end
        for _,entry in ipairs(entries) do
            lines[#lines+1]="target="..rect(entry.image).."; host="..rect(entry.host).."; view="..rect(entry.view)
        end
        return table.concat(lines," | ")
    end
    function manager:RefreshOverlay()
        if not api.renderThumbnail then return end
        local prepared=self.prepared
        if not self.alive or not prepared or not (prepared.modelIcon or prepared.fixHotbar) or not self.iconTool then
            self:ClearOverlay(); return
        end
        if self.overlayPrepared~=prepared then self:ClearOverlay(); self.overlayPrepared=prepared end
        local roots={api.playerGui}
        local coreGui
        if api.getCoreGui then
            local ok,root=pcall(api.getCoreGui)
            if ok and root then coreGui=root; table.insert(roots,1,root) end
        end
        local function queue()
            if pending then return end
            pending=true
            api.task.delay(.08,function()
                pending=false
                if manager.alive and manager.overlayPrepared==prepared then manager:RefreshOverlay() end
            end)
        end
        if #watchers==0 then
            for _,root in ipairs(roots) do
                pcall(function()
                    watchers[#watchers+1]=root.DescendantAdded:Connect(function(item)
                        if item:IsA("ImageLabel") or item:IsA("ImageButton") then queue() end
                    end)
                end)
            end
        end
        local inspected,failures=0,{}
        for _,root in ipairs(roots) do
            local success,problem=pcall(function()
                local queue,head={root},1
                while head<=#queue and head<=6000 do
                    local image=queue[head]; head+=1; inspected+=1
                    if (image:IsA("ImageLabel") or image:IsA("ImageButton")) and isIcon(image) and hotbar(image) then
                        local value=image.Image
                        local owner=ownerOf(image)
                        local function knownIcon(current)
                            return current and current~="" and (current==self.originalIcon or current==prepared.icon or current==self.iconTool.TextureId)
                        end
                        local identity=boundToTool(owner,self.iconTool)
                        local original=value and value~="" and value==self.originalIcon
                        local match=not otherTool(owner,self.iconTool) and (original or identity and (image.Name=="ToolIcon" or image.Name=="Icon"))
                        local exists=false
                        for _,entry in ipairs(entries) do if entry.image==image then exists=true; if match then hideLocks(entry) end; break end end
                        if match and not exists then
                            local host,layer
                            if api.UDim2 and api.UDim2.fromOffset and image.AbsolutePosition and image.AbsoluteSize then
                                layer=getPixelLayer(coreGui)
                                host=api.Instance.new("Frame"); host.Name="WeaponHotbarThumbnailHost"
                                host.BackgroundTransparency=1; host.BorderSizePixel=0; host.ZIndex=60
                                host.ClipsDescendants=true
                                host.Parent=layer
                            end
                            local ok,view=pcall(function()
                                local parent=host or image
                                if prepared.modelIcon then return api.renderThumbnail(prepared,parent,{hotbar=true}) end
                                local icon=api.Instance.new("ImageLabel")
                                icon.Name="NativeWeaponImage"; icon.BackgroundTransparency=1; icon.BorderSizePixel=0
                                icon.Image=prepared.icon; icon.Size=api.UDim2.fromScale(1,1); icon.ZIndex=parent.ZIndex+1
                                if prepared.iconRect then
                                    icon.ImageRectOffset=prepared.iconRect.offset
                                    icon.ImageRectSize=prepared.iconRect.size
                                end
                                if api.Enum and api.Enum.ScaleType then icon.ScaleType=api.Enum.ScaleType.Fit end
                                icon.Parent=parent; return icon
                            end)
                            if ok and view then
                                local entry={image=image,view=view,host=host,owner=owner,identityOnly=not knownIcon(value),transparency=image.ImageTransparency,locks={}}
                                entries[#entries+1]=entry
                                hideLocks(entry)
                                image.ImageTransparency=1
                                local function sync()
                                    local stillWeapon=not otherTool(owner,self.iconTool) and (knownIcon(image.Image) or entry.identityOnly and boundToTool(owner,self.iconTool))
                                    local visible=stillWeapon==true
                                    local ancestor=owner
                                    for _=1,12 do
                                        if not ancestor then break end
                                        if ancestor:IsA("GuiObject") and not ancestor.Visible then visible=false end
                                        if ancestor:IsA("ScreenGui") and not ancestor.Enabled then visible=false end
                                        ancestor=ancestor.Parent
                                    end
                                    if host then
                                        local origin=layer.AbsolutePosition
                                        local x,y=origin and origin.X or 0,origin and origin.Y or 0
                                        host.Position=api.UDim2.fromOffset(image.AbsolutePosition.X-x,image.AbsolutePosition.Y-y)
                                        host.Size=api.UDim2.fromOffset(image.AbsoluteSize.X,image.AbsoluteSize.Y)
                                        host.Visible=visible and image.AbsoluteSize.X>0 and image.AbsoluteSize.Y>0
                                    else view.Visible=visible end
                                    local transparency=stillWeapon and 1 or entry.transparency
                                    if image.ImageTransparency~=transparency then image.ImageTransparency=transparency end
                                    for _,saved in ipairs(entry.locks) do
                                        if stillWeapon then saved.item.Visible=false else saved.item.Visible=saved.visible end
                                    end
                                end
                                for _,property in ipairs({"Image","ImageTransparency","AbsolutePosition","AbsoluteSize"}) do
                                    watchers[#watchers+1]=image:GetPropertyChangedSignal(property):Connect(sync)
                                end
                                if layer then watchers[#watchers+1]=layer:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync) end
                                local ancestor=owner
                                for _=1,12 do
                                    if not ancestor then break end
                                    if ancestor:IsA("GuiObject") then watchers[#watchers+1]=ancestor:GetPropertyChangedSignal("Visible"):Connect(sync)
                                    elseif ancestor:IsA("ScreenGui") then watchers[#watchers+1]=ancestor:GetPropertyChangedSignal("Enabled"):Connect(sync) end
                                    ancestor=ancestor.Parent
                                end
                                for _,child in ipairs(owner:GetDescendants()) do
                                    if child:IsA("ObjectValue") then watchers[#watchers+1]=child:GetPropertyChangedSignal("Value"):Connect(sync)
                                    elseif child:IsA("TextLabel") and child.Name=="ToolName" then watchers[#watchers+1]=child:GetPropertyChangedSignal("Text"):Connect(sync) end
                                end
                                sync()
                            else
                                if host then host:Destroy() end
                                failures[#failures+1]=tostring(view):sub(1,100)
                            end
                        end
                    end
                    for _,child in ipairs(image:GetChildren()) do queue[#queue+1]=child end
                end
            end)
            if not success then failures[#failures+1]=tostring(problem):sub(1,100) end
        end
        self.hotbarMatched=#entries
        self.hotbarReport="matched="..#entries.."; inspected="..inspected.."; errors="..table.concat(failures," | ")
    end
end

    installWeaponHotbarOverlay(api,manager)
    function manager:ClearIcon()
        self:ClearOverlay()
        if self.iconChanged then self.iconChanged:Disconnect(); self.iconChanged=nil end
        if self.iconTool then pcall(function() self.iconTool.TextureId=self.originalIcon end) end
        self.iconTool,self.originalIcon=nil,nil
    end
    local function getBackpack()
        if api.getBackpack then return api.getBackpack() end
        local ok,result=pcall(function() return api.player:FindFirstChild("Backpack") end)
        return ok and result or nil
    end
    function manager:ApplyIcon(tool)
        local icon=self.prepared and self.prepared.icon
        if not self.prepared then self:ClearIcon(); return end
        tool=tool or self.tool or self.iconTool
        if not tool then
            local bag=getBackpack()
            if bag then for _,item in ipairs(bag:GetChildren()) do
                if item:IsA("Tool") and not isFood(item) and (item.Name==self.toolName or isWeapon(item)) then tool=item; break end
            end end
        end
        if not tool then return end
        if self.iconTool~=tool then
            self:ClearIcon()
            self.iconTool,self.originalIcon=tool,tool.TextureId
            self.iconChanged=listen(tool:GetPropertyChangedSignal("TextureId"),function()
                local current=self.prepared and self.prepared.icon
                if self.alive and self.iconTool==tool and current and current~="" and not self.prepared.iconRect and tool.TextureId~=current then
                    tool.TextureId=current
                    self:RefreshOverlay()
                end
            end)
        end
        self:RefreshOverlay()
        if icon and icon~="" and not self.prepared.iconRect and tool.TextureId~=icon then tool.TextureId=icon end
        self:RefreshOverlay()
    end
    function manager:SetFX(enabled)
        if not self.prepared then return end
        for _,entry in ipairs(self.prepared.effects or {}) do
            entry.clone.Enabled=enabled and entry.enabled or false
            if not enabled and (entry.clone:IsA("Trail") or entry.clone:IsA("ParticleEmitter")) then
                pcall(function() entry.clone:Clear() end)
            end
        end
    end
    function manager:AttackFX()
        local prepared,tool=self.prepared,self.tool
        if not prepared or not tool then return end
        self.fxEpoch=(self.fxEpoch or 0)+1
        local epoch=self.fxEpoch
        for _,entry in ipairs(prepared.effects or {}) do
            local item=entry.clone
            if item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") then
                local function fire()
                    if not self.alive or self.prepared~=prepared or self.tool~=tool or self.fxEpoch~=epoch then return end
                    if item:IsA("ParticleEmitter") then
                        local count=entry.count
                        if count then item:Emit(math.clamp(math.floor(count),0,200))
                        elseif not entry.enabled then item:Emit(math.clamp(math.floor((item.Rate or 0)*entry.duration),1,80)) end
                    end
                    if not entry.enabled then
                        item.Enabled=true
                        api.task.delay(entry.duration,function()
                            if self.alive and self.prepared==prepared and self.tool==tool and self.fxEpoch==epoch then item.Enabled=false end
                        end)
                    end
                end
                if entry.delay>0 then api.task.delay(entry.delay,function() pcall(fire) end) else pcall(fire) end
            end
        end
    end
    local function hide(item)
        if manager.saved[item] then return end
        if item:IsA("BasePart") then
            manager.saved[item] = {"LocalTransparencyModifier",item.LocalTransparencyModifier}
            item.LocalTransparencyModifier = 1
        elseif item:IsA("Trail") or item:IsA("Beam") or item:IsA("ParticleEmitter")
            or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles") then
            manager.saved[item] = {"Enabled",item.Enabled}; item.Enabled=false
        end
    end
    function manager:Unmount()
        self.fxEpoch=(self.fxEpoch or 0)+1
        if self.attack then self.attack:Disconnect(); self.attack=nil end
        self:SetFX(false)
        if self.render then self.render:Disconnect(); self.render=nil end
        if self.toolAdded then self.toolAdded:Disconnect(); self.toolAdded=nil end
        for item,entry in pairs(self.saved) do pcall(function() item[entry[1]]=entry[2] end) end
        self.saved={}
        if self.prepared then self.prepared.model.Parent=nil end
        self.tool,self.handle=nil,nil
        self.handBody,self.handLocalPivot=nil,nil
    end
    function manager:Step()
        local character = api.player.Character
        if not self.tool or self.tool.Parent ~= character or not self.handle or self.handle.Parent ~= self.tool then
            self:Unmount(); return
        end
        local camera = api.Workspace.CurrentCamera
        if not camera then self:Unmount(); return end
        local prepared = self.prepared
        if prepared.model.Parent ~= camera then prepared.model.Parent=camera end
        local originalPivot = self.handle.CFrame * (self.tool.Grip or identity)
        local pivot = originalPivot
        if api.getVisualHandOffset then
            local offset,scale,shownGrip,_,body=api.getVisualHandOffset(character)
            if offset then pivot=pivot+offset end
            if body~=self.handBody then
                self.handBody,self.handLocalPivot=body,nil
            end
            if scale and scale<.85 and shownGrip then
                local humanoid=character:FindFirstChildOfClass("Humanoid")
                local moving=humanoid and humanoid.MoveDirection.Magnitude>.05
                if not moving then
                    self.handLocalPivot=shownGrip:Inverse()*pivot
                elseif self.handLocalPivot then
                    pivot=shownGrip*self.handLocalPivot
                end
            end
        end
        for _,entry in ipairs(prepared.parts) do entry.part.CFrame=pivot*entry.offset end
        for item,entry in pairs(self.saved) do
            if item.Parent then
                local hidden=entry[1]=="LocalTransparencyModifier" and 1 or false
                if item[entry[1]]~=hidden then item[entry[1]]=hidden end
            end
        end
    end
    function manager:ReorderRender()
        if self.render then self.render:Disconnect(); self.render=nil end
        if not self.tool or not self.handle or not self.prepared then return end
        self.render=listen(api.RunService.RenderStepped,function()
            local ok,problem=pcall(function() self:Step() end)
            if not ok then self:Disable(); notify("Hiển thị vũ khí lỗi: "..tostring(problem):sub(1,45)) end
        end)
    end
    function manager:MountCurrent(explicit)
        self:Unmount()
        if not self.alive or not self.prepared then return end
        local character = api.player.Character
        if not character then return end
        local equipped
        for _,item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and not isFood(item)
                and (item.Name==self.toolName or isWeapon(item) or explicit) then equipped=item; break end
        end
        if not equipped then self:ApplyIcon(); return end
        self.tool,self.toolName=equipped,equipped.Name
        self:ApplyIcon(equipped)
        self.toolAdded=listen(equipped.DescendantAdded,function(item)
            if self.tool ~= equipped then return end
            if not self.handle then
                self:MountCurrent(false)
            else hide(item) end
        end)
        self.handle=handleOf(equipped)
        if not self.handle then return end
        if not api.Workspace.CurrentCamera then return end
        self:Step()
        self:SetFX(true)
        self.attack=listen(equipped.Activated,function() self:AttackFX() end)
        for _,item in ipairs(equipped:GetDescendants()) do hide(item) end
        self:ReorderRender()
    end
    function manager:WatchCharacter()
        for _,connection in ipairs(self.characterConnections) do connection:Disconnect() end
        self.characterConnections={}
        self:Unmount()
        local character=api.player.Character
        if not character or not self.prepared then return end
        self.characterConnections[#self.characterConnections+1]=listen(character.ChildAdded,function(item)
            if item:IsA("Tool") then self:MountCurrent(false) end
        end)
        self.characterConnections[#self.characterConnections+1]=listen(character.ChildRemoved,function(item)
            if item==self.tool then self:Unmount() end
        end)
        local bag=getBackpack()
        if bag then
            self.characterConnections[#self.characterConnections+1]=listen(bag.ChildAdded,function(item)
                if item:IsA("Tool") and not isFood(item) and (item.Name==self.toolName or isWeapon(item)) then self:ApplyIcon(item) end
            end)
        end
        self:MountCurrent(false)
        self:ApplyIcon()
    end
    local now=api.clock or os.clock
    local MAX_NODES,MAX_SECONDS=16000,2.5
    local function path(item)
        local ok,value=pcall(function() return item:GetFullName() end)
        return ok and value or item.Name
    end
    local function contextOf(item)
        local current=item
        for _=1,6 do
            if not current then break end
            local label=normalized(current.Name)
            if label=="batrig" or label=="ratrig" or label=="stickrig" or label=="trngvng" or label=="goldstaff" then return "" end
            current=current.Parent
        end
        local pieces={normalized(item.Name)}
        local ancestor=item.Parent
        for _=1,5 do
            if not ancestor then break end
            if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then break end
            if normalized(ancestor.Name)=="pets" or normalized(ancestor.Name)=="eggs" then return "" end
            pieces[#pieces+1]=normalized(ancestor.Name); ancestor=ancestor.Parent
        end
        local ok,attributes=pcall(function() return item:GetAttributes() end)
        if ok then
            for key,value in pairs(attributes) do
                if type(value)=="string" and matches(normalized(key),{"name","weapon","zone","area","theme","biome","type","category"}) then
                    pieces[#pieces+1]=normalized(value)
                end
            end
        end
        return table.concat(pieces," ")
    end
    local function score(item, mode, context)
        if not (item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart")) then return 0 end
        local label=normalized(item.Name)
        if label=="localweaponvisual" then return 0 end
        context=context or contextOf(item)
        if context=="" then return 0 end
        local definition=byId[mode]
        if not definition or mode=="wood" or definition.source then return 0 end
        local theme=matches(context,definition.themes)
        local exactKind=false
        for _,name in ipairs(definition.exact) do if label==name then exactKind=true; break end end
        if not theme and not exactKind then return 0 end
        local form=matches(context,definition.forms)
        if not exactKind and not form then return 0 end
        local weapon=matches(context,{"weapon","tool","reward"}) or matches(label,definition.forms)
        if not weapon and not item:IsA("Tool") then return 0 end
        return 10+(theme and 8 or 0)+(exactKind and 12 or 0)
            +(item:IsA("Tool") and 12 or item:IsA("Model") and 6 or 0)
            +(matches(label,definition.forms) and 4 or 0)
    end
local function discoverNativeWeapon(item,contextOf,byId,definitions,context)
    if not (item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart")) then return nil end
    context=context or contextOf(item)
    if context=="" or item.Name=="LocalWeaponVisual" then return nil end
    local function norm(value) return tostring(value):lower():gsub("[^%w]","") end
    local function has(value,words)
        for _,word in ipairs(words) do if value:find(word,1,true) then return true end end
        return false
    end
    local label=norm(item.Name)
    if label=="batrig" or label=="ratrig" or label=="stickrig" or label=="trngvng" or label=="goldstaff" then return nil end
    for _,key in ipairs({"DisplayName","WeaponName","Name"}) do
        local ok,value=pcall(function() return item:GetAttribute(key) end)
        local alias=ok and norm(value) or ""
        if alias=="batrig" or alias=="ratrig" or alias=="stickrig" or alias=="trngvng" then return nil end
    end
    if label=="bat" or label=="wood" or label=="wooden" or label=="woodenbat" or label=="woodbat" or label=="woodenstick" or label=="default" then return nil end
    if has(label,{"egg","potion","petfood","crate","hatch","trail","effect","vfx","particle","icon"}) then return nil end
    local parent=item.Parent
    if not parent then return nil end
    local ancestor=parent
    for _=1,6 do
        if not ancestor then break end
        if ancestor:IsA("Tool") then return nil end
        if ancestor:IsA("Model") and (ancestor.PrimaryPart or ancestor:FindFirstChild("Handle") or ancestor:FindFirstChildOfClass("Humanoid")) then return nil end
        ancestor=ancestor.Parent
    end
    local forms={"sword","katana","hammer","mallet","axe","spear","staff","scythe","mace","dagger","bat","club","stick","wand","trident","blade","chainsaw","scepter","sceptre"}
    local folder=norm(parent.Name)
    local weaponFolder=folder=="weapons" or folder=="weaponskins" or folder=="weaponmodels" or folder=="bats" or folder=="batmodels" or folder=="swords" or folder=="hammers"
    local named=has(label,forms)
    if not weaponFolder and not (named and (item:IsA("Tool") or item:IsA("BasePart") or item:FindFirstChild("Handle") or item:IsA("Model") and item.PrimaryPart)) then return nil end
    if item:IsA("Model") and not item:FindFirstChildWhichIsA("BasePart",true) then return nil end
    if not item:IsA("Model") and not item:IsA("Tool") and not (weaponFolder and named) then return nil end
    for _,definition in ipairs(definitions) do
        if definition.source==item then return definition end
        if definition.id~="wood" and not definition.source then
            if has(context,definition.themes) or has(label,definition.exact) then
                if has(context,definition.forms) or weaponFolder then return definition end
            end
        end
    end
    local name=item.Name
    for _,key in ipairs({"DisplayName","WeaponName","Name"}) do
        local ok,value=pcall(function() return item:GetAttribute(key) end)
        if ok and type(value)=="string" and value~="" then name=value; break end
    end
    local id="native"..(#definitions+1)
    local definition={id=id,name=name,detail=parent.Name,themes={},exact={},forms=forms,source=item}
    definitions[#definitions+1]=definition; byId[id]=definition
    return definition
end

    function manager:Scan(mode, token, wantReport)
        self.iconCache={}; self.companionCache=nil
        local candidates,report,catalog={},wantReport and {} or nil,{}
        for _,definition in ipairs(definitions) do catalog[definition.id]={} end
        local roots={}
        local gear=api.ReplicatedStorage:FindFirstChild("GearTools")
        local shop=gear and gear:FindFirstChild("ShopItems")
        if shop then roots[#roots+1]=shop end
        roots[#roots+1]=api.ReplicatedStorage
        if api.Players then
            local ok,players=pcall(function() return api.Players:GetPlayers() end)
            if ok then for _,player in ipairs(players) do
                if player~=api.player and player.Character then
                    for _,child in ipairs(player.Character:GetChildren()) do
                        if child:IsA("Tool") then roots[#roots+1]=child end
                    end
                end
            end end
        end
        local stack={}
        for i=#roots,1,-1 do if roots[i] then stack[#stack+1]=roots[i] end end
        local seen={}
        local count,start,reportCount=0,now(),0
        while #stack>0 and count<MAX_NODES and now()-start<MAX_SECONDS do
            if not self.alive or token and self.generation~=token then return nil end
            local item=table.remove(stack)
            if not seen[item] then
                seen[item]=true; count+=1
                local context
                if item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart") then
                    context=contextOf(item)
                end
                for _,definition in ipairs(definitions) do
                    local value=score(item,definition.id,context)
                    if value>0 then
                        local list=catalog[definition.id]
                        list[#list+1]={item=item,score=value}
                    end
                end
                if wantReport and reportCount<100 then
                    context=context or contextOf(item)
                end
                if wantReport and reportCount<100 and matches(context,{"weapon","katana","hammer","sword","mallet","blade","reward","moonbloom","staff","spear","axe","titan","heaven"}) then
                    if item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart") then
                        reportCount+=1
                        local line=item.ClassName.." | "..path(item)
                        if item:IsA("Tool") then line=line.." | ToolIcon="..tostring(item.TextureId) end
                        if item:IsA("MeshPart") then line=line.." | Mesh="..tostring(item.MeshId).." | Texture="..tostring(item.TextureID) end
                        report[#report+1]=line
                    elseif item:IsA("SpecialMesh") then
                        reportCount+=1; report[#report+1]="SpecialMesh | "..path(item).." | Mesh="..tostring(item.MeshId).." | Texture="..tostring(item.TextureId)
                    elseif item:IsA("Trail") or item:IsA("Beam") or item:IsA("ParticleEmitter") then
                        reportCount+=1; report[#report+1]=item.ClassName.." | "..path(item).." | Texture="..tostring(item.Texture)
                    elseif item:IsA("ImageLabel") or item:IsA("ImageButton") then
                        reportCount+=1; report[#report+1]="2D icon, NOT a 3D model | "..path(item).." | Image="..tostring(item.Image)
                    end
                end
                local source=discoverNativeWeapon(item,contextOf,byId,definitions,context)
                if source then
                    names[source.id]=source.name
                    catalog[source.id]=catalog[source.id] or {}
                    local list=catalog[source.id]
                    if #list==0 or list[#list].item~=item then list[#list+1]={item=item,score=40} end
                end
                local children=item:GetChildren()
                for i=#children,1,-1 do stack[#stack+1]=children[i] end
                if count%120==0 then api.task.wait() end
            end
        end
        for _,list in pairs(catalog) do table.sort(list,function(x,y) return x.score>y.score end) end
        self.catalog=catalog
        candidates=mode and catalog[mode] or {}
        if wantReport then
            self.lastReport="Steal an Egg — loaded weapon assets\nPlaceId="..tostring(api.placeId or "unknown")
                .."\nInspected="..count.."; truncated="..tostring(#stack>0).."\n"
                .."Only client-loaded instances inspected. No server data or script source read.\n\n"
                ..table.concat(report,"\n")
        end
        return candidates
    end
local function verifiedWeaponIcon(api,manager,source,definition,mode)
    local function norm(value) return tostring(value):lower():gsub("[^%w]","") end
    local function imageValue(value)
        if type(value)=="number" then return value>0 and "rbxassetid://"..value or nil end
        if type(value)~="string" or value=="" or value=="0" or value=="rbxassetid://0" then return nil end
        return value:match("^%d+$") and "rbxassetid://"..value or value
    end
    local aliases={[norm(source.Name)]=true}
    for _,value in ipairs(definition.exact) do aliases[value]=true end
    local ancestor=source
    for _=1,4 do
        if not ancestor then break end
        if ancestor:IsA("Tool") then
            local icon=imageValue(ancestor.TextureId)
            if icon and not (definition.fallbackOutline and icon:lower():find("egg",1,true))
                and not (definition.fallbackOutline and icon:lower():find("nest",1,true))
                and not (definition.fallbackOutline and icon:lower():find("lock",1,true)) then
                return icon,"Tool.TextureId"
            end
        end
        for _,key in ipairs({"WeaponIcon","BatIcon","ToolTextureId"}) do
            local ok,value=pcall(function() return ancestor:GetAttribute(key) end)
            local icon=ok and imageValue(value)
            if icon then return icon,"weapon attribute "..key end
        end
        ancestor=ancestor.Parent
    end
    manager.iconCache=manager.iconCache or {}
    local cached=manager.iconCache[mode]
    if cached then return cached.icon,cached.source,cached.rect end
    local function identity(item)
        local name=norm(item.Name)
        for _=1,3 do
            local changed=false
            for _,suffix in ipairs({"reward","frame","icon","image","preview","button"}) do
                if name:sub(-#suffix)==suffix then name=name:sub(1,-#suffix-1); changed=true; break end
            end
            if not changed then break end
        end
        if aliases[name] then return true end
        for _,key in ipairs({"WeaponName","ToolName","ItemName"}) do
            local ok,value=pcall(function() return item:GetAttribute(key) end)
            if ok and aliases[norm(value)] then return true end
        end
        return false
    end
    local function safeImage(item)
        local name=norm(item.Name)
        for _,word in ipairs({"egg","nest","peticon","lock","cash","money","coin","speed","shoe","glow","particle","gradient","background","shadow","flare","shine","blur","placeholder","check"}) do
            if name:find(word,1,true) then return false end
        end
        return true
    end
    local result={icon=nil,source="no exact weapon icon"}
    local biomeIcon
    local function cropOf(item)
        local size=item.ImageRectSize
        if size and size.Magnitude>0 then return {offset=item.ImageRectOffset,size=size} end
        return nil
    end
    local function indexWeaponReward(item)
        if not definition.fallbackOutline then return false end
        local weapon=false; local reward=false; local biome=false
        local cursor=item
        for _=1,8 do
            if not cursor then break end
            local name=norm(cursor.Name)
            if name:find("index",1,true) or name:find("reward",1,true) then reward=true end
            if name:find("weapon",1,true) or name:find("gear",1,true)
                or name:find("bat",1,true) or name:find("staff",1,true) or name:find("axe",1,true) then weapon=true end
            for _,theme in ipairs(definition.indexThemes or definition.themes) do
                if name:find(theme,1,true) then biome=true; break end
            end
            cursor=cursor.Parent
        end
        return reward and weapon and biome
    end
    local roots={}
    if api.playerGui then
        for _,child in ipairs(api.playerGui:GetChildren()) do
            if norm(child.Name):find("index",1,true) then roots[#roots+1]=child end
            for _,grandchild in ipairs(child:GetChildren()) do
                if norm(grandchild.Name):find("index",1,true) then roots[#roots+1]=grandchild end
            end
        end
        roots[#roots+1]=api.playerGui
    end
    if api.ReplicatedStorage then roots[#roots+1]=api.ReplicatedStorage end
    for _,root in ipairs(roots) do
        if root and not result.icon then
            local queue,head={root},1
            while head<=#queue and head<=8000 do
                local item=queue[head]; head+=1
            if (item:IsA("ImageLabel") or item:IsA("ImageButton")) and safeImage(item) then
                local exact=false; local owner=item
                for _=1,4 do
                    if not owner then break end
                    if identity(owner) then exact=true; break end
                    owner=owner.Parent
                end
                local icon=exact and imageValue(item.Image)
                if icon then
                    result={icon=icon,source="exact weapon reward image",rect=cropOf(item)}; break
                end
                if not biomeIcon and not exact then
                    local candidate=imageValue(item.Image)
                    local lower=candidate and candidate:lower() or ""
                    if candidate and not lower:find("egg",1,true) and not lower:find("nest",1,true)
                        and indexWeaponReward(item) then biomeIcon={icon=candidate,rect=cropOf(item)} end
                end
            end
                for _,child in ipairs(item:GetChildren()) do queue[#queue+1]=child end
            end
        end
    end
    if not result.icon and biomeIcon then result={icon=biomeIcon.icon,source="indexed weapon reward image",rect=biomeIcon.rect} end
    manager.iconCache[mode]=result
    return result.icon,result.source,result.rect
end

    local function findIcon(source,mode) return verifiedWeaponIcon(api,manager,source,byId[mode],mode) end
    local function prepareTemplate(source,mode)
        local all,stack={}, {source}
        while #stack>0 do
            local item=table.remove(stack); all[#all+1]=item
            if #all>2048 then error("Model quá lớn để dùng làm vũ khí") end
            for _,child in ipairs(item:GetChildren()) do stack[#stack+1]=child end
        end
        local sourceParts={}
        local nestedTool
        local handle=source:IsA("BasePart") and source or handleOf(source) or source:IsA("Model") and source.PrimaryPart
        for _,item in ipairs(all) do
            if item:IsA("Tool") and not nestedTool then nestedTool=item end
            if item:IsA("Humanoid") then error("Không dùng model nhân vật làm vũ khí") end
            if item:IsA("BasePart") then sourceParts[#sourceParts+1]=item end
        end
        if #sourceParts==0 or #sourceParts>128 then error("Model không phải vũ khí nhỏ") end
        handle=handle or nestedTool and handleOf(nestedTool) or sourceParts[1]
        local grip=source:IsA("Tool") and source.Grip or nestedTool and nestedTool.Grip
        local attachment=handle:FindFirstChild("RightGripAttachment")
        local pivot=handle.CFrame*(grip or attachment and attachment.CFrame or identity)
        local model=api.Instance.new("Model"); model.Name="LocalWeaponVisual"
        local prepared={model=model,parts={},effects={},exact=true,sourcePath=path(source),sourceName=source.Name}
        prepared.icon,prepared.iconSource,prepared.iconRect=findIcon(source,mode)
        prepared.fixHotbar=prepared.iconSource=="exact weapon reward image" or prepared.iconSource=="indexed weapon reward image"
        prepared.hotbarRoll=mode=="katana" and 35 or 0
        prepared.fallbackOutline=byId[mode].fallbackOutline and not prepared.icon
        prepared.modelIcon=not prepared.icon
        local ok,problem=pcall(function()
            local copy=source:Clone()
            if not copy then error("Model vũ khí không cho sao chép") end
            copy.Parent=model
            local map={}
            local function pair(original,cloned)
                map[original]=cloned
                local buckets={}
                for _,child in ipairs(cloned:GetChildren()) do
                    local key=child.ClassName.."/"..child.Name
                    buckets[key]=buckets[key] or {}; table.insert(buckets[key],child)
                end
                for _,child in ipairs(original:GetChildren()) do
                    local bucket=buckets[child.ClassName.."/"..child.Name]
                    if bucket and #bucket>0 then pair(child,table.remove(bucket,1)) end
                end
            end
            pair(source,copy)
            if source:IsA("BasePart") then copy.Parent=model
            else
                for _,child in ipairs(copy:GetChildren()) do child.Parent=model end
                copy:Destroy(); map[source]=model
            end
            for _,item in ipairs(model:GetDescendants()) do
                if item:IsA("Tool") then
                    local parent=item.Parent
                    for _,child in ipairs(item:GetChildren()) do child.Parent=parent end
                    item:Destroy()
                end
            end
            for _,item in ipairs(model:GetDescendants()) do
                if not (item:IsA("BasePart") or item:IsA("Model") or item:IsA("Folder")
                    or item:IsA("DataModelMesh") or item:IsA("SurfaceAppearance")
                    or item:IsA("Decal") or item:IsA("Texture") or item:IsA("Attachment")
                    or item:IsA("Bone") or isFX(item)) then item:Destroy() end
            end
            for _,original in ipairs(sourceParts) do
                local clone=map[original]
                if clone and clone:IsDescendantOf(model) then
                    clone.Anchored=true; clone.Massless=true
                    clone.CanCollide,clone.CanTouch,clone.CanQuery=false,false,false
                    clone.LocalTransparencyModifier=0
                    prepared.parts[#prepared.parts+1]={part=clone,offset=pivot:ToObjectSpace(original.CFrame)}
                end
            end
            for _,original in ipairs(all) do
                local clone=map[original]
                if clone and clone:IsDescendantOf(model) and isFX(original) then
                    if not (clone.Parent:IsA("BasePart") or clone.Parent:IsA("Attachment") or clone.Parent:IsA("Bone")) then
                        clone.Parent=map[handle]
                    end
                    local enabled=original.Enabled
                    if original:IsA("Trail") or original:IsA("Beam") then
                        clone.Attachment0,clone.Attachment1=map[original.Attachment0],map[original.Attachment1]
                        if not clone.Attachment0 or not clone.Attachment1 then enabled=false; clone:Destroy(); clone=nil end
                    end
                    if clone then
                        local duration=numericAttribute(original,"EmitDuration") or numericAttribute(original,"Duration") or .2
                        prepared.effects[#prepared.effects+1]={clone=clone,enabled=enabled,
                            count=numericAttribute(original,"EmitCount") or numericAttribute(original,"BurstCount"),
                            delay=math.clamp(numericAttribute(original,"EmitDelay") or 0,0,3),
                            duration=math.clamp(duration,.03,5)}
                        clone.Enabled=false
                    end
                end
            end
            if #prepared.parts==0 then error("Model không có hình học vũ khí") end
        end)
        if not ok then model:Destroy(); error(problem) end
        return prepared
    end
local function chooseNativePrefab(mode,candidates,definition,prepare,current)
    local pool,seen={},{}
    local function append(item)
        if item and not seen[item] then seen[item]=true; pool[#pool+1]=item end
    end
    for index,candidate in ipairs(candidates) do
        append(candidate.item)
        if definition.preferEffects then
            local ancestor=candidate.item.Parent
            for _=1,3 do
                if not ancestor then break end
                local name=ancestor.Name:lower():gsub("[^%w]","")
                for _,alias in ipairs(definition.themes) do
                    if name:find(alias,1,true) and (ancestor:IsA("Model") or ancestor:IsA("Folder")) then append(ancestor); break end
                end
                ancestor=ancestor.Parent
            end
        end
        if index>=12 then break end
    end
    local function meshes(prepared)
        local ids={}
        for _,entry in ipairs(prepared.parts) do
            local part=entry.part
            if part:IsA("MeshPart") and type(part.MeshId)=="string" and part.MeshId~="" then ids[part.MeshId]=true end
            for _,child in ipairs(part:GetChildren()) do
                if child:IsA("SpecialMesh") and type(child.MeshId)=="string" and child.MeshId~="" then ids[child.MeshId]=true end
            end
        end
        return ids
    end
    local best,bestSource,geometry
    for _,source in ipairs(pool) do
        if not current() then if best then best.model:Destroy() end; return nil end
        local ok,result=pcall(prepare,source,mode)
        if ok then
            if not definition.preferEffects then return result,source end
            local compatible=not best
            local ids=meshes(result)
            if geometry then for id in pairs(ids) do if geometry[id] then compatible=true; break end end end
            if not best or compatible and #result.effects>#best.effects then
                if best then best.model:Destroy() end
                best,bestSource=result,source; geometry=geometry or ids
            else result.model:Destroy() end
        end
    end
    return best,bestSource
end
local function augmentNativeStaffFX(api,manager,prepared,source,definition,prepare,current)
    if #prepared.effects>0 or not definition.preferEffects then return prepared end
    local function norm(value) return tostring(value):lower():gsub("[^%w]","") end
    local aliases={}
    for _,name in ipairs(definition.exact) do aliases[name]=true end
    local function exactPacket(item)
        local name=norm(item.Name)
        for _,suffix in ipairs({"effects","effect","vfx","fx"}) do
            if name:sub(-#suffix)==suffix then name=name:sub(1,-#suffix-1); break end
        end
        if aliases[name] then return true end
        local ok,value=pcall(function() return item:GetAttribute("WeaponName") end)
        return ok and aliases[norm(value)]==true
    end
    local function fx(item)
        return item:IsA("ParticleEmitter") or item:IsA("Trail") or item:IsA("Beam") or item:IsA("Light")
            or item:IsA("Fire") or item:IsA("Smoke") or item:IsA("Sparkles")
    end
    local function allowed(item) return fx(item) or item:IsA("Attachment") or item:IsA("Bone") or item:IsA("Folder") end
    local packets=manager.companionCache
    if not packets then
        packets={}
        local queue,head={},1
        local queued={}
        local function addRoot(item)
            if item and not queued[item] then queued[item]=true; queue[#queue+1]=item end
        end
        local storage=api.ReplicatedStorage
        local gear=storage:FindFirstChild("GearTools")
        addRoot(gear and gear:FindFirstChild("ShopItems"))
        for _,name in ipairs({"VFX","FX","Effects","VisualEffects","WeaponEffects"}) do addRoot(storage:FindFirstChild(name)) end
        addRoot(storage)
        local clock=api.clock or os.clock; local start=clock()
        while head<=#queue and head<=24000 and clock()-start<2 do
            if not current() then return prepared end
            local item=queue[head]; head+=1
            if item~=source and not item:IsDescendantOf(source) and exactPacket(item) then
                local descendants=item:GetDescendants()
                if #descendants<=1024 then
                    for _,child in ipairs(descendants) do if fx(child) then packets[#packets+1]=item; break end end
                end
                if #packets>=8 then break end
            end
            for _,child in ipairs(item:GetChildren()) do addRoot(child) end
            if head%180==0 then api.task.wait() end
        end
        manager.companionCache=packets
        manager.staffFXReport="packets="..#packets.."; inspected="..(head-1).."; truncated="..tostring(head<=#queue)
    end
    for _,packet in ipairs(packets) do
        if not current() then return prepared end
        local proxy
        local ok,result=pcall(function()
            proxy=source:Clone()
            if not proxy then return nil end
            local parts,counts={},{}
            for _,part in ipairs(proxy:GetDescendants()) do
                if part:IsA("BasePart") then
                    counts[part.Name]=(counts[part.Name] or 0)+1
                    parts[part.Name]=counts[part.Name]==1 and part or false
                end
            end
            local map,added={},{}
            local function pair(original,copy)
                map[original]=copy
                local buckets={}
                for _,child in ipairs(copy:GetChildren()) do
                    local key=child.ClassName.."/"..child.Name
                    buckets[key]=buckets[key] or {}; table.insert(buckets[key],child)
                end
                for _,child in ipairs(original:GetChildren()) do
                    local list=buckets[child.ClassName.."/"..child.Name]
                    if list and #list>0 then pair(child,table.remove(list,1)) end
                end
            end
            local function copyNode(node,target)
                if not allowed(node) then return end
                local copy=node:Clone(); if not copy then return end
                pair(node,copy); copy.Parent=target; added[#added+1]=copy
                for _,child in ipairs(copy:GetDescendants()) do if not allowed(child) then child:Destroy() end end
            end
            local nodes={packet}
            for _,item in ipairs(packet:GetDescendants()) do nodes[#nodes+1]=item end
            for _,node in ipairs(nodes) do
                if not map[node] then
                    local okTarget,targetName=pcall(function() return node:GetAttribute("TargetPart") end)
                    local target=okTarget and type(targetName)=="string" and parts[targetName] or nil
                    if not target and (node:IsA("BasePart") or node:IsA("Folder")) then target=parts[node.Name] end
                    if target then
                        if node:IsA("BasePart") or node:IsA("Folder") then
                            map[node]=target
                            for _,child in ipairs(node:GetChildren()) do copyNode(child,target) end
                        else copyNode(node,target) end
                    end
                end
            end
            local copiedFX=0
            for original,copy in pairs(map) do
                if fx(original) and copy.Parent then
                    if copy:IsA("Beam") or copy:IsA("Trail") then
                        copy.Attachment0,copy.Attachment1=map[original.Attachment0],map[original.Attachment1]
                        if not copy.Attachment0 or not copy.Attachment1 then copy:Destroy() end
                    end
                    if copy.Parent then copiedFX+=1 end
                end
            end
            if copiedFX==0 then return nil end
            local rebuilt=prepare(proxy,definition.id)
            if #rebuilt.effects==0 then rebuilt.model:Destroy(); return nil end
            rebuilt.sourcePath,rebuilt.sourceName=prepared.sourcePath,prepared.sourceName
            rebuilt.fxSourcePath=packet:GetFullName()
            return rebuilt
        end)
        if proxy then proxy:Destroy() end
        if ok and result then
            if not current() then result.model:Destroy(); return prepared end
            prepared.model:Destroy()
            manager.staffFXReport=(manager.staffFXReport or "").."; bound="..result.fxSourcePath
            return result
        end
    end
    return prepared
end
local function addScrambleSwordFX(api, prepared, source)
    if not prepared or not source or not source:IsA("Tool") or prepared.sourceName~="Scramble Sword"
        or #prepared.effects>0 then return prepared end

    local blade
    local blades={}
    local handle=prepared.model:FindFirstChild("Handle")
    local origin=handle and handle.CFrame.Position
    for _,entry in ipairs(prepared.parts) do
        local part=entry.part
        if part.Name:match("^Plane%.") then
            local distance=origin and (part.CFrame.Position-origin).Magnitude or 0
            blades[#blades+1]={part=part,distance=distance}
        end
    end
    table.sort(blades,function(a,b) return a.distance<b.distance end)
    blade=blades[#blades] and blades[#blades].part
    blade=blade or handle
    if not blade then return prepared end
    if #blades==0 then blades[1]={part=blade,distance=0} end

    local glow=api.Instance.new("PointLight")
    glow.Name="ScrambleBladeGlow"
    glow.Color=api.Color3.fromRGB(52,255,166)
    glow.Brightness=.35
    glow.Range=2.5
    glow.Shadows=false
    glow.Enabled=false
    glow.Parent=blade
    local aura
    local selected={}
    local count=#blades
    for _,index in ipairs({math.max(1,math.floor(count*.45)),math.max(1,math.floor(count*.72)),count}) do
        local part=blades[index] and blades[index].part
        if part and not selected[part] then
            selected[part]=true
            local anchor=api.Instance.new("Attachment")
            anchor.Name="ScrambleFlameAnchor"
            anchor.CFrame=api.CFrame.new()
            anchor.Parent=part
            local fire=api.Instance.new("Fire")
            fire.Name=aura and "ScrambleBladeFlame" or "ScrambleBladeAura"
            fire.Color=api.Color3.fromRGB(49,218,75)
            fire.SecondaryColor=api.Color3.fromRGB(29,226,174)
            fire.Size=2
            fire.Heat=.6
            fire.TimeScale=.65
            fire.Enabled=false
            fire.Parent=anchor
            aura=aura or fire
            prepared.effects[#prepared.effects+1]={clone=fire,enabled=true,delay=0,duration=.2}
        end
    end
    local size=blade.Size
    local half=math.max(size.X,size.Y,size.Z)*.42
    local lower=api.Instance.new("Attachment")
    lower.Name="ScrambleEdgeStart"
    local upper=api.Instance.new("Attachment")
    upper.Name="ScrambleEdgeEnd"
    if size.X>=size.Y and size.X>=size.Z then
        lower.CFrame=api.CFrame.new(-half,0,0); upper.CFrame=api.CFrame.new(half,0,0)
    elseif size.Z>=size.Y then
        lower.CFrame=api.CFrame.new(0,0,-half); upper.CFrame=api.CFrame.new(0,0,half)
    else
        lower.CFrame=api.CFrame.new(0,-half,0); upper.CFrame=api.CFrame.new(0,half,0)
    end
    lower.Parent=blade; upper.Parent=blade
    local trail=api.Instance.new("Trail")
    trail.Name="ScrambleEnergySwipe"
    trail.Attachment0,trail.Attachment1=lower,upper
    trail.Color=api.ColorSequence.new(api.Color3.fromRGB(112,255,67),api.Color3.fromRGB(18,189,156))
    trail.Transparency=api.NumberSequence.new({
        api.NumberSequenceKeypoint.new(0,.28),
        api.NumberSequenceKeypoint.new(1,1)})
    trail.WidthScale=api.NumberSequence.new({
        api.NumberSequenceKeypoint.new(0,.8),
        api.NumberSequenceKeypoint.new(1,0)})
    trail.Lifetime=.16
    trail.MinLength=.04
    trail.LightEmission=.8
    trail.FaceCamera=true
    trail.Enabled=false
    trail.Parent=blade

    prepared.effects[#prepared.effects+1]={clone=glow,enabled=true,delay=0,duration=.2}
    prepared.effects[#prepared.effects+1]={clone=trail,enabled=true,delay=0,duration=.2}
    prepared.customEffect="Scramble Sword / blade energy + swipe"
    return prepared
end

    function manager:Prepare(mode, token)
        if mode=="wood" then
            local roots={api.player.Character,getBackpack()}
            for _,root in ipairs(roots) do if root then for _,item in ipairs(root:GetChildren()) do
                if item:IsA("Tool") and not isFood(item) and isWeapon(item) then return prepareTemplate(item,mode) end
            end end end
            return nil
        end
        local cached=self.cache[mode]
        if cached and cached.Parent and not byId[mode].preferEffects then
            local ok,result=pcall(function() return prepareTemplate(cached,mode) end)
            if ok then return addScrambleSwordFX(api,result,cached) end
            self.cache[mode]=nil
        end
        local candidates=self.catalog and self.catalog[mode]
        if not candidates or #candidates==0 then candidates=self:Scan(mode,token) end
        if not candidates then return nil end
        local result,source=chooseNativePrefab(mode,candidates,byId[mode],prepareTemplate,
            function() return self.alive and self.generation==token end)
        if source then self.cache[mode]=source end
        if result and byId[mode].preferEffects then
            result=augmentNativeStaffFX(api,self,result,source,byId[mode],prepareTemplate,
                function() return self.alive and self.generation==token end)
        end
        if result then result=addScrambleSwordFX(api,result,source) end
        return result
    end
    function manager:LoadPreviews(callback)
        if not self.alive then return end
        self.previewEpoch=(self.previewEpoch or 0)+1
        local token=self.previewEpoch
        api.task.spawn(function()
            local ok=pcall(function()
                if not self.catalog then self:Scan(nil,nil) end
                for _,definition in ipairs(definitions) do
                    if not self.alive or self.previewEpoch~=token then return end
                    local prepared
                    if definition.id=="wood" then local success,result=pcall(function() return self:Prepare("wood",token) end); if success then prepared=result end end
                    if definition.id~="wood" then
                        local source
                        prepared,source=chooseNativePrefab(definition.id,self.catalog and self.catalog[definition.id] or {},definition,prepareTemplate,
                            function() return self.alive and self.previewEpoch==token end)
                        if source then self.cache[definition.id]=source end
                        if prepared and definition.preferEffects then
                            prepared=augmentNativeStaffFX(api,self,prepared,source,definition,prepareTemplate,
                                function() return self.alive and self.previewEpoch==token end)
                        end
                    end
                    local success,problem=pcall(callback,definition.id,prepared)
                    if prepared then prepared.model:Destroy() end
                    if not success then error(problem) end
                end
            end)
            if not ok and self.alive and self.previewEpoch==token then notify("Chưa tải được ảnh xem trước") end
        end)
    end
    function manager:Inspect()
        if not self.alive then return end
        self.generation+=1; self.pendingToken=nil; selection(false)
        local token=self.generation
        notify("Đang quét model gốc đã tải...")
        api.task.spawn(function()
            local ok,problem=pcall(function() self:Scan(nil,token,true) end)
            if not self.alive or self.generation~=token then return end
            if not ok then notify("Quét mẫu lỗi: "..tostring(problem):sub(1,55)); return end
            for _,definition in ipairs(definitions) do
                local list=self.catalog and self.catalog[definition.id]
                if list and list[1] then
                    local icon,provenance=findIcon(list[1].item,definition.id)
                    if icon then self.lastReport=(self.lastReport or "").."\n2D icon, NOT a 3D model | "..definition.name.." | Image="..icon.." | "..provenance end
                end
            end
            local chosen=self.prepared
            if chosen then
                self.lastReport=(self.lastReport or "").."\nSelected="..chosen.sourcePath.."; FX="..#chosen.effects
                    .."; IconSource="..tostring(chosen.iconSource).."; Icon="..tostring(chosen.icon)
            end
            self.lastReport=(self.lastReport or "").."\nHotbar="..self:HotbarDiagnostics()
                .."\nStaffCompanionFX="..tostring(self.staffFXReport or "not searched")
            local iconLines={}
            for _,root in ipairs({api.playerGui,api.ReplicatedStorage}) do
                local queue,head={root},1
                while head<=#queue and head<=12000 and #iconLines<90 do
                    local item=queue[head]; head+=1
                    if item:IsA("ImageLabel") or item:IsA("ImageButton") then
                        local location=path(item)
                        local lower=location:lower()
                        if not lower:find("thtitemvisualizer",1,true)
                            and (lower:find("weapon",1,true) or lower:find("katana",1,true)
                                or lower:find("staff",1,true) or lower:find("axe",1,true)
                                or lower:find("cherry",1,true) or lower:find("titan",1,true)
                                or lower:find("heaven",1,true) or lower:find("hell",1,true)) then
                            iconLines[#iconLines+1]=location.." | Image="..tostring(item.Image)
                                .." | Rect="..tostring(item.ImageRectOffset).."/"..tostring(item.ImageRectSize)
                        end
                    end
                    for _,child in ipairs(item:GetChildren()) do queue[#queue+1]=child end
                end
            end
            self.lastReport=self.lastReport.."\nIndexIconCandidates="..#iconLines.."\n"..table.concat(iconLines,"\n")
            if api.onReport then api.onReport(self.lastReport or "Không có dữ liệu model vũ khí") end
            notify("Đã quét mẫu / có thể copy báo cáo")
        end)
    end
    function manager:Disable()
        self.generation+=1; self.pendingToken=nil
        self:ClearIcon()
        self:Unmount()
        for _,connection in ipairs(self.characterConnections) do connection:Disconnect() end
        self.characterConnections={}
        if self.prepared then self.prepared.model:Destroy(); self.prepared=nil end
        self.mode=nil; selection(false)
    end
    function manager:RefreshAvatarDisplay()
        if self.mode and self.mode~="wood" then
            self:ReorderRender()
            return
        end
        local character=api.player.Character
        local scale
        if character and api.getVisualHandOffset then
            local _,displayScale=api.getVisualHandOffset(character)
            scale=displayScale
        end
        if not scale or scale>=.85 then
            if self.mode=="wood" then self:Disable() end
            return
        end
        if self.mode=="wood" and self.prepared then return end
        local source
        for _,root in ipairs({character,getBackpack()}) do
            if root then for _,item in ipairs(root:GetChildren()) do
                if item:IsA("Tool") and not isFood(item) and isWeapon(item) then source=item; break end
            end end
            if source then break end
        end
        if not source then return end
        local ok,prepared=pcall(prepareTemplate,source,"wood")
        if not ok or not prepared then return end
        self:Disable()
        self.prepared,self.mode,self.toolName=prepared,"wood",source.Name
        self:WatchCharacter()
        selection(false)
    end
    function manager:SetMode(mode)
        if not self.alive then return end
        if mode==nil or mode=="wood" then self:Disable(); if mode=="wood" then self:RefreshAvatarDisplay() end; notify("Đã trả lại hình gậy gốc"); return end
        if not names[mode] then return end
        self.generation+=1
        local token=self.generation
        self.pendingToken=token
        self.iconCache={}
        if api.onSelection then api.onSelection(mode,true) end
        notify("Đang tìm "..names[mode].." trong dữ liệu game...")
        api.task.delay(4,function()
            if not self.alive or self.pendingToken~=token or self.generation~=token then return end
            self.generation+=1; self.pendingToken=nil; selection(false)
            notify("Tìm mẫu hết thời gian / bấm Quét mẫu gốc")
        end)
        api.task.spawn(function()
            local ok,result=pcall(function() return self:Prepare(mode,token) end)
            if not self.alive or self.generation~=token then
                if ok and result then result.model:Destroy() end
                return
            end
            self.pendingToken=nil
            if not ok or not result then
                selection(false)
                notify(ok and "Chưa có model gốc / bấm Quét mẫu gốc"
                    or "Tìm vũ khí lỗi: "..tostring(result):gsub("^.-:%d+:%s*",""):sub(1,55))
                return
            end
            local previous,previousMode=self.prepared,self.mode
            local installed,problem=pcall(function()
                self:Unmount()
                self.prepared,self.mode=result,mode
                self:WatchCharacter()
                self:MountCurrent(true)
            end)
            if not installed then
                pcall(function() self:Unmount() end)
                result.model:Destroy()
                self.prepared,self.mode=previous,previousMode
                if previous then pcall(function() self:WatchCharacter(); self:MountCurrent(true) end) end
                selection(false)
                notify("Gắn vũ khí lỗi: "..tostring(problem):gsub("^.-:%d+:%s*",""):sub(1,55))
                return
            end
            if previous then previous.model:Destroy() end
            selection(false)
            local iconStatus=result.modelIcon and ((self.hotbarMatched or 0)>0 and (result.fallbackOutline and " / icon viền đen từ model gốc" or " / icon model") or " / chưa gắn icon; Quét mẫu game") or result.icon and " / icon gốc" or " / chưa có icon gốc"
            local fxStatus=byId[mode].preferEffects and #result.effects==0 and " / chưa thấy FX gốc; Quét mẫu game" or " / FX "..#result.effects
            notify(names[mode]..fxStatus..iconStatus..(self.handle and "" or " / cầm gậy để hiện"))
            self.lastReport=(self.lastReport or "").."\nSelected="..result.sourcePath
                .."\nEffects="..#result.effects.."; Icon="..tostring(result.icon).."; IconSource="..tostring(result.iconSource)
        end)
    end
    function manager:Destroy()
        if not self.alive then return end
        self.alive=false; self:Disable()
        if self.respawn then self.respawn:Disconnect() end
        if self.assetConnection then self.assetConnection:Disconnect() end
    end
    manager.assetConnection=listen(api.ReplicatedStorage.DescendantAdded,function(item)
        if item:IsA("Tool") or item:IsA("Model") or item:IsA("BasePart") or item:IsA("Folder") or item:IsA("ParticleEmitter") or item:IsA("Beam") or item:IsA("Trail") then manager.catalog=nil; manager.companionCache=nil end
    end)
    manager.respawn=listen(api.player.CharacterAdded,function() manager:WatchCharacter() end)
    return manager
end
local function createPartialLegDisplay(api)
    local display={}
    local rank={LowerTorso=0,RightUpperLeg=1,LeftUpperLeg=1,RightLowerLeg=2,LeftLowerLeg=2,RightFoot=3,LeftFoot=3}
    local function binding(joint)
        local a,b,c0,c1
        if joint:IsA("Motor6D") then
            a,b,c0,c1=joint.Part0,joint.Part1,joint.C0,joint.C1
        elseif joint:IsA("AnimationConstraint") then
            local first,second=joint.Attachment0,joint.Attachment1
            if first and second then a,b,c0,c1=first.Parent,second.Parent,first.CFrame,second.CFrame
            else
                pcall(function() a,b,c0,c1=joint.Part0,joint.Part1,joint.C0,joint.C1 end)
            end
        end
        if not a or not b or not c0 or not c1 then return nil end
        local reverse=(rank[a.Name] or 0)>(rank[b.Name] or 0)
        return {joint=joint,child=reverse and a or b,parent=reverse and b or a,
            c0=reverse and c1 or c0,c1=reverse and c0 or c1,reverse=reverse}
    end
    function display:Restore(snapshot)
        local view=snapshot and snapshot.partialLegs
        if not view then return end
        snapshot.partialLegs=nil
        if view.connection then view.connection:Disconnect() end
        view.model:Destroy()
        for _,entry in ipairs(view.saved) do pcall(function() entry.part.Transparency=entry.value end) end
    end
    function display:Apply(source,snapshot,data)
        if data.useBody or snapshot.humanoid.RigType~=api.Enum.HumanoidRigType.R15 then return end
        local sourceHumanoid=source:FindFirstChildOfClass("Humanoid")
        if not sourceHumanoid or sourceHumanoid.RigType~=api.Enum.HumanoidRigType.R15 then return end
        local selected={}
        for _,side in ipairs({"Left","Right"}) do
            if (data[side.."Leg"] or 0)>0 then
                for _,suffix in ipairs({"UpperLeg","LowerLeg","Foot"}) do selected[side..suffix]=true end
            end
        end
        if not next(selected) then return end
        local joints,realJoints={},{}
        for _,joint in ipairs(source:GetDescendants()) do
            local link=binding(joint)
            if link then joints[link.child.Name]=link end
        end
        for _,joint in ipairs(snapshot.character:GetDescendants()) do
            local link=binding(joint)
            if link then realJoints[link.child.Name]=link end
        end
        local model=api.Instance.new("Model"); model.Name="NativePartialLegs"
        local view={model=model,saved={},parts={}}
        snapshot.partialLegs=view
        local ok,problem=pcall(function()
            for name in pairs(selected) do
                local native=source:FindFirstChild(name)
                local real=snapshot.character:FindFirstChild(name)
                if native and real and native:IsA("BasePart") and real:IsA("BasePart") then
                    local clone=native:Clone(); clone.Parent=model
                    for _,child in ipairs(clone:GetDescendants()) do
                        if not (child:IsA("DataModelMesh") or child:IsA("SurfaceAppearance")
                            or child:IsA("Decal") or child:IsA("Texture") or child:IsA("Bone")
                            or child:IsA("Attachment")) then child:Destroy() end
                    end
                    clone.Anchored=true; clone.Massless=true; clone.LocalTransparencyModifier=0
                    clone.CanCollide,clone.CanTouch,clone.CanQuery=false,false,false
                    local joint=joints[name]
                    view.parts[name]={clone=clone,real=real,joint=joint,
                        driver=realJoints[name],c0=joint and joint.c0,c1=joint and joint.c1,
                        parent=joint and joint.parent.Name}
                end
            end
            if not next(view.parts) then self:Restore(snapshot); return end
            local order={"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
            local function sync()
                local camera=api.Workspace.CurrentCamera
                if camera and model.Parent~=camera then model.Parent=camera end
                for _,name in ipairs(order) do
                    local part=view.parts[name]
                    if part then
                        local parent=view.parts[part.parent]
                        parent=parent and parent.clone or snapshot.character:FindFirstChild(part.parent or "")
                        if parent and part.c0 and part.c1 then
                            local transform=part.driver and part.driver.joint.Transform or api.CFrame.new()
                            if part.driver and part.driver.reverse then transform=transform:Inverse() end
                            part.clone.CFrame=parent.CFrame*part.c0*transform*part.c1:Inverse()
                        else part.clone.CFrame=part.real.CFrame end
                    end
                end
            end
            sync()
            for _,part in pairs(view.parts) do
                view.saved[#view.saved+1]={part=part.real,value=part.real.Transparency}
                part.real.Transparency=1
            end
            view.connection=api.RunService.RenderStepped:Connect(function()
                local success,err=pcall(sync)
                if not success then self:Restore(snapshot); if api.onFailure then api.onFailure(err) end end
            end)
        end)
        if not ok then self:Restore(snapshot); error(problem) end
    end
    return display
end
local function createWeaponPickerUI(api)
    local picker={rows={},alive=true}
    local C,U=api.Color3,api.UDim2
    local frame=api.Instance.new("Frame"); frame.Name="WeaponPicker"
    frame.BackgroundTransparency=1; frame.BorderSizePixel=0
    frame.Size=U.fromOffset(340,356); frame.Position=U.fromOffset(0,0)
    frame.ZIndex=api.host.ZIndex+1; frame.Parent=api.host
    api.makeText(frame,"VŨ KHÍ",10,0,190,19,10,C.fromRGB(165,147,255))
    local accent=api.Instance.new("Frame"); accent.Size=U.fromOffset(3,12); accent.Position=U.fromOffset(0,3)
    accent.BackgroundColor3=C.fromRGB(115,86,255); accent.BorderSizePixel=0; accent.ZIndex=frame.ZIndex+1; accent.Parent=frame
    local search=api.Instance.new("TextBox"); search.Name="WeaponSearch"
    search.PlaceholderText="Tìm vũ khí…"; search.Text=""; search.ClearTextOnFocus=false
    search.Font=api.Enum.Font.Gotham; search.TextSize=12; search.TextColor3=C.fromRGB(241,241,250)
    search.PlaceholderColor3=C.fromRGB(152,156,180); search.BackgroundColor3=C.fromRGB(30,33,45)
    search.BorderSizePixel=0; search.Position=U.fromOffset(0,28); search.Size=U.fromOffset(340,34)
    search.ZIndex=frame.ZIndex+1; search.Parent=frame; api.corner(search,7)
    local searchBorder=api.Instance.new("UIStroke"); searchBorder.Color=C.fromRGB(66,66,89); searchBorder.Thickness=1; searchBorder.Parent=search
    local list=api.Instance.new("ScrollingFrame"); list.Name="Weapons"
    list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=3
    list.ScrollBarImageColor3=C.fromRGB(124,103,199)
    list.Position=U.fromOffset(0,72); list.Size=U.fromOffset(340,254)
    list.CanvasSize=U.fromOffset(0,0); list.ZIndex=frame.ZIndex+1; list.Parent=frame
    local count=api.makeText(frame,"Đang đọc vũ khí đã tải…",0,335,340,19,10,C.fromRGB(152,156,180))
    function picker:Filter()
        local query=search.Text:lower(); local n=0
        for _,definition in ipairs(api.manager:GetDefinitions()) do
            local row=self.rows[definition.id]
            if row then
                row.frame.Visible=(definition.name.." "..definition.detail.." "..definition.id):lower():find(query,1,true)~=nil
                if row.frame.Visible then row.frame.Position=U.fromOffset(0,n*62); n+=1 end
            end
        end
        list.CanvasSize=U.fromOffset(0,n*62)
        local loaded=0
        for _,row in pairs(self.rows) do if row.available then loaded+=1 end end
        count.Text=loaded.." mẫu đã tải  •  "..n.." mục hiển thị"
    end
    function picker:SyncRows()
        for _,definition in ipairs(api.manager:GetDefinitions()) do
            if not self.rows[definition.id] then
                local card=api.Instance.new("Frame"); card.Name=definition.id
                card.Size=U.fromOffset(332,56); card.BackgroundColor3=C.fromRGB(39,42,57)
                card.BorderSizePixel=0; card.ZIndex=list.ZIndex+1; card.Parent=list; api.corner(card,7)
                local border=api.Instance.new("UIStroke"); border.Color=C.fromRGB(64,65,87); border.Thickness=1; border.Transparency=.35; border.Parent=card
                local icon=api.Instance.new("Frame"); icon.BackgroundColor3=C.fromRGB(27,29,40)
                icon.Position=U.fromOffset(5,5); icon.Size=U.fromOffset(46,46); icon.ZIndex=card.ZIndex+1; icon.Parent=card; api.corner(icon,6)
                local placeholder=api.makeText(icon,"…",13,11,25,24,15,C.fromRGB(152,156,180))
                api.makeText(card,definition.name,61,7,178,21,12,C.fromRGB(241,241,250))
                local detail=api.makeText(card,definition.detail,61,30,178,18,10,C.fromRGB(152,156,180))
                local select=api.makeButton(card,"SELECT",244,15,80,27,C.fromRGB(115,86,255)); select.Name="Select_"..definition.id; select.TextSize=10
                self.rows[definition.id]={frame=card,icon=icon,placeholder=placeholder,detail=detail,button=select,border=border}
                api.on(select.MouseButton1Click,function() search:ReleaseFocus(false); api.manager:SetMode(definition.id) end)
            end
        end
        self:Filter()
    end
    function picker:SetSelected(mode,busy)
        for id,row in pairs(self.rows) do
            local selected=id==(mode or "wood")
            row.button.Text=selected and (busy and "TẢI…" or "ĐÃ CHỌN") or "SELECT"
            row.button.BackgroundColor3=selected and C.fromRGB(46,192,115) or C.fromRGB(115,86,255)
            row.frame.BackgroundColor3=selected and C.fromRGB(51,49,76) or C.fromRGB(39,42,57)
            row.border.Color=selected and C.fromRGB(144,118,255) or C.fromRGB(64,65,87)
            row.border.Transparency=selected and 0 or .35
        end
    end
    function picker:Open()
        if not self.alive then return end
        if api.showPage then api.showPage("weapons") end
        self:SyncRows(); self:SetSelected(api.manager.mode,false); frame.Visible=true
        if self.previewsLoaded and self.previewCatalog==api.manager.catalog then return end
        api.manager:LoadPreviews(function(id,prepared)
            if not self.alive then return end
            self:SyncRows()
            local row=self.rows[id]
            if not row then return end
            if row.preview then row.preview:Destroy(); row.preview=nil end
            row.available=prepared~=nil; row.placeholder.Visible=not prepared
            if prepared then
                local ok,view=pcall(function()
                    if prepared.icon and prepared.iconRect then
                        local image=api.Instance.new("ImageLabel")
                        image.Name="NativeWeaponPreview"
                        image.BackgroundTransparency=1; image.BorderSizePixel=0
                        image.Size=U.fromScale(1,1); image.ZIndex=row.icon.ZIndex+1
                        image.Image=prepared.icon
                        image.ImageRectOffset=prepared.iconRect.offset
                        image.ImageRectSize=prepared.iconRect.size
                        image.ScaleType=api.Enum.ScaleType.Fit
                        image.Parent=row.icon
                        return image
                    end
                    return api.renderThumbnail(prepared,row.icon)
                end)
                if ok and view then row.preview=view; row.placeholder.Visible=false
                else row.placeholder.Visible=true; row.placeholder.Text="?" end
            else row.placeholder.Text="?" end
            self:Filter()
            local definitions=api.manager:GetDefinitions()
            if id==definitions[#definitions].id then self.previewsLoaded=true; self.previewCatalog=api.manager.catalog end
        end)
    end
    function picker:Destroy() self.alive=false; frame:Destroy() end
    api.on(search:GetPropertyChangedSignal("Text"),function() picker:Filter() end)
    picker:SyncRows()
    return picker
end

local restoreAppearance
local bodyDisplay = createV8BodyDisplay({Instance = Instance, CFrame = CFrame, Enum = Enum,
    Workspace = game:GetService("Workspace"),
    RunService = RunService,
    getCloneMotion = function() return state.CloneMotion end,
    isPackActive = function() return state.adidasActive == true end,
    createR6Driver = function(model, humanoid, character, current)
        return createR6Locomotion({Instance=Instance, Enum=Enum, task=task, clock=os.clock,
            getCloneMotion=function() return state.CloneMotion end,
            isAdidasActive=function() return state.adidasActive == true end,
            onStatus=setStatus}, model, humanoid, character, current)
    end,
    onFailure = function(snapshot, problem)
        if state.originalAppearance == snapshot then state.originalAppearance = nil end
        pcall(function() restoreAppearance(snapshot) end)
        warn("[V8 Body] " .. tostring(problem))
        setStatus("Hiển thị thân lỗi; đã khôi phục")
    end,
})
local roomBodyDisplay = createRoomBodyDisplay({Instance = Instance, CFrame = CFrame, Enum = Enum,
    Workspace = game:GetService("Workspace"),
    RunService = RunService,
    getCloneMotion = function() return state.CloneMotion end,
    isPackActive = function() return state.adidasActive == true end,
    createR6Driver = function(model, humanoid, character, current)
        return createRoomR6Locomotion({Instance=Instance, Enum=Enum, task=task, clock=os.clock,
            getCloneMotion=function() return state.CloneMotion end,
            isAdidasActive=function() return state.adidasActive == true end,
            onStatus=setStatus}, model, humanoid, character, current)
    end,
    onFailure = function(snapshot, problem)
        if state.originalAppearance == snapshot then state.originalAppearance = nil end
        pcall(function() restoreAppearance(snapshot) end)
        warn("[V8 Body] " .. tostring(problem))
        setStatus("Hiển thị thân lỗi; đã khôi phục")
    end,
})
state.CreateCloneClipDriver = function(model, source, rig, current)
    return createCloneClipDriver({Instance=Instance, Enum=Enum, Workspace=game:GetService("Workspace"),
        task=task, clock=os.clock}, model, resolveCloneClips(source, nil, rig), current)
end
local moonbloom = createMoonbloomNative({Instance=Instance, player=localPlayer, playerGui=playerGui, Players=Players, task=task, clock=os.clock, Workspace=game:GetService("Workspace"), RunService=RunService,
    ReplicatedStorage=game:GetService("ReplicatedStorage"), Vector3=Vector3,
    Color3=Color3, ColorSequence=ColorSequence, NumberSequence=NumberSequence,
    NumberSequenceKeypoint=NumberSequenceKeypoint, NumberRange=NumberRange,
    onStatus=setStatus, onToggle=function(enabled)
        if enabled then settings.moon=true; persistSettings() end
        moonButton.Text = enabled and "Moonbloom Trail: BẬT" or "Moonbloom Trail: TẮT"
        moonButton.BackgroundColor3 = enabled and Color3.fromRGB(57,161,112) or Color3.fromRGB(69,58,94)
    end})
state.SetMoonbloomCloneRoot = function(root)
    moonbloom:SetCloneRoot(root)
end
local weaponReportFrame,weaponReportBox
local function showWeaponReport(report)
    if not weaponReportFrame then
        weaponReportFrame=Instance.new("Frame")
        weaponReportFrame.Name="WeaponAssetReport"
        weaponReportFrame.Size=UDim2.fromOffset(520,420)
        weaponReportFrame.Position=UDim2.new(.5,-260,.5,-210)
        weaponReportFrame.BackgroundColor3=Color3.fromRGB(22,18,34)
        weaponReportFrame.BorderSizePixel=0
        weaponReportFrame.ZIndex=100
        weaponReportFrame.Parent=ui
        corner(weaponReportFrame,10)
        makeText(weaponReportFrame,"Vũ khí và Moonbloom đã tải / Steal an Egg",14,10,450,25,14,Color3.fromRGB(255,255,255))
        local dismiss=makeButton(weaponReportFrame,"X",476,8,30,28,Color3.fromRGB(69,58,94))
        local copy=makeButton(weaponReportFrame,"Copy báo cáo",14,373,492,33,Color3.fromRGB(114,65,208))
        weaponReportBox=Instance.new("TextBox")
        weaponReportBox.Size=UDim2.fromOffset(492,322)
        weaponReportBox.Position=UDim2.fromOffset(14,42)
        weaponReportBox.BackgroundColor3=Color3.fromRGB(35,30,50)
        weaponReportBox.TextColor3=Color3.fromRGB(235,230,245)
        weaponReportBox.TextSize=11
        weaponReportBox.Font=Enum.Font.Code
        weaponReportBox.MultiLine=true
        weaponReportBox.TextEditable=false
        weaponReportBox.ClearTextOnFocus=false
        weaponReportBox.TextXAlignment=Enum.TextXAlignment.Left
        weaponReportBox.TextYAlignment=Enum.TextYAlignment.Top
        weaponReportBox.TextWrapped=true
        weaponReportBox.ZIndex=101
        weaponReportBox.Parent=weaponReportFrame
        on(dismiss.MouseButton1Click,function() weaponReportFrame.Visible=false end)
        on(copy.MouseButton1Click,function()
            local copier=type(setclipboard)=="function" and setclipboard
            local ok=copier and pcall(function() copier(weaponReportBox.Text) end)
            if ok then setStatus("Đã copy báo cáo mẫu vũ khí")
            else
                weaponReportBox:CaptureFocus()
                weaponReportBox.SelectionStart=1
                weaponReportBox.CursorPosition=#weaponReportBox.Text+1
                setStatus("Nhấn Ctrl+C để copy báo cáo")
            end
        end)
    end
    weaponReportBox.Text=report
    weaponReportFrame.Visible=true
end
local partialLegDisplay=createPartialLegDisplay({Instance=Instance,CFrame=CFrame,Enum=Enum,
    Workspace=game:GetService("Workspace"),RunService=RunService,
    onFailure=function(problem) warn("[Native Leg] "..tostring(problem)); setStatus("Chân hiển thị lỗi; đã khôi phục") end})
local weaponPicker
local function drawWeaponThumbnail(prepared,parent,options)
    return renderWeaponThumbnail({Instance=Instance,UDim2=UDim2,Color3=Color3,CFrame=CFrame,Vector3=Vector3},prepared,parent,options)
end
local function visualWeaponHandOffset(api,snapshot,character)
    local body=snapshot and snapshot.character==character and snapshot.bodyDisplay
    local model=body and body.model
    if not model or not model.Parent then return nil end
    local shown=model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
    local real=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if not shown or not real or not shown:IsA("BasePart") or not real:IsA("BasePart") then return nil end
    local function gripFrame(part)
        local attachment=part:FindFirstChild("RightGripAttachment")
        if attachment then return part.CFrame*attachment.CFrame end
        if part.Name=="Right Arm" then return part.CFrame*api.CFrame.new(0,-part.Size.Y*.42,0) end
        return part.CFrame
    end
    local shownGrip,realGrip=gripFrame(shown),gripFrame(real)
    local cached=body.weaponHandScale
    if cached and cached.shown==shown and cached.real==real then
        return shownGrip.Position-realGrip.Position,cached.scale,shownGrip,realGrip,body
    end
    local scale=1
    if shown.Name==real.Name and real.Size.Magnitude>.05 then
        scale=math.min(scale,shown.Size.Magnitude/real.Size.Magnitude)
    end
    local visualHead=model:FindFirstChild("Head")
    local realHead=character:FindFirstChild("Head")
    local visualRoot=model:FindFirstChild("HumanoidRootPart")
    local realRoot=character:FindFirstChild("HumanoidRootPart")
    local humanoid=snapshot.humanoid
    if visualHead and realHead and visualRoot and realRoot and humanoid and body.floorDistance then
        local driverDistance=humanoid.HipHeight+realRoot.Size.Y/2
        if humanoid.RigType==api.Enum.HumanoidRigType.R6 then
            local leg=character:FindFirstChild("Left Leg")
            driverDistance+=leg and leg.Size.Y or 2
        end
        local visualHeight=visualHead.CFrame.Position.Y+visualHead.Size.Y/2
            -(visualRoot.CFrame.Position.Y-body.floorDistance)
        local realHeight=realHead.CFrame.Position.Y+realHead.Size.Y/2
            -(realRoot.CFrame.Position.Y-driverDistance)
        if visualHeight>0 and realHeight>.1 then scale=math.min(scale,visualHeight/realHeight) end
    end
    scale=scale<.85 and math.clamp(scale,.45,.84) or 1
    body.weaponHandScale={shown=shown,real=real,scale=scale}
    return shownGrip.Position-realGrip.Position,scale,shownGrip,realGrip,body
end

local handAnchorApi={CFrame=CFrame,Enum=Enum}
local function currentVisualWeaponHandOffset(character)
    return visualWeaponHandOffset(handAnchorApi,state.originalAppearance,character)
end
local weaponVisual = createWeaponPickerLocal({Instance=Instance, CFrame=CFrame, Vector3=Vector3,
    Color3=Color3, ColorSequence=ColorSequence, NumberSequence=NumberSequence,
    NumberSequenceKeypoint=NumberSequenceKeypoint, NumberRange=NumberRange, Vector2=Vector2,
    getVisualHandOffset=currentVisualWeaponHandOffset, Enum=Enum, player=localPlayer, playerGui=playerGui,
    Workspace=game:GetService("Workspace"), ReplicatedStorage=game:GetService("ReplicatedStorage"),
    RunService=RunService, task=task, clock=os.clock, Players=Players, placeId=game.PlaceId, onStatus=setStatus, onReport=showWeaponReport,
    getCoreGui=function() return game:GetService("CoreGui") end,
    renderThumbnail=drawWeaponThumbnail, overlayRoot=ui, UDim2=UDim2,
    onSelection=function(mode,busy)
        if weaponPicker then weaponPicker:SetSelected(mode,busy) end
        weaponPickerButton.Text=busy and "Đang tải vũ khí…" or "Chọn vũ khí…"
        if not busy and mode and mode~="wood" and not state.restoringWeapon then
            settings.weapon=mode; persistSettings()
        elseif not busy and state.restoringWeapon then state.restoringWeapon=false end
    end})
weaponPicker=createWeaponPickerUI({Instance=Instance,UDim2=UDim2,Color3=Color3,Enum=Enum,
    ui=ui,host=weaponPage,showPage=showMenuPage,on=on,corner=corner,makeText=makeText,makeButton=makeButton,
    renderThumbnail=drawWeaponThumbnail,manager=weaponVisual})
openWeaponPicker=function() weaponPicker:Open() end
local extras = createV8Additions({
    Instance = Instance, CFrame = CFrame, Enum = Enum, player = localPlayer,
    RunService = RunService, task = task, clock = os.clock,
    getCloneMotion = function() return state.CloneMotion end,
    getObjects = function(id) return game:GetObjects(id) end,
    isActive = function() return state.alive end,
    onStatus = setStatus,
    onToggle = function(enabled, busy, active, pending)
        state.adidasActive = enabled
        if enabled and not busy and active then settings.pack=active; persistSettings() end
        for key, button in pairs({community=adidasButton, aura=auraButton}) do
            local name = key == "community" and "Community" or "Aura"
            local selected = enabled and active == key
            button.Text = "adidas " .. name .. ": " .. (busy and pending == key and "ĐANG TẢI" or selected and "BẬT" or "TẮT")
            button.BackgroundColor3 = selected and Color3.fromRGB(57,161,112) or Color3.fromRGB(69,58,94)
        end
    end,
})
local scaleFields = {
    "HeightScale", "WidthScale", "DepthScale", "HeadScale",
    "BodyTypeScale", "ProportionScale",
}
local animationFields = {
    "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation",
    "FallAnimation", "ClimbAnimation", "SwimAnimation", "MoodAnimation",
}

local function isCosmetic(item)
    return item:IsA("Accoutrement") or item:IsA("Shirt") or item:IsA("Pants")
        or item:IsA("ShirtGraphic") or item:IsA("BodyColors")
        or item:IsA("CharacterMesh")
end

local function keepOriginal(snapshot, item)
    snapshot.originals[#snapshot.originals + 1] = {item, item.Parent}
    item.Parent = snapshot.stash
end

local function addCosmetic(snapshot, item, parent)
    item.Parent = parent
    snapshot.added[#snapshot.added + 1] = item
end

restoreAppearance = function(snapshot)
    if not snapshot then return end
    partialLegDisplay:Restore(snapshot)
    bodyDisplay:Restore(snapshot)
    if snapshot.originalDescription then
        local original = snapshot.originalDescription
        snapshot.originalDescription = nil
        if snapshot.humanoid.Parent == snapshot.character then
            local ok, problem = pcall(function()
                snapshot.humanoid:ApplyDescriptionResetAsync(original)
            end)
            if not ok then warn("[Gift Player V8] Restore description: " .. tostring(problem)) end
        end
        original:Destroy()
    end
    for _, item in ipairs(snapshot.added) do
        item:Destroy()
    end
    for _, entry in ipairs(snapshot.originals) do
        local item, originalParent = entry[1], entry[2]
        if originalParent and originalParent.Parent then item.Parent = originalParent end
    end
    if snapshot.humanoid.Parent then
        snapshot.humanoid.DisplayName = snapshot.displayName
    end
    extras:RestoreFace(snapshot)
    snapshot.stash:Destroy()
end

local function makeSnapshot(character, humanoid)
    return {
        character = character, humanoid = humanoid,
        displayName = humanoid.DisplayName,
        stash = Instance.new("Folder"),
        originals = {}, added = {},
    }
end

local function findMatchingAttachment(character, handle)
    for _, accessoryAttachment in ipairs(handle:GetChildren()) do
        if accessoryAttachment:IsA("Attachment") then
            for _, bodyPart in ipairs(character:GetChildren()) do
                if bodyPart:IsA("BasePart") then
                    local bodyAttachment = bodyPart:FindFirstChild(accessoryAttachment.Name)
                    if bodyAttachment and bodyAttachment:IsA("Attachment") then
                        return bodyPart, accessoryAttachment.CFrame, bodyAttachment.CFrame
                    end
                end
            end
        end
    end
    return nil
end

local function cloneAccessory(source, sourceModel, character)
    local sourceHandle = source:FindFirstChild("Handle")
    if not sourceHandle or not sourceHandle:IsA("BasePart") then return nil end
    local clone = source:Clone()
    local handle = clone:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then clone:Destroy(); return nil end

    local sourceWeld = sourceHandle:FindFirstChild("AccessoryWeld")
    local realPart, c0, c1
    if sourceWeld and sourceWeld:IsA("Weld") and sourceWeld.Part1 then
        realPart = character:FindFirstChild(sourceWeld.Part1.Name)
        c0, c1 = sourceWeld.C0, sourceWeld.C1
    end
    if not realPart then
        realPart, c0, c1 = findMatchingAttachment(character, handle)
    end
    if not realPart then
        local sourceHead = sourceModel:FindFirstChild("Head")
        realPart = character:FindFirstChild("Head")
        if sourceHead and realPart and realPart:IsA("BasePart") then
            c0 = CFrame.new()
            c1 = sourceHead.CFrame:ToObjectSpace(sourceHandle.CFrame)
        end
    end
    if not realPart or not realPart:IsA("BasePart") then
        clone:Destroy()
        return nil
    end

    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Massless = true
        elseif part:IsA("JointInstance") or part:IsA("WeldConstraint") then
            local p0, p1 = part.Part0, part.Part1
            if (p0 and not p0:IsDescendantOf(clone))
                or (p1 and not p1:IsDescendantOf(clone)) then
                part:Destroy()
            end
        end
    end
    handle.CFrame = realPart.CFrame * c1 * c0:Inverse()
    local weld = Instance.new("Weld")
    weld.Name = "GiftPlayerVisualWeld"
    weld.Part0 = handle
    weld.Part1 = realPart
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = handle
    return clone
end

local function applyCosmetics(sourceModel, snapshot, username, faceHead, targetData)
    local character = snapshot.character
    local humanoid = snapshot.humanoid
    if targetData.usePhysicalDescription then
        -- Same-rig R15 outfits belong on the existing moving Humanoid. This
        -- keeps the target's body proportions and clothing without a second
        -- full-size body chasing the player's root every render frame.
        local sourceHumanoid = sourceModel:FindFirstChildOfClass("Humanoid")
        if not sourceHumanoid then error("Avatar nguồn thiếu Humanoid") end
        local target = sourceHumanoid:GetAppliedDescription()
        local okOriginal, original = pcall(function() return humanoid:GetAppliedDescription() end)
        if not okOriginal or not original then
            target:Destroy()
            error("Không lưu được ngoại hình cũ: " .. tostring(original))
        end
        snapshot.originalDescription = original
        local ok, problem = pcall(function()
            target.UseAvatarSettings = false
            for _, field in ipairs(animationFields) do
                target[field] = snapshot.originalDescription[field]
            end
            humanoid:ApplyDescriptionResetAsync(target)
        end)
        target:Destroy()
        if not ok then error(problem) end
        humanoid.DisplayName = username
        return
    end
    local head = character:FindFirstChild("Head")
    local sourceHead = faceHead or sourceModel:FindFirstChild("Head")
    for _, item in ipairs(character:GetChildren()) do
        if isCosmetic(item) then keepOriginal(snapshot, item) end
    end
    if head then
        for _, item in ipairs(head:GetChildren()) do
            if item:IsA("Decal") and item.Name:lower() == "face" then
                keepOriginal(snapshot, item)
            end
        end
    end

    if targetData.useBody then
        -- Generated descriptions use the stable visual rig; only an actual room character
        -- needs the live-renderer path.
        local display = targetData.fromLive and roomBodyDisplay or bodyDisplay
        display:Apply(sourceModel, snapshot, targetData)
        humanoid.DisplayName = username
        return
    end
    for _, item in ipairs(sourceModel:GetChildren()) do
        if isCosmetic(item) then
            local clone
            if item:IsA("Accoutrement") then
                clone = cloneAccessory(item, sourceModel, character)
            else
                clone = item:Clone()
            end
            if clone then addCosmetic(snapshot, clone, character) end
        end
    end
    extras:ApplyFace(snapshot, sourceHead, head, targetData)
    partialLegDisplay:Apply(sourceModel,snapshot,targetData)
    humanoid.DisplayName = username
end

local function setError(stage, problem)
    local message = tostring(problem)
    warn("[Gift Player V8] " .. stage .. ": " .. message)
    setStatus(stage .. ": " .. message:sub(1, 65))
end

local function restoreNow()
    weaponVisual:Disable()
    moonbloom:Disable()
    usernameBox:ReleaseFocus(false)
    extras:Disable()
    state.avatarToken = state.avatarToken + 1
    local snapshot = state.originalAppearance
    state.originalAppearance = nil
    if snapshot then
        local ok, problem = pcall(function() restoreAppearance(snapshot) end)
        if not ok then setError("Khôi phục lỗi", problem); return end
    end
    refreshDeveloperReal()
    settings.avatar=""; settings.weapon=""; settings.pack=""; settings.moon=false
    persistSettings()
    setStatus(snapshot and "Đã khôi phục avatar" or "Đã hủy Apply")
end

local function cloneRoomAvatar(userId)
    local target = Players:GetPlayerByUserId(userId)
    local source = target and target ~= localPlayer and target.Character
    local h = source and source:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 or not source:FindFirstChild("Head")
        or not source:FindFirstChild("HumanoidRootPart") then return nil end
    local originalArchivable = source.Archivable
    local ok,model = pcall(function() source.Archivable=true; return source:Clone() end)
    pcall(function() source.Archivable=originalArchivable end)
    if not ok then return nil end
    if not model or not model:FindFirstChildOfClass("Humanoid") or not model:FindFirstChild("Head") then
        if model then model:Destroy() end
        return nil
    end
    return model,{useBody=true,fromLive=true}
end

local function applyAvatar(rawUsername)
    usernameBox:ReleaseFocus(false)
    local username = rawUsername:match("^%s*(.-)%s*$"):gsub("^@", "")
    if username == "" then setStatus("Nhập username Roblox trước"); return end
    if state.avatarBusy then setStatus("Đang tải avatar, chờ một chút"); return end
    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        setStatus("Chờ nhân vật xuất hiện rồi thử lại")
        return
    end

    state.avatarToken = state.avatarToken + 1
    local token = state.avatarToken
    state.avatarBusy = true
    setStatus("Đang tải avatar @" .. username .. "...")
    task.spawn(function()
        local function current()
            return state.alive and token == state.avatarToken
                and localPlayer.Character == character and humanoid.Parent == character
        end
        local okId, userId = pcall(function() return Players:GetUserIdFromNameAsync(username) end)
        if not current() then state.avatarBusy = false; return end
        if not okId or not userId then
            state.avatarBusy = false
            setError("Username lỗi", userId)
            return
        end
        local okInfo, info = pcall(function()
            return Players:GetCharacterAppearanceInfoAsync(userId)
        end)
        if not current() then state.avatarBusy = false; return end
        local accountRig = okInfo and type(info) == "table" and info.playerAvatarType
        local okRoom,roomModel,roomData = pcall(function() return cloneRoomAvatar(userId) end)
        if not current() then
            if okRoom and roomModel then roomModel:Destroy() end
            state.avatarBusy=false; return
        end
        if okRoom and roomModel and (accountRig == "R6" or accountRig == "R15") then
            local roomHumanoid = roomModel:FindFirstChildOfClass("Humanoid")
            if not roomHumanoid or roomHumanoid.RigType.Name ~= accountRig then
                roomModel:Destroy()
                roomModel, roomData = nil, nil
            end
        end
        local okModel,model,targetData,faceModel
        if okRoom and roomModel then
            okModel,model,targetData = true,roomModel,roomData
        else
        local okDesc, description = pcall(function()
            return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
        end)
        if not current() then
            if okDesc and description then description:Destroy() end
            state.avatarBusy = false; return
        end
        if not okDesc or not description then
            state.avatarBusy = false
            setError("Tải avatar lỗi", description)
            return
        end
        targetData = {}
        for _, field in ipairs({"Head", "Face", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
            "Shirt", "Pants", "GraphicTShirt", "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor",
            "LeftLegColor", "RightLegColor", "WalkAnimation", "RunAnimation",
            "JumpAnimation", "FallAnimation"}) do
            targetData[field] = description[field]
        end
        local nativeBody = bodyDisplay:CanUse(targetData)
        local hasAccountRig = accountRig == "R6" or accountRig == "R15"
        targetData.sourceRig = hasAccountRig and accountRig or humanoid.RigType.Name
        targetData.forceFullRig = hasAccountRig
            and accountRig ~= humanoid.RigType.Name and not nativeBody
        -- Same-rig R15 clothing can be applied to the actual local Humanoid,
        -- preserving the target's dimensions while game movement stays native.
        targetData.usePhysicalDescription = not nativeBody and not targetData.forceFullRig
            and targetData.sourceRig == "R15" and humanoid.RigType == Enum.HumanoidRigType.R15
        targetData.useBody = nativeBody or targetData.forceFullRig
        local modelRig = targetData.sourceRig == "R15" and Enum.HumanoidRigType.R15
            or Enum.HumanoidRigType.R6
        pcall(function() description.UseAvatarSettings = false end)
        if not targetData.useBody and not targetData.usePhysicalDescription then
            local okOriginal, original = pcall(function() return humanoid:GetAppliedDescription() end)
            if okOriginal and original then
                local okScale, scaleError = pcall(function()
                    for _, field in ipairs(scaleFields) do
                        description[field] = original[field]
                    end
                end)
                if not okScale then warn("[Gift Player V8] Scale: " .. tostring(scaleError)) end
                original:Destroy()
            end
        end
        okModel, model = pcall(function()
            return Players:CreateHumanoidModelFromDescriptionAsync(description, modelRig)
        end)
        if okModel and model and current() and not targetData.useBody and description.Head > 0
            and humanoid.RigType == Enum.HumanoidRigType.R6 then
            local okFace, loadedFace = pcall(function()
                return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
            end)
            if okFace then faceModel = loadedFace end
        end
        description:Destroy()
        if not current() then
            if faceModel then faceModel:Destroy() end
            if okModel and model then model:Destroy() end
            state.avatarBusy = false
            return
        end
        if not okModel or not model then
            state.avatarBusy = false
            setError("Tạo avatar lỗi", model)
            return
        end
        if targetData.forceFullRig then
            local generated = model:FindFirstChildOfClass("Humanoid")
            if not generated or generated.RigType.Name ~= targetData.sourceRig
                or not model:FindFirstChild("HumanoidRootPart") then
                model:Destroy()
                state.avatarBusy = false
                setError("Rig avatar lỗi", "Roblox chưa tạo đúng bộ khớp " .. targetData.sourceRig)
                return
            end
        end
        end
        if state.originalAppearance then
            local old = state.originalAppearance
            state.originalAppearance = nil
            local okRestore, problem = pcall(function() restoreAppearance(old) end)
            if not okRestore then
                if faceModel then faceModel:Destroy() end
                model:Destroy()
                state.avatarBusy = false
                setError("Khôi phục cũ lỗi", problem)
                return
            end
        end
        local snapshot = makeSnapshot(character, humanoid)
        state.originalAppearance = snapshot
        local okApply, problem = pcall(function()
            applyCosmetics(model, snapshot, username, faceModel and faceModel:FindFirstChild("Head"), targetData)
        end)
        if faceModel then faceModel:Destroy() end
        model:Destroy()
        if not okApply then
            state.originalAppearance = nil
            pcall(function() restoreAppearance(snapshot) end)
            state.avatarBusy = false
            refreshDeveloperReal()
            setError("Apply lỗi", problem)
            return
        end
        state.avatarBusy = false
        weaponVisual:RefreshAvatarDisplay()
        refreshDeveloperReal()
        settings.username=username; settings.avatar=username; persistSettings()
        if snapshot.bodyDisplay then
            setStatus("@" .. username .. " / hiển thị " .. snapshot.bodyDisplay.rig .. " / game " .. humanoid.RigType.Name)
            return
        end
        if snapshot.originalDescription then
            setStatus("@" .. username .. " / body R15 trên nhân vật thật / local")
            return
        end
        local gameRig = humanoid.RigType.Name
        setStatus("@" .. username .. " / rig game " .. gameRig .. " / local")
        local statusSerial = state.statusSerial
        task.spawn(function()
            local okInfo, info = pcall(function()
                return Players:GetCharacterAppearanceInfoAsync(userId)
            end)
            if not current() or state.originalAppearance ~= snapshot
                or state.statusSerial ~= statusSerial then return end
            local sourceRig = okInfo and type(info) == "table" and info.playerAvatarType
            if sourceRig == "R6" or sourceRig == "R15" then
                if sourceRig == gameRig then
                    setStatus("@" .. username .. " / mỹ phẩm V8 / game " .. gameRig)
                else
                    setStatus("@" .. username .. " gốc " .. sourceRig .. ", game " .. gameRig)
                end
            end
        end)
    end)
end

on(localPlayer.CharacterAdded, function(character)
    developerNameplate:Detach("real")
    moonbloom:Disable()
    extras:Disable()
    state.avatarToken = state.avatarToken + 1
    local snapshot = state.originalAppearance
    state.originalAppearance = nil
    if snapshot then pcall(function() restoreAppearance(snapshot) end) end
    setStatus("Nhân vật mới / nhập tên rồi Apply")
    task.spawn(function()
        character:WaitForChild("Head",5)
        if state.alive and localPlayer.Character==character then refreshDeveloperReal() end
    end)
end)

on(hideToggle.MouseButton1Click, function()
    state.hideRoom = not state.hideRoom
    settings.hideRoom=state.hideRoom; persistSettings()
    paintToggle()
    setRealListVisible(not state.hideRoom)
    setStatus(state.hideRoom and "Ẩn room; kết quả tìm kiếm vẫn hiện" or "Đã hiện người trong room")
end)
state.ApplyAvatar = function(rawUsername)
    usernameBox.Text = rawUsername
    applyAvatar(rawUsername)
end
on(applyButton.MouseButton1Click, function() applyAvatar(usernameBox.Text) end)
on(usernameBox.FocusLost, function(enterPressed)
    local username=usernameBox.Text:match("^%s*(.-)%s*$"):gsub("^@", "")
    if #username<=40 and username:match("^[%w_]*$") then
        settings.username=username; persistSettings()
    end
    if enterPressed then applyAvatar(usernameBox.Text) end
end)
on(restoreButton.MouseButton1Click, restoreNow)
local function choosePack(key)
    usernameBox:ReleaseFocus(false)
    if extras.enabled and extras.activePack == key or extras.pending and extras.pending.packKey == key then
        settings.pack=""; persistSettings()
        extras:Disable()
        setStatus("adidas tắt / R6 dùng chuyển động R6")
    else extras:Enable(key) end
end
on(adidasButton.MouseButton1Click, function() choosePack("community") end)
on(auraButton.MouseButton1Click, function() choosePack("aura") end)
on(moonButton.MouseButton1Click, function()
    usernameBox:ReleaseFocus(false)
    if moonbloom.enabled then
        settings.moon=false; persistSettings()
        moonbloom:Disable(); setStatus("Đã tắt Moonbloom local")
    else moonbloom:Enable() end
end)

on(scanWeaponButton.MouseButton1Click, function() usernameBox:ReleaseFocus(false); weaponVisual:Inspect() end)
on(weaponPickerButton.MouseButton1Click,function()
    usernameBox:ReleaseFocus(false); weaponPicker:Open()
end)
on(woodButton.MouseButton1Click, function()
    usernameBox:ReleaseFocus(false)
    settings.weapon=""; persistSettings()
    weaponVisual:SetMode(nil)
end)

function state.stop(keepGiftHidden)
    if not state.alive then return end
    if type(state.CloseClone)=="function" then pcall(state.CloseClone); state.CloseClone=nil end
    state.CloneMotion = nil
    state.alive = false
    restoreDefaultNames()
    developerNameplate:Destroy()
    weaponPicker:Destroy()
    weaponVisual:Destroy()
    moonbloom:Destroy()
    extras:Disable()
    usernameBox:ReleaseFocus(false)
    state.avatarToken = state.avatarToken + 1
    local snapshot = state.originalAppearance
    state.originalAppearance = nil
    if snapshot then pcall(function() restoreAppearance(snapshot) end) end
    if not keepGiftHidden then setRealListVisible(true) end
    for _, connection in ipairs(state.connections) do connection:Disconnect() end
    ui:Destroy()
    if env.__giftPlayerWeaponPicker == state then env.__giftPlayerWeaponPicker = nil end
end

on(closeButton.MouseButton1Click, function() state.stop(false) end)
task.delay(2,function()
    if not state.alive then return end
    if settings.pack~="" then extras:Enable(settings.pack) end
    if settings.moon then moonbloom:Enable() end
    if settings.weapon~="" then
        local known=false
        for _,definition in ipairs(weaponVisual:GetDefinitions()) do
            if definition.id==settings.weapon then known=true; break end
        end
        if known then
            state.restoringWeapon=true
            weaponVisual:SetMode(settings.weapon)
        else settings.weapon=""; persistSettings() end
    end
    if settings.avatar~="" then
        task.spawn(function()
            local character=localPlayer.Character or localPlayer.CharacterAdded:Wait()
            if character then character:WaitForChild("Humanoid",10) end
            if state.alive then applyAvatar(settings.avatar) end
        end)
    end
end)
end

-- Separate clone controller; all clone instances and camera changes stay local.
do
-- LocalScript (StarterPlayerScripts): the avatar copy exists only on this client.
-- They do not change the server character or fool other players/clients/scanners.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local env = type(getgenv) == "function" and getgenv() or _G
local integrationState = env.__giftPlayerWeaponPicker
local hostPage = type(integrationState) == "table" and integrationState.alive and integrationState.CloneHostPage or nil
local instanceKey = "ClientDecoyMarker_" .. player.UserId
local guiName = instanceKey .. "_Gui"
local folderName = instanceKey .. "_World"

-- A second run replaces only this script's previous UI, connections, and visuals.
local previousCleanup = env[instanceKey] or _G[instanceKey]
if type(previousCleanup) == "function" then
	pcall(previousCleanup)
end
if env ~= _G then _G[instanceKey] = nil end

local previousGui = playerGui:FindFirstChild(guiName)
if previousGui then
	previousGui:Destroy()
end
local previousFolder = Workspace:FindFirstChild(folderName)
if previousFolder then
	previousFolder:Destroy()
end

local folder = Instance.new("Folder")
folder.Name = folderName
folder.Parent = Workspace

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 1000
if not hostPage then gui.Parent = playerGui end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(306, 466)
panel.Position = UDim2.new(0.5, -180, 0, 90)
panel.BackgroundColor3 = Color3.fromRGB(25, 18, 43)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(119, 76, 176)
stroke.Thickness = 1.5
stroke.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local function makeLabel(name, order, height, text, color, size)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = size
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = panel
	return label
end

local header = Instance.new("Frame")
header.Name = "DragHeader"
header.LayoutOrder = 1
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundTransparency = 1
header.Active = true
header.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 1, 0)
title.BackgroundTransparency = 1
title.Text = "THT  /  BẢN SAO CỤC BỘ"
title.TextColor3 = Color3.fromRGB(236, 216, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = header

local collapseButton = Instance.new("TextButton")
collapseButton.Name = "Collapse"
collapseButton.Position = UDim2.new(1, -28, 0, 0)
collapseButton.Size = UDim2.fromOffset(28, 27)
collapseButton.BackgroundColor3 = Color3.fromRGB(74, 47, 107)
collapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collapseButton.Text = "−"
collapseButton.TextSize = 18
collapseButton.Font = Enum.Font.GothamBold
collapseButton.Parent = header
local status = makeLabel("Status", 2, 46, "CHỈ TRÊN MÁY BẠN  •  Chọn chỗ đặt bản sao.", Color3.fromRGB(210, 189, 231), 12)

local usernameBox = Instance.new("TextBox")
usernameBox.Name = "AvatarUsername"
usernameBox.LayoutOrder = 3
usernameBox.Size = UDim2.new(1, 0, 0, 32)
usernameBox.BackgroundColor3 = Color3.fromRGB(43, 32, 65)
usernameBox.BorderSizePixel = 0
usernameBox.ClearTextOnFocus = false
usernameBox.PlaceholderText = "Username Roblox để đổi avatar cục bộ"
usernameBox.Text = ""
usernameBox.TextColor3 = Color3.fromRGB(245, 247, 255)
usernameBox.PlaceholderColor3 = Color3.fromRGB(167, 149, 190)
usernameBox.TextSize = 12
usernameBox.Font = Enum.Font.Gotham
usernameBox.Parent = panel
local usernameCorner = Instance.new("UICorner")
usernameCorner.CornerRadius = UDim.new(0, 6)
usernameCorner.Parent = usernameBox
local visualizerAtStart = playerGui:FindFirstChild("THTItemVisualizer")
local previousAvatarBox = visualizerAtStart and visualizerAtStart:FindFirstChild("AvatarUsername", true)
if previousAvatarBox and previousAvatarBox:IsA("TextBox") then
	usernameBox.Text = previousAvatarBox.Text
end

local function makeButton(name, order, caption, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = caption
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.Font = Enum.Font.GothamMedium
	button.AutoButtonColor = true
	button.Parent = panel
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	return button
end

local applyAvatarButton = makeButton("ApplyAvatar", 4, "Áp dụng avatar theo username", Color3.fromRGB(116, 69, 177))
local placeButton = makeButton("Place", 5, "Đặt bản sao tại điểm chọn", Color3.fromRGB(83, 58, 139))
local refreshButton = makeButton("Refresh", 6, "Làm mới ngoại hình và gậy", Color3.fromRGB(73, 83, 139))
local viewButton = makeButton("View", 7, "Xem từ bản sao", Color3.fromRGB(80, 58, 124))
local controlButton = makeButton("Control", 8, "Điều khiển bản sao: TẮT", Color3.fromRGB(118, 65, 149))
local removeButton = makeButton("Remove", 9, "Xóa bản sao", Color3.fromRGB(95, 48, 87))
local closeButton = makeButton("Close", 10, "Đóng bảng và xóa", Color3.fromRGB(62, 50, 82))
local hint = makeLabel("Hint", 11, 25, "WASD / phím mũi tên + Space  •  Bản sao chỉ hiển thị cục bộ", Color3.fromRGB(158, 139, 178), 11)
if hostPage then
    panel.Parent = hostPage
    panel.Size = UDim2.fromOffset(340, 394)
    panel.Position = UDim2.fromOffset(0, 0)
    panel.BackgroundTransparency = 1
    stroke.Transparency = 1
    title.Text = "BẢN SAO CỤC BỘ"
    title.Size = UDim2.new(1, 0, 1, 0)
    collapseButton.Visible = false
    closeButton.Visible = false
    usernameBox.Visible = false
    applyAvatarButton.Visible = false
end

local connections = {}
local selectedPosition = nil
local clone = nil
local poseMirror = nil
local weaponMirror = nil
local legMirror = nil
local applyingUsername = false
local awaitingClick = false
local closed = false
local generation = 0
local viewingClone = false
local cameraBeforeClone = nil
local collapsed = false
local restoreAfterRespawn = false
local controllingClone = false
local controlKeys = {}
local verticalSpeed = 0
local grounded = true
local walkClock = 0
local moveAmount = 0
local displayedWalkSpeed = nil
local jumpRequested = false
local jumpRequestedAt = 0
local planarVelocity = Vector3.zero
local cameraFollow = nil
local controlAction = instanceKey .. "_Movement"
local controlRenderStep = instanceKey .. "_StopRealMovement"

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
end

local function setStatus(message)
	if not closed then
		status.Text = message
	end
end

local function cameraTarget()
	if not clone or not clone.Parent then return nil end
	if controllingClone and cameraFollow and cameraFollow.Parent then return cameraFollow end
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	if humanoid then return humanoid end
	local root = clone:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then return root end
	return clone:FindFirstChildWhichIsA("BasePart", true)
end

local function moveCameraNear(camera, targetPosition)
	local offset = camera.CFrame.Position - camera.Focus.Position
	if offset.Magnitude < 3 or offset.Magnitude > 100 then
		offset = Vector3.new(0, 5, 12)
	end
	local focus = targetPosition + Vector3.new(0, 1.5, 0)
	camera.CFrame = CFrame.lookAt(focus + offset, focus)
	camera.Focus = CFrame.new(focus)
end

local function focusClone()
	local camera = Workspace.CurrentCamera
	local target = cameraTarget()
	if not camera or not target then return false end
	local root = clone:FindFirstChild("HumanoidRootPart")
	local point = root and root:IsA("BasePart") and root.Position
		or clone:GetPivot().Position
	if not viewingClone then
		cameraBeforeClone = {subject = camera.CameraSubject, cameraType = camera.CameraType}
	end
	if not viewingClone then moveCameraNear(camera, point) end
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = target
	viewingClone = true
	viewButton.Text = "Về nhân vật thật"
	return true
end

local function restoreCamera()
	if not viewingClone then return end
	local camera = Workspace.CurrentCamera
	if camera then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local oldSubject = cameraBeforeClone and cameraBeforeClone.subject
		camera.CameraType = Enum.CameraType.Custom
		if humanoid then
			camera.CameraSubject = humanoid
		elseif oldSubject and oldSubject.Parent then
			camera.CameraSubject = oldSubject
		end
		if root and root:IsA("BasePart") then moveCameraNear(camera, root.Position) end
		if cameraBeforeClone then camera.CameraType = cameraBeforeClone.cameraType end
	end
	viewingClone = false
	cameraBeforeClone = nil
	viewButton.Text = "Xem từ bản sao"
end

local movementKeys = {
	Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
	Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right,
	Enum.KeyCode.Space,
}

local function stopControl()
    if type(integrationState) == "table" then integrationState.CloneMotion = nil end
	if poseMirror and poseMirror.cloneDriver then
		poseMirror.cloneDriver:Destroy()
		poseMirror.cloneDriver = nil
	end
	if not controllingClone then return end
	controllingClone = false
	ContextActionService:UnbindAction(controlAction)
	RunService:UnbindFromRenderStep(controlRenderStep)
	table.clear(controlKeys)
	verticalSpeed = 0
	moveAmount = 0
	displayedWalkSpeed = nil
	planarVelocity = Vector3.zero
	jumpRequested = false
	controlButton.Text = "Điều khiển bản sao: TẮT"
	controlButton.BackgroundColor3 = Color3.fromRGB(118, 65, 149)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.Jump = false
	end
	restoreCamera()
end

local function startControl()
	if not clone or not clone.Parent or not poseMirror then
		setStatus("Hãy đặt bản sao trước khi điều khiển.")
		return
	end
	if not focusClone() then
		setStatus("Chưa thể chuyển camera sang bản sao.")
		return
	end
	controllingClone = true
	table.clear(controlKeys)
	verticalSpeed = 0
	grounded = true
	planarVelocity = Vector3.zero
	if cameraFollow and poseMirror then cameraFollow.CFrame = poseMirror.anchor end
	jumpRequested = false
	controlButton.Text = "Điều khiển bản sao: BẬT"
	controlButton.BackgroundColor3 = Color3.fromRGB(155, 81, 194)
	ContextActionService:BindActionAtPriority(controlAction, function(_, inputState, input)
		if not controllingClone then return Enum.ContextActionResult.Pass end
		if UserInputService:GetFocusedTextBox() then
			table.clear(controlKeys)
			jumpRequested = false
			return Enum.ContextActionResult.Pass
		end
		if inputState == Enum.UserInputState.Begin then
			controlKeys[input.KeyCode] = true
			if input.KeyCode == Enum.KeyCode.Space and controlKeys[input.KeyCode] then
				jumpRequested = true
				jumpRequestedAt = os.clock()
			end
		elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			controlKeys[input.KeyCode] = nil
		end
		return Enum.ContextActionResult.Sink
	end, false, 10000, table.unpack(movementKeys))
	RunService:BindToRenderStep(controlRenderStep, Enum.RenderPriority.Character.Value + 1, function()
		if not controllingClone then return end
		local camera = Workspace.CurrentCamera
		local target = cameraTarget()
		if camera and target and camera.CameraSubject ~= target then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = target
		end
		local realHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if realHumanoid then
			realHumanoid:Move(Vector3.zero, false)
			realHumanoid.Jump = false
		end
	end)
	setStatus("Đang điều khiển bản sao cục bộ. Nhân vật thật giữ nguyên vị trí.")
end

local function updateCloneMovement(dt)
	if not controllingClone then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.Jump = false
	end
	local pose = poseMirror
	if not pose or not clone or not clone.Parent or character ~= pose.character then
		stopControl()
		return
	end
	if UserInputService:GetFocusedTextBox() then
		table.clear(controlKeys)
		jumpRequested = false
	end
	if jumpRequested and os.clock() - jumpRequestedAt > 0.18 then
		jumpRequested = false
	end
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	if forward.Magnitude < 0.01 then forward = Vector3.new(0, 0, -1) end
	forward = forward.Unit
	local right = Vector3.new(-forward.Z, 0, forward.X)
	local x = ((controlKeys[Enum.KeyCode.D] or controlKeys[Enum.KeyCode.Right]) and 1 or 0)
		- ((controlKeys[Enum.KeyCode.A] or controlKeys[Enum.KeyCode.Left]) and 1 or 0)
	local z = ((controlKeys[Enum.KeyCode.W] or controlKeys[Enum.KeyCode.Up]) and 1 or 0)
		- ((controlKeys[Enum.KeyCode.S] or controlKeys[Enum.KeyCode.Down]) and 1 or 0)
	local direction = forward * z + right * x
	if direction.Magnitude > 1 then direction = direction.Unit end
	-- Read the live Humanoid value every frame. Speed boosts and slowdowns can
	-- change while the clone is already being controlled.
	local speed = math.max(0, pose.humanoid.WalkSpeed)
	local roundedSpeed = math.floor(speed * 10 + 0.5) / 10
	if displayedWalkSpeed ~= roundedSpeed then
		displayedWalkSpeed = roundedSpeed
		controlButton.Text = ("Bản sao: BẬT  |  WalkSpeed %g"):format(roundedSpeed)
	end
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Exclude
	parameters.FilterDescendantsInstances = {folder, character}
	parameters.RespectCanCollide = true
	local simulatedDt = math.min(dt, 0.25)
	local remaining = simulatedDt
	local groundDistance = 0
	local stepHeight = math.clamp(pose.groundOffset * 0.55, 0.75, 1.35)
	local radius = math.clamp(pose.copyRoot.Size.X * 0.5, 0.7, 1.25)
	while remaining > 0 do
		local step = math.min(remaining, 1 / 60)
		remaining -= step
		local current = pose.anchor.Position
		local desired = direction * speed
		if speed <= 0 then
			planarVelocity = Vector3.zero
		else
			-- Keep the current velocity below a newly reduced WalkSpeed, then
			-- respond proportionally so high speed boosts do not take seconds.
			local currentSpeed = planarVelocity.Magnitude
			if currentSpeed > speed then planarVelocity = planarVelocity.Unit * speed end
			local response = direction.Magnitude > 0.05 and 30 or 35
			planarVelocity = planarVelocity:Lerp(desired, 1 - math.exp(-step * response))
		end
		local horizontal = planarVelocity * step
		local target = current + horizontal
		local function wallHit(from, displacement)
			if displacement.Magnitude < 0.001 then return nil end
			local heading = displacement.Unit
			local side = Vector3.new(-heading.Z, 0, heading.X) * (radius * 0.7)
			local distance = displacement.Magnitude + radius * 0.45
			for _, height in ipairs({-pose.groundOffset + 0.45, 0.15, 1.4}) do
				for _, lateral in ipairs({Vector3.zero, side, -side}) do
					local hit = Workspace:Raycast(from + lateral + Vector3.new(0, height, 0),
						heading * distance, parameters)
					if hit and hit.Normal.Y < 0.6 then return hit end
				end
			end
			return nil
		end
		local obstacle = wallHit(current, horizontal)
		if obstacle then
			local stepTop = Workspace:Raycast(current + horizontal + Vector3.new(0, stepHeight + 0.5, 0),
				Vector3.new(0, -(stepHeight + 1), 0), parameters)
			local canStep = grounded and stepTop and stepTop.Normal.Y >= 0.6
				and stepTop.Position.Y > current.Y - pose.groundOffset + 0.05
				and stepTop.Position.Y <= current.Y - pose.groundOffset + stepHeight
				and not Workspace:Raycast(current + Vector3.new(0, stepHeight + 0.35, 0),
					horizontal.Unit * (horizontal.Magnitude + radius * 0.45), parameters)
			local slide = horizontal - obstacle.Normal * horizontal:Dot(obstacle.Normal)
			if canStep then
				target = current + horizontal
			elseif slide:Dot(horizontal) > 0 and not wallHit(current, slide) then
				target = current + slide
				planarVelocity = slide / step
			else
				target = current
				planarVelocity = Vector3.zero
			end
		end
		local ground = Workspace:Raycast(target + Vector3.new(0, stepHeight + 1.5, 0),
			Vector3.new(0, -(pose.groundOffset + stepHeight + 8), 0), parameters)
		local groundY = ground and ground.Normal.Y >= 0.6 and ground.Position.Y + pose.groundOffset or nil
		if grounded and groundY and groundY > current.Y + stepHeight then
			target = current
			planarVelocity = Vector3.zero
			groundY = current.Y
		end
		if jumpRequested and grounded then
			local jumpPower = pose.humanoid.UseJumpPower and pose.humanoid.JumpPower
				or math.sqrt(2 * Workspace.Gravity * pose.humanoid.JumpHeight)
			verticalSpeed = math.max(26, jumpPower)
			pose.jumpUntil = os.clock() + 0.3
			grounded = false
			jumpRequested = false
		end
		if not grounded then
			verticalSpeed -= Workspace.Gravity * step
			local rise = verticalSpeed * step
			if rise > 0 then
				local ceiling = Workspace:Raycast(target + Vector3.new(0, 1.6, 0),
					Vector3.new(0, rise + 0.2, 0), parameters)
				if ceiling then rise = 0; verticalSpeed = 0 end
			end
			target += Vector3.new(0, rise, 0)
			if groundY and verticalSpeed <= 0 and target.Y <= groundY
				and current.Y >= groundY - stepHeight then
				target = Vector3.new(target.X, groundY, target.Z)
				verticalSpeed = 0
				grounded = true
				pose.jumpUntil = nil
			end
		elseif groundY and groundY >= current.Y - 0.55 then
			local heightAlpha = 1 - math.exp(-step * 22)
			local nextY = current.Y + (groundY - current.Y) * heightAlpha
			if math.abs(groundY - nextY) < 0.03 then nextY = groundY end
			target = Vector3.new(target.X, nextY, target.Z)
		else
			grounded = false
		end
		local rotation = pose.anchor.Rotation
		if planarVelocity.Magnitude > 0.8 then
			local facing = CFrame.lookAt(Vector3.zero, planarVelocity.Unit).Rotation
			rotation = rotation:Lerp(facing, 1 - math.exp(-step * 12))
		end
		if grounded then
			local moved = Vector3.new(target.X - current.X, 0, target.Z - current.Z)
			groundDistance += moved.Magnitude
		end
		pose.anchor = CFrame.new(target) * rotation
	end
	local groundLevel = grounded and pose.anchor.Position.Y - pose.groundOffset
		or selectedPosition.Y
	selectedPosition = Vector3.new(pose.anchor.Position.X, groundLevel, pose.anchor.Position.Z)
	-- Drive the visual gait from distance actually covered, not requested
	-- velocity: walls and tight turns should not produce a sliding run cycle.
	local actualSpeed = simulatedDt > 0 and groundDistance / simulatedDt or 0
	local gait = grounded and speed > 0 and math.clamp(actualSpeed / speed, 0, 1) or 0
	moveAmount += (gait - moveAmount) * (1 - math.exp(-simulatedDt * 14))
	if grounded then walkClock += math.min(groundDistance * 0.55, simulatedDt * 27) end
	if type(integrationState) == "table" and integrationState.alive then
		local motion = integrationState.CloneMotion or {}
		motion.amount = moveAmount
		motion.phase = walkClock
		motion.grounded = grounded
		motion.airState = not grounded and ((pose.jumpUntil and
			(verticalSpeed > 0 or os.clock() < pose.jumpUntil)) and "jump" or "fall") or nil
		motion.verticalSpeed = verticalSpeed
		motion.speed = actualSpeed
		motion.holdingLimb = pose.holdingLimb
		integrationState.CloneMotion = motion
	end
	if cameraFollow then
		cameraFollow.CFrame = cameraFollow.CFrame:Lerp(pose.anchor,
			1 - math.exp(-dt * 12))
	end
end

local function clearWorld()
	generation += 1
	awaitingClick = false
	selectedPosition = nil
	if type(integrationState) == "table" and type(integrationState.SetDeveloperCloneModel) == "function" then
		integrationState.SetDeveloperCloneModel(nil)
	end
	if type(integrationState) == "table" and type(integrationState.SetMoonbloomCloneRoot) == "function" then
		integrationState.SetMoonbloomCloneRoot(nil)
	end
	stopControl()
	restoreCamera()
	if cameraFollow then cameraFollow:Destroy(); cameraFollow = nil end
	poseMirror = nil
	if weaponMirror and weaponMirror.copy then weaponMirror.copy:Destroy() end
	weaponMirror = nil
	if legMirror and legMirror.copy then legMirror.copy:Destroy() end
	legMirror = nil
	if clone then
		clone:Destroy()
		clone = nil
	end
end

local function cleanup()
	if closed then
		return
	end
	closed = true
	RunService:UnbindFromRenderStep(instanceKey .. "Render")
	clearWorld()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
	panel:Destroy()
	gui:Destroy()
	folder:Destroy()
	if integrationState and integrationState.CloseClone == cleanup then integrationState.CloseClone = nil end
	if env[instanceKey] == cleanup then
		env[instanceKey] = nil
	end
end

env[instanceKey] = cleanup
if hostPage then integrationState.CloseClone = cleanup end

local function pickGround(screenPosition)
	local camera = Workspace.CurrentCamera
	if not camera then
		error("Không tìm thấy camera.")
	end
	local character = player.Character
	local excluded = { folder }
	if character then
		table.insert(excluded, character)
	end
	local parameters = RaycastParams.new()
	parameters.FilterType = Enum.RaycastFilterType.Exclude
	parameters.FilterDescendantsInstances = excluded
	parameters.IgnoreWater = true

	local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	for _ = 1, 20 do
		local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, parameters)
		if not hit then return nil end
		local part = hit.Instance
		local broadSurface = part:IsA("Terrain")
			or part:IsA("BasePart") and math.min(part.Size.X, part.Size.Z) >= 2
		if hit.Normal.Y >= 0.6 and broadSurface then
			return hit.Position
		end
		table.insert(excluded, part)
		parameters.FilterDescendantsInstances = excluded
	end
	return nil
end

local function makeAvatarCopy(source)
    -- Character.Archivable is commonly false; restore its original value immediately.
    local wasArchivable = source.Archivable
	local copiedOk, result = pcall(function()
        source.Archivable = true
        return source:Clone()
	end)
    source.Archivable = wasArchivable
	if not copiedOk then
		error(result)
	end
	if not result then
		error("Không thể sao chép nhân vật.")
	end
	return result
end

local function prepareCopy(copy)
	copy.Name = "Ban_Sao_Cuc_Bo"
	for _, descendant in ipairs(copy:GetDescendants()) do
		if descendant:IsDescendantOf(copy) then
			if descendant:IsA("LuaSourceContainer")
				or descendant:IsA("RemoteEvent")
				or descendant:IsA("RemoteFunction")
				or descendant:IsA("Tool")
				or descendant:IsA("Sound")
				or descendant:IsA("ProximityPrompt")
				or descendant:IsA("ClickDetector")
				or descendant:IsA("BillboardGui") and descendant.Name == "LocalDeveloperNameplate" then
				descendant:Destroy()
			elseif descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
				local a, b = descendant.Part0, descendant.Part1
				if a and not a:IsDescendantOf(copy) or b and not b:IsDescendantOf(copy) then
					descendant:Destroy()
				end
			elseif descendant:IsA("Constraint") then
				local ok, a, b = pcall(function()
					return descendant.Attachment0, descendant.Attachment1
				end)
				if ok and (a and not a:IsDescendantOf(copy)
					or b and not b:IsDescendantOf(copy)) then descendant:Destroy() end
			elseif descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
				descendant.LocalTransparencyModifier = 0
			end
		end
	end
	local humanoid = copy:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.EvaluateStateMachine = false
		humanoid.AutomaticScalingEnabled = false
		humanoid.AutoRotate = false
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then animator:Destroy() end
	end
end

local function limbForPart(part, depth)
	if not part or depth > 2 then return nil end
	local name = part.Name
	local side = name:find("Left", 1, true) and "Left"
		or name:find("Right", 1, true) and "Right" or nil
	if side then
		if name:find("Arm", 1, true) or name:find("Hand", 1, true) then return side .. "Arm" end
		if name:find("Leg", 1, true) or name:find("Foot", 1, true) then return side .. "Leg" end
	end
	-- Only accessory handles inherit a limb's swing through their weld.
	-- Traversing body joints here would incorrectly classify the torso as an arm.
	if not (part.Parent and part.Parent:IsA("Accoutrement")) then return nil end
	for _, joint in ipairs(part:GetDescendants()) do
		if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
			local other = joint.Part0 == part and joint.Part1 or joint.Part1 == part and joint.Part0
			if other and other ~= part then
				local attached = limbForPart(other, depth + 1)
				if attached then return attached end
			end
		end
	end
	return nil
end

local function matchParts(source, copy)
	local pairs = {}
	local function walk(original, duplicate)
		if original:IsA("BasePart") and duplicate:IsA("BasePart") then
			pairs[#pairs + 1] = {source = original, copy = duplicate,
				limb = limbForPart(original, 0)}
		end
		local buckets = {}
		for _, child in ipairs(duplicate:GetChildren()) do
			local key = child.ClassName .. "\0" .. child.Name
			local bucket = buckets[key]
			if not bucket then bucket = {}; buckets[key] = bucket end
			bucket[#bucket + 1] = child
		end
		local used = {}
		for _, child in ipairs(original:GetChildren()) do
			if child.Archivable then
				local key = child.ClassName .. "\0" .. child.Name
				used[key] = (used[key] or 0) + 1
				local bucket = buckets[key]
				local match = bucket and bucket[used[key]]
				if match then walk(child, match) end
			end
		end
	end
	walk(source, copy)
	return pairs
end

local function currentBodySource(character)
	local camera = Workspace.CurrentCamera
	local display = camera and camera:FindFirstChild("GiftPlayerV8BodyDisplay")
	if display and display:IsA("Model") and display:FindFirstChild("HumanoidRootPart") then
		return display
	end
	return character
end

local function appearanceItems(character)
	local items = {}
	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Accoutrement") or item:IsA("Shirt") or item:IsA("Pants")
			or item:IsA("ShirtGraphic") or item:IsA("BodyColors")
			or item:IsA("CharacterMesh") then items[item] = true end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, item in ipairs(head:GetChildren()) do
			if item:IsA("Decal") then items[item] = item.Texture end
		end
	end
	return items
end

local function appearanceChanged(pose)
	local current = appearanceItems(pose.character)
	for item, value in pairs(current) do if pose.appearance[item] ~= value then return true end end
	for item in pairs(pose.appearance) do if current[item] == nil then return true end end
	return false
end

local function appearanceSignature(source)
	local values = {}
	for _, item in ipairs(source:GetDescendants()) do
		if item:IsA("Shirt") then
			values[#values + 1] = "shirt:" .. item.ShirtTemplate
		elseif item:IsA("Pants") then
			values[#values + 1] = "pants:" .. item.PantsTemplate
		elseif item:IsA("ShirtGraphic") then
			values[#values + 1] = "graphic:" .. item.Graphic
		elseif item:IsA("Decal") or item:IsA("Texture") then
			values[#values + 1] = item.ClassName .. ":" .. item.Texture
		elseif item:IsA("MeshPart") then
			values[#values + 1] = "mesh:" .. item.MeshId .. ":" .. item.TextureID
		elseif item:IsA("SpecialMesh") then
			values[#values + 1] = "special:" .. item.MeshId .. ":" .. item.TextureId
		elseif item:IsA("BodyColors") then
			values[#values + 1] = "colors:" .. tostring(item.HeadColor3) .. tostring(item.TorsoColor3)
				.. tostring(item.LeftArmColor3) .. tostring(item.RightArmColor3)
				.. tostring(item.LeftLegColor3) .. tostring(item.RightLegColor3)
		elseif item:IsA("BasePart") then
			values[#values + 1] = item.Name .. ":" .. tostring(item.Color) .. ":" .. tostring(item.Size)
		end
	end
	return table.concat(values, "|")
end

local function equippedTool(character)
	if not character then return nil end
	for _, item in ipairs(character:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChildWhichIsA("BasePart", true) then return item end
	end
	return nil
end

local function currentWeaponSource(character)
	local tool = equippedTool(character)
	if not tool then return nil end
	local camera = Workspace.CurrentCamera
	local visual = camera and camera:FindFirstChild("LocalWeaponVisual")
	if visual and visual:IsA("Model") and visual:FindFirstChildWhichIsA("BasePart", true) then
		return visual
	end
	return tool
end

local function currentLegSource()
	local camera = Workspace.CurrentCamera
	local model = camera and camera:FindFirstChild("NativePartialLegs")
	return model and model:IsA("Model") and model or nil
end

local function clearWeaponMirror()
	if weaponMirror and weaponMirror.copy then weaponMirror.copy:Destroy() end
	weaponMirror = nil
end

local function updateWeaponMirror(source)
	if weaponMirror and weaponMirror.source == source and weaponMirror.copy.Parent then return end
	clearWeaponMirror()
	if not source or not clone or not clone.Parent then return end
	local copy = makeAvatarCopy(source)
	local pairs = matchParts(source, copy)
	prepareCopy(copy)
	copy.Name = "Vu_Khi_Ban_Sao"
	copy.Parent = folder
	weaponMirror = {source = source, copy = copy, pairs = pairs}
end

local function clearLegMirror()
	if legMirror and legMirror.copy then legMirror.copy:Destroy() end
	legMirror = nil
end

local function updateLegMirror(source)
	if legMirror and legMirror.source == source and legMirror.copy.Parent then return end
	clearLegMirror()
	if not source or not clone or not clone.Parent then return end
	local copy = makeAvatarCopy(source)
	local pairs = matchParts(source, copy)
	prepareCopy(copy)
	copy.Name = "Chan_Ban_Sao"
	copy.Parent = folder
	legMirror = {source = source, copy = copy, pairs = pairs}
end

local function limbOffsets(pose, anchor, sourceFrame)
	local offsets = {}
	if not controllingClone then return offsets end
	local torso = pose.source:FindFirstChild("UpperTorso") or pose.source:FindFirstChild("Torso")
	for _, limb in ipairs({"LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
		local arm = limb:find("Arm", 1, true) ~= nil
		local left = limb:find("Left", 1, true) ~= nil
		local angle
		if grounded then
			local swing = math.sin(walkClock + (left and 0 or math.pi))
			angle = swing * (arm and -0.38 or 0.55) * moveAmount
		else
			angle = arm and -0.25 or (left and -0.32 or 0.18)
		end
		if arm and limb == pose.holdingLimb then angle = 0 end
		local joint = pose.limbJoints[limb]
		local pivotFrame = joint and joint.Part0 and joint.Part0.Parent
			and joint.Part0.CFrame * joint.C0 or nil
		if not pivotFrame and torso and torso:IsA("BasePart") then
			local x = (left and -1 or 1) * torso.Size.X * (arm and 0.52 or 0.28)
			local y = torso.Size.Y * (arm and 0.35 or -0.46)
			pivotFrame = torso.CFrame * CFrame.new(x, y, 0)
		end
		if pivotFrame and math.abs(angle) > 0.001 then
			local pivot = anchor * sourceFrame:ToObjectSpace(pivotFrame)
			offsets[limb] = pivot * CFrame.Angles(angle, 0, 0) * pivot:Inverse()
		end
	end
	return offsets
end

local function posedFrame(pair, frame, pose)
	local offset = pair.limb and pose.limbOffsets[pair.limb]
	return offset and offset * frame or frame
end

local function buildCloneAnimationLinks(model, root)
	local links, remaining, known = {}, {}, {[root] = true}
	for _, joint in ipairs(model:GetDescendants()) do
		if joint:IsA("JointInstance") and joint.Part0 and joint.Part1
			and joint.Part0:IsDescendantOf(model) and joint.Part1:IsDescendantOf(model) then
			remaining[#remaining + 1] = joint
		end
	end
	while #remaining > 0 do
		local progressed = false
		for index = #remaining, 1, -1 do
			local joint = remaining[index]
			local a, b = joint.Part0, joint.Part1
			if known[a] or known[b] then
				if not known[a] or not known[b] then
					local forward = known[a] == true
					links[#links + 1] = {joint = joint, parent = forward and a or b,
						child = forward and b or a, forward = forward}
					known[forward and b or a] = true
				end
				table.remove(remaining, index)
				progressed = true
			end
		end
		if not progressed then break end
	end
	return links
end

local function syncClonePose()
	local pose = poseMirror
	if not pose or not clone or not clone.Parent then return end
	local sourceRoot, copyRoot = pose.sourceRoot, pose.copyRoot
	if not sourceRoot or not sourceRoot.Parent or not copyRoot or not copyRoot.Parent then return end
	local anchor
	if controllingClone then
		anchor = pose.anchor
	else
		local realRoot = pose.character:FindFirstChild("HumanoidRootPart")
		if realRoot and realRoot:IsA("BasePart")
			and pose.humanoid.FloorMaterial ~= Enum.Material.Air then
			pose.groundedY = realRoot.Position.Y
		end
		local rise = realRoot and pose.groundedY
			and math.clamp(realRoot.Position.Y - pose.groundedY, 0, 25) or 0
		local turn = pose.initialRotation:Inverse() * sourceRoot.CFrame.Rotation
		anchor = CFrame.new(pose.anchor.Position + Vector3.new(0, rise, 0))
			* pose.anchor.Rotation * turn
	end
	local sourceFrame = sourceRoot.CFrame
	local desiredWeapon = currentWeaponSource(pose.character)
	pose.holdingWeapon = desiredWeapon ~= nil
	pose.holdingLimb = pose.holdingWeapon and
		(pose.character:FindFirstChild("LeftGrip", true) and "LeftArm" or "RightArm") or nil
	local nativePlain = false
	local packPlain = controllingClone and pose.source.Name ~= "GiftPlayerV8BodyDisplay"
		and pose.humanoid.RigType == Enum.HumanoidRigType.R15
		and type(integrationState) == "table" and integrationState.adidasActive == true
	if controllingClone and pose.source.Name ~= "GiftPlayerV8BodyDisplay"
		and not packPlain
		and type(integrationState) == "table"
		and type(integrationState.CreateCloneClipDriver) == "function" then
		if not pose.cloneDriver then
			local rig = pose.humanoid.RigType.Name
			pose.cloneDriver = integrationState.CreateCloneClipDriver(clone, pose.source,
				rig, function() return poseMirror == pose and controllingClone end)
		end
		nativePlain = pose.cloneDriver:Step(integrationState.CloneMotion)
	elseif pose.cloneDriver then
		pose.cloneDriver:Destroy()
		pose.cloneDriver = nil
	end
	-- The display body already receives this same gait. Copy its live pose so the
	-- decoy and the stationary real avatar never get two different arm swings.
	pose.limbOffsets = (packPlain or nativePlain or pose.source.Name == "GiftPlayerV8BodyDisplay")
		and {} or limbOffsets(pose, anchor, sourceFrame)
	for _, pair in ipairs(pose.pairs) do
		if pair.source.Parent and pair.copy.Parent then
			local frame = anchor * sourceFrame:ToObjectSpace(pair.source.CFrame)
			pair.copy.CFrame = posedFrame(pair, frame, pose)
			pair.copy.Transparency = pair.source.Transparency
		end
	end
	if nativePlain then
		-- Rebuild the local clone's joint tree from its AnimationTrack. Copying
		-- source CFrames alone would erase every animated R6/R15 limb each frame.
		pose.copyRoot.CFrame = anchor
		for _, link in ipairs(pose.cloneLinks) do
			local joint = link.joint
			if link.parent.Parent and link.child.Parent then
				local transform = joint:IsA("Motor6D") and joint.Transform.Rotation or CFrame.new()
				if link.forward then
					link.child.CFrame = link.parent.CFrame * joint.C0 * transform * joint.C1:Inverse()
				else
					link.child.CFrame = link.parent.CFrame * joint.C1
						* transform:Inverse() * joint.C0:Inverse()
				end
			end
		end
	end
	local desiredLegs = currentLegSource()
	local mirroredLegs = legMirror and legMirror.source or nil
	if (mirroredLegs ~= desiredLegs or legMirror and not legMirror.copy.Parent)
		and (not pose.legRetryAt or os.clock() >= pose.legRetryAt) then
		local ok, problem = pcall(updateLegMirror, desiredLegs)
		if not ok then
			clearLegMirror()
			pose.legRetryAt = os.clock() + 0.5
			warn("[ClientDecoy] Legs copy: " .. tostring(problem))
		else
			pose.legRetryAt = nil
		end
	end
	if legMirror and legMirror.source.Parent then
		for _, pair in ipairs(legMirror.pairs) do
			if pair.source.Parent and pair.copy.Parent then
				local frame = anchor * sourceFrame:ToObjectSpace(pair.source.CFrame)
				pair.copy.CFrame = posedFrame(pair, frame, pose)
			end
		end
	end
	local mirroredWeapon = weaponMirror and weaponMirror.source or nil
	if (mirroredWeapon ~= desiredWeapon or weaponMirror and not weaponMirror.copy.Parent)
		and (not pose.weaponRetryAt or os.clock() >= pose.weaponRetryAt) then
		local ok, problem = pcall(updateWeaponMirror, desiredWeapon)
		if not ok then
			clearWeaponMirror()
			pose.weaponRetryAt = os.clock() + 0.5
			warn("[ClientDecoy] Weapon copy: " .. tostring(problem))
		else
			pose.weaponRetryAt = nil
		end
	end
	if weaponMirror and weaponMirror.source.Parent then
		for _, pair in ipairs(weaponMirror.pairs) do
			if pair.source.Parent and pair.copy.Parent then
				pair.copy.CFrame = anchor * sourceFrame:ToObjectSpace(pair.source.CFrame)
			end
		end
	end
end

local function createOrUpdateClone(autoView)
	if not selectedPosition then
		setStatus("Chọn chỗ đặt trước.")
		return false
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid or humanoid.Health <= 0 then
		setStatus("Chờ nhân vật xuất hiện rồi thử lại.")
		return false
	end

	local currentGeneration = generation
	local controlledAnchor = controllingClone and poseMirror and poseMirror.anchor or nil
	local controlledGroundOffset = controllingClone and poseMirror and poseMirror.groundOffset or nil
	local newCopy = nil
	local newPose = nil
	local ok, err = pcall(function()
		-- The separate visualizer can render a local body under CurrentCamera
		-- while making the real character's body transparent on this client.
		local source = currentBodySource(character)
		newCopy = makeAvatarCopy(source)
		local pairs = matchParts(source, newCopy)
		local limbJoints = {}
		for _, joint in ipairs(source:GetDescendants()) do
			if joint:IsA("Motor6D") and joint.Part0 and joint.Part1 then
				local part = joint.Part1
				local limb = limbForPart(part, 0)
				if limb and (part.Name:find("Upper", 1, true)
					or part.Name == "Left Arm" or part.Name == "Right Arm"
					or part.Name == "Left Leg" or part.Name == "Right Leg") then
					limbJoints[limb] = joint
				end
			end
		end
		prepareCopy(newCopy)

		local root = character:FindFirstChild("HumanoidRootPart")
		local sourceRoot = source:FindFirstChild("HumanoidRootPart")
		local copyRoot = newCopy:FindFirstChild("HumanoidRootPart")
		if not sourceRoot or not sourceRoot:IsA("BasePart") or not copyRoot
			or not copyRoot:IsA("BasePart") or not root or not root:IsA("BasePart") then
			error("Nhân vật chưa có đủ bộ phận để đồng bộ.")
		end
		local heading = 0
		if root and root:IsA("BasePart") then
			local look = root.CFrame.LookVector
			heading = math.atan2(-look.X, -look.Z)
		end
		newCopy:PivotTo(CFrame.new(selectedPosition) * CFrame.Angles(0, heading, 0))
		local floorDistance = source.Name == "GiftPlayerV8BodyDisplay"
			and source:GetAttribute("VisualFloorDistance") or nil
		local adjustment
		if type(floorDistance) == "number" and floorDistance > 0 then
			-- The live display is already grounded using this root-to-feet distance.
			-- Bounding boxes include invisible pieces and oversized 3D accessories.
			adjustment = selectedPosition.Y + floorDistance - copyRoot.Position.Y + 0.03
		else
			local bounds, size = newCopy:GetBoundingBox()
			local bottom = bounds.Position.Y - size.Y / 2
			adjustment = selectedPosition.Y - bottom + 0.03
		end
		newCopy:PivotTo(newCopy:GetPivot() + Vector3.new(0, adjustment, 0))
		if closed or currentGeneration ~= generation or player.Character ~= character then
			error("Nhân vật đã thay đổi; hãy thử lại.")
		end
		newPose = {
			character = character, humanoid = humanoid, source = source,
			sourceRoot = sourceRoot, copyRoot = copyRoot, pairs = pairs,
			anchor = copyRoot.CFrame, initialRotation = sourceRoot.CFrame.Rotation,
			groundOffset = copyRoot.Position.Y - selectedPosition.Y,
			groundedY = root.Position.Y, displayName = humanoid.DisplayName,
			limbJoints = limbJoints,
			cloneLinks = buildCloneAnimationLinks(newCopy, copyRoot),
			appearance = appearanceItems(character),
			sourceAppearance = appearanceSignature(source),
			moonbloomRoot = source.Name == "GiftPlayerV8BodyDisplay" and copyRoot or nil,
		}
		if controlledAnchor then
			local rise = math.max(0, controlledAnchor.Position.Y
				- (selectedPosition.Y + controlledGroundOffset))
			newPose.anchor = CFrame.new(selectedPosition.X,
				selectedPosition.Y + newPose.groundOffset + rise, selectedPosition.Z)
				* controlledAnchor.Rotation
		end
		newCopy.Parent = folder
	end)
	if not ok then
		if newCopy then
			newCopy:Destroy()
		end
		setStatus("Không tạo được bản sao: " .. tostring(err))
		return false
	end
	clearWeaponMirror()
	clearLegMirror()
	if poseMirror and poseMirror.cloneDriver then poseMirror.cloneDriver:Destroy() end
	if type(integrationState) == "table" and type(integrationState.SetDeveloperCloneModel) == "function" then
		integrationState.SetDeveloperCloneModel(nil)
	end
	if type(integrationState) == "table" and type(integrationState.SetMoonbloomCloneRoot) == "function" then
		integrationState.SetMoonbloomCloneRoot(nil)
	end
	if clone then clone:Destroy() end
	clone = newCopy
	poseMirror = newPose
	if type(integrationState) == "table" and type(integrationState.SetDeveloperCloneModel) == "function" then
		integrationState.SetDeveloperCloneModel(newCopy)
	end
	if type(integrationState) == "table" and type(integrationState.SetMoonbloomCloneRoot) == "function" then
		integrationState.SetMoonbloomCloneRoot(newPose.moonbloomRoot)
	end
	if not cameraFollow then
		cameraFollow = Instance.new("Part")
		cameraFollow.Name = "CloneCameraFollow"
		cameraFollow.Size = Vector3.new(1, 1, 1)
		cameraFollow.Transparency = 1
		cameraFollow.Anchored = true
		cameraFollow.CanCollide = false
		cameraFollow.CanTouch = false
		cameraFollow.CanQuery = false
		cameraFollow.Parent = folder
	end
	cameraFollow.CFrame = newPose.anchor
	pcall(syncClonePose)
	if autoView or viewingClone then
		local cameraOk, cameraResult = pcall(focusClone)
		if not cameraOk or not cameraResult then
			setStatus("Đã đặt bản sao, nhưng chưa chuyển được camera.")
			return true
		end
	end
	setStatus(controllingClone and "Đã cập nhật bản sao; tiếp tục điều khiển tại vị trí hiện tại."
		or viewingClone and "Đang xem bản sao; bật điều khiển để dùng WASD."
		or "Đã đặt bản sao. Chỉ máy bạn nhìn thấy.")
	return true
end

local function applyUsername()
	if applyingUsername then
		setStatus("Đang áp dụng avatar; vui lòng chờ.")
		return
	end
	local username = usernameBox.Text:match("^%s*(.-)%s*$"):gsub("^@", "")
	if username == "" or #username > 40 or not username:match("^[%w_]+$") then
		setStatus("Nhập username Roblox hợp lệ.")
		return
	end
	local state = env.__giftPlayerWeaponPicker
	if type(state) ~= "table" or not state.alive or type(state.ApplyAvatar) ~= "function" then
		setStatus("Thiếu API ApplyAvatar. Hãy chạy bản Visualizer tích hợp mới.")
		return
	end
	if state.avatarBusy then
		setStatus("Visualizer đang tải avatar; thử lại sau.")
		return
	end
	applyingUsername = true
	setStatus("Đang yêu cầu Visualizer áp dụng avatar " .. username .. "…")
	task.spawn(function()
		local oldToken = state.avatarToken or 0
		local ok, result = pcall(function()
			return env.__giftPlayerWeaponPicker.ApplyAvatar(username)
		end)
		applyingUsername = false
		if closed then return end
		if not ok then
			setStatus("Không áp dụng được avatar: " .. tostring(result))
			return
		end
		if result == false then
			setStatus("Visualizer từ chối avatar; kiểm tra username trong Visualizer.")
			return
		end
		if (state.avatarToken or 0) == oldToken and not state.avatarBusy then
			setStatus("Đã gọi ApplyAvatar; chờ Visualizer xác nhận và cập nhật bản sao.")
		else
			setStatus("Đang tải avatar; bản sao sẽ tự cập nhật khi ngoại hình đổi.")
		end
	end)
end

local lastSourceCheck = 0
local lastPoseWarning = 0
RunService:BindToRenderStep(instanceKey .. "Render",
	Enum.RenderPriority.Character.Value + 3, function(dt)
	if closed then return end
	updateCloneMovement(dt)
	if not poseMirror or closed then return end
	local now = os.clock()
	if now - lastSourceCheck >= 0.3 then
		lastSourceCheck = now
		local pose = poseMirror
		if player.Character == pose.character and pose.humanoid.Health > 0 then
			local source = currentBodySource(pose.character)
			if source ~= pose.source or not pose.source.Parent
				or pose.humanoid.DisplayName ~= pose.displayName or appearanceChanged(pose)
				or appearanceSignature(source) ~= pose.sourceAppearance then
				createOrUpdateClone(viewingClone)
			end
		end
	end
	local ok, problem = pcall(syncClonePose)
	if not ok and now - lastPoseWarning >= 3 then
		lastPoseWarning = now
		warn("[ClientDecoy] Pose: " .. tostring(problem))
	end
end)

connect(collapseButton.MouseButton1Click, function()
	collapsed = not collapsed
	for _, item in ipairs({status, usernameBox, applyAvatarButton, placeButton, refreshButton,
		viewButton, controlButton, removeButton, closeButton, hint}) do
		item.Visible = not collapsed
	end
	panel.Size = UDim2.fromOffset(306, collapsed and 52 or 466)
	collapseButton.Text = collapsed and "+" or "−"
end)

local dragging = false
local dragType = nil
local dragTouch = nil
local dragStart = nil
local dragPanelPosition = nil
local dragAbsolutePosition = nil
connect(title.InputBegan, function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then return end
	dragging = true
	dragType = input.UserInputType
	dragTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil
	dragStart = Vector2.new(input.Position.X, input.Position.Y)
	dragPanelPosition = panel.Position
	dragAbsolutePosition = panel.AbsolutePosition
end)
connect(UserInputService.InputChanged, function(input)
	if not dragging then return end
	if dragType == Enum.UserInputType.MouseButton1 then
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	elseif input ~= dragTouch then
		return
	end
	local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local absolute = dragAbsolutePosition + delta
	local x = math.clamp(absolute.X, 6, math.max(6, viewport.X - panel.AbsoluteSize.X - 6))
	local y = math.clamp(absolute.Y, 40, math.max(40, viewport.Y - panel.AbsoluteSize.Y - 6))
	local offset = Vector2.new(x, y) - dragAbsolutePosition
	panel.Position = UDim2.new(dragPanelPosition.X.Scale, dragPanelPosition.X.Offset + offset.X,
		dragPanelPosition.Y.Scale, dragPanelPosition.Y.Offset + offset.Y)
end)
connect(UserInputService.InputEnded, function(input)
	if dragType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseButton1
		or dragType == Enum.UserInputType.Touch and input == dragTouch then
		dragging = false
		dragType = nil
		dragTouch = nil
	end
end)

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
	if not viewingClone then return end
	task.defer(function()
		if closed or not viewingClone then return end
		local camera = Workspace.CurrentCamera
		local target = cameraTarget()
		if camera and target then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = target
			moveCameraNear(camera, clone:GetPivot().Position)
		end
	end)
end)

connect(applyAvatarButton.MouseButton1Click, applyUsername)
connect(usernameBox.FocusLost, function(enterPressed)
	if enterPressed then applyUsername() end
end)

connect(placeButton.MouseButton1Click, function()
	awaitingClick = true
	setStatus("Nhấp mặt đất để đặt bản sao và chuyển camera.")
end)

connect(UserInputService.InputBegan, function(input, processed)
	if not awaitingClick or processed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local ok, positionOrError = pcall(pickGround, input.Position)
	if not ok then
		setStatus("Không chọn được chỗ đặt: " .. tostring(positionOrError))
		return
	end
	if not positionOrError then
		setStatus("Chưa thấy mặt đất tại điểm nhấp. Thử vị trí khác.")
		return
	end
	if controllingClone then stopControl() end
	selectedPosition = positionOrError
	if createOrUpdateClone(true) then
		awaitingClick = false
	end
end)

connect(refreshButton.MouseButton1Click, function()
	createOrUpdateClone(false)
end)
connect(viewButton.MouseButton1Click, function()
	if controllingClone then
		stopControl()
		setStatus("Đã dừng điều khiển và quay về nhân vật thật.")
	elseif viewingClone then
		restoreCamera()
		setStatus("Đã quay về nhân vật thật.")
	elseif clone and clone.Parent then
		local ok, result = pcall(focusClone)
		setStatus(ok and result and "Đang xem bản sao; bật Điều khiển để dùng WASD."
			or "Không chuyển được camera.")
	else
		setStatus("Hãy đặt bản sao trước.")
	end
end)
connect(controlButton.MouseButton1Click, function()
	if controllingClone then
		stopControl()
		setStatus("Đã dừng điều khiển và quay về nhân vật thật.")
	else
		startControl()
	end
end)
connect(removeButton.MouseButton1Click, function()
	clearWorld()
	setStatus("Đã xóa bản sao và quay về nhân vật thật.")
end)
connect(closeButton.MouseButton1Click, cleanup)
connect(player.CharacterRemoving, function()
	restoreAfterRespawn = viewingClone
	clearWorld()
	setStatus("Nhân vật đang hồi sinh. Đặt lại bản sao sau khi xuất hiện.")
end)
connect(player.CharacterAdded, function(character)
	local needsCameraRestore = restoreAfterRespawn
	restoreAfterRespawn = false
	clearWorld()
	setStatus("Đã hồi sinh. Chọn chỗ đặt bản sao.")
	if not needsCameraRestore then return end
	local thisGeneration = generation
	task.defer(function()
		local humanoid = character:WaitForChild("Humanoid", 5)
		if not closed and not viewingClone and thisGeneration == generation and player.Character == character
			and humanoid and Workspace.CurrentCamera then
			Workspace.CurrentCamera.CameraSubject = humanoid
		end
	end)
end)
end
