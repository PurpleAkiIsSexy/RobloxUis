local UIManager = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local TOGGLE_KEY = Enum.KeyCode.RightControl

----------------------------------------------------------------------
-- Notification Type Palette & Stack
----------------------------------------------------------------------

local NOTIF_TYPES = {
	["info"] = {
		TextColor = Color3.fromRGB(255,255,255),
		Background = Color3.fromRGB(55,115,255),
		Border = Color3.fromRGB(44,90,210),
		Icon = "ℹ️",
	},
	["success"] = {
		TextColor = Color3.fromRGB(255,255,255),
		Background = Color3.fromRGB(60,180,75),
		Border = Color3.fromRGB(32,120,57),
		Icon = "✓",
	},
	["warning"] = {
		TextColor = Color3.fromRGB(60,60,60),
		Background = Color3.fromRGB(255,215,60),
		Border = Color3.fromRGB(210,180,44),
		Icon = "!",
	},
	["error"] = {
		TextColor = Color3.fromRGB(255,255,255),
		Background = Color3.fromRGB(200,53,53),
		Border = Color3.fromRGB(145,32,32),
		Icon = "✕",
	},
}

local _notifActive = {}
local _notifYOffset = 12 -- Notification stack padding

function UIManager.ShowNotification(message, notifType, duration)
	notifType = notifType or "info"
	duration = duration or 2.5

	local screenGui = PlayerGui:FindFirstChild("ScreenGui") or PlayerGui:GetChildren()[1]
	local currentIndex = #_notifActive

	local notif = Instance.new("Frame")
	notif.AnchorPoint = Vector2.new(1, 1)
	notif.Position = UDim2.new(1, 420, 1, -((currentIndex * (_notifYOffset + 56)) + 16))
	notif.Size = UDim2.new(0, 340, 0, 56)
	notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	notif.BorderSizePixel = 0
	notif.BackgroundTransparency = 1
	notif.ZIndex = 50
	notif.Parent = screenGui
	notif.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notif

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
	gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}
	gradient.Parent = notif

	local typeData
	if notifType == "success" then
		typeData = {GradientColors = ColorSequence.new(Color3.fromRGB(25,25,25), Color3.fromRGB(60,180,75)), Border = Color3.fromRGB(32,120,57), Icon = "✓", TextColor = Color3.fromRGB(200,255,200)}
	elseif notifType == "warning" then
		typeData = {GradientColors = ColorSequence.new(Color3.fromRGB(25,25,25), Color3.fromRGB(255,215,60)), Border = Color3.fromRGB(210,180,44), Icon = "!", TextColor = Color3.fromRGB(255,240,180)}
	elseif notifType == "error" then
		typeData = {GradientColors = ColorSequence.new(Color3.fromRGB(25,25,25), Color3.fromRGB(200,53,53)), Border = Color3.fromRGB(145,32,32), Icon = "X", TextColor = Color3.fromRGB(255,200,200)}
	else
		typeData = {GradientColors = ColorSequence.new(Color3.fromRGB(25,25,25), Color3.fromRGB(55,115,255)), Border = Color3.fromRGB(44,90,210), Icon = "ℹ️", TextColor = Color3.fromRGB(200,220,255)}
	end
	gradient.Color = typeData.GradientColors

	local border = Instance.new("UIStroke")
	border.Transparency = 0.85
	border.Color = typeData.Border
	border.Thickness = 1.5
	border.Parent = notif

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.new(0, 16, 0.5, -14)
	icon.Size = UDim2.new(0, 28, 0, 28)
	icon.Text = typeData.Icon
	icon.TextColor3 = typeData.TextColor
	icon.TextScaled = true
	icon.Font = Enum.Font.GothamBold
	icon.ZIndex = 53
	icon.Parent = notif

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 52, 0, 0)
	label.Size = UDim2.new(1, -84, 1, 0)
	label.Text = message
	label.TextColor3 = typeData.TextColor
	label.Font = Enum.Font.GothamMedium
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextSize = 17
	label.ZIndex = 52
	label.Parent = notif

	local close = Instance.new("TextButton")
	close.Text = "X"
	close.BackgroundTransparency = 1
	close.Size = UDim2.new(0, 36, 1, 0)
	close.Position = UDim2.new(1, -36, 0, 0)
	close.TextColor3 = typeData.TextColor
	close.Font = Enum.Font.Gotham
	close.TextSize = 22
	close.ZIndex = 54
	close.Parent = notif

	table.insert(_notifActive, notif)

	notif.Position = UDim2.new(1, 420, 1, -((currentIndex * (_notifYOffset + 56)) + 16))
	notif.BackgroundTransparency = 1
	icon.TextTransparency = 1
	label.TextTransparency = 1
	close.TextTransparency = 1

	TweenService:Create(notif, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -16, 1, -((currentIndex * (_notifYOffset + 56)) + 16)),
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(icon, TweenInfo.new(0.32), {TextTransparency = 0}):Play()
	TweenService:Create(label, TweenInfo.new(0.32), {TextTransparency = 0}):Play()
	TweenService:Create(close, TweenInfo.new(0.32), {TextTransparency = 0}):Play()

	local closed = false
	local function closeNotif()
		if closed then return end
		closed = true
		TweenService:Create(notif, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, 420, 1, notif.Position.Y.Offset),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(icon, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
		TweenService:Create(label, TweenInfo.new(0.21), {TextTransparency = 1}):Play()
		TweenService:Create(close, TweenInfo.new(0.23), {TextTransparency = 1}):Play()
		task.wait(0.3)
		notif:Destroy()

		for i, n in ipairs(_notifActive) do
			if n == notif then
				table.remove(_notifActive, i)
				break
			end
		end

		for i, n in ipairs(_notifActive) do
			TweenService:Create(n, TweenInfo.new(0.19, Enum.EasingStyle.Quad), {
				Position = UDim2.new(1, -16, 1, -((i - 1) * (_notifYOffset + 56) + 16))
			}):Play()
		end
	end

	close.MouseButton1Click:Connect(closeNotif)
	UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Escape then
			closeNotif()
		end
	end)
	task.spawn(function()
		task.wait(duration)
		closeNotif()
	end)
