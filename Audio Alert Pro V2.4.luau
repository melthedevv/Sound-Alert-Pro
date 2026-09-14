local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CONFIG_FILE = "sound_alert_config.json"

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or (http_request)
        or (request)
        or (fluxus and fluxus.request)
        or (krnl and krnl.request)
end

local function loadConfig()
    if isfile and isfile(CONFIG_FILE) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return { webhook = "", watched = {}, stats = { detected = 0, lastAlert = "Never" } }
end

local function saveConfig(cfg)
    if writefile then
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end)
    end
end

local config = loadConfig()

local Theme = {
    Background = Color3.fromRGB(13, 13, 15),
    Surface = Color3.fromRGB(22, 22, 26),
    SurfaceHover = Color3.fromRGB(28, 28, 34),
    Border = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(105, 118, 255),
    TextPrimary = Color3.fromRGB(235, 235, 245),
    TextSecondary = Color3.fromRGB(150, 150, 170),
    TextMuted = Color3.fromRGB(110, 110, 130),
    Success = Color3.fromRGB(80, 200, 120),
    Error = Color3.fromRGB(240, 80, 80),
    Warning = Color3.fromRGB(255, 180, 80)
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("SoundAlertPro")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SoundAlertPro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 600, 0, 450)
main.Position = UDim2.new(0.5, -300, 0.5, -225)
main.BackgroundColor3 = Theme.Surface
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = false
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Border
stroke.Thickness = 1
stroke.Parent = main

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.ZIndex = -1
shadow.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Theme.Background
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 25)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Theme.Background
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 24, 0, 24)
icon.Position = UDim2.new(0, 16, 0, 13)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://3926307971"
icon.ImageRectOffset = Vector2.new(524, 44)
icon.ImageRectSize = Vector2.new(36, 36)
icon.ImageColor3 = Theme.Accent
icon.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 48, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Sound Alert Pro"
title.TextColor3 = Theme.TextPrimary
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 9)
closeBtn.BackgroundColor3 = Theme.Surface
closeBtn.Text = "×"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -32, 1, -82)
content.Position = UDim2.new(0, 16, 0, 66)
content.BackgroundTransparency = 1
content.Parent = main

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 220, 1, 0)
leftPanel.BackgroundColor3 = Theme.Background
leftPanel.BorderSizePixel = 0
leftPanel.Parent = content

local leftCorner = Instance.new("UICorner")
leftCorner.CornerRadius = UDim.new(0, 10)
leftCorner.Parent = leftPanel

local webhookSection = Instance.new("Frame")
webhookSection.Size = UDim2.new(1, -16, 0, 120)
webhookSection.Position = UDim2.new(0, 8, 0, 8)
webhookSection.BackgroundColor3 = Theme.Surface
webhookSection.BorderSizePixel = 0
webhookSection.Parent = leftPanel

local wsCorner = Instance.new("UICorner")
wsCorner.CornerRadius = UDim.new(0, 8)
wsCorner.Parent = webhookSection

local wsTitle = Instance.new("TextLabel")
wsTitle.Size = UDim2.new(1, -16, 0, 20)
wsTitle.Position = UDim2.new(0, 8, 0, 8)
wsTitle.BackgroundTransparency = 1
wsTitle.Text = "Discord Webhook"
wsTitle.TextColor3 = Theme.TextPrimary
wsTitle.Font = Enum.Font.GothamBold
wsTitle.TextSize = 13
wsTitle.TextXAlignment = Enum.TextXAlignment.Left
wsTitle.Parent = webhookSection

local webhookStatus = Instance.new("Frame")
webhookStatus.Size = UDim2.new(1, -16, 0, 32)
webhookStatus.Position = UDim2.new(0, 8, 0, 32)
webhookStatus.BackgroundColor3 = Theme.Background
webhookStatus.BorderSizePixel = 0
webhookStatus.Parent = webhookSection

local wsStatusCorner = Instance.new("UICorner")
wsStatusCorner.CornerRadius = UDim.new(0, 6)
wsStatusCorner.Parent = webhookStatus

