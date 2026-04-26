-- ////////////////////////////////////////////
--   NexusUI  |  Custom Roblox UI Library
--   github.com/yourname/nexusui
--   Drop this file in your repo, loadstring it
-- ////////////////////////////////////////////

local NexusUI = {}
NexusUI.__index = NexusUI

-- Services
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
--   UTILITIES
-- ============================================================

local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
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
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--   ICONS  (inline SVG-style via ImageLabel using Lucide IDs)
--   Maps icon name -> Roblox rbxassetid
--   Add your own asset IDs here or use the name as a label fallback
-- ============================================================

NexusUI.Icons = {
    home        = "rbxassetid://7072706663",
    user        = "rbxassetid://7072724862",
    settings    = "rbxassetid://7072719169",
    eye         = "rbxassetid://7072708913",
    wheat       = "rbxassetid://7072726260",
    sword       = "rbxassetid://7072722913",
    zap         = "rbxassetid://7072726564",
    star        = "rbxassetid://7072721689",
    shield      = "rbxassetid://7072721073",
    crosshair   = "rbxassetid://7072707430",
    map         = "rbxassetid://7072713928",
    activity    = "rbxassetid://7072704534",
    box         = "rbxassetid://7072706088",
    bell        = "rbxassetid://7072705681",
    trash       = "rbxassetid://7072724108",
    refresh     = "rbxassetid://7072718441",
}

-- ============================================================
--   CREATE WINDOW
-- ============================================================