end


----------------------------------------------------------------------
-- UI and Controls
----------------------------------------------------------------------

function UIManager.CreateMainUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ScreenGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui



	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 550, 0, 450)
	mainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 60)
	titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -80, 0, 28)
	title.Position = UDim2.new(0, 10, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "🌙 Professional Roblox UI"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -80, 0, 20)
	subtitle.Position = UDim2.new(0, 10, 0, 32)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Hover to see tips..."
	subtitle.TextColor3 = Color3.fromRGB(255, 215, 0)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 14
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = titleBar

	local minimize = Instance.new("TextButton")
	minimize.Size = UDim2.new(0, 30, 0, 30)
	minimize.Position = UDim2.new(1, -70, 0, 5)
	minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	minimize.BorderSizePixel = 0
	minimize.Text = "-"
	minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimize.Font = Enum.Font.GothamBold
	minimize.TextSize = 20
	minimize.Parent = titleBar

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -35, 0, 5)
	close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	close.BorderSizePixel = 0
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 18
	close.Parent = titleBar

	-- Tab Frame
	local tabFrame = Instance.new("Frame")
	tabFrame.Size = UDim2.new(0, 140, 1, -75)
	tabFrame.Position = UDim2.new(0, 5, 0, 65)
	tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tabFrame.BorderSizePixel = 0
	tabFrame.Parent = mainFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Parent = tabFrame

	-- Content Frame (NOT scrollable)
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -160, 1, -75)
	contentFrame.Position = UDim2.new(0, 150, 0, 65)
	contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	contentFrame.BorderSizePixel = 0
	contentFrame.ClipsDescendants = true
	contentFrame.Parent = mainFrame

	local minimized = false
	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized
		tabFrame.Visible = not minimized
		contentFrame.Visible = not minimized
		mainFrame.Size = minimized and UDim2.new(0, 550, 0, 60) or UDim2.new(0, 550, 0, 450)
	end)

	local closeClick = 0
	close.MouseButton1Click:Connect(function()
		if closeClick == 0 then
			closeClick = 1
			UIManager.ShowNotification("Are you sure? Click X again to confirm", "warning", 1.8)
			task.spawn(function()
				task.wait(1.5)
				closeClick = 0
			end)
			return
		end
		mainFrame:Destroy()
	end)

	local dragging, startPos, startInputPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startPos = mainFrame.Position
			startInputPos = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - startInputPos
			mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
		end
	end)

	UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == TOGGLE_KEY then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)

	return {
		MainFrame = mainFrame,
		TitleBar = titleBar,
		TabFrame = tabFrame,
		ContentFrame = contentFrame,
		Subtitle = subtitle
	}
