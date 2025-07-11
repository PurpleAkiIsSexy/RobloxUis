local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PurpleAkiIsSexy/Scouse-Starter-Pack/refs/heads/main/Scouse.lua"))()

-- Show intro & create main UI
local ui = UIManager.ShowIntroAndCreateMainUI()

-- Create tabs and widgets
local tabs = UIManager.CreateTabsManager(ui.TabFrame, ui.ContentFrame)
local mainTab = tabs.AddTab("⭐ Main")
local testTab = tabs.AddTab("⭐ Test")

UIManager.CreateSectionHeader(mainTab, "Controls")
UIManager.CreateButton(mainTab, "Test Button")
UIManager.CreateToggle(mainTab, "Enable Feature")
UIManager.CreateTextbox(mainTab, "Enter something")
UIManager.CreateDropdown(mainTab, "Select Option", {"One", "Two", "Three"}, 1)
UIManager.CreateMultiDropdown(mainTab, "Select Items", {"Apple", "Banana", "Cherry"})
UIManager.CreateRGBColorPicker(mainTab, "Color")
UIManager.CreateSlider(mainTab, "Volume", 0, 100)
UIManager.CreateKeybindPicker(mainTab, "Bind Key")
UIManager.CreateNumericStepper(mainTab, "Step", 5)
UIManager.CreateProgressBar(mainTab, "Loading", 40)
UIManager.CreateSliderToggle(mainTab, "Volume", 0, 100)
UIManager.CreateStepperToggle(mainTab, "Use Range Stepper", "Range", 10)

UIManager.CreateSectionHeader(mainTab, "Test Notifications")

UIManager.CreateButton(mainTab, "📢 Info Notification").MouseButton1Click:Connect(function()
	UIManager.ShowNotification("This is an info notification.", "info")
end)

UIManager.CreateButton(mainTab, "✅ Success Notification").MouseButton1Click:Connect(function()
	UIManager.ShowNotification("Action completed successfully!", "success")
end)

UIManager.CreateButton(mainTab, "⚠️ Warning Notification").MouseButton1Click:Connect(function()
	UIManager.ShowNotification("Be careful! Something may go wrong.", "warning")
end)

UIManager.CreateButton(mainTab, "❌ Error Notification").MouseButton1Click:Connect(function()
	UIManager.ShowNotification("An error occurred while processing.", "error")
end)
