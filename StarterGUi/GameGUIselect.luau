
--  HELLQUAKE  —  Title Screen + Level Select
--  LocalScript → place in StarterGui


local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")   -- ← NEW
local player          = Players.LocalPlayer
local playerGui       = player:WaitForChild("PlayerGui")

--configurations

local CONFIG = {

    GAME_NAME  = "Battle For Robloxia",
    SUBTITLE   = "Pluh",
    VERSION    = "v0.1.1",

    MENU_ITEMS = {
        { label = "START GAME",  action = "LEVELS" },
        { label = "HOW TO PLAY", action = "CUSTOM" },
        { label = "QUIT",        action = "QUIT"   },
    },

    OnMenuAction = function(item)
        print("Menu action: " .. item.label)
    end,

    -- ── TELEPORT HANDLER ───────────────────────────────────
    -- Called when player hits LAUNCH on a level.
    -- Replace placeId values in ACTS below with your real Place IDs.
    OnLaunch = function(level, launchBtn)
        if not level.placeId then
            warn("No placeId set for level: " .. level.num)
            return
        end

        -- Visual feedback while teleport loads
        launchBtn.Text            = "LOADING..."
        launchBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        launchBtn.Active           = false

        local ok, err = pcall(function()
            TeleportService:Teleport(level.placeId, player)
        end)

        if not ok then
            warn("Teleport failed: " .. tostring(err))
            launchBtn.Text             = "ERROR — RETRY"
            launchBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            launchBtn.Active           = true
        end
    end,

    LEVEL_SELECT_KEY    = Enum.KeyCode.M,
    SHOW_TITLE_ON_START = true,

    COLORS = {
        BG          = Color3.fromRGB(6,  0,  0),
        PANEL       = Color3.fromRGB(12, 0,  0),
        SIDEPANEL   = Color3.fromRGB(15, 0,  0),
        HEADER_BG   = Color3.fromRGB(17, 0,  0),
        LINE        = Color3.fromRGB(50, 0,  0),
        RED         = Color3.fromRGB(200,0,  0),
        RED_BRIGHT  = Color3.fromRGB(255,17, 17),
        RED_DIM     = Color3.fromRGB(80, 0,  0),
        RED_DIMMER  = Color3.fromRGB(35, 0,  0),
        WHITE       = Color3.fromRGB(230,230,230),
        TITLE_COLOR = Color3.fromRGB(255,20, 20),
        SCANLINE    = Color3.fromRGB(255,0,  0),
        RANK_P  = Color3.fromRGB(255,228,77),
        RANK_S  = Color3.fromRGB(255,228,77),
        RANK_A  = Color3.fromRGB(77, 166,255),
        RANK_B  = Color3.fromRGB(68, 204,85),
        RANK_C  = Color3.fromRGB(204,204,34),
        RANK_D  = Color3.fromRGB(255,80, 80),
    },

    -- ── ACTS / LEVELS ──────────────────────────────────────
    -- ↓↓ REPLACE every placeId value with your actual Roblox Place IDs ↓↓
    ACTS = {
        {
            label  = "Start",
            sub    = "Start of the acts",
            levels = {
                { num = "0-1", name = "Unknown 0-1",        rank = nil,    ch = {true,  false, false}, locked = false, placeId = 1234567890 },
                { num = "0-2", name = "Unknown 0-2",      rank = nil,    ch = {true,  true,  false}, locked = false, placeId = 1234567891 },
                { num = "0-3", name = "Unknown 0-3",   rank = nil,    ch = {true,  true,  true }, locked = false, placeId = 1234567892 },
                { num = "0-S", name = "Unknown 0-4",   rank = nil,    ch = {true,  true,  true }, locked = false, placeId = 1234567893, secret = true },
                { num = "0-4", name = "Unknown 0-5",     rank = nil, ch = {false, false, false}, locked = false, placeId = 1234567894 },
            },
        },
        {
            label  = "1",
            sub    = "First",
            levels = {
                { num = "1-1", name = "Unknown 1-1",    rank = nil,    ch = {true,  true,  false}, locked = false, placeId = 1234567895 },
                { num = "1-2", name = "Unknown 1-2",          rank = nil,    ch = {true,  false, false}, locked = false, placeId = 1234567896 },
                { num = "P-1", name = "unknown 1-3",  rank = nil, ch = {false, false, false}, locked = false, placeId = 1234567897, secret = true },
                { num = "1-3", name = "Unknown 1-4",             rank = nil,    ch = {true,  true,  false}, locked = false, placeId = 1234567898 },
                { num = "1-4", name = "Unknown 1-5",       rank = nil, ch = {false, false, false}, locked = false, placeId = 1234567899 },
                { num = "1-E", name = "Unknown 1-6",        rank = nil, ch = {false, false, false}, locked = true,  placeId = 1234567900 },
            },
        },
        {
            label  = "ACT II",
            sub    = "IMPURE DESIGN",
            levels = {
                { num = "2-1", name = "CARVED IN STONE",    rank = "none", ch = {false, false, false}, locked = false, placeId = 1234567901 },
                { num = "2-2", name = "DEAD ON ARRIVAL",    rank = "none", ch = {false, false, false}, locked = false, placeId = 1234567902 },
                { num = "2-3", name = "BURNING MERIDIAN",   rank = "none", ch = {false, false, false}, locked = true,  placeId = 1234567903 },
                { num = "2-4", name = "THE WEIGHT OF FIRE", rank = "none", ch = {false, false, false}, locked = true,  placeId = 1234567904 },
            },
        },
        {
            label  = "ACT III",
            sub    = "FAULTLINE",
            levels = {
                { num = "3-1", name = "THROAT OF THE WORLD", rank = "none", ch = {false, false, false}, locked = true, placeId = 1234567905 },
                { num = "3-2", name = "LAST LIGHT",          rank = "none", ch = {false, false, false}, locked = true, placeId = 1234567906 },
            },
        },
    },
}