end


function UIManager.CreateTab(tabFrame, name)
	local icon, label = name:match("^(%S+)%s+(.+)$")
	if not label then
		label = name
		icon = nil
	end

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, 38)
	button.BackgroundColor3 = Color3.fromRGB(45,45,45)
	button.BorderSizePixel = 0
	button.Text = icon and (icon .. "  " .. label) or label
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 17
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextYAlignment = Enum.TextYAlignment.Center
	button.TextWrapped = true -- allows multi-line if needed
	button.ClipsDescendants = true
	button.Parent = tabFrame

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.Parent = button

	return button
end



function UIManager.CreateButton(content,text)
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(1,-10,0,35)
	btn.BackgroundColor3=Color3.fromRGB(55,55,55)
	btn.BorderSizePixel=0
	btn.Text=text
	btn.TextColor3=Color3.fromRGB(255,255,255)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=16
	btn.Parent=content
	return btn
end

function UIManager.CreateToggle(content,text)
	local toggle=Instance.new("TextButton")
	toggle.Size=UDim2.new(1,-10,0,35)
	toggle.BackgroundColor3=Color3.fromRGB(55,55,55)
	toggle.BorderSizePixel=0
	toggle.Text="[ OFF ] "..text
	toggle.TextColor3=Color3.fromRGB(255,255,255)
	toggle.Font=Enum.Font.Gotham
	toggle.TextSize=16
	toggle.Parent=content
	local state=false
	toggle.MouseButton1Click:Connect(function()
		state=not state
		toggle.Text=(state and "[ ON ] " or "[ OFF ] ")..text
	end)
	return toggle
end

function UIManager.CreateTextbox(content,placeholder)
	local box=Instance.new("TextBox")
	box.Size=UDim2.new(1,-10,0,35)
	box.BackgroundColor3=Color3.fromRGB(55,55,55)
	box.BorderSizePixel=0
	box.PlaceholderText=placeholder
	box.TextColor3=Color3.fromRGB(255,255,255)
	box.Font=Enum.Font.Gotham
	box.TextSize=16
	box.Parent=content
	return box
end

function UIManager.CreateProgressBar(content,text,percent)
	local holder=Instance.new("Frame")
	holder.Size=UDim2.new(1,-10,0,30)
	holder.BackgroundTransparency=1
	holder.Parent=content

	local label=Instance.new("TextLabel")
	label.Size=UDim2.new(1,0,0,15)
	label.BackgroundTransparency=1
	label.Text=text.." ("..percent.."%)"
	label.TextColor3=Color3.fromRGB(255,255,255)
	label.Font=Enum.Font.Gotham
	label.TextSize=14
	label.Parent=holder

	local bar=Instance.new("Frame")
	bar.Size=UDim2.new(1,0,0,10)
	bar.Position=UDim2.new(0,0,0,18)
	bar.BackgroundColor3=Color3.fromRGB(80,80,80)
	bar.BorderSizePixel=0
	bar.Parent=holder

	local fill=Instance.new("Frame")
	fill.Size=UDim2.new(percent/100,0,1,0)
	fill.BackgroundColor3=Color3.fromRGB(120,120,255)
	fill.BorderSizePixel=0
	fill.Parent=bar
	return holder
end

function UIManager.CreateKeybindPicker(content,text)
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(1,-10,0,35)
	btn.BackgroundColor3=Color3.fromRGB(55,55,55)
	btn.BorderSizePixel=0
	btn.Text=text..": [None]"
	btn.TextColor3=Color3.fromRGB(255,255,255)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=14
	btn.Parent=content
	btn.MouseButton1Click:Connect(function()
		btn.Text=text..": [Press a key]"
		local key=UIS.InputBegan:Wait().KeyCode
		btn.Text=text..": ["..key.Name.."]"
	end)
	return btn
end