local webhookText = Instance.new("TextLabel")
webhookText.Size = UDim2.new(1, -10, 1, 0)
webhookText.Position = UDim2.new(0, 8, 0, 0)
webhookText.BackgroundTransparency = 1
webhookText.Text = "Not configured"
webhookText.TextColor3 = Theme.TextMuted
webhookText.Font = Enum.Font.Gotham
webhookText.TextSize = 11
webhookText.TextXAlignment = Enum.TextXAlignment.Left
webhookText.TextTruncate = Enum.TextTruncate.AtEnd
webhookText.Parent = webhookStatus

local webhookBtn = Instance.new("TextButton")
webhookBtn.Size = UDim2.new(0.48, 0, 0, 32)
webhookBtn.Position = UDim2.new(0, 8, 0, 72)
webhookBtn.BackgroundColor3 = Theme.Accent
webhookBtn.Text = "Configure"
webhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
webhookBtn.Font = Enum.Font.GothamBold
webhookBtn.TextSize = 12
webhookBtn.BorderSizePixel = 0
webhookBtn.Parent = webhookSection

local wbCorner = Instance.new("UICorner")
wbCorner.CornerRadius = UDim.new(0, 6)
wbCorner.Parent = webhookBtn

local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0.48, 0, 0, 32)
testBtn.Position = UDim2.new(0.52, 0, 0, 72)
testBtn.BackgroundColor3 = Theme.SurfaceHover
testBtn.Text = "Test"
testBtn.TextColor3 = Theme.TextPrimary
testBtn.Font = Enum.Font.GothamBold
testBtn.TextSize = 12
testBtn.BorderSizePixel = 0
testBtn.Parent = webhookSection

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 6)
tbCorner.Parent = testBtn

local statsSection = Instance.new("Frame")
statsSection.Size = UDim2.new(1, -16, 0, 100)
statsSection.Position = UDim2.new(0, 8, 0, 136)
statsSection.BackgroundColor3 = Theme.Surface
statsSection.BorderSizePixel = 0
statsSection.Parent = leftPanel

local ssCorner = Instance.new("UICorner")
ssCorner.CornerRadius = UDim.new(0, 8)
ssCorner.Parent = statsSection

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -16, 0, 20)
statsTitle.Position = UDim2.new(0, 8, 0, 8)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "Statistics"
statsTitle.TextColor3 = Theme.TextPrimary
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 13
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsSection

local detectedLabel = Instance.new("TextLabel")
detectedLabel.Size = UDim2.new(1, -16, 0, 18)
detectedLabel.Position = UDim2.new(0, 8, 0, 32)
detectedLabel.BackgroundTransparency = 1
detectedLabel.Text = "Alerts Sent: 0"
detectedLabel.TextColor3 = Theme.TextSecondary
detectedLabel.Font = Enum.Font.Gotham
detectedLabel.TextSize = 12
detectedLabel.TextXAlignment = Enum.TextXAlignment.Left
detectedLabel.Parent = statsSection

local lastAlertLabel = Instance.new("TextLabel")
lastAlertLabel.Size = UDim2.new(1, -16, 0, 18)
lastAlertLabel.Position = UDim2.new(0, 8, 0, 52)
lastAlertLabel.BackgroundTransparency = 1
lastAlertLabel.Text = "Last Alert: Never"
lastAlertLabel.TextColor3 = Theme.TextSecondary
lastAlertLabel.Font = Enum.Font.Gotham
lastAlertLabel.TextSize = 12
lastAlertLabel.TextXAlignment = Enum.TextXAlignment.Left
lastAlertLabel.Parent = statsSection

local globalToggle = Instance.new("Frame")
globalToggle.Size = UDim2.new(1, -16, 0, 40)
globalToggle.Position = UDim2.new(0, 8, 1, -48)
globalToggle.BackgroundColor3 = Theme.Surface
globalToggle.BorderSizePixel = 0
globalToggle.Parent = leftPanel