-- ╔══════════════════════════════════════════════════════════╗
-- ║                     END CONFIG                          ║
-- ╚══════════════════════════════════════════════════════════╝

local C = CONFIG.COLORS
local RANK_COLORS = {
    P = C.RANK_P, S = C.RANK_S, A = C.RANK_A,
    B = C.RANK_B, C = C.RANK_C, D = C.RANK_D,
    none = C.RED_DIMMER,
}


--  UTILITY
local function make(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function lbl(text, size, color, props, parent)
    props = props or {}
    props.Text               = text
    props.TextColor3         = color
    props.TextSize           = size
    props.Font               = Enum.Font.Code
    props.BackgroundTransparency = 1
    props.TextXAlignment     = props.TextXAlignment or Enum.TextXAlignment.Left
    return make("TextLabel", props, parent)
end

local function hline(parent, yPos)
    make("Frame", {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,yPos),
        BackgroundColor3 = C.LINE, BorderSizePixel = 0,
    }, parent)
end

local function hoverFx(btn, onColor, offColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = onColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = offColor}):Play()
    end)
end

local function scanlines(parent)
    local f = make("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = C.SCANLINE,
        BackgroundTransparency = 0.97,
        BorderSizePixel = 0,
        ZIndex = 20,
    }, parent)
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.96),
        NumberSequenceKeypoint.new(0.49,0.96),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1,   1),
    })
    g.Parent = f
end

--  SCREEN GUI ROOT