function UIManager.CreateNumericStepper(content,text,initial)
	local holder=Instance.new("Frame")
	holder.Size=UDim2.new(1,-10,0,35)
	holder.BackgroundColor3=Color3.fromRGB(55,55,55)
	holder.BorderSizePixel=0
	holder.Parent=content

	local label=Instance.new("TextLabel")
	label.Size=UDim2.new(0.5,0,1,0)
	label.BackgroundTransparency=1
	label.Text=text..": "..initial
	label.TextColor3=Color3.fromRGB(255,255,255)
	label.Font=Enum.Font.Gotham
	label.TextSize=14
	label.TextXAlignment=Enum.TextXAlignment.Left
	label.Parent=holder

	local plus=Instance.new("TextButton")
	plus.Size=UDim2.new(0,25,1,0)
	plus.Position=UDim2.new(1,-25,0,0)
	plus.Text="+"
	plus.BackgroundTransparency=1
	plus.TextColor3=Color3.fromRGB(255,255,255)
	plus.Font=Enum.Font.Gotham
	plus.TextSize=16
	plus.Parent=holder

	local minus=Instance.new("TextButton")
	minus.Size=UDim2.new(0,25,1,0)
	minus.Position=UDim2.new(1,-50,0,0)
	minus.Text="-"
	minus.BackgroundTransparency=1
	minus.TextColor3=Color3.fromRGB(255,255,255)
	minus.Font=Enum.Font.Gotham
	minus.TextSize=16
	minus.Parent=holder

	local value=initial
	plus.MouseButton1Click:Connect(function()
		value=value+1
		label.Text=text..": "..value
	end)
	minus.MouseButton1Click:Connect(function()
		value=value-1
		label.Text=text..": "..value
	end)
	return holder
end