function NexusUI:CreateWindow(config)
    config = config or {}

    local cfg = {
        Title       = config.Title       or "NexusUI",
        Subtitle    = config.Subtitle    or "Hub",
        Icon        = config.Icon        or nil,       -- icon name (string) or rbxassetid (string)
        AccentColor = config.AccentColor or Color3.fromRGB(139, 92, 246),  -- purple default
        BgColor     = config.BgColor     or Color3.fromRGB(15, 15, 23),
        SideColor   = config.SideColor   or Color3.fromRGB(10, 10, 18),
        TextColor   = config.TextColor   or Color3.fromRGB(225, 225, 240),
        MutedColor  = config.MutedColor  or Color3.fromRGB(90, 90, 120),
        Width       = config.Width       or 560,
        Height      = config.Height      or 380,
        ToggleKey   = config.ToggleKey   or Enum.KeyCode.RightShift,
    }

    -- ScreenGui
    local screenGui = Create("ScreenGui", {
        Name            = "NexusUI",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = (RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")),
    })

    -- Main Frame
    local main = Create("Frame", {
        Name            = "Main",
        Size            = UDim2.new(0, cfg.Width, 0, cfg.Height),
        Position        = UDim2.new(0.5, -cfg.Width/2, 0.5, -cfg.Height/2),
        BackgroundColor3 = cfg.BgColor,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }, {}):Clone().Parent = main

    -- Accent top bar line
    Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 2),
        Position        = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = cfg.AccentColor,
        BorderSizePixel = 0,
        Parent          = main,
    })

    -- Sidebar
    local sidebar = Create("Frame", {
        Name            = "Sidebar",
        Size            = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = cfg.SideColor,
        BorderSizePixel = 0,
        Parent          = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10) }):Clone().Parent = sidebar

    -- Fix sidebar right-side corners
    Create("Frame", {
        Size            = UDim2.new(0, 10, 1, 0),
        Position        = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = cfg.SideColor,
        BorderSizePixel = 0,
        Parent          = sidebar,
    })

    -- Logo area
    local logoFrame = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent          = sidebar,
    })

    -- Icon
    if cfg.Icon then
        local iconId = NexusUI.Icons[cfg.Icon] or cfg.Icon
        Create("ImageLabel", {
            Size            = UDim2.new(0, 20, 0, 20),
            Position        = UDim2.new(0, 14, 0.5, -10),
            BackgroundTransparency = 1,
            Image           = iconId,
            ImageColor3     = cfg.AccentColor,
            Parent          = logoFrame,
        })
    end

    Create("TextLabel", {
        Size            = UDim2.new(1, -20, 0, 20),
        Position        = UDim2.new(0, cfg.Icon and 40 or 14, 0.5, -10),
        BackgroundTransparency = 1,
        Text            = cfg.Title,
        TextColor3      = cfg.TextColor,
        TextSize        = 15,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = logoFrame,
    })

    Create("TextLabel", {
        Size            = UDim2.new(1, -20, 0, 14),
        Position        = UDim2.new(0, cfg.Icon and 40 or 14, 0.5, 12),
        BackgroundTransparency = 1,
        Text            = cfg.Subtitle,
        TextColor3      = cfg.MutedColor,
        TextSize        = 11,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        Parent          = logoFrame,
    })

    -- Separator
    Create("Frame", {
        Size            = UDim2.new(1, -20, 0, 1),
        Position        = UDim2.new(0, 10, 0, 60),
        BackgroundColor3 = Color3.fromRGB(30, 30, 50),
        BorderSizePixel = 0,
        Parent          = sidebar,
    })

    -- Tab buttons list
    local tabList = Create("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, -70),
        Position        = UDim2.new(0, 0, 0, 68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        Parent          = sidebar,
    })
    Create("UIListLayout", {
        Padding         = UDim.new(0, 2),
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Parent          = tabList,
    })
    Create("UIPadding", {
        PaddingLeft     = UDim.new(0, 8),
        PaddingRight    = UDim.new(0, 8),
        PaddingTop      = UDim.new(0, 4),
        Parent          = tabList,
    })

    -- Content area
    local contentArea = Create("Frame", {
        Name            = "Content",
        Size            = UDim2.new(1, -148, 1, -10),
        Position        = UDim2.new(0, 144, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent          = main,
    })

    -- Close button
    local closeBtn = Create("TextButton", {
        Size            = UDim2.new(0, 24, 0, 24),
        Position        = UDim2.new(1, -30, 0, 8),
        BackgroundColor3 = Color3.fromRGB(60, 20, 30),
        BorderSizePixel = 0,
        Text            = "✕",
        TextColor3      = Color3.fromRGB(220, 80, 100),
        TextSize        = 12,
        Font            = Enum.Font.GothamBold,
        Parent          = main,
        ZIndex          = 10,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }):Clone().Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        Tween(main, { Size = UDim2.new(0, cfg.Width, 0, 0) }, 0.3)
        task.wait(0.35)
        main.Visible = false
        main.Size = UDim2.new(0, cfg.Width, 0, cfg.Height)
    end)

    -- Toggle visibility with key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == cfg.ToggleKey then
            main.Visible = not main.Visible
        end
    end)

    -- Make draggable via logo area
    MakeDraggable(main, logoFrame)

    -- Window object
    local Window = {}
    Window._cfg         = cfg
    Window._tabList     = tabList
    Window._contentArea = contentArea
    Window._tabs        = {}
    Window._activeTab   = nil

    -- --------------------------------------------------------
    --   CreateTab
    -- --------------------------------------------------------
    function Window:CreateTab(name, icon)
        local tabCfg = self._cfg

        -- Sidebar button
        local btn = Create("TextButton", {
            Size            = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = tabCfg.SideColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text            = "",
            AutoButtonColor = false,
            Parent          = self._tabList,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 7) }):Clone().Parent = btn

        -- Accent indicator
        local indicator = Create("Frame", {
            Size            = UDim2.new(0, 3, 0.6, 0),
            Position        = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = tabCfg.AccentColor,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent          = btn,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }):Clone().Parent = indicator

        -- Icon
        local xOffset = 10
        if icon then
            local iconId = NexusUI.Icons[icon] or icon
            Create("ImageLabel", {
                Size            = UDim2.new(0, 15, 0, 15),
                Position        = UDim2.new(0, xOffset, 0.5, -7),
                BackgroundTransparency = 1,
                Image           = iconId,
                ImageColor3     = tabCfg.MutedColor,
                Name            = "Icon",
                Parent          = btn,
            })
            xOffset = 30
        end

        Create("TextLabel", {
            Size            = UDim2.new(1, -xOffset - 6, 1, 0),
            Position        = UDim2.new(0, xOffset, 0, 0),
            BackgroundTransparency = 1,
            Text            = name,
            TextColor3      = tabCfg.MutedColor,
            TextSize        = 13,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Name            = "Label",
            Parent          = btn,
        })

        -- Tab content frame
        local tabFrame = Create("ScrollingFrame", {
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = tabCfg.AccentColor,
            Visible         = false,
            Parent          = self._contentArea,
        })
        Create("UIListLayout", {
            Padding         = UDim.new(0, 6),
            SortOrder       = Enum.SortOrder.LayoutOrder,
            Parent          = tabFrame,
        })
        Create("UIPadding", {
            PaddingRight    = UDim.new(0, 6),
            PaddingTop      = UDim.new(0, 8),
            PaddingBottom   = UDim.new(0, 8),
            Parent          = tabFrame,
        })

        -- Auto-size scroll
        local listLayout = tabFrame:FindFirstChildOfClass("UIListLayout")
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
        end)

        local tabObj = {
            _frame  = tabFrame,
            _btn    = btn,
            _cfg    = tabCfg,
            _win    = self,
        }

        -- Button click
        btn.MouseButton1Click:Connect(function()
            self:_SelectTab(tabObj)
        end)

        -- Hover
        btn.MouseEnter:Connect(function()
            if self._activeTab ~= tabObj then
                Tween(btn, { BackgroundTransparency = 0.85 }, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeTab ~= tabObj then
                Tween(btn, { BackgroundTransparency = 1 }, 0.15)
            end
        end)

        table.insert(self._tabs, tabObj)

        -- Select first tab automatically
        if #self._tabs == 1 then
            self:_SelectTab(tabObj)
        end

        -- Attach component methods
        self:_AttachComponents(tabObj)

        return tabObj
    end

    function Window:_SelectTab(tabObj)
        -- Deselect current
        if self._activeTab then
            local prev = self._activeTab
            prev._frame.Visible = false
            Tween(prev._btn, { BackgroundTransparency = 1 }, 0.15)
            Tween(prev._btn:FindFirstChild("Label"), { TextColor3 = self._cfg.MutedColor }, 0.15)
            local prevInd = prev._btn:FindFirstChild("Frame")
            if prevInd then Tween(prevInd, { BackgroundTransparency = 1 }, 0.15) end
            local prevIcon = prev._btn:FindFirstChild("Icon")
            if prevIcon then Tween(prevIcon, { ImageColor3 = self._cfg.MutedColor }, 0.15) end
        end

        -- Select new
        self._activeTab = tabObj
        tabObj._frame.Visible = true
        Tween(tabObj._btn, { BackgroundTransparency = 0.92 }, 0.15)
        Tween(tabObj._btn:FindFirstChild("Label"), { TextColor3 = self._cfg.AccentColor }, 0.15)
        local ind = tabObj._btn:FindFirstChild("Frame")
        if ind then Tween(ind, { BackgroundTransparency = 0 }, 0.15) end
        local icon = tabObj._btn:FindFirstChild("Icon")
        if icon then Tween(icon, { ImageColor3 = self._cfg.AccentColor }, 0.15) end
    end

    -- --------------------------------------------------------
    --   Component factory (attached to each tab object)
    -- --------------------------------------------------------
    function Window:_AttachComponents(tab)
        local cfg = self._cfg

        -- Helper: make a base element row
        local function BaseRow(height)
            local row = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, height or 40),
                BackgroundColor3 = Color3.fromRGB(20, 20, 33),
                BorderSizePixel = 0,
                Parent          = tab._frame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }):Clone().Parent = row
            return row
        end

        -- ------------------------------------------------
        --   CreateSection
        -- ------------------------------------------------
        function tab:CreateSection(name)
            local sec = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent          = self._frame,
            })
            Create("TextLabel", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = name:upper(),
                TextColor3      = cfg.AccentColor,
                TextSize        = 10,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = sec,
            })
            Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 1),
                Position        = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = cfg.AccentColor,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                Parent          = sec,
            })
        end

        -- ------------------------------------------------
        --   CreateToggle
        -- ------------------------------------------------
        function tab:CreateToggle(config)
            config = config or {}
            local value = config.Default or false
            local row = BaseRow(42)

            Create("TextLabel", {
                Size            = UDim2.new(1, -70, 0, 20),
                Position        = UDim2.new(0, 14, 0, 7),
                BackgroundTransparency = 1,
                Text            = config.Name or "Toggle",
                TextColor3      = cfg.TextColor,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = row,
            })

            if config.Description then
                Create("TextLabel", {
                    Size            = UDim2.new(1, -70, 0, 14),
                    Position        = UDim2.new(0, 14, 0, 24),
                    BackgroundTransparency = 1,
                    Text            = config.Description,
                    TextColor3      = cfg.MutedColor,
                    TextSize        = 11,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Parent          = row,
                })
                row.Size = UDim2.new(1, 0, 0, 54)
            end

            -- Track
            local track = Create("Frame", {
                Size            = UDim2.new(0, 38, 0, 20),
                Position        = UDim2.new(1, -52, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(35, 35, 55),
                BorderSizePixel = 0,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }):Clone().Parent = track

            -- Knob
            local knob = Create("Frame", {
                Size            = UDim2.new(0, 14, 0, 14),
                Position        = value
                    and UDim2.new(0, 21, 0.5, -7)
                    or  UDim2.new(0, 3,  0.5, -7),
                BackgroundColor3 = value and cfg.AccentColor or cfg.MutedColor,
                BorderSizePixel = 0,
                Parent          = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }):Clone().Parent = knob

            if value then
                track.BackgroundColor3 = Color3.fromRGB(
                    math.floor(cfg.AccentColor.R * 255 * 0.3),
                    math.floor(cfg.AccentColor.G * 255 * 0.3),
                    math.floor(cfg.AccentColor.B * 255 * 0.3)
                )
            end

            local btn = Create("TextButton", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = "",
                Parent          = row,
            })

            btn.MouseButton1Click:Connect(function()
                value = not value
                if value then
                    Tween(knob, { Position = UDim2.new(0, 21, 0.5, -7), BackgroundColor3 = cfg.AccentColor }, 0.15)
                    Tween(track, { BackgroundColor3 = Color3.fromRGB(
                        math.floor(cfg.AccentColor.R * 255 * 0.3),
                        math.floor(cfg.AccentColor.G * 255 * 0.3),
                        math.floor(cfg.AccentColor.B * 255 * 0.3)
                    )}, 0.15)
                else
                    Tween(knob, { Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = cfg.MutedColor }, 0.15)
                    Tween(track, { BackgroundColor3 = Color3.fromRGB(35, 35, 55) }, 0.15)
                end
                if config.Callback then config.Callback(value) end
            end)

            return { GetValue = function() return value end }
        end

        -- ------------------------------------------------
        --   CreateSlider
        -- ------------------------------------------------
        function tab:CreateSlider(config)
            config = config or {}
            local min   = config.Min     or 0
            local max   = config.Max     or 100
            local value = config.Default or min
            local row   = BaseRow(58)

            Create("TextLabel", {
                Size            = UDim2.new(1, -70, 0, 16),
                Position        = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text            = config.Name or "Slider",
                TextColor3      = cfg.TextColor,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = row,
            })

            local valLabel = Create("TextLabel", {
                Size            = UDim2.new(0, 50, 0, 16),
                Position        = UDim2.new(1, -64, 0, 8),
                BackgroundTransparency = 1,
                Text            = tostring(value),
                TextColor3      = cfg.AccentColor,
                TextSize        = 13,
                Font            = Enum.Font.GothamBold,
                TextXAlignment  = Enum.TextXAlignment.Right,
                Parent          = row,
            })

            -- Track bg
            local trackBg = Create("Frame", {
                Size            = UDim2.new(1, -28, 0, 4),
                Position        = UDim2.new(0, 14, 0, 36),
                BackgroundColor3 = Color3.fromRGB(35, 35, 55),
                BorderSizePixel = 0,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }):Clone().Parent = trackBg

            -- Fill
            local fill = Create("Frame", {
                Size            = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = cfg.AccentColor,
                BorderSizePixel = 0,
                Parent          = trackBg,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }):Clone().Parent = fill

            -- Knob
            local knob = Create("Frame", {
                Size            = UDim2.new(0, 12, 0, 12),
                Position        = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent          = trackBg,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }):Clone().Parent = knob

            -- Interaction
            local dragging = false
            local inputBtn = Create("TextButton", {
                Size            = UDim2.new(1, 0, 0, 24),
                Position        = UDim2.new(0, 0, 0, -10),
                BackgroundTransparency = 1,
                Text            = "",
                Parent          = trackBg,
            })

            local function updateSlider(inputPos)
                local abs = trackBg.AbsolutePosition
                local siz = trackBg.AbsoluteSize
                local rel = math.clamp((inputPos.X - abs.X) / siz.X, 0, 1)
                local step = config.Step or 1
                value = math.floor((min + rel * (max - min)) / step + 0.5) * step
                value = math.clamp(value, min, max)
                local pct = (value - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -6, 0.5, -6)
                valLabel.Text = tostring(value)
                if config.Callback then config.Callback(value) end
            end

            inputBtn.MouseButton1Down:Connect(function()
                dragging = true
                updateSlider(Mouse)
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then updateSlider(Mouse) end
            end)

            return { GetValue = function() return value end }
        end

        -- ------------------------------------------------
        --   CreateButton
        -- ------------------------------------------------
        function tab:CreateButton(config)
            config = config or {}
            local row = BaseRow(42)

            local btn = Create("TextButton", {
                Size            = UDim2.new(1, -28, 0, 28),
                Position        = UDim2.new(0, 14, 0.5, -14),
                BackgroundColor3 = cfg.AccentColor,
                BorderSizePixel = 0,
                Text            = config.Name or "Button",
                TextColor3      = Color3.fromRGB(255, 255, 255),
                TextSize        = 13,
                Font            = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 7) }):Clone().Parent = btn

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundTransparency = 0.2 }, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundTransparency = 0 }, 0.1)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, { Size = UDim2.new(1, -32, 0, 26) }, 0.08)
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn, { Size = UDim2.new(1, -28, 0, 28) }, 0.08)
                if config.Callback then config.Callback() end
            end)
        end

        -- ------------------------------------------------
        --   CreateInput  (text box)
        -- ------------------------------------------------
        function tab:CreateInput(config)
            config = config or {}
            local row = BaseRow(54)

            Create("TextLabel", {
                Size            = UDim2.new(1, -28, 0, 16),
                Position        = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Text            = config.Name or "Input",
                TextColor3      = cfg.TextColor,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = row,
            })

            local box = Create("TextBox", {
                Size            = UDim2.new(1, -28, 0, 22),
                Position        = UDim2.new(0, 14, 0, 26),
                BackgroundColor3 = Color3.fromRGB(10, 10, 18),
                BorderSizePixel = 0,
                Text            = config.Default or "",
                PlaceholderText = config.Placeholder or "Enter value...",
                TextColor3      = cfg.TextColor,
                PlaceholderColor3 = cfg.MutedColor,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                ClearTextOnFocus = config.ClearOnFocus ~= false,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }):Clone().Parent = box
            Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }):Clone().Parent = box

            box.FocusLost:Connect(function(enter)
                if config.Callback then config.Callback(box.Text, enter) end
            end)

            return { GetValue = function() return box.Text end }
        end

        -- ------------------------------------------------
        --   CreateDropdown
        -- ------------------------------------------------
        function tab:CreateDropdown(config)
            config = config or {}
            local options = config.Options or {}
            local selected = config.Default or options[1] or ""
            local open = false
            local row = BaseRow(42)

            Create("TextLabel", {
                Size            = UDim2.new(1, -28, 0, 16),
                Position        = UDim2.new(0, 14, 0, 5),
                BackgroundTransparency = 1,
                Text            = config.Name or "Dropdown",
                TextColor3      = cfg.TextColor,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = row,
            })

            local selBtn = Create("TextButton", {
                Size            = UDim2.new(1, -28, 0, 22),
                Position        = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.fromRGB(10, 10, 18),
                BorderSizePixel = 0,
                Text            = "  " .. selected,
                TextColor3      = cfg.TextColor,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }):Clone().Parent = selBtn

            Create("TextLabel", {
                Size            = UDim2.new(0, 20, 1, 0),
                Position        = UDim2.new(1, -22, 0, 0),
                BackgroundTransparency = 1,
                Text            = "▾",
                TextColor3      = cfg.MutedColor,
                TextSize        = 12,
                Font            = Enum.Font.GothamBold,
                Parent          = selBtn,
            })

            -- Dropdown list
            local dropFrame = Create("Frame", {
                Size            = UDim2.new(1, -28, 0, #options * 26 + 4),
                Position        = UDim2.new(0, 14, 0, 40),
                BackgroundColor3 = Color3.fromRGB(10, 10, 18),
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 5,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }):Clone().Parent = dropFrame
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }):Clone().Parent = dropFrame
            Create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) }):Clone().Parent = dropFrame

            for _, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Size            = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    Text            = "  " .. opt,
                    TextColor3      = opt == selected and cfg.AccentColor or cfg.TextColor,
                    TextSize        = 12,
                    Font            = Enum.Font.Gotham,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 6,
                    Parent          = dropFrame,
                })
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selBtn.Text = "  " .. selected
                    for _, c in ipairs(dropFrame:GetChildren()) do
                        if c:IsA("TextButton") then
                            c.TextColor3 = cfg.MutedColor
                        end
                    end
                    optBtn.TextColor3 = cfg.AccentColor
                    open = false
                    dropFrame.Visible = false
                    row.Size = UDim2.new(1, 0, 0, 42)
                    if config.Callback then config.Callback(selected) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                dropFrame.Visible = open
                row.Size = open
                    and UDim2.new(1, 0, 0, 42 + #options * 26 + 4)
                    or  UDim2.new(1, 0, 0, 42)
            end)

            return { GetValue = function() return selected end }
        end

        -- ------------------------------------------------
        --   CreateLabel
        -- ------------------------------------------------
        function tab:CreateLabel(text, color)
            local row = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent          = self._frame,
            })
            Create("TextLabel", {
                Size            = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text            = text or "",
                TextColor3      = color or cfg.MutedColor,
                TextSize        = 12,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
                Parent          = row,
            })
        end

        -- ------------------------------------------------
        --   CreateKeybind
        -- ------------------------------------------------
        function tab:CreateKeybind(config)
            config = config or {}
            local key = config.Default or Enum.KeyCode.E
            local listening = false
            local row = BaseRow(42)

            Create("TextLabel", {
                Size            = UDim2.new(1, -100, 0, 20),
                Position        = UDim2.new(0, 14, 0.5, -10),
                BackgroundTransparency = 1,
                Text            = config.Name or "Keybind",
                TextColor3      = cfg.TextColor,
                TextSize        = 13,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                Parent          = row,
            })

            local keyBtn = Create("TextButton", {
                Size            = UDim2.new(0, 70, 0, 24),
                Position        = UDim2.new(1, -84, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(10, 10, 18),
                BorderSizePixel = 0,
                Text            = key.Name,
                TextColor3      = cfg.AccentColor,
                TextSize        = 12,
                Font            = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent          = row,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5) }):Clone().Parent = keyBtn

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

            return { GetValue = function() return key end }
        end

    end -- _AttachComponents

    return Window
end

return NexusUI