local gui = make("ScreenGui", {
    Name           = "Gui",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

--  TITLE SCREEN

local titleScreen = make("Frame", {
    Size             = UDim2.fromScale(1,1),
    BackgroundColor3 = C.BG,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = 5,
}, gui)
scanlines(titleScreen)

make("Frame", {
    Size = UDim2.new(0,3,1,0), Position = UDim2.new(0,60,0,0),
    BackgroundColor3 = C.LINE, BorderSizePixel = 0,
}, titleScreen)
make("Frame", {
    Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,70,0,0),
    BackgroundColor3 = C.RED_DIMMER, BorderSizePixel = 0,
}, titleScreen)

local titleLabel = lbl(CONFIG.GAME_NAME, 72, C.TITLE_COLOR, {
    Size = UDim2.new(0.9,0,0,90), Position = UDim2.new(0.05,0,0.18,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextStrokeTransparency = 0.7,
    TextStrokeColor3 = Color3.fromRGB(80,0,0),
}, titleScreen)

lbl(CONFIG.SUBTITLE, 14, C.RED_DIM, {
    Size = UDim2.new(0.8,0,0,20), Position = UDim2.new(0.05,0,0.18,96),
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleScreen)

make("Frame", {
    Size = UDim2.new(0,500,0,2), Position = UDim2.new(0.05,0,0.18,120),
    BackgroundColor3 = C.RED, BorderSizePixel = 0,
}, titleScreen)

lbl(CONFIG.VERSION, 10, C.RED_DIMMER, {
    Size = UDim2.new(0,80,0,16), Position = UDim2.new(1,-90,1,-24),
    TextXAlignment = Enum.TextXAlignment.Right,
}, titleScreen)

-- These reference levelScreen, defined below — forward declare
local levelScreen  -- forward declaration

local menuY = 0.46
for i, item in ipairs(CONFIG.MENU_ITEMS) do
    local btn = make("TextButton", {
        Size             = UDim2.new(0,300,0,40),
        Position         = UDim2.new(0.05,0,menuY + (i-1)*0.09,0),
        BackgroundColor3 = C.PANEL,
        BorderColor3     = C.LINE,
        BorderSizePixel  = 1,
        Text             = "",
        ZIndex           = 6,
    }, titleScreen)

    local acc = make("Frame", {
        Size = UDim2.new(0,3,1,0),
        BackgroundColor3 = C.RED_DIMMER,
        BorderSizePixel = 0,
    }, btn)

    lbl("> " .. item.label, 14, C.WHITE, {
        Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,14,0,0),
    }, btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(22,0,0)}):Play()
        TweenService:Create(acc, TweenInfo.new(0.07), {BackgroundColor3 = C.RED}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = C.PANEL}):Play()
        TweenService:Create(acc, TweenInfo.new(0.07), {BackgroundColor3 = C.RED_DIMMER}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if item.action == "LEVELS" then
            titleScreen.Visible = false
            levelScreen.Visible = true
            rebuildSidebar()
            rebuildLevelList()
            rebuildDetail()
        elseif item.action == "QUIT" then
            player:Kick("Thanks for joining " .. CONFIG.GAME_NAME)
        else
            CONFIG.OnMenuAction(item)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(math.random(4, 10))
        for _ = 1, math.random(1, 3) do
            titleLabel.Visible = false
            task.wait(0.05)
            titleLabel.Visible = true
            task.wait(0.05)
        end
    end
end)


levelScreen = make("Frame", {
    Size             = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.25,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = 4,
}, gui)

local main = make("Frame", {
    Size             = UDim2.new(0.84,0,0.84,0),
    Position         = UDim2.new(0.08,0,0.08,0),
    BackgroundColor3 = C.BG,
    BorderColor3     = C.RED,
    BorderSizePixel  = 2,
    ZIndex           = 4,
}, levelScreen)
scanlines(main)

-- Header
local header = make("Frame", {
    Size = UDim2.new(1,0,0,46),
    BackgroundColor3 = C.HEADER_BG,
    BorderSizePixel = 0,
}, main)
hline(header, 44)
make("Frame", {
    Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,1,-2),
    BackgroundColor3 = C.RED, BorderSizePixel = 0,
}, header)

lbl(CONFIG.GAME_NAME .. "  //  MISSION SELECT", 16, C.RED_BRIGHT, {
    Size = UDim2.new(0.7,0,1,0), Position = UDim2.new(0,14,0,0),
}, header)

local headerRankLabel = lbl("--", 20, C.RANK_P, {
    Size = UDim2.new(0,50,1,0), Position = UDim2.new(1,-64,0,0),
    TextXAlignment = Enum.TextXAlignment.Right,
}, header)

local closeBtn = make("TextButton", {
    Size = UDim2.new(0,46,1,0), Position = UDim2.new(1,-46,0,0),
    BackgroundColor3 = Color3.fromRGB(18,0,0),
    BorderSizePixel = 0,
    Text = "✕", TextColor3 = C.RED_DIM, TextSize = 14, Font = Enum.Font.Code,
    ZIndex = 10,
}, header)
hoverFx(closeBtn, C.RED, Color3.fromRGB(18,0,0))
closeBtn.MouseButton1Click:Connect(function()
    levelScreen.Visible = false
    if CONFIG.SHOW_TITLE_ON_START then
        titleScreen.Visible = true
    end
end)

