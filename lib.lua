--[[
    Usage:

    local Ember = loadstring(game:HttpGet("https://raw.githubusercontent.com/asdwasdwd/EmberLib/refs/heads/main/lib.lua"))()

    local Window = Ember:CreateWindow({
        Name = "UI TITLE"
    })
]]

local Ember = {}
Ember.__index = Ember
Ember.Flags = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local primaryColor = Color3.fromRGB(35, 35, 35)
local accentColor = Color3.fromRGB(126, 11, 11)
local textColor = Color3.fromRGB(255, 255, 255)
local buttonColor = Color3.fromRGB(50, 50, 50)
local exitButtonColor = Color3.fromRGB(80, 20, 20)

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = parent
    return corner
end

local function createLayout(parent, padding)
    local layout = Instance.new("UIListLayout")
    layout.Parent = parent
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, padding or 6)
    layout.FillDirection = Enum.FillDirection.Vertical
    return layout
end

local Window = {}
Window.__index = Window

function Window:CreateToggle(config)
    self.ElementCount = self.ElementCount + 1

    local toggle = Instance.new("TextButton")
    toggle.Name = config.Name or "Toggle"
    toggle.Parent = self.ButtonContainer
    toggle.BackgroundColor3 = config.CurrentValue and accentColor or buttonColor
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.new(1, 0, 0, 26)
    toggle.Font = Enum.Font.Gotham
    toggle.Text = (config.Name or "Toggle") .. ": " .. (config.CurrentValue and "ON" or "OFF")
    toggle.TextColor3 = textColor
    toggle.TextSize = 11
    toggle.LayoutOrder = self.ElementCount
    toggle.AutoButtonColor = false

    createCorner(toggle, 4)

    local currentValue = config.CurrentValue or false
    if config.Flag then
        Ember.Flags[config.Flag] = currentValue
    end

    toggle.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        toggle.BackgroundColor3 = currentValue and accentColor or buttonColor
        toggle.Text = (config.Name or "Toggle") .. ": " .. (currentValue and "ON" or "OFF")

        if config.Flag then
            Ember.Flags[config.Flag] = currentValue
        end

        if config.Callback then
            config.Callback(currentValue)
        end
    end)

    return toggle
end

function Window:CreateButton(config)
    self.ElementCount = self.ElementCount + 1

    local button = Instance.new("TextButton")
    button.Name = config.Name or "Button"
    button.Parent = self.ButtonContainer
    button.BackgroundColor3 = buttonColor
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 26)
    button.Font = Enum.Font.Gotham
    button.Text = config.Name or "Button"
    button.TextColor3 = textColor
    button.TextSize = 11
    button.LayoutOrder = self.ElementCount
    button.AutoButtonColor = false

    createCorner(button, 4)

    button.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)

    return button
end