local gtCorner = Instance.new("UICorner")
gtCorner.CornerRadius = UDim.new(0, 8)
gtCorner.Parent = globalToggle

local gtLabel = Instance.new("TextLabel")
gtLabel.Size = UDim2.new(1, -60, 1, 0)
gtLabel.Position = UDim2.new(0, 12, 0, 0)
gtLabel.BackgroundTransparency = 1
gtLabel.Text = "Monitoring Active"
gtLabel.TextColor3 = Theme.TextPrimary
gtLabel.Font = Enum.Font.GothamBold
gtLabel.TextSize = 13
gtLabel.TextXAlignment = Enum.TextXAlignment.Left
gtLabel.Parent = globalToggle

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 44, 0, 24)
toggleBtn.Position = UDim2.new(1, -52, 0.5, -12)
toggleBtn.BackgroundColor3 = Theme.Accent
toggleBtn.Text = ""
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = globalToggle

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleBtn

local toggleKnob = Instance.new("Frame")
toggleKnob.Size = UDim2.new(0, 20, 0, 20)
toggleKnob.Position = UDim2.new(0, 22, 0.5, -10)
toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleKnob.BorderSizePixel = 0
toggleKnob.Parent = toggleBtn

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = toggleKnob

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -228, 1, 0)
rightPanel.Position = UDim2.new(0, 228, 0, 0)
rightPanel.BackgroundColor3 = Theme.Background
rightPanel.BorderSizePixel = 0
rightPanel.Parent = content

local rpCorner = Instance.new("UICorner")
rpCorner.CornerRadius = UDim.new(0, 10)
rpCorner.Parent = rightPanel

local searchBox = Instance.new("Frame")
searchBox.Size = UDim2.new(1, -16, 0, 36)
searchBox.Position = UDim2.new(0, 8, 0, 8)
searchBox.BackgroundColor3 = Theme.Surface
searchBox.BorderSizePixel = 0
searchBox.Parent = rightPanel

local searchBoxCorner = Instance.new("UICorner")
searchBoxCorner.CornerRadius = UDim.new(0, 8)
searchBoxCorner.Parent = searchBox

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 16, 0, 16)
searchIcon.Position = UDim2.new(0, 12, 0.5, -8)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = "rbxassetid://3926307971"
searchIcon.ImageRectOffset = Vector2.new(964, 324)
searchIcon.ImageRectSize = Vector2.new(36, 36)
searchIcon.ImageColor3 = Theme.TextMuted
searchIcon.Parent = searchBox

local searchInput = Instance.new("TextBox")
searchInput.Size = UDim2.new(1, -44, 1, 0)
searchInput.Position = UDim2.new(0, 36, 0, 0)
searchInput.BackgroundTransparency = 1
searchInput.Text = ""
searchInput.PlaceholderText = "Search sounds..."
searchInput.TextColor3 = Theme.TextPrimary
searchInput.PlaceholderColor3 = Theme.TextMuted
searchInput.Font = Enum.Font.Gotham
searchInput.TextSize = 13
searchInput.ClearTextOnFocus = false
searchInput.Parent = searchBox

local filterFrame = Instance.new("Frame")
filterFrame.Size = UDim2.new(1, -16, 0, 28)
filterFrame.Position = UDim2.new(0, 8, 0, 48)
filterFrame.BackgroundTransparency = 1
filterFrame.Parent = rightPanel

local allBtn = Instance.new("TextButton")
allBtn.Size = UDim2.new(0, 60, 1, 0)
allBtn.BackgroundColor3 = Theme.Accent
allBtn.Text = "All"
allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
allBtn.Font = Enum.Font.GothamBold
allBtn.TextSize = 11
allBtn.BorderSizePixel = 0
allBtn.Parent = filterFrame