-- Body
local body = make("Frame", {
    Size = UDim2.new(1,0,1,-46), Position = UDim2.new(0,0,0,46),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, main)

local sidebar = make("Frame", {
    Size = UDim2.new(0,148,1,0),
    BackgroundColor3 = C.SIDEPANEL,
    BorderSizePixel = 0,
}, body)
make("Frame", {
    Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0),
    BackgroundColor3 = C.LINE, BorderSizePixel = 0,
}, sidebar)

local levelScroll = make("ScrollingFrame", {
    Size = UDim2.new(1,-348,1,0), Position = UDim2.new(0,148,0,0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = C.RED,
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, body)

local detailPanel = make("Frame", {
    Size = UDim2.new(0,200,1,0), Position = UDim2.new(1,-200,0,0),
    BackgroundColor3 = Color3.fromRGB(11,0,0),
    BorderSizePixel = 0,
}, body)
make("Frame", {
    Size = UDim2.new(0,1,1,0),
    BackgroundColor3 = C.LINE, BorderSizePixel = 0,
}, detailPanel)

-- ============================================================
--  STATE
-- ============================================================
local currentAct   = 1
local currentLevel = nil

-- ============================================================
--  DETAIL PANEL  (now passes launchBtn ref to OnLaunch)
-- ============================================================
local function rebuildDetail()
    for _, c in detailPanel:GetChildren() do
        if not (c:IsA("Frame") and c.Size == UDim2.new(0,1,1,0)) then c:Destroy() end
    end

    local stripe = make("Frame", {
        Size = UDim2.new(1,0,0,30),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, detailPanel)
    lbl("MISSION INFO", 10, C.RED_BRIGHT, {
        Size = UDim2.new(1,-14,1,0), Position = UDim2.new(0,14,0,0),
    }, stripe)
    make("Frame", {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = C.LINE, BorderSizePixel = 0,
    }, stripe)

    if currentLevel == nil then
        lbl("SELECT A\nMISSION.", 10, C.RED_DIMMER, {
            Size = UDim2.new(1,-14,0,60), Position = UDim2.new(0,14,0,40),
            TextWrapped = true,
        }, detailPanel)
        return
    end

    local lv = CONFIG.ACTS[currentAct].levels[currentLevel]

    lbl(lv.name, 12, C.WHITE, {
        Size = UDim2.new(1,-14,0,44), Position = UDim2.new(0,14,0,36),
        TextWrapped = true,
    }, detailPanel)
    lbl(lv.num, 10, C.RED_DIM, {
        Size = UDim2.new(1,-14,0,16), Position = UDim2.new(0,14,0,82),
    }, detailPanel)

    lbl("BEST RANK", 9, C.RED_DIM, {
        Size = UDim2.new(1,-14,0,12), Position = UDim2.new(0,14,0,106),
    }, detailPanel)
    local rankBox = make("Frame", {
        Size = UDim2.new(0,44,0,44), Position = UDim2.new(0,14,0,120),
        BackgroundColor3 = C.BG,
        BorderColor3 = RANK_COLORS[lv.rank] or C.RED_DIMMER,
        BorderSizePixel = 2,
    }, detailPanel)
    lbl(lv.rank == "none" and "-" or lv.rank, 24, RANK_COLORS[lv.rank] or C.RED_DIMMER, {
        Size = UDim2.fromScale(1,1), TextXAlignment = Enum.TextXAlignment.Center,
    }, rankBox)

    lbl("CHALLENGES", 9, C.RED_DIM, {
        Size = UDim2.new(1,-14,0,12), Position = UDim2.new(0,14,0,174),
    }, detailPanel)
    for j, done in ipairs(lv.ch) do
        make("Frame", {
            Size = UDim2.new(0,11,0,11),
            Position = UDim2.new(0, 14+(j-1)*16, 0, 188),
            BackgroundColor3 = done and C.RED or C.RED_DIMMER,
            BorderSizePixel = 0, Rotation = 45,
        }, detailPanel)
    end

    if lv.rank ~= "none" then
        lbl("CLEARED", 9, C.RED_DIM, {
            Size = UDim2.new(1,-14,0,12), Position = UDim2.new(0,14,0,212),
        }, detailPanel)
    end

    if lv.secret then
        lbl("[SECRET LEVEL]", 9, Color3.fromRGB(255,136,0), {
            Size = UDim2.new(1,-14,0,14), Position = UDim2.new(0,14,0,230),
        }, detailPanel)
    end

    -- ── LAUNCH BUTTON (now fires teleport) ──────────────────
    local launchBtn = make("TextButton", {
        Size             = UDim2.new(1,0,0,38),
        Position         = UDim2.new(0,0,1,-38),
        BackgroundColor3 = lv.locked and C.RED_DIMMER or C.RED,
        BorderSizePixel  = 0,
        Text             = lv.locked and "// LOCKED" or "> LAUNCH",
        TextColor3       = lv.locked and C.RED_DIM or C.WHITE,
        TextSize         = 12,
        Font             = Enum.Font.Code,
        Active           = not lv.locked,
    }, detailPanel)

    if not lv.locked then
        hoverFx(launchBtn, C.RED_BRIGHT, C.RED)
        launchBtn.MouseButton1Click:Connect(function()
            CONFIG.OnLaunch(lv, launchBtn)   -- passes button so OnLaunch can mutate it
        end)
    end
end

-- ============================================================
--  LEVEL LIST
-- ============================================================
local function rebuildLevelList()
    for _, c in levelScroll:GetChildren() do c:Destroy() end

    local act = CONFIG.ACTS[currentAct]

    local hdr = make("Frame", {
        Size = UDim2.new(1,0,0,46), BackgroundColor3 = Color3.fromRGB(14,0,0),
        BorderSizePixel = 0, LayoutOrder = 0,
    }, levelScroll)
    lbl(act.label .. ":  " .. act.sub, 13, C.RED_BRIGHT, {
        Size = UDim2.new(1,-14,0.55,0), Position = UDim2.new(0,14,0,0),
    }, hdr)
    local cleared = 0
    for _, lv in act.levels do if lv.rank ~= "none" and not lv.locked then cleared += 1 end end
    lbl(#act.levels .. " MISSIONS  —  " .. cleared .. " CLEARED", 10, C.RED_DIM, {
        Size = UDim2.new(1,-14,0.45,0), Position = UDim2.new(0,14,0.55,0),
    }, hdr)
    make("Frame", {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
        BackgroundColor3 = C.LINE, BorderSizePixel = 0,
    }, hdr)

    for i, lv in ipairs(act.levels) do
        local isSelected = (currentLevel == i)
        local row = make("Frame", {
            Size = UDim2.new(1,0,0,46),
            BackgroundColor3 = isSelected and Color3.fromRGB(20,0,0) or C.BG,
            BorderSizePixel = 0, LayoutOrder = i,
        }, levelScroll)
        make("Frame", {
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
            BackgroundColor3 = C.LINE, BorderSizePixel = 0,
        }, row)

        local accent = make("Frame", {
            Size = UDim2.new(0,3,1,0),
            BackgroundColor3 = isSelected and C.RED or C.BG,
            BorderSizePixel = 0,
        }, row)

        lbl(lv.num, 11, C.RED_DIM, {
            Size = UDim2.new(0,38,1,0), Position = UDim2.new(0,10,0,0),
        }, row)

        local nameColor = lv.locked and C.RED_DIMMER or (isSelected and C.WHITE or Color3.fromRGB(195,195,195))
        lbl(lv.name .. (lv.secret and "  [S]" or ""), 12, nameColor, {
            Size = UDim2.new(0.54,0,1,0), Position = UDim2.new(0,52,0,0),
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)

        for j, done in ipairs(lv.Ch) do
            make("Frame", {
                Size = UDim2.new(0,8,0,8),
                Position = UDim2.new(0.61,(j-1)*13,0.5,-4),
                BackgroundColor3 = done and C.RED or C.RED_DIMMER,
                BorderSizePixel = 0, Rotation = 45,
            }, row)
        end

        local rankBox = make("Frame", {
            Size = UDim2.new(0,26,0,26), Position = UDim2.new(1,-36,0.5,-13),
            BackgroundColor3 = C.BG,
            BorderColor3 = RANK_COLORS[lv.rank] or C.RED_DIMMER,
            BorderSizePixel = 1,
        }, row)
        lbl(lv.rank == "none" and "-" or lv.rank, 13, RANK_COLORS[lv.rank] or C.RED_DIMMER, {
            Size = UDim2.fromScale(1,1), TextXAlignment = Enum.TextXAlignment.Center,
        }, rankBox)

        if not lv.locked then
            local btn = make("TextButton", {
                Size = UDim2.fromScale(1,1),
                BackgroundTransparency = 1, Text = "", ZIndex = 5,
            }, row)
            btn.MouseEnter:Connect(function()
                if currentLevel ~= i then
                    TweenService:Create(row,    TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(18,0,0)}):Play()
                    TweenService:Create(accent, TweenInfo.new(0.07), {BackgroundColor3 = C.RED_DIM}):Play()
                end
            end)
            btn.MouseLeave:Connect(function()
                if currentLevel ~= i then
                    TweenService:Create(row,    TweenInfo.new(0.07), {BackgroundColor3 = C.BG}):Play()
                    TweenService:Create(accent, TweenInfo.new(0.07), {BackgroundColor3 = C.BG}):Play()
                end
            end)
            btn.MouseButton1Click:Connect(function()
                currentLevel = i
                rebuildLevelList()
                rebuildDetail()
            end)
        end
    end

    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,0),
    }, levelScroll)

    local best  = "none"
    local order = {"P","S","A","B","C","D"}
    for _, lv in act.levels do
        for idx, r in order do
            if lv.rank == r then
                local cur = table.find(order, best) or 99
                if idx < cur then best = r end
                break
            end
        end
    end
    headerRankLabel.Text       = best == "none" and "--" or best
    headerRankLabel.TextColor3 = RANK_COLORS[best] or C.RED_DIM