function UIManager.CreateSlider(content, text, min, max)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-10,0,40)
	frame.BackgroundTransparency = 1
	frame.Parent = content

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0,20)
	label.BackgroundTransparency = 1
	label.Text = text..": "..min
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1,0,0,10)
	bar.Position = UDim2.new(0,0,0,25)
	bar.BackgroundColor3 = Color3.fromRGB(80,80,80)
	bar.BorderSizePixel = 0
	bar.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,120,255)
	fill.BorderSizePixel = 0
	fill.Parent = bar

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local conn
			conn = UIS.InputChanged:Connect(function(move)
				if move.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = math.clamp((move.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(pos,0,1,0)
					label.Text = text..": "..math.floor(min + (max - min) * pos)
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End then conn:Disconnect() end
			end)
		end
	end)
	return frame
end

function UIManager.CreateMultiDropdown(content, text, options)
	local closedHeight = 35
	local openHeight = closedHeight + #options * 25

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, closedHeight)
	holder.BackgroundColor3 = Color3.fromRGB(55,55,55)
	holder.BorderSizePixel = 0
	holder.Parent = content

	local selected = {}

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 0, closedHeight)
	label.Position = UDim2.new(0,5,0,0)
	label.BackgroundTransparency = 1
	label.Text = text..": [None]"
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,25,0,closedHeight)
	btn.Position = UDim2.new(1,-25,0,0)
	btn.Text = "▼"
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = holder

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1,0,0,#options*25)
	listFrame.Position = UDim2.new(0,0,0,closedHeight)
	listFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
	listFrame.BorderSizePixel = 0
	listFrame.Visible = false
	listFrame.Parent = holder

	local layout = Instance.new("UIListLayout")
	layout.Parent = listFrame

	for _, opt in ipairs(options) do
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1,0,0,25)
		item.Text = "[ ] "..opt
		item.BackgroundTransparency = 1
		item.TextColor3 = Color3.fromRGB(255,255,255)
		item.Font = Enum.Font.Gotham
		item.TextSize = 14
		item.Parent = listFrame

		item.MouseButton1Click:Connect(function()
			if selected[opt] then
				selected[opt] = nil
				item.Text = "[ ] "..opt
			else
				selected[opt] = true
				item.Text = "[✔] "..opt
			end
			local sel = {}
			for k in pairs(selected) do table.insert(sel,k) end
			label.Text = text..": [".. (#sel>0 and table.concat(sel,", ") or "None") .."]"
		end)
	end

	btn.MouseButton1Click:Connect(function()
		local open = not listFrame.Visible
		listFrame.Visible = open
		holder.Size = UDim2.new(1, -10, 0, open and openHeight or closedHeight)
		btn.Text = open and "▲" or "▼"
	end)

	return holder
end

function UIManager.CreateDropdown(content, text, options, defaultIndex)
	local closedHeight = 35
	local openHeight = closedHeight + #options * 25

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, closedHeight)
	holder.BackgroundColor3 = Color3.fromRGB(55,55,55)
	holder.BorderSizePixel = 0
	holder.Parent = content
	holder.ClipsDescendants = true

	local selectedIndex = defaultIndex or 1
	local selectedOption = options[selectedIndex]

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 0, closedHeight)
	label.Position = UDim2.new(0,5,0,0)
	label.BackgroundTransparency = 1
	label.Text = text..": "..selectedOption
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,25,0,closedHeight)
	btn.Position = UDim2.new(1,-25,0,0)
	btn.Text = "▼"
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = holder

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1,0,0,#options*25)
	listFrame.Position = UDim2.new(0,0,0,closedHeight)
	listFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
	listFrame.BorderSizePixel = 0
	listFrame.Visible = false
	listFrame.Parent = holder

	local layout = Instance.new("UIListLayout")
	layout.Parent = listFrame

	local isOpen = false
	local tweens = {}

	local function closeDropdown()
		if not isOpen then return end
		isOpen = false

		for _, t in pairs(tweens) do
			t:Cancel()
		end
		tweens = {}

		table.insert(tweens, TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,0)}))
		table.insert(tweens, TweenService:Create(holder, TweenInfo.new(0.2), {Size = UDim2.new(1,-10,0,closedHeight)}))

		for _, t in pairs(tweens) do
			t:Play()
		end
		btn.Text = "▼"
		task.delay(0.2, function()
			listFrame.Visible = false
		end)
	end

	local function openDropdown()
		if isOpen then return end
		isOpen = true
		listFrame.Visible = true

		for _, t in pairs(tweens) do
			t:Cancel()
		end
		tweens = {}

		table.insert(tweens, TweenService:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,#options*25)}))
		table.insert(tweens, TweenService:Create(holder, TweenInfo.new(0.2), {Size = UDim2.new(1,-10,0,openHeight)}))

		for _, t in pairs(tweens) do
			t:Play()
		end
		btn.Text = "▲"
	end

	for i, opt in ipairs(options) do
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1,0,0,25)
		item.Text = opt
		item.BackgroundTransparency = 1
		item.TextColor3 = Color3.fromRGB(255,255,255)
		item.Font = Enum.Font.Gotham
		item.TextSize = 14
		item.Parent = listFrame

		item.MouseButton1Click:Connect(function()
			selectedIndex = i
			selectedOption = opt
			label.Text = text..": "..selectedOption
			closeDropdown()
			btn.Text = "▼"
		end)
	end

	btn.MouseButton1Click:Connect(function()
		if isOpen then
			closeDropdown()
		else
			openDropdown()
		end
	end)

	-- Close when clicking outside
	UIS.InputBegan:Connect(function(input, processed)
		if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not holder:IsDescendantOf(PlayerGui) then return end
			local pos = input.Position
			local absPos = holder.AbsolutePosition
			local absSize = holder.AbsoluteSize
			if pos.X < absPos.X or pos.X > absPos.X + absSize.X 
				or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
				closeDropdown()
				btn.Text = "▼"
			end
		end
	end)

	return {
		Holder = holder,
		GetSelected = function() return selectedIndex, selectedOption end,
		SetSelected = function(index)
			if index >= 1 and index <= #options then
				selectedIndex = index
				selectedOption = options[index]
				label.Text = text..": "..selectedOption
			end
		end
	}
end