local watchedBtn = Instance.new("TextButton")
watchedBtn.Size = UDim2.new(0, 80, 1, 0)
watchedBtn.Position = UDim2.new(0, 64, 0, 0)
watchedBtn.BackgroundColor3 = Theme.Surface
watchedBtn.Text = "Watched"
watchedBtn.TextColor3 = Theme.TextSecondary
watchedBtn.Font = Enum.Font.GothamBold
watchedBtn.TextSize = 11
watchedBtn.BorderSizePixel = 0
watchedBtn.Parent = filterFrame

local refreshSmall = Instance.new("TextButton")
refreshSmall.Size = UDim2.new(0, 28, 0, 28)
refreshSmall.Position = UDim2.new(1, -28, 0, 0)
refreshSmall.BackgroundColor3 = Theme.Surface
refreshSmall.Text = "↻"
refreshSmall.TextColor3 = Theme.TextSecondary
refreshSmall.Font = Enum.Font.GothamBold
refreshSmall.TextSize = 14
refreshSmall.BorderSizePixel = 0
refreshSmall.Parent = filterFrame

for _, btn in ipairs({allBtn, watchedBtn, refreshSmall}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -84)
scroll.Position = UDim2.new(0, 8, 0, 80)
scroll.BackgroundColor3 = Theme.Surface
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Theme.Accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = rightPanel

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 8)
scCorner.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = scroll

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 28)
statusBar.Position = UDim2.new(0, 0, 1, -28)
statusBar.BackgroundColor3 = Theme.Background
statusBar.BorderSizePixel = 0
statusBar.Parent = main

local statusBarCorner = Instance.new("UICorner")
statusBarCorner.CornerRadius = UDim.new(0, 12)
statusBarCorner.Parent = statusBar

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 10, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Ready"
statusText.TextColor3 = Theme.TextMuted
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

