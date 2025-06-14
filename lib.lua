local Ember = {}
Ember.__index = Ember
Ember.Flags = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer

-- Color scheme
local primaryColor = Color3.fromRGB(35, 35, 35)
local accentColor = Color3.fromRGB(126, 11, 11)
local successColor = Color3.fromRGB(126, 11, 11)
local textColor = Color3.fromRGB(255, 255, 255)
local buttonColor = Color3.fromRGB(50, 50, 50)

-- Utility functions
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

-- Window class
local Window = {}
Window.__index = Window

function Window:CreateTab(name)
    local tab = setmetatable({
        Name = name,
        Window = self,
        Elements = {},
        ElementCount = 0
    }, {__index = self})
    
    -- For now, just return the tab (single tab design)
    return tab
end

function Window:CreateToggle(config)
    self.ElementCount = self.ElementCount + 1
    
    local toggle = Instance.new("TextButton")
    toggle.Name = config.Name or "Toggle"
    toggle.Parent = self.ButtonContainer
    toggle.BackgroundColor3 = config.CurrentValue and successColor or buttonColor
    toggle.BorderSizePixel = 0
    toggle.Size = UDim2.new(1, 0, 0, 26)
    toggle.Font = Enum.Font.Gotham
    toggle.Text = (config.Name or "Toggle") .. ": " .. (config.CurrentValue and "ON" or "OFF")
    toggle.TextColor3 = textColor
    toggle.TextSize = 11
    toggle.LayoutOrder = self.ElementCount
    
    createCorner(toggle)
    
    -- Store current value
    local currentValue = config.CurrentValue or false
    if config.Flag then
        Ember.Flags[config.Flag] = currentValue
    end
    
    toggle.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        toggle.BackgroundColor3 = currentValue and successColor or buttonColor
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
    
    createCorner(button)
    
    button.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = buttonColor
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
    
    createCorner(dropdown)
    
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Parent = dropdown
    arrow.BackgroundTransparency = 1
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Position = UDim2.new(0.95, 0, 0.5, 0)
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
    listFrame.Size = UDim2.new(1, -20, 0, math.min((#config.Options + 1) * 22, 100)) -- +1 for Select All
    listFrame.Visible = false
    listFrame.ZIndex = 10
    
    createCorner(listFrame)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = listFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = accentColor
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (#config.Options + 1) * 22) -- +1 for Select All
    scrollFrame.ZIndex = 11
    
    createLayout(scrollFrame, 0)
    
    -- Store current values (support multiple selection)
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
    
    -- Helper functions for multi-select
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
            
            -- Update flag with selected options array
            if config.Flag then
                Ember.Flags[config.Flag] = selectedList
            end
            
            -- Call callback with selected options
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
                -- Update all option buttons for multi-select
                for _, child in pairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isChildSelectAll = child.Name == "<Select All>"
                        local isChildSelected = isChildSelectAll and areAllOptionsSelected() or isOptionSelected(child.Name)
                        child.BackgroundColor3 = isChildSelected and accentColor or buttonColor
                        child.Text = (isChildSelected and "✓ " or "") .. child.Name
                    end
                end
            else
                -- Update all option buttons for single-select
                for _, child in pairs(scrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isChildSelected = isOptionSelected(child.Name)
                        child.BackgroundColor3 = isChildSelected and accentColor or buttonColor
                    end
                end
                -- Close dropdown for single select
                listFrame.Visible = false
                arrow.Text = "▼"
                dropdownOpen = false
            end
        end)
        
        -- Hover effects
        optionButton.MouseEnter:Connect(function()
            local isSelected = isSelectAll and areAllOptionsSelected() or isOptionSelected(option)
            if not isSelected then
                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end)
        
        optionButton.MouseLeave:Connect(function()
            local isSelected = isSelectAll and areAllOptionsSelected() or isOptionSelected(option)
            optionButton.BackgroundColor3 = isSelected and accentColor or buttonColor
        end)
        
        return optionButton
    end
    
    local function rebuildOptions()
        -- Clear existing options
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add Select All option if multi-select
        if multiSelect then
            createOptionButton("<Select All>", true)
        end
        
        -- Add regular options
        for _, option in ipairs(config.Options) do
            createOptionButton(option, false)
        end
        
        -- Update canvas size
        local itemCount = multiSelect and (#config.Options + 1) or #config.Options
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 22)
        listFrame.Size = UDim2.new(1, -20, 0, math.min(itemCount * 22, 100))
    end
    
    -- Initial setup
    rebuildOptions()
    updateDropdownText()
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        listFrame.Visible = dropdownOpen
        arrow.Text = dropdownOpen and "▲" or "▼"
        
        if dropdownOpen then
            -- Position the dropdown
            local dropdownPos = dropdown.AbsolutePosition
            local dropdownSize = dropdown.AbsoluteSize
            listFrame.Position = UDim2.new(0, 10, 0, dropdownPos.Y + dropdownSize.Y - self.Main.AbsolutePosition.Y + 5)
        end
    end)
    
    return dropdown
end

function Window:CreateSlider(config)
    self.ElementCount = self.ElementCount + 1
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = config.Name or "Slider"
    sliderFrame.Parent = self.ButtonContainer
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.LayoutOrder = self.ElementCount
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = sliderFrame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Font = Enum.Font.Gotham
    label.Text = (config.Name or "Slider") .. ": " .. (config.CurrentValue or config.Range[1])
    label.TextColor3 = textColor
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBackground"
    sliderBg.Parent = sliderFrame
    sliderBg.BackgroundColor3 = buttonColor
    sliderBg.BorderSizePixel = 0
    sliderBg.Position = UDim2.new(0, 0, 0, 18)
    sliderBg.Size = UDim2.new(1, 0, 0, 18)
    
    createCorner(sliderBg, 2)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = accentColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    
    createCorner(sliderFill, 2)
    
    -- Store current value
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
        local percentage = (value - minValue) / (maxValue - minValue)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        label.Text = (config.Name or "Slider") .. ": " .. value .. (config.Suffix or "")
        
        if config.Flag then
            Ember.Flags[config.Flag] = currentValue
        end
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    -- Initialize slider
    updateSlider(currentValue)
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percentage = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = minValue + (maxValue - minValue) * percentage
            updateSlider(value)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = minValue + (maxValue - minValue) * percentage
            updateSlider(value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return sliderFrame
end

function Window:CreateLabel(text)
    self.ElementCount = self.ElementCount + 1
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = self.ButtonContainer
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = text or "Label"
    label.TextColor3 = textColor
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.LayoutOrder = self.ElementCount
    
    return label
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
    textBox.PlaceholderText = config.PlaceholderText or "Enter text..."
    textBox.Text = ""
    textBox.TextColor3 = textColor
    textBox.TextSize = 11
    textBox.ClearTextOnFocus = false
    textBox.LayoutOrder = self.ElementCount
    
    createCorner(textBox)
    
    if config.Flag then
        Ember.Flags[config.Flag] = ""
    end
    
    textBox.FocusLost:Connect(function(enterPressed)
        if config.Flag then
            Ember.Flags[config.Flag] = textBox.Text
        end
        
        if config.Callback then
            config.Callback(textBox.Text)
        end
        
        if config.RemoveTextAfterFocusLost then
            textBox.Text = ""
        end
    end)
    
    return textBox
end

function Window:CreateKeybind(config)
    self.ElementCount = self.ElementCount + 1
    
    local keybind = Instance.new("TextButton")
    keybind.Name = config.Name or "Keybind"
    keybind.Parent = self.ButtonContainer
    keybind.BackgroundColor3 = buttonColor
    keybind.BorderSizePixel = 0
    keybind.Size = UDim2.new(1, 0, 0, 26)
    keybind.Font = Enum.Font.Gotham
    keybind.Text = (config.Name or "Keybind") .. ": " .. (config.CurrentKeybind and config.CurrentKeybind.Name or "None")
    keybind.TextColor3 = textColor
    keybind.TextSize = 11
    keybind.LayoutOrder = self.ElementCount
    
    createCorner(keybind)
    
    local currentKeybind = config.CurrentKeybind
    local holdToInteract = config.HoldToInteract or false
    local isHolding = false
    
    if config.Flag then
        Ember.Flags[config.Flag] = currentKeybind
    end
    
    local listening = false
    
    keybind.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keybind.Text = (config.Name or "Keybind") .. ": ..."
            keybind.BackgroundColor3 = accentColor
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKeybind = input.KeyCode
                keybind.Text = (config.Name or "Keybind") .. ": " .. input.KeyCode.Name
                keybind.BackgroundColor3 = buttonColor
                listening = false
                
                if config.Flag then
                    Ember.Flags[config.Flag] = currentKeybind
                end
            end
        elseif currentKeybind and input.KeyCode == currentKeybind then
            if holdToInteract then
                isHolding = true
                if config.Callback then
                    config.Callback()
                end
            else
                if config.Callback then
                    config.Callback()
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if currentKeybind and input.KeyCode == currentKeybind and holdToInteract and isHolding then
            isHolding = false
        end
    end)
    
    return keybind
end

function Window:Toggle()
    self.Main.Visible = not self.Main.Visible
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Main Ember functions
function Ember:CreateWindow(config)
    local window = setmetatable({
        Name = config.Name or "Ember UI",
        ElementCount = 0
    }, {__index = Window})
    
    -- Create ScreenGui
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "EmberUI"
    window.ScreenGui.Parent = game.CoreGui
    
    -- Create Main Frame
    window.Main = Instance.new("Frame")
    window.Main.Name = "Main"
    window.Main.Parent = window.ScreenGui
    window.Main.BackgroundColor3 = primaryColor
    window.Main.BorderSizePixel = 0
    window.Main.Position = UDim2.new(0.4, 0, 0.3, 0)
    window.Main.Size = UDim2.new(0, 200, 0, 200)
    window.Main.Active = true
    window.Main.Draggable = true
    
    createCorner(window.Main, 6)
    
    -- Create Header
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
    
    -- Create Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = window.Header
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 25, 1, 0)
    closeButton.Position = UDim2.new(1, -25, 0, 0)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = textColor
    closeButton.TextSize = 14
    closeButton.ZIndex = 2
    
    local exitClickCount = 0
    closeButton.MouseButton1Click:Connect(function()
        exitClickCount = exitClickCount + 1
        
        if exitClickCount == 1 then
            closeButton.Text = "!"
            spawn(function()
                wait(3)
                if exitClickCount == 1 then
                    exitClickCount = 0
                    closeButton.Text = "×"
                end
            end)
        elseif exitClickCount >= 2 then
            window:Destroy()
        end
    end)
    
    -- Hover effects for close button
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundTransparency = 0.8
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundTransparency = 1
    end)
    
    -- Create Button Container
    window.ButtonContainer = Instance.new("Frame")
    window.ButtonContainer.Name = "ButtonContainer"
    window.ButtonContainer.Parent = window.Main
    window.ButtonContainer.BackgroundTransparency = 1
    window.ButtonContainer.Position = UDim2.new(0, 10, 0, 32)
    window.ButtonContainer.Size = UDim2.new(1, -20, 1, -40)
    
    -- Store reference to layout before creating elements
    local layout = createLayout(window.ButtonContainer, 6)
    window.ButtonContainer.UIListLayout = layout
    
    -- Auto-resize function
    local function updateWindowSize()
        local contentHeight = 32 -- Header height (25) + top padding (7)
        local layoutPadding = 6
        local elementCount = 0
        
        for _, child in pairs(window.ButtonContainer:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible and not child:IsA("UIListLayout") then
                contentHeight = contentHeight + child.Size.Y.Offset
                elementCount = elementCount + 1
            end
        end
        
        -- Add padding between elements
        if elementCount > 1 then
            contentHeight = contentHeight + (elementCount - 1) * layoutPadding
        end
        
        contentHeight = contentHeight + 7 -- Bottom padding
        
        window.Main.Size = UDim2.new(0, 200, 0, math.max(contentHeight, 100))
        
        -- Update ButtonContainer size to match new window size
        window.ButtonContainer.Size = UDim2.new(1, -20, 1, -(32 + 7))
    end
    
    -- Connect to layout changes
    window.ButtonContainer.ChildAdded:Connect(updateWindowSize)
    window.ButtonContainer.ChildRemoved:Connect(updateWindowSize)
    
    -- Initial size update
    spawn(function() 
        wait(0.1) -- Wait for initial UI elements to be added
        updateWindowSize()
    end)
    
    return window
end

return Ember