-- Section header with lines on each side
function UIManager.CreateSectionHeader(content, text)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 24)
	holder.BackgroundTransparency = 1
	holder.Parent = content

	-- Left divider
	local leftLine = Instance.new("Frame")
	leftLine.BackgroundColor3 = Color3.fromRGB(100,100,100)
	leftLine.BorderSizePixel = 0
	leftLine.Position = UDim2.new(0, 0, 0.5, 0)
	leftLine.Size = UDim2.new(0.22, 0, 0, 1)
	leftLine.AnchorPoint = Vector2.new(0, 0.5)
	leftLine.Parent = holder

	-- Label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, (#text*9) + 24, 1, 0)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Text = "[ " .. text .. " ]"
	label.TextColor3 = Color3.fromRGB(180,180,180)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = holder

	-- Right divider
	local rightLine = Instance.new("Frame")
	rightLine.BackgroundColor3 = Color3.fromRGB(100,100,100)
	rightLine.BorderSizePixel = 0
	rightLine.Position = UDim2.new(0.78, 0, 0.5, 0)
	rightLine.Size = UDim2.new(0.22, 0, 0, 1)
	rightLine.AnchorPoint = Vector2.new(0, 0.5)
	rightLine.Parent = holder

	return holder
end

function UIManager.CreateRGBColorPicker(content, text)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1,-10,0,120)
	holder.BackgroundColor3 = Color3.fromRGB(55,55,55)
	holder.BorderSizePixel = 0
	holder.Parent = content

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-40,0,20)
	label.Position = UDim2.new(0,10,0,5)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0,20,0,20)
	preview.Position = UDim2.new(1,-30,0,5)
	preview.BackgroundColor3 = Color3.fromRGB(255,255,255)
	preview.BorderSizePixel = 0
	preview.Parent = holder

	local sliders = {}
	local colors = {"R","G","B"}
	local current = {R=255,G=255,B=255}

	for i, c in ipairs(colors) do
		local yPos = 40 + (i-1)*28

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1,-20,0,10)
		bar.Position = UDim2.new(0,10,0,yPos)
		bar.BackgroundColor3 = Color3.fromRGB(80,80,80)
		bar.BorderSizePixel = 0
		bar.Parent = holder

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(1,0,1,0)
		fill.BackgroundColor3 = Color3.fromRGB(200,200,200)
		fill.BorderSizePixel = 0
		fill.Parent = bar

		local valueLabel = Instance.new("TextLabel")
		valueLabel.Size = UDim2.new(1,0,0,13)
		valueLabel.Position = UDim2.new(0,0,0,-13)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = c..": "..current[c]
		valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
		valueLabel.Font = Enum.Font.Gotham
		valueLabel.TextSize = 12
		valueLabel.TextXAlignment = Enum.TextXAlignment.Left
		valueLabel.Parent = bar

		sliders[c] = {bar=bar,fill=fill,label=valueLabel}
	end

	for c,slider in pairs(sliders) do
		slider.bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local conn
				conn = UIS.InputChanged:Connect(function(move)
					if move.UserInputType == Enum.UserInputType.MouseMovement then
						local pos = math.clamp((move.Position.X - slider.bar.AbsolutePosition.X) / slider.bar.AbsoluteSize.X, 0, 1)
						slider.fill.Size = UDim2.new(pos,0,1,0)
						local value = math.floor(pos * 255)
						current[c]=value
						slider.label.Text = c..": "..value
						preview.BackgroundColor3 = Color3.fromRGB(current.R,current.G,current.B)
					end
				end)
				input.Changed:Connect(function()
					if input.UserInputState==Enum.UserInputState.End then conn:Disconnect() end
				end)
			end
		end)
	end

	return holder
end