local modal = nil
local function createModal()
    if modal then
        modal:Destroy()
        modal = nil
    end

    modal = Instance.new("Frame")
    modal.Name = "WebhookModal"
    modal.Size = UDim2.fromScale(1, 1)
    modal.Position = UDim2.fromScale(0, 0)
    modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modal.BackgroundTransparency = 0.4
    modal.BorderSizePixel = 0
    modal.Active = true
    modal.Selectable = true
    modal.ZIndex = 1000
    modal.Parent = gui

    local overlayButton = Instance.new("TextButton")
    overlayButton.Name = "OverlayButton"
    overlayButton.Size = UDim2.fromScale(1, 1)
    overlayButton.Position = UDim2.fromScale(0, 0)
    overlayButton.BackgroundTransparency = 1
    overlayButton.BorderSizePixel = 0
    overlayButton.Text = ""
    overlayButton.AutoButtonColor = false
    overlayButton.Modal = true
    overlayButton.ZIndex = 1000
    overlayButton.Parent = modal

    local box = Instance.new("Frame")
    box.Name = "Dialog"
    box.Size = UDim2.new(0, 400, 0, 200)
    box.Position = UDim2.new(0.5, -200, 0.5, -100)
    box.BackgroundColor3 = Theme.Surface
    box.BorderSizePixel = 0
    box.Active = true
    box.ZIndex = 1010
    box.Parent = modal

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 12)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Theme.Border
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local mTitle = Instance.new("TextLabel")
    mTitle.Size = UDim2.new(1, -24, 0, 30)
    mTitle.Position = UDim2.new(0, 12, 0, 12)
    mTitle.BackgroundTransparency = 1
    mTitle.Text = "Configure Webhook"
    mTitle.TextColor3 = Theme.TextPrimary
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 16
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 1011
    mTitle.Parent = box

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -24, 0, 40)
    input.Position = UDim2.new(0, 12, 0, 50)
    input.BackgroundColor3 = Theme.Background
    input.Text = config.webhook
    input.PlaceholderText = "https://discord.com/api/webhooks/..."
    input.TextColor3 = Theme.TextPrimary
    input.PlaceholderColor3 = Theme.TextMuted
    input.Font = Enum.Font.Code
    input.TextSize = 12
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.BorderSizePixel = 0
    input.ZIndex = 1011
    input.Parent = box

    local inCorner = Instance.new("UICorner")
    inCorner.CornerRadius = UDim.new(0, 8)
    inCorner.Parent = input

    local inPad = Instance.new("UIPadding")
    inPad.PaddingLeft = UDim.new(0, 12)
    inPad.Parent = input

    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -24, 0, 36)
    btnFrame.Position = UDim2.new(0, 12, 1, -48)
    btnFrame.BackgroundTransparency = 1
    btnFrame.ZIndex = 1011
    btnFrame.Parent = box

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.48, -4, 1, 0)
    cancelBtn.BackgroundColor3 = Theme.SurfaceHover
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Theme.TextPrimary
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 13
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Modal = true
    cancelBtn.ZIndex = 1012
    cancelBtn.Parent = btnFrame

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, -4, 1, 0)
    saveBtn.Position = UDim2.new(0.52, 0, 0, 0)
    saveBtn.BackgroundColor3 = Theme.Accent
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 13
    saveBtn.BorderSizePixel = 0
    saveBtn.Modal = true
    saveBtn.ZIndex = 1012
    saveBtn.Parent = btnFrame

    for _, btn in ipairs({cancelBtn, saveBtn}) do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
    end

    local closing = false

    local function closeModal()
        if closing or not modal then
            return
        end

        closing = true

        local currentModal = modal
        modal = nil

        local fade = TweenService:Create(
            currentModal,
            TweenInfo.new(0.15),
            {BackgroundTransparency = 1}
        )

        fade.Completed:Connect(function()
            if currentModal then
                currentModal:Destroy()
            end
        end)

        fade:Play()
    end

    cancelBtn.Activated:Connect(closeModal)

    saveBtn.Activated:Connect(function()
        local url = input.Text:gsub("^%s+", ""):gsub("%s+$", "")

        if url == "" then
            statusText.Text = "Webhook URL cannot be empty"
            statusText.TextColor3 = Theme.Error
            return
        end

        config.webhook = url
        saveConfig(config)

        webhookText.Text = url:sub(1, 30) .. "..." .. url:sub(-10)
        webhookText.TextColor3 = Theme.Success
        statusText.Text = "Webhook saved successfully"
        statusText.TextColor3 = Theme.Success

        closeModal()
    end)

    overlayButton.Activated:Connect(closeModal)

    input:CaptureFocus()
end

local selected = {}
for _, id in ipairs(config.watched or {}) do
    selected[id] = true
end
local monitoring = true
local currentFilter = "all"

local function updateToggleVisual()
    local targetPos = monitoring and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    local targetColor = monitoring and Theme.Accent or Theme.SurfaceHover
    TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = targetPos}):Play()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()

    if monitoring then
        gtLabel.Text = "Monitoring Active"
        gtLabel.TextColor3 = Theme.TextPrimary
        toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        gtLabel.Text = "Monitoring Paused"
        gtLabel.TextColor3 = Theme.TextMuted
        toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function getFullSoundList()
    local list = {}
    local seen = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("Sound") then
            local key = obj.SoundId ~= "" and obj.SoundId or obj:GetFullName()
            if not seen[key] then
                seen[key] = true
                local category = "Other"
                if obj:IsDescendantOf(workspace) then category = "Workspace"
                elseif obj:IsDescendantOf(game.ReplicatedStorage) then category = "ReplicatedStorage"
                elseif obj:IsDescendantOf(game.SoundService) then category = "SoundService"
                elseif obj:IsDescendantOf(game.StarterGui) then category = "StarterGui"
                end

                table.insert(list, {
                    name = obj.Name,
                    id = obj.SoundId,
                    path = obj:GetFullName(),
                    category = category,
                    key = key
                })
            end
        end
    end
    table.sort(list, function(a, b)
        if a.category ~= b.category then
            return a.category < b.category
        end
        return a.name:lower() < b.name:lower()
    end)
    return list
end

local soundList = {}
local soundFrames = {}