function Window:CreateDropdown(config)
    self.ElementCount = self.ElementCount + 1

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = config.Name or "Dropdown"
    dropdownFrame.Parent = self.ButtonContainer
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Size = UDim2.new(1, 0, 0, 26)
    dropdownFrame.LayoutOrder = self.ElementCount

    local dropdown = Instance.new("TextButton")
    dropdown.Name = "DropdownButton"
    dropdown.Parent = dropdownFrame
    dropdown.BackgroundColor3 = buttonColor
    dropdown.BorderSizePixel = 0
    dropdown.Size = UDim2.new(1, 0, 1, 0)
    dropdown.Font = Enum.Font.Gotham
    dropdown.Text = config.CurrentOption or config.Options[1] or "Select..."
    dropdown.TextColor3 = textColor
    dropdown.TextSize = 11
    dropdown.TextXAlignment = Enum.TextXAlignment.Center
    dropdown.TextTruncate = Enum.TextTruncate.AtEnd
    dropdown.AutoButtonColor = false

    createCorner(dropdown, 4)

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Parent = dropdown
    arrow.BackgroundTransparency = 1
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Position = UDim2.new(0.95, 0, 0.46, 0)
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Font = Enum.Font.Gotham
    arrow.Text = "▼"
    arrow.TextColor3 = textColor
    arrow.TextScaled = true

    local listFrame = Instance.new("Frame")
    listFrame.Name = "ListFrame"
    listFrame.Parent = self.Main
    listFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    listFrame.BorderSizePixel = 0
    listFrame.Size = UDim2.new(1, -20, 0, math.min((#config.Options + 1) * 22, 100))
    listFrame.Visible = false
    listFrame.ZIndex = 10

    createCorner(listFrame, 4)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = listFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = accentColor
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (#config.Options + 1) * 22)
    scrollFrame.ZIndex = 11

    createLayout(scrollFrame, 0)

    local selectedOptions = {}
    local multiSelect = config.MultiSelect or false
    
    if multiSelect then
        if config.CurrentOptions then
            for _, option in ipairs(config.CurrentOptions) do
                selectedOptions[option] = true
            end
        end
    else
        local currentValue = config.CurrentOption or config.Options[1]
        selectedOptions[currentValue] = true
        if config.Flag then
            Ember.Flags[config.Flag] = currentValue
        end
    end
    
    local dropdownOpen = false
    
    local function isOptionSelected(option)
        return selectedOptions[option] == true
    end
    
    local function areAllOptionsSelected()
        if #config.Options == 0 then return false end
        for _, option in ipairs(config.Options) do
            if not isOptionSelected(option) then
                return false
            end
        end
        return true
    end
    
    local function selectAllOptions()
        selectedOptions = {}
        for _, option in ipairs(config.Options) do
            selectedOptions[option] = true
        end
    end
    
    local function unselectAllOptions()
        selectedOptions = {}
    end
    
    local function updateDropdownText()
        if multiSelect then
            local selectedCount = 0
            local selectedList = {}
            for option, selected in pairs(selectedOptions) do
                if selected then
                    selectedCount = selectedCount + 1
                    table.insert(selectedList, option)
                end
            end
            
            if selectedCount == 0 then
                dropdown.Text = "Select " .. (config.Name or "Options") .. "..."
            elseif selectedCount == 1 then
                dropdown.Text = selectedList[1]
            else
                dropdown.Text = selectedCount .. " " .. (config.Name or "options") .. " selected"
            end
            
            if config.Flag then
                Ember.Flags[config.Flag] = selectedList
            end
            
            if config.Callback then
                config.Callback(selectedList)
            end
        else
            for option, selected in pairs(selectedOptions) do
                if selected then
                    dropdown.Text = option
                    if config.Flag then
                        Ember.Flags[config.Flag] = option
                    end
                    if config.Callback then
                        config.Callback(option)
                    end
                    break
                end
            end
        end
    end
    
    local function toggleOptionSelection(option)
        if option == "<Select All>" then
            if areAllOptionsSelected() then
                unselectAllOptions()
            else
                selectAllOptions()
            end
        else
            if multiSelect then
                selectedOptions[option] = not isOptionSelected(option)
            else
                selectedOptions = {}
                selectedOptions[option] = true
            end
        end
        updateDropdownText()
    end
    
    local function createOptionButton(option, isSelectAll)
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option
        optionButton.Parent = scrollFrame
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, 22)
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextColor3 = textColor
        optionButton.TextSize = 11
        optionButton.TextXAlignment = Enum.TextXAlignment.Center
        optionButton.ZIndex = 12
        optionButton.LayoutOrder = isSelectAll and 0 or 1
        optionButton.AutoButtonColor = false
        
        createCorner(optionButton, 2)
        
        local function updateOptionAppearance()
            local isSelected = isSelectAll and areAllOptionsSelected() or isOptionSelected(option)
            optionButton.BackgroundColor3 = isSelected and accentColor or buttonColor
            if multiSelect then
                optionButton.Text = (isSelected and "✓ " or "") .. option
            else
                optionButton.Text = option
            end
        end
        
        updateOptionAppearance()
        
        optionButton.MouseButton1Click:Connect(function()
            toggleOptionSelection(option)
            if multiSelect then
                for _, child in pairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isChildSelectAll = child.Name == "<Select All>"
                        local isChildSelected = isChildSelectAll and areAllOptionsSelected() or isOptionSelected(child.Name)
                        child.BackgroundColor3 = isChildSelected and accentColor or buttonColor
                        child.Text = (isChildSelected and "✓ " or "") .. child.Name
                    end
                end
            else
                for _, child in pairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isChildSelected = isOptionSelected(child.Name)
                        child.BackgroundColor3 = isChildSelected and accentColor or buttonColor
                    end
                end
                listFrame.Visible = false
                arrow.Text = "▼"
                dropdownOpen = false
            end
        end)
        
        return optionButton
    end
    
    local function rebuildOptions()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        if multiSelect then
            createOptionButton("<Select All>", true)
        end
        
        for _, option in ipairs(config.Options) do
            createOptionButton(option, false)
        end
        
        local itemCount = multiSelect and (#config.Options + 1) or #config.Options
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 22)
        listFrame.Size = UDim2.new(1, -20, 0, math.min(itemCount * 22, 100))
    end
    
    rebuildOptions()
    updateDropdownText()
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        listFrame.Visible = dropdownOpen
        arrow.Text = dropdownOpen and "▲" or "▼"
        
        if dropdownOpen then
            local dropdownPos = dropdown.AbsolutePosition
            local dropdownSize = dropdown.AbsoluteSize
            listFrame.Position = UDim2.new(0, 10, 0, dropdownPos.Y + dropdownSize.Y - self.Main.AbsolutePosition.Y + 5)
        end
    end)
    
    return dropdown
end

function Window:CreateSlider(config)
    self.ElementCount = self.ElementCount + 1

    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = config.Name or "Slider"
    sliderContainer.Parent = self.ButtonContainer
    sliderContainer.BackgroundColor3 = buttonColor
    sliderContainer.BorderSizePixel = 0
    sliderContainer.Size = UDim2.new(1, 0, 0, 26)
    sliderContainer.LayoutOrder = self.ElementCount

    createCorner(sliderContainer, 4)

    local fillBar = Instance.new("Frame")
    fillBar.Name = "FillBar"
    fillBar.Parent = sliderContainer
    fillBar.BackgroundColor3 = accentColor
    fillBar.BorderSizePixel = 0
    fillBar.Position = UDim2.new(0, 0, 0, 0)
    fillBar.Size = UDim2.new(0, 0, 1, 0)
    fillBar.ZIndex = 1
    createCorner(fillBar, 4)

    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Parent = sliderContainer
    sliderButton.BackgroundTransparency = 1
    sliderButton.BorderSizePixel = 0
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.Font = Enum.Font.Gotham
    sliderButton.TextColor3 = textColor
    sliderButton.TextSize = 11
    sliderButton.AutoButtonColor = false
    sliderButton.TextXAlignment = Enum.TextXAlignment.Center
    sliderButton.TextYAlignment = Enum.TextYAlignment.Center
    sliderButton.ZIndex = 2

    local currentValue = config.CurrentValue or config.Range[1]
    local minValue, maxValue = config.Range[1], config.Range[2]
    local increment = config.Increment or 1

    if config.Flag then
        Ember.Flags[config.Flag] = currentValue
    end

    local function updateSlider(value)
        value = math.clamp(value, minValue, maxValue)
        if increment > 0 then
            value = math.floor(value / increment + 0.5) * increment
        end

        currentValue = value
        sliderButton.Text = (config.Name or "Slider") .. ": " .. tostring(value) .. (config.Suffix or "")

        local percent = (value - minValue) / (maxValue - minValue)
        fillBar.Size = UDim2.new(percent, 0, 1, 0)

        if config.Flag then
            Ember.Flags[config.Flag] = currentValue
        end

        if config.Callback then
            config.Callback(value)
        end
    end

    updateSlider(currentValue)

    local dragging = false

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self.Main.Draggable = false

            local percentage = math.clamp((input.Position.X - sliderButton.AbsolutePosition.X) / sliderButton.AbsoluteSize.X, 0, 1)
            local value = minValue + (maxValue - minValue) * percentage
            updateSlider(value)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = math.clamp((input.Position.X - sliderButton.AbsolutePosition.X) / sliderButton.AbsoluteSize.X, 0, 1)
            local value = minValue + (maxValue - minValue) * percentage
            updateSlider(value)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            self.Main.Draggable = true
        end
    end)

    return sliderContainer
end

function Window:CreateTextBox(config)
    self.ElementCount = self.ElementCount + 1

    local textBox = Instance.new("TextBox")
    textBox.Name = config.Name or "TextBox"
    textBox.Parent = self.ButtonContainer
    textBox.BackgroundColor3 = buttonColor
    textBox.BorderSizePixel = 0
    textBox.Size = UDim2.new(1, 0, 0, 26)
    textBox.Font = Enum.Font.Gotham
    textBox.TextColor3 = textColor
    textBox.TextSize = 11
    textBox.ClearTextOnFocus = false
    textBox.LayoutOrder = self.ElementCount

    createCorner(textBox, 4)

    local initialText = config.CurrentValue or config.Text or ""
    if initialText ~= "" then
        textBox.Text = ""
        textBox.PlaceholderText = (config.Name or "Value") .. ": " .. initialText
    else
        textBox.Text = ""
        textBox.PlaceholderText = config.PlaceholderText or (config.Name or "Enter value...")
    end

    if config.Flag then
        Ember.Flags[config.Flag] = initialText
    end

    textBox.FocusLost:Connect(function(enterPressed)
        if config.Flag then
            Ember.Flags[config.Flag] = textBox.Text
        end

        if config.Callback then
            config.Callback(textBox.Text)
        end

        if textBox.Text ~= "" then
            local label = (config.Name or "Value") .. ": " .. textBox.Text
            textBox.PlaceholderText = label
            textBox.Text = ""
        end
    end)

    return textBox
end

function Window:Toggle()
    self.Main.Visible = not self.Main.Visible
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function Ember:CreateWindow(config)
    local window = setmetatable({
        Name = config.Name or "Ember UI",
        ElementCount = 0
    }, {__index = Window})

    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "EmberUI"
    window.ScreenGui.Parent = Players.LocalPlayer.PlayerGui

    window.Main = Instance.new("Frame")
    window.Main.Name = "Main"
    window.Main.Parent = window.ScreenGui
    window.Main.BackgroundColor3 = primaryColor
    window.Main.BorderSizePixel = 0
    window.Main.Position = UDim2.new(0.4, 0, 0.3, 0)
    window.Main.Size = UDim2.new(0, 200, 0, 195)
    window.Main.Active = true
    window.Main.Draggable = true

    createCorner(window.Main, 6)

    window.Header = Instance.new("TextLabel")
    window.Header.Name = "Header"
    window.Header.Parent = window.Main
    window.Header.BackgroundColor3 = accentColor
    window.Header.BorderSizePixel = 0
    window.Header.Size = UDim2.new(1, 0, 0, 25)
    window.Header.Font = Enum.Font.GothamBold
    window.Header.TextColor3 = textColor
    window.Header.Text = window.Name
    window.Header.TextSize = 12

    createCorner(window.Header, 6)

    local exitButton = Instance.new("TextButton")
    exitButton.Name = "ExitButton"
    exitButton.Parent = window.Main
    exitButton.BackgroundColor3 = exitButtonColor
    exitButton.BorderSizePixel = 0
    exitButton.Position = UDim2.new(1, -20, 0, 5)
    exitButton.Size = UDim2.new(0, 15, 0, 15)
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Text = "×"
    exitButton.TextColor3 = textColor
    exitButton.TextSize = 12
    exitButton.ZIndex = 15
    exitButton.AutoButtonColor = false

    createCorner(exitButton, 3)

    local exitClickCount = 0
    exitButton.MouseButton1Click:Connect(function()
        exitClickCount = exitClickCount + 1
        if exitClickCount == 1 then
            exitButton.Text = "!"
            spawn(function()
                wait(3)
                if exitClickCount == 1 then
                    exitClickCount = 0
                    exitButton.Text = "×"
                end
            end)
        elseif exitClickCount >= 2 then
            window:Destroy()
        end
    end)

    window.ButtonContainer = Instance.new("Frame")
    window.ButtonContainer.Name = "ButtonContainer"
    window.ButtonContainer.Parent = window.Main
    window.ButtonContainer.BackgroundTransparency = 1
    window.ButtonContainer.Position = UDim2.new(0, 10, 0, 32)
    window.ButtonContainer.Size = UDim2.new(1, -20, 1, -90)

    local layout = createLayout(window.ButtonContainer, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function updateWindowSize()
        local totalHeight = 0
        local paddingBetweenItems = 6
        
        local visibleCount = 0
        for _, child in pairs(window.ButtonContainer:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible and not child:IsA("UIListLayout") then
                totalHeight = totalHeight + child.Size.Y.Offset
                visibleCount = visibleCount + 1
            end
        end
        
        if visibleCount > 1 then
            totalHeight = totalHeight + ((visibleCount - 1) * paddingBetweenItems)
        end
        
        local minHeight = 100
        local containerPadding = 39
        local frameHeight = math.max(minHeight, totalHeight + containerPadding)
        
        window.Main.Size = UDim2.new(0, 200, 0, frameHeight)
    end
    
    window.ButtonContainer.ChildAdded:Connect(function()
        task.wait()
        updateWindowSize()
    end)
    
    window.ButtonContainer.ChildRemoved:Connect(updateWindowSize)
    
    return window
end

return Ember
