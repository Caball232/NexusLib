-- ////////////////////////////////////////////
--   NexusUI  |  FULL FINAL VERSION
--   Draggable Top Bar + Fixed Dropdown
-- ////////////////////////////////////////////

local NexusUI = {}
NexusUI.__index = NexusUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--   UTILITIES
-- ============================================================

local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--   ICONS (Simple & Reliable)
-- ============================================================

NexusUI.Icons = {
    home = "rbxassetid://7072706663",
    sword = "rbxassetid://7072722913",
    zap = "rbxassetid://7072726564",
    settings = "rbxassetid://7072719169",
}

-- ============================================================
--   CREATE WINDOW
-- ============================================================

function NexusUI:CreateWindow(config)
    config = config or {}

    local cfg = {
        Title = config.Title or "NexusUI",
        Subtitle = config.Subtitle or "Hub",
        Icon = config.Icon or nil,
        AccentColor = config.AccentColor or Color3.fromRGB(139, 92, 246),
        BgColor = config.BgColor or Color3.fromRGB(15, 15, 23),
        SideColor = config.SideColor or Color3.fromRGB(10, 10, 18),
        TextColor = config.TextColor or Color3.fromRGB(225, 225, 240),
        MutedColor = config.MutedColor or Color3.fromRGB(140, 140, 170),
        Width = config.Width or 590,
        Height = config.Height or 420,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
    }

    local screenGui = Create("ScreenGui", {
        Name = "NexusUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
    })

    local main = Create("Frame", {
        Name = "Main", Size = UDim2.new(0, cfg.Width, 0, cfg.Height),
        Position = UDim2.new(0.5, -cfg.Width/2, 0.5, -cfg.Height/2),
        BackgroundColor3 = cfg.BgColor, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = screenGui,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 14)}):Clone().Parent = main

    Create("ImageLabel", {
        Size = UDim2.new(1,40,1,40), Position = UDim2.new(0,-20,0,-20),
        BackgroundTransparency = 1, Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10,10,118,118),
        ZIndex = -1, Parent = main,
    })

    -- Top Bar
    local topBar = Create("Frame", {
        Name = "TopBar", Size = UDim2.new(1,0,0,52),
        BackgroundColor3 = cfg.BgColor, BorderSizePixel = 0, Parent = main,
    })
    Create("UICorner", {CornerRadius = UDim.new(0,14)}):Clone().Parent = topBar

    local titleX = 16
    if cfg.Icon then
        local iconId = NexusUI.Icons[cfg.Icon] or cfg.Icon
        Create("ImageLabel", {Size = UDim2.new(0,24,0,24), Position = UDim2.new(0,16,0.5,-12),
            BackgroundTransparency = 1, Image = iconId, ImageColor3 = cfg.AccentColor, Parent = topBar})
        titleX = 52
    end

    Create("TextLabel", {Size = UDim2.new(0.6,0,0,22), Position = UDim2.new(0,titleX,0.5,-14),
        BackgroundTransparency = 1, Text = cfg.Title, TextColor3 = cfg.TextColor,
        TextSize = 17, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar})

    Create("TextLabel", {Size = UDim2.new(0.6,0,0,14), Position = UDim2.new(0,titleX,0.5,6),
        BackgroundTransparency = 1, Text = cfg.Subtitle, TextColor3 = cfg.MutedColor,
        TextSize = 11.5, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar})

    -- Close Button (Text X - Reliable)
    local closeBtn = Create("TextButton", {Size = UDim2.new(0,32,0,32), Position = UDim2.new(1,-40,0.5,-16),
        BackgroundColor3 = Color3.fromRGB(45,15,20), Text = "✕",
        TextColor3 = Color3.fromRGB(255,90,100), TextSize = 18,
        Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = topBar})
    Create("UICorner", {CornerRadius = UDim.new(0,8)}):Clone().Parent = closeBtn

    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(60,20,25)}, 0.15) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(45,15,20)}, 0.15) end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, {Size = UDim2.new(0, cfg.Width, 0, 0)}, 0.3)
        task.wait(0.32)
        main.Visible = false
        main.Size = UDim2.new(0, cfg.Width, 0, cfg.Height)
    end)

    -- Sidebar
    local sidebar = Create("Frame", {Name = "Sidebar", Size = UDim2.new(0,152,1,-52),
        Position = UDim2.new(0,0,0,52), BackgroundColor3 = cfg.SideColor, BorderSizePixel = 0, Parent = main})
    Create("UICorner", {CornerRadius = UDim.new(0,12)}):Clone().Parent = sidebar

    local tabList = Create("ScrollingFrame", {Size = UDim2.new(1,0,1,-10), Position = UDim2.new(0,0,0,8),
        BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = sidebar})
    Create("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}):Clone().Parent = tabList
    Create("UIPadding", {PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)}):Clone().Parent = tabList

    local contentArea = Create("Frame", {Name = "Content", Size = UDim2.new(1,-160,1,-60),
        Position = UDim2.new(0,156,0,54), BackgroundTransparency = 1, ClipsDescendants = true, Parent = main})

    MakeDraggable(main, topBar)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == cfg.ToggleKey then main.Visible = not main.Visible end
    end)

    local Window = {_cfg = cfg, _tabList = tabList, _contentArea = contentArea, _tabs = {}, _activeTab = nil}

    -- Tab System
    function Window:CreateTab(name, icon)
        local btn = Create("TextButton", {Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, AutoButtonColor = false, Parent = self._tabList})
        Create("UICorner", {CornerRadius = UDim.new(0,9)}):Clone().Parent = btn

        local xOffset = 12
        if icon then
            local iconId = NexusUI.Icons[icon] or icon
            Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,xOffset,0.5,-9),
                BackgroundTransparency = 1, Image = iconId, ImageColor3 = cfg.MutedColor, Parent = btn})
            xOffset = 38
        end

        Create("TextLabel", {Size = UDim2.new(1,-xOffset-12,1,0), Position = UDim2.new(0,xOffset,0,0),
            BackgroundTransparency = 1, Text = name, TextColor3 = cfg.MutedColor,
            TextSize = 14, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})

        local tabFrame = Create("ScrollingFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
            ScrollBarThickness = 4, ScrollBarImageColor3 = cfg.AccentColor, Visible = false, Parent = contentArea})
        Create("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder}):Clone().Parent = tabFrame
        Create("UIPadding", {PaddingTop = UDim.new(0,8), PaddingRight = UDim.new(0,12), PaddingBottom = UDim.new(0,8)}):Clone().Parent = tabFrame

        local tabObj = {_frame = tabFrame, _btn = btn}

        btn.MouseButton1Click:Connect(function() self:_SelectTab(tabObj) end)
        btn.MouseEnter:Connect(function() if self._activeTab ~= tabObj then Tween(btn, {BackgroundTransparency = 0.88}, 0.15) end end)
        btn.MouseLeave:Connect(function() if self._activeTab ~= tabObj then Tween(btn, {BackgroundTransparency = 1}, 0.15) end end)

        table.insert(self._tabs, tabObj)
        if #self._tabs == 1 then self:_SelectTab(tabObj) end

        self:_AttachComponents(tabObj)
        return tabObj
    end

    function Window:_SelectTab(tabObj)
        if self._activeTab then
            local p = self._activeTab
            p._frame.Visible = false
            Tween(p._btn, {BackgroundTransparency = 1}, 0.2)
            local lbl = p._btn:FindFirstChildWhichIsA("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = cfg.MutedColor}, 0.2) end
        end
        self._activeTab = tabObj
        tabObj._frame.Visible = true
        Tween(tabObj._btn, {BackgroundTransparency = 0.92}, 0.2)
        local lbl = tabObj._btn:FindFirstChildWhichIsA("TextLabel")
        if lbl then Tween(lbl, {TextColor3 = cfg.AccentColor}, 0.2) end
    end

    -- All Components
    function Window:_AttachComponents(tab)
        local cfg = self._cfg

        local function BaseRow(height)
            local row = Create("Frame", {Size = UDim2.new(1,0,0,height or 46),
                BackgroundColor3 = Color3.fromRGB(20,20,33), BorderSizePixel = 0, Parent = tab._frame})
            Create("UICorner", {CornerRadius = UDim.new(0,10)}):Clone().Parent = row
            return row
        end

        function tab:CreateSection(name)
            local sec = Create("Frame", {Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1, Parent = self._frame})
            Create("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = name:upper(), TextColor3 = cfg.AccentColor, TextSize = 11.5,
                Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = sec})
        end

        function tab:CreateToggle(config)
            config = config or {}
            local value = config.Default or false
            local row = BaseRow(config.Description and 58 or 46)

            Create("TextLabel", {Size = UDim2.new(1,-80,0,20), Position = UDim2.new(0,16,0,8),
                BackgroundTransparency = 1, Text = config.Name or "Toggle",
                TextColor3 = cfg.TextColor, TextSize = 14, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

            if config.Description then
                Create("TextLabel", {Size = UDim2.new(1,-80,0,14), Position = UDim2.new(0,16,0,28),
                    BackgroundTransparency = 1, Text = config.Description,
                    TextColor3 = cfg.MutedColor, TextSize = 11, Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
            end

            local track = Create("Frame", {Size = UDim2.new(0,42,0,22), Position = UDim2.new(1,-58,0.5,-11),
                BackgroundColor3 = Color3.fromRGB(35,35,55), Parent = row})
            Create("UICorner", {CornerRadius = UDim.new(1,0)}):Clone().Parent = track

            local knob = Create("Frame", {Size = UDim2.new(0,18,0,18),
                Position = value and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
                BackgroundColor3 = value and cfg.AccentColor or Color3.fromRGB(200,200,200), Parent = track})
            Create("UICorner", {CornerRadius = UDim.new(1,0)}):Clone().Parent = knob

            local btn = Create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = row})

            btn.MouseButton1Click:Connect(function()
                value = not value
                if value then
                    Tween(knob, {Position = UDim2.new(1,-20,0.5,-9), BackgroundColor3 = cfg.AccentColor}, 0.2)
                    Tween(track, {BackgroundColor3 = Color3.fromRGB(40,30,70)}, 0.2)
                else
                    Tween(knob, {Position = UDim2.new(0,2,0.5,-9), BackgroundColor3 = Color3.fromRGB(200,200,200)}, 0.2)
                    Tween(track, {BackgroundColor3 = Color3.fromRGB(35,35,55)}, 0.2)
                end
                if config.Callback then config.Callback(value) end
            end)

            return {GetValue = function() return value end}
        end

        function tab:CreateSlider(config)
            config = config or {}
            local min, max = config.Min or 0, config.Max or 100
            local value = config.Default or min
            local row = BaseRow(58)

            Create("TextLabel", {Size = UDim2.new(1,-80,0,16), Position = UDim2.new(0,16,0,8),
                BackgroundTransparency = 1, Text = config.Name or "Slider",
                TextColor3 = cfg.TextColor, TextSize = 14, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

            local valLabel = Create("TextLabel", {Size = UDim2.new(0,50,0,16), Position = UDim2.new(1,-64,0,8),
                BackgroundTransparency = 1, Text = tostring(value),
                TextColor3 = cfg.AccentColor, TextSize = 13, Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right, Parent = row})

            local trackBg = Create("Frame", {Size = UDim2.new(1,-32,0,6), Position = UDim2.new(0,16,0,36),
                BackgroundColor3 = Color3.fromRGB(35,35,55), Parent = row})
            Create("UICorner", {CornerRadius = UDim.new(1,0)}):Clone().Parent = trackBg

            local fill = Create("Frame", {Size = UDim2.new((value-min)/(max-min),0,1,0),
                BackgroundColor3 = cfg.AccentColor, Parent = trackBg})
            Create("UICorner", {CornerRadius = UDim.new(1,0)}):Clone().Parent = fill

            local knob = Create("Frame", {Size = UDim2.new(0,14,0,14),
                Position = UDim2.new((value-min)/(max-min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255,255,255), Parent = trackBg})
            Create("UICorner", {CornerRadius = UDim.new(1,0)}):Clone().Parent = knob

            local dragging = false

            local function update(pos)
                local absPos = trackBg.AbsolutePosition
                local absSize = trackBg.AbsoluteSize
                local rel = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                value = math.floor(min + rel * (max - min) + 0.5)
                value = math.clamp(value, min, max)
                local pct = (value - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -7, 0.5, -7)
                valLabel.Text = tostring(value)
                if config.Callback then config.Callback(value) end
            end

            local inputBtn = Create("TextButton", {Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0,-10),
                BackgroundTransparency = 1, Text = "", Parent = trackBg})

            inputBtn.MouseButton1Down:Connect(function()
                dragging = true
                update(UserInputService:GetMouseLocation())
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then update(UserInputService:GetMouseLocation()) end
            end)

            return {GetValue = function() return value end}
        end

        function tab:CreateButton(config)
            config = config or {}
            local row = BaseRow(46)
            local btn = Create("TextButton", {
                Size = UDim2.new(1,-28,0,32), Position = UDim2.new(0,14,0.5,-16),
                BackgroundColor3 = cfg.AccentColor, Text = config.Name or "Button",
                TextColor3 = Color3.new(1,1,1), TextSize = 14, Font = Enum.Font.GothamBold,
                AutoButtonColor = false, Parent = row,
            })
            Create("UICorner", {CornerRadius = UDim.new(0,8)}):Clone().Parent = btn

            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.2}, 0.1) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0}, 0.1) end)
            btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
        end

        function tab:CreateInput(config)
            config = config or {}
            local row = BaseRow(54)
            Create("TextLabel", {Size = UDim2.new(1,-28,0,16), Position = UDim2.new(0,16,0,8),
                BackgroundTransparency = 1, Text = config.Name or "Input",
                TextColor3 = cfg.TextColor, TextSize = 12, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

            local box = Create("TextBox", {
                Size = UDim2.new(1,-28,0,26), Position = UDim2.new(0,16,0,24),
                BackgroundColor3 = Color3.fromRGB(10,10,18), Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Enter here...",
                TextColor3 = cfg.TextColor, PlaceholderColor3 = cfg.MutedColor,
                TextSize = 13, Font = Enum.Font.Gotham, ClearTextOnFocus = true,
                Parent = row,
            })
            Create("UICorner", {CornerRadius = UDim.new(0,6)}):Clone().Parent = box

            box.FocusLost:Connect(function(enter) if config.Callback then config.Callback(box.Text, enter) end end)
            return {GetValue = function() return box.Text end}
        end

        function tab:CreateDropdown(config)
            config = config or {}
            local options = config.Options or {}
            local selected = config.Default or options[1] or ""
            local open = false
            local row = BaseRow(52)

            Create("TextLabel", {Size = UDim2.new(1,-28,0,16), Position = UDim2.new(0,16,0,6),
                BackgroundTransparency = 1, Text = config.Name or "Dropdown",
                TextColor3 = cfg.TextColor, TextSize = 13, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

            local selBtn = Create("TextButton", {Size = UDim2.new(1,-32,0,32), Position = UDim2.new(0,16,0,22),
                BackgroundColor3 = Color3.fromRGB(10,10,18), Text = "   " .. selected,
                TextColor3 = cfg.TextColor, TextSize = 14, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = row})
            Create("UICorner", {CornerRadius = UDim.new(0,8)}):Clone().Parent = selBtn

            local arrow = Create("TextLabel", {Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-28,0.5,-10),
                BackgroundTransparency = 1, Text = "▼", TextColor3 = cfg.MutedColor,
                TextSize = 14, Font = Enum.Font.GothamBold, Parent = selBtn})

            local dropFrame = Create("Frame", {Size = UDim2.new(1,-32,0, #options * 34 + 12),
                Position = UDim2.new(0,16,1,4), BackgroundColor3 = Color3.fromRGB(10,10,18),
                Visible = false, ZIndex = 10, Parent = row})
            Create("UICorner", {CornerRadius = UDim.new(0,8)}):Clone().Parent = dropFrame
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2)}):Clone().Parent = dropFrame
            Create("UIPadding", {PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6)}):Clone().Parent = dropFrame

            for _, opt in ipairs(options) do
                local optBtn = Create("TextButton", {Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1,
                    Text = "   " .. opt, TextColor3 = cfg.TextColor, TextSize = 14,
                    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = dropFrame})

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selBtn.Text = "   " .. selected
                    for _, c in ipairs(dropFrame:GetChildren()) do
                        if c:IsA("TextButton") then c.TextColor3 = cfg.TextColor end
                    end
                    optBtn.TextColor3 = cfg.AccentColor
                    open = false
                    dropFrame.Visible = false
                    row.Size = UDim2.new(1,0,0,52)
                    arrow.Rotation = 0
                    if config.Callback then config.Callback(selected) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                dropFrame.Visible = open
                row.Size = open and UDim2.new(1,0,0,52 + #options*34 + 16) or UDim2.new(1,0,0,52)
                arrow.Rotation = open and 180 or 0
            end)

            return {GetValue = function() return selected end}
        end

        function tab:CreateLabel(text, color)
            local row = Create("Frame", {Size = UDim2.new(1,0,0,32), BackgroundTransparency = 1, Parent = self._frame})
            Create("TextLabel", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                Text = text or "", TextColor3 = color or cfg.MutedColor,
                TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true, Parent = row,
            })
        end

        function tab:CreateKeybind(config)
            config = config or {}
            local key = config.Default or Enum.KeyCode.E
            local listening = false
            local row = BaseRow(46)

            Create("TextLabel", {Size = UDim2.new(1,-110,0,20), Position = UDim2.new(0,16,0.5,-10),
                BackgroundTransparency = 1, Text = config.Name or "Keybind",
                TextColor3 = cfg.TextColor, TextSize = 14, Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

            local keyBtn = Create("TextButton", {
                Size = UDim2.new(0,80,0,28), Position = UDim2.new(1,-94,0.5,-14),
                BackgroundColor3 = Color3.fromRGB(10,10,18), Text = key.Name,
                TextColor3 = cfg.AccentColor, TextSize = 13, Font = Enum.Font.GothamBold,
                AutoButtonColor = false, Parent = row,
            })
            Create("UICorner", {CornerRadius = UDim.new(0,6)}):Clone().Parent = keyBtn

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = cfg.MutedColor
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = input.KeyCode
                    keyBtn.Text = key.Name
                    keyBtn.TextColor3 = cfg.AccentColor
                    if config.Callback then config.Callback(key) end
                elseif not listening and not gpe and input.KeyCode == key then
                    if config.OnPress then config.OnPress() end
                end
            end)

            return {GetValue = function() return key end}
        end
    end

    return Window
end

return NexusUI