local function createSoundRow(data)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Theme.Background
    row.BorderSizePixel = 0
    row.LayoutOrder = #soundFrames + 1

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local isSelected = selected[data.key] == true

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = isSelected and Theme.Accent or Color3.fromRGB(0,0,0)
    indicator.BorderSizePixel = 0
    indicator.Parent = row

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 2)
    indCorner.Parent = indicator

    local check = Instance.new("TextButton")
    check.Size = UDim2.new(0, 20, 0, 20)
    check.Position = UDim2.new(0, 12, 0.5, -10)
    check.BackgroundColor3 = isSelected and Theme.Accent or Theme.SurfaceHover
    check.Text = isSelected and "✓" or ""
    check.TextColor3 = Color3.fromRGB(255, 255, 255)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 12
    check.BorderSizePixel = 0
    check.Parent = row

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = check

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -180, 0, 18)
    nameLbl.Position = UDim2.new(0, 40, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = data.name
    nameLbl.TextColor3 = Theme.TextPrimary
    nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row

    local pathLbl = Instance.new("TextLabel")
    pathLbl.Size = UDim2.new(1, -180, 0, 14)
    pathLbl.Position = UDim2.new(0, 40, 0, 26)
    pathLbl.BackgroundTransparency = 1
    pathLbl.Text = data.id ~= "" and data.id:gsub("rbxassetid://", "") or data.path
    pathLbl.TextColor3 = Theme.TextMuted
    pathLbl.Font = Enum.Font.Code
    pathLbl.TextSize = 10
    pathLbl.TextXAlignment = Enum.TextXAlignment.Left
    pathLbl.TextTruncate = Enum.TextTruncate.AtEnd
    pathLbl.Parent = row

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 80, 0, 18)
    badge.Position = UDim2.new(1, -90, 0.5, -9)
    badge.BackgroundColor3 = Theme.SurfaceHover
    badge.Text = data.category
    badge.TextColor3 = Theme.TextSecondary
    badge.Font = Enum.Font.Gotham
    badge.TextSize = 9
    badge.Parent = row

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = badge

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHover}):Play()
    end)

    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Background}):Play()
    end)

    check.MouseButton1Click:Connect(function()
        isSelected = not isSelected
        selected[data.key] = isSelected

        TweenService:Create(check, TweenInfo.new(0.15), {
            BackgroundColor3 = isSelected and Theme.Accent or Theme.SurfaceHover
        }):Play()
        check.Text = isSelected and "✓" or ""
        indicator.BackgroundColor3 = isSelected and Theme.Accent or Color3.fromRGB(0,0,0)

        local newList = {}
        for k, v in pairs(selected) do
            if v then table.insert(newList, k) end
        end
        config.watched = newList
        saveConfig(config)

        statusText.Text = isSelected and "Added to watch list" or "Removed from watch list"
        statusText.TextColor3 = Theme.TextSecondary
    end)

    return row
end

local function refreshList(filterText)
    filterText = filterText or ""

    for _, frame in ipairs(soundFrames) do
        frame:Destroy()
    end
    soundFrames = {}

    soundList = getFullSoundList()
    local count = 0

    for _, sound in ipairs(soundList) do
        local shouldShow = true

        if filterText ~= "" then
            local searchLower = filterText:lower()
            if not (sound.name:lower():find(searchLower) or
                   sound.path:lower():find(searchLower) or
                   sound.id:lower():find(searchLower)) then
                shouldShow = false
            end
        end

        if currentFilter == "watched" and not selected[sound.key] then
            shouldShow = false
        end

        if shouldShow then
            local row = createSoundRow(sound)
            row.Parent = scroll
            table.insert(soundFrames, row)
            count = count + 1
        end
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, #soundFrames * 50 + 20)
    statusText.Text = string.format("Showing %d/%d sounds", count, #soundList)
    statusText.TextColor3 = Theme.TextMuted
end

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Error}):Play()
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Surface}):Play()
    closeBtn.TextColor3 = Theme.TextSecondary
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