function UIManager.ShowIntroAndCreateMainUI()
	local introGui = Instance.new("ScreenGui")
	introGui.Name = "IntroGui"
	introGui.IgnoreGuiInset = true
	introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	introGui.Parent = PlayerGui

	local introFrame = Instance.new("Frame")
	introFrame.BackgroundColor3 = Color3.fromRGB(18,18,19)
	introFrame.BorderSizePixel = 0
	introFrame.Size = UDim2.new(1,0,1,0)
	introFrame.BackgroundTransparency = 1
	introFrame.Parent = introGui

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5,0.5)
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.Size = UDim2.new(0, 420, 0, 72)
	label.BackgroundTransparency = 1
	label.Text = "🌙 Professional Roblox UI"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Parent = introFrame
	label.TextTransparency = 1

	-- Animate intro fade-in
	TweenService:Create(introFrame, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
	TweenService:Create(label, TweenInfo.new(0.4,Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
	task.wait(0.25)
	TweenService:Create(label, TweenInfo.new(0.42), {TextStrokeTransparency=.65}):Play()
	task.wait(2)

	-- Animate intro fade-out
	TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
	TweenService:Create(introFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	task.wait(0.7)
	introGui:Destroy()

	-- Wait to ensure GUI is cleared before creating a new one
	task.wait(0.1)

	-- Now create/show the main UI and return it
	return UIManager.CreateMainUI()
end


function UIManager.CreateTabPage(contentFrame)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.CanvasSize = UDim2.new(0,0,1,0)
	page.ScrollBarThickness = 6
	page.ScrollBarImageColor3 = Color3.fromRGB(100,100,100)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ClipsDescendants = true
	page.Visible = false
	page.Parent = contentFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8) -- gap between widgets
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- ← center align
	layout.Parent = page

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 5)
	padding.PaddingRight = UDim.new(0, 5)
	padding.Parent = page

	return page
end



-- New: CreateTabsManager
function UIManager.CreateTabsManager(tabFrame, contentFrame)
	local tabs = {}
	local currentTab = nil

	local function selectTab(name)
		for tabName, tab in pairs(tabs) do
			local isActive = (tabName == name)
			tab.button.BackgroundColor3 = isActive and Color3.fromRGB(70,70,70) or Color3.fromRGB(45,45,45)
			tab.page.Visible = isActive
		end
		currentTab = name
	end

	local function addTab(name)
		local button = UIManager.CreateTab(tabFrame, name)
		local page = UIManager.CreateTabPage(contentFrame)

		button.MouseButton1Click:Connect(function()
			selectTab(name)
		end)

		tabs[name] = {button = button, page = page}
		if not currentTab then
			selectTab(name)
		end
		return page
	end

	return {
		AddTab = addTab,
		SelectTab = selectTab,
		GetTabs = function() return tabs end
	}
end

function UIManager.CreateSliderToggle(content, labelText, min, max)
	local closedHeight = 35
	local openHeight = 85

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, closedHeight)
	holder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	holder.BorderSizePixel = 0
	holder.Parent = content
	holder.ClipsDescendants = true

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, 0, 0, 35)
	toggle.Position = UDim2.new(0, 0, 0, 0)
	toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggle.BorderSizePixel = 0
	toggle.Text = "[ OFF ] " .. labelText
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = holder

	local sliderFrame = Instance.new("Frame")
	sliderFrame.Position = UDim2.new(0, 0, 0, 35)
	sliderFrame.Size = UDim2.new(1, 0, 0, 50)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Parent = holder

	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Size = UDim2.new(1, 0, 0, 20)
	sliderLabel.Position = UDim2.new(0, 0, 0, 0)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.Text = "Value: " .. min
	sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	sliderLabel.Font = Enum.Font.Gotham
	sliderLabel.TextSize = 13
	sliderLabel.Parent = sliderFrame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 10)
	bar.Position = UDim2.new(0, 0, 0, 25)
	bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	bar.BorderSizePixel = 0
	bar.Parent = sliderFrame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(120, 120, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local active = false
	local sliderValue = min

	toggle.MouseButton1Click:Connect(function()
		active = not active
		toggle.Text = (active and "[ ON ] " or "[ OFF ] ") .. labelText
		local tweenSize = active and openHeight or closedHeight
		game:GetService("TweenService"):Create(holder, TweenInfo.new(0.25), {
			Size = UDim2.new(1, -10, 0, tweenSize)
		}):Play()
	end)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local conn
			conn = game:GetService("UserInputService").InputChanged:Connect(function(move)
				if move.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = math.clamp((move.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(pos, 0, 1, 0)
					sliderValue = math.floor(min + (max - min) * pos)
					sliderLabel.Text = "Value: " .. sliderValue
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if conn then conn:Disconnect() end
				end
			end)
		end
	end)

	return {
		Holder = holder,
		GetValue = function() return sliderValue end,
		IsEnabled = function() return active end
	}
end

function UIManager.CreateStepperToggle(content, toggleText, labelText, initialValue)
	local closedHeight = 35
	local openHeight = 85

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, closedHeight)
	holder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	holder.BorderSizePixel = 0
	holder.Parent = content
	holder.ClipsDescendants = true

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, 0, 0, 35)
	toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	toggle.BorderSizePixel = 0
	toggle.Text = "[ OFF ] " .. toggleText
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.Parent = holder

	local stepper = UIManager.CreateNumericStepper(holder, labelText, initialValue)
	stepper.Position = UDim2.new(0, 0, 0, 40)
	stepper.Visible = false

	local active = false
	toggle.MouseButton1Click:Connect(function()
		active = not active
		toggle.Text = (active and "[ ON ] " or "[ OFF ] ") .. toggleText
		stepper.Visible = active
		holder.Size = active and UDim2.new(1, -10, 0, openHeight) or UDim2.new(1, -10, 0, closedHeight)
	end)

	return {
		Holder = holder,
		IsEnabled = function() return active end
	}
end


return UIManager