end

-- ============================================================
--  SIDEBAR
-- ============================================================
function rebuildSidebar()
    for _, c in sidebar:GetChildren() do
        if not (c:IsA("Frame") and c.Size == UDim2.new(0,1,1,0)) then c:Destroy() end
    end

    local yOff = 8
    for i, act in ipairs(CONFIG.ACTS) do
        local isActive = (i == currentAct)
        local btn = make("TextButton", {
            Size = UDim2.new(1,-3,0,34), Position = UDim2.new(0,3,0,yOff),
            BackgroundColor3 = isActive and C.PANEL or C.SIDEPANEL,
            BorderSizePixel = 0, Text = "",
        }, sidebar)
        local acc = make("Frame", {
            Size = UDim2.new(0,3,1,0), Position = UDim2.new(0,-3,0,0),
            BackgroundColor3 = isActive and C.RED or C.SIDEPANEL,
            BorderSizePixel = 0,
        }, btn)
        lbl(act.label, 11, isActive and C.RED_BRIGHT or C.RED_DIM, {
            Size = UDim2.new(1,-10,0.5,0), Position = UDim2.new(0,10,0,0),
        }, btn)
        lbl(act.sub, 8, isActive and C.RED_DIM or C.RED_DIMMER, {
            Size = UDim2.new(1,-10,0.5,0), Position = UDim2.new(0,10,0.5,0),
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, btn)

        if not isActive then
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(20,0,0)}):Play()
                TweenService:Create(acc, TweenInfo.new(0.07), {BackgroundColor3 = C.RED_DIMMER}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3 = C.SIDEPANEL}):Play()
                TweenService:Create(acc, TweenInfo.new(0.07), {BackgroundColor3 = C.SIDEPANEL}):Play()
            end)
        end

        btn.MouseButton1Click:Connect(function()
            currentAct   = i
            currentLevel = nil
            rebuildSidebar()
            rebuildLevelList()
            rebuildDetail()
        end)

        yOff += 36
        if i < #CONFIG.ACTS then
            make("Frame", {
                Size = UDim2.new(1,-20,0,1), Position = UDim2.new(0,10,0,yOff),
                BackgroundColor3 = C.LINE, BorderSizePixel = 0,
            }, sidebar)
            yOff += 6
        end
    end
end

-- ============================================================
--  INIT
-- ============================================================
local function openLevelSelect()
    titleScreen.Visible = false
    levelScreen.Visible = true
    rebuildSidebar()
    rebuildLevelList()
    rebuildDetail()
end

local function openTitle()
    levelScreen.Visible = false
    titleScreen.Visible = true
end

if CONFIG.SHOW_TITLE_ON_START then
    titleScreen.Visible = true
else
    openLevelSelect()
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.LEVEL_SELECT_KEY then
        if levelScreen.Visible then
            levelScreen.Visible = false
        else
            openLevelSelect()
        end
    end
end)

return {
    OpenTitle       = openTitle,
    OpenLevelSelect = openLevelSelect,
    Close           = function() titleScreen.Visible = false; levelScreen.Visible = false end,
}