webhookBtn.MouseButton1Click:Connect(createModal)

testBtn.MouseButton1Click:Connect(function()
    if config.webhook == "" then
        statusText.Text = "Configure webhook first"
        statusText.TextColor3 = Theme.Error
        return
    end

    statusText.Text = "Testing webhook..."
    statusText.TextColor3 = Theme.Warning

    local rf = getRequestFunction()
    if not rf then
        statusText.Text = "Executor not supported"
        statusText.TextColor3 = Theme.Error
        return
    end

    local ok = pcall(function()
        rf({
            Url = config.webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                content = "",
                embeds = {{
                    title = "✅ Test Alert",
                    description = "Sound Alert Pro is configured correctly!",
                    color = 0x5865F2,
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            })
        })
    end)

    if ok then
        statusText.Text = "Test sent successfully"
        statusText.TextColor3 = Theme.Success
    else
        statusText.Text = "Test failed - check URL"
        statusText.TextColor3 = Theme.Error
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    monitoring = not monitoring
    updateToggleVisual()
    statusText.Text = monitoring and "Monitoring resumed" or "Monitoring paused"
    statusText.TextColor3 = monitoring and Theme.Success or Theme.Warning
end)

searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    refreshList(searchInput.Text)
end)

allBtn.MouseButton1Click:Connect(function()
    currentFilter = "all"
    allBtn.BackgroundColor3 = Theme.Accent
    allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    watchedBtn.BackgroundColor3 = Theme.Surface
    watchedBtn.TextColor3 = Theme.TextSecondary
    refreshList(searchInput.Text)
end)

watchedBtn.MouseButton1Click:Connect(function()
    currentFilter = "watched"
    watchedBtn.BackgroundColor3 = Theme.Accent
    watchedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    allBtn.BackgroundColor3 = Theme.Surface
    allBtn.TextColor3 = Theme.TextSecondary
    refreshList(searchInput.Text)
end)

refreshSmall.MouseButton1Click:Connect(function()
    refreshList(searchInput.Text)
end)

if config.webhook ~= "" then
    webhookText.Text = config.webhook:sub(1, 25) .. "..." .. config.webhook:sub(-10)
    webhookText.TextColor3 = Theme.Success
end

updateToggleVisual()
refreshList()

local lastFire = {}
local function fire(sound)
    if not monitoring then return end
    local now = tick()
    if lastFire[sound] and now - lastFire[sound] < 2 then return end
    lastFire[sound] = now

    config.stats = config.stats or {}
    config.stats.detected = (config.stats.detected or 0) + 1
    config.stats.lastAlert = os.date("%H:%M:%S")
    saveConfig(config)

    detectedLabel.Text = "Alerts Sent: " .. config.stats.detected
    lastAlertLabel.Text = "Last Alert: " .. config.stats.lastAlert

    if config.webhook ~= "" then
        local rf = getRequestFunction()
        if rf then
            pcall(function()
                rf({
                    Url = config.webhook,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode({
                        content = "",
                        embeds = {{
                            title = "🔊 Sound Detected",
                            description = string.format("**%s** is playing", sound.Name),
                            color = 0x5865F2,
                            fields = {
                                { name = "Sound ID", value = sound.SoundId ~= "" and sound.SoundId or "N/A", inline = true },
                                { name = "Location", value = sound.Parent and sound.Parent.Name or "Unknown", inline = true },
                                { name = "Full Path", value = sound:GetFullName(), inline = false }
                            },
                            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                        }}
                    })
                })
            end)
        end
    end
end

local function isWatched(sound)
    local key = sound.SoundId ~= "" and sound.SoundId or sound:GetFullName()
    return selected[key] == true
end

task.spawn(function()
    while gui and gui.Parent do
        if monitoring then
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("Sound") and obj.IsPlaying and isWatched(obj) then
                    fire(obj)
                end
            end
        end
        task.wait(0.05)
    end
end)

print("Sound Alert Pro loaded")
