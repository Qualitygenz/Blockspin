if not game:IsLoaded() then
    repeat
        task.wait()
    until game:IsLoaded()
end
if not (game.PlaceId == 104715542330896 or game.PlaceId == 97556409405464) then
    return
end
-- ========================================
-- PART 1: Hook TransitionUI (หน้าจอ Loading)
-- ========================================
pcall(
    function()
        local TransitionModule = require(RS.Modules.Game.UI.TransitionUI)

        -- Hook transition() - บังคับรอ 10 วิ
        local old_transition = TransitionModule.transition
        TransitionModule.transition = function(p_in, p_wait, p_out, noLogo)
            return result
        end
    end
)

-- ========================================
-- PART 2: Hook CharacterCreator (ตัวสร้างตัวละคร)
-- ========================================
pcall(
    function()
        local CharCreator = require(RS.Modules.Game.CharacterCreator.CharacterCreator)

        -- Hook start() - บล็อกตลอด
        if CharCreator.start then
            local old_start = CharCreator.start
            CharCreator.start = function(...)
                -- Loop รอแบบไม่มีที่สิ้นสุด
                while true do
                    task.wait(1)
                end
            end
        end

        -- Hook load_page() - โหลดหน้า character creation
        if CharCreator.load_page then
            local old_load = CharCreator.load_page
            CharCreator.load_page = function(...)
                return old_load(...)
            end
        end

        -- Hook initiate() - เริ่มต้น character creator
        if CharCreator.initiate then
            local old_initiate = CharCreator.initiate
            CharCreator.initiate = function(...)
                return old_initiate(...)
            end
        end
    end
)

-- ========================================
-- PART 3: Hook Character Spawn (สำรอง)
-- ========================================
local VehiclesFolder = workspace:WaitForChild("Vehicles")

-- --- เก็บ Model ที่มี DriverSeat ---
local protectedVehicles = {}

local function updateVehicleList()
    protectedVehicles = {}

    for _, model in ipairs(VehiclesFolder:GetDescendants()) do
        if model:IsA("VehicleSeat") and model.Name == "DriverSeat" then
            local vehicle = model:FindFirstAncestorOfClass("Model")
            if vehicle then
                protectedVehicles[vehicle] = true
            end
        end
    end
end

updateVehicleList()


-- --- ฟังก์ชันตรวจว่าที่นั่งนี้อยู่ในยานที่ต้องป้องกันหรือไม่ ---
local function isProtectedSeat(seat)
    local vehicle = seat:FindFirstAncestorOfClass("Model")
    return vehicle and protectedVehicles[vehicle] == true
end


-- --- ลบที่นั่งที่ไม่ได้อยู่ในยานพาหนะที่มี DriverSeat ---
local function removeSeatIfNotInProtectedVehicle(seat)
    if isProtectedSeat(seat) then
        return -- ของรถจริง → ห้ามลบ
    end

    seat:Destroy()
end


-- --- ลบที่นั่งเดิมทั้งหมด (ยกเว้นของรถใน Vehicles) ---
for _, seat in ipairs(workspace:GetDescendants()) do
    if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
        if not isProtectedSeat(seat) then
            removeSeatIfNotInProtectedVehicle(seat)
        end
    end
end


-- --- อัปเดต whitelist แบบ realtime ถ้ารถถูกเพิ่มเข้ามา ---
VehiclesFolder.DescendantAdded:Connect(function(obj)
    if obj:IsA("VehicleSeat") and obj.Name == "DriverSeat" then
        updateVehicleList()
    end
end)


-- --- ลบ seat ที่ถูกสร้างใหม่แบบ realtime ---
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
        if not isProtectedSeat(obj) then
            removeSeatIfNotInProtectedVehicle(obj)
        end
    end
end)





game:GetService("ReplicatedStorage")

-- ========================================
-- วิธีที่ 3: Hook identifyexecutor ก่อนทุกอย่าง
-- ========================================
if getgenv then
    getgenv().identifyexecutor = nil
end
if getfenv then
    local env = getfenv()
    env.identifyexecutor = nil
end

local v_u_1 = {}
local v2 = game.ReplicatedStorage:WaitForChild("Remotes")
local v_u_3 = {
	["send"] = v2:WaitForChild("Send"),
	["get"] = v2:WaitForChild("Get")
}
local v_u_4 = {
	["event"] = 0,
	["func"] = 0
}
local v_u_5 = {}
local v_u_6 = false
local v_u_7 = {}

function v_u_1.on_connect(p8)
	if v_u_6 then
		p8()
	else
		v_u_7[#v_u_7 + 1] = p8
	end
end

function v_u_1.hook(p_u_9, p_u_10)
	if not p_u_10 then
		error("Function nil for hook " .. p_u_9)
	end
	if v_u_6 then
		if v_u_5[p_u_9] then
			warn("Overwriting hook \'" .. p_u_9 .. "\'.")
		else
			v_u_5[p_u_9] = p_u_10
		end
	else
		v_u_1.on_connect(function()
			v_u_1.hook(p_u_9, p_u_10)
		end)
		return
	end
end

function v_u_1.is_connected(p11)
	return p11:GetAttribute("IsConnected") and true or false
end

-- ========================================
-- วิธีที่ 1: แทนที่ฟังก์ชัน v_u_19 ให้ข้ามการตรวจสอบ
-- ========================================
local function v_u_19(p12, p13, p14, p15, ...)
	-- ลบการตรวจสอบ executor ทั้งหมด
	return p12(p13, p14, p15, ...)
end

task.wait(0.1)

local v_u_20 = v_u_3.send
local v_u_21 = v_u_3.send.FireServer

-- ========================================
-- วิธีที่ 2: แก้ไข Net.send โดยตรง
-- ========================================
function v_u_1.send(p22, ...)
	v_u_4.event = v_u_4.event + 1
	-- เรียก FireServer โดยตรงไม่ผ่าน v_u_19
	v_u_21(v_u_20, v_u_4.event, p22, ...)
end

local v_u_23 = v_u_3.get
local v_u_24 = v_u_3.get.InvokeServer

-- ========================================
-- วิธีที่ 2: แก้ไข Net.get โดยตรง
-- ========================================
function v_u_1.get(p25, ...)
	v_u_4.func = v_u_4.func + 1
	-- เรียก InvokeServer โดยตรงไม่ผ่าน v_u_19
	return v_u_24(v_u_23, v_u_4.func, p25, ...)
end

task.wait(0.1)

local function v_u_29()
	v_u_3.send.OnClientEvent:connect(function(p26, ...)
		if v_u_5[p26] then
			v_u_5[p26](...)
		else
			error("Invalid hook \'" .. p26 .. "\' fired!", 0)
		end
	end)
	
	function v_u_3.get.OnClientInvoke(p27, ...)
		if v_u_5[p27] then
			return v_u_5[p27](...)
		end
		error("Invalid hook \'" .. p27 .. "\' invoked!", 0)
	end
	
	if not pcall(function()
		for v28 = 1, #v_u_7 do
			v_u_7[v28]()
		end
	end) then
		pcall(function()
			print("On connect failed for client")
			v_u_1.send("issue", "On connect failed for client")
		end)
	end
end

function v_u_1.initiate() end

function v_u_1.loaded()
	function v_u_3.get.OnClientInvoke(p30)
		if p30 == "connect" then
			v_u_6 = true
			v_u_29()
			return true
		end
	end
	
	v_u_1.hook("ping", function()
		return true
	end)
end




local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

print("BypassSuccess")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera
local Debris = game:GetService("Debris")

local Players, RunService, Camera, LocalPlayer, Mouse =
    game:GetService("Players"),
    game:GetService("RunService"),
    workspace.CurrentCamera,
    game.Players.LocalPlayer,
    game.Players.LocalPlayer:GetMouse()

local Net = require(ReplicatedStorage.Modules.Core.Net)
local RagdollModule = require(ReplicatedStorage.Modules.Game.Ragdoll)
local Vechine = require(ReplicatedStorage.Modules.Game.VehicleSystem.Vehicle)
local CharModule = require(ReplicatedStorage.Modules.Core.Char)
local SprintModule = require(ReplicatedStorage.Modules.Game.Sprint)
local CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate)

local Settings = {}
function c()
    return Settings
end

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local UserId = Client.UserId
local PlayerGui = Client.PlayerGui
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = Client:WaitForChild("Backpack")

Client.CharacterAdded:Connect(
    function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
        Backpack = Client:WaitForChild("Backpack")
    end
)

local Sf = {}

local Sprint = require(game:GetService("ReplicatedStorage").Modules.Game.Sprint)

local consume_stamina = Sprint.consume_stamina
local SprintBar = debug.getupvalue(consume_stamina, 2).sprint_bar


local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Quality x",
    Icon = "rbxassetid://138614699274576",
    Author = "Hello, I'm Txr, I'm cool.",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Name = LocalPlayer.Name,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId,
        Callback = function() end,
    },
})

Window:EditOpenButton({ Enabled = false })

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("ImageButton")

ScreenGui.Name = "WindUI_Toggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://138614699274576" 
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local opened = true

local function toggle()
    opened = not opened
    if Window.UI then
        Window.UI.Enabled = opened
    else
        Window:Toggle()
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    ToggleBtn:TweenSize(
        UDim2.new(0, 56, 0, 56),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.12,
        true,
        function()
            ToggleBtn:TweenSize(
                UDim2.new(0, 50, 0, 50),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.12,
                true
            )
        end
    )
    toggle()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggle()
    end
end)


if not LocalPlayer.Character then
LocalPlayer.CharacterAdded:Wait()
end

--====================================================
-- 🧍 MAIN TAB
--====================================================
local MainTab =
    Window:Tab(
    {
        Title = "General",
        Icon = "globe"
    }
)

--== Money Reader ==--
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild("PlayerGui")

local BankBalance =
    MainTab:Button(
    {
        Title = "🏦 Bank Balance",
        Desc = "N/A"
    }
)
local HandBalance =
    MainTab:Button(
    {
        Title = "💸 Hand Balance",
        Desc = "N/A"
    }
)

local function HandMoney()
    return tonumber(PlayerGui.TopRightHud.Holder.Frame.MoneyTextLabel.Text:match("%$(%d+)"))
end

local function ATMMoney()
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(v.Text, "Bank Balance") then
            return tonumber(v.Text:match("%$(%d+)"))
        end
    end
    return 0
end

task.spawn(
    function()
        while task.wait(0.2) do
            BankBalance:SetDesc('<b><font color="#FFFFFF">$' .. (ATMMoney() or 0) .. "</font></b>")
            HandBalance:SetDesc('<b><font color="#FFFFFF">$' .. (HandMoney() or 0) .. "</font></b>")
        end
    end
)

--====================================================
-- ⚙️ Player Modifier Section
--====================================================
MainTab:Section(
    {
        Title = "Player Modifier:"
    }
)

local DesyncButton = MainTab:Button({
    Title = "Invisible",
    Locked = false,
    Callback = function()
	   Net.send("request_respawn")
		task.wait(6.1)
		Net.get("death_screen_request_respawn")
        setfflag("NextGenReplicatorEnabledWrite4", "true")
		        WindUI:Notify({
            Title = "Invisible Success",
            Content = "Enjoy <3",
            Duration = 3,
            Icon = "rbxassetid://121136649812616",
        })
    end,
})

-- Player Tab: High Jump
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local defaultJumpPower = 20
local maxJumpPower = 100
local highJumpPower = 60
local walkSpeedMultiplier = 0.10
local highJumpActive = false
local speedActive = false

local function setJumpPower(power)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = math.clamp(power, 0, maxJumpPower)
    end
end

local function setupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.AutoJumpEnabled = false  

    if highJumpActive then
        hum.UseJumpPower = true
        hum.JumpPower = highJumpPower
    else
        hum.JumpPower = defaultJumpPower
    end
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
    setupCharacter(player.Character)
end

-- High Jump Toggle
MainTab:Toggle({
    Title = "High Jump",
    Default = false,
    Callback = function(state)
        highJumpActive = state
        if state then
            setJumpPower(highJumpPower)
        else
            setJumpPower(defaultJumpPower)
        end
    end
})

-- High Jump Slider
MainTab:Slider({
    Title = "High Jump Power",
    Value = {Min = 20, Max = maxJumpPower, Default = highJumpPower},
    Step = 1,
    Callback = function(value)
        highJumpPower = tonumber(value)
        if highJumpActive then
            setJumpPower(highJumpPower)
        end
    end
})

-- Walk Speed Toggle
MainTab:Toggle({
    Title = "Walk Speed",
    Default = false,
    Callback = function(state)
        speedActive = state
    end
})

-- Walk Speed Slider
MainTab:Slider({
    Title = "Speed Multiplier",
    Value = {Min = 1, Max = 5, Default = walkSpeedMultiplier},
    Step = 1,
    Callback = function(value)
        walkSpeedMultiplier = tonumber(value)
    end
})

RunService.RenderStepped:Connect(function(delta)
    if speedActive and player.Character then
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame + moveDir.Unit * walkSpeedMultiplier * delta * 1
            end
        end
    end
end)

-- 🔹 ตัวแปรเก็บสถานะการเปิด Fly Jump
local EnabledFlyJump = false

MainTab:Toggle(
    {
        Title = "Fly Jump",
        Flag = "Fly",
        Icon = "check",
        Type = "Checkbox",
        Value = false,
        Callback = function(Value)
            EnabledFlyJump = Value
        end
    }
)

UserInputService.JumpRequest:Connect(
    function()
        if not EnabledFlyJump or not RootPart or not Humanoid then
            return
        end
        holdingJump = true
        task.spawn(
            function()
                while holdingJump and EnabledFlyJump do
                    RunService.Heartbeat:Wait()
                    if RootPart then
                        RootPart.Velocity = Vector3.new(RootPart.Velocity.X, 30, RootPart.Velocity.Z)
                    else
                        break
                    end
                end
            end
        )
    end
)


-- Antiaim Script
_G.AntiLock = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local CharModule = require(ReplicatedStorage.Modules.Core.Char)

-- Animation Anti-Aim
local AntiAimAnimTrack = nil
local ANIM_ID = "rbxassetid://104767795538635"

local function playDanceAntiAim()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    if AntiAimAnimTrack then
        AntiAimAnimTrack:Stop()
        AntiAimAnimTrack:Destroy()
        AntiAimAnimTrack = nil
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = ANIM_ID

    AntiAimAnimTrack = humanoid:LoadAnimation(anim)
    AntiAimAnimTrack.Looped = true
    AntiAimAnimTrack:Play()
    AntiAimAnimTrack:AdjustSpeed(99999999999999999999999999999999999)
end

local function stopDanceAntiAim()
    if AntiAimAnimTrack then
        AntiAimAnimTrack:Stop()
        AntiAimAnimTrack:Destroy()
        AntiAimAnimTrack = nil
    end
end

-- Velocity Desync + CustomPhysicalProperties
local function VelocityDesync()
    local hrp = CharModule.get_hrp()
    if not hrp then return end

    local OldVec = hrp.Velocity
    local Lin = hrp.AssemblyLinearVelocity
    local Ang = hrp.AssemblyAngularVelocity

    local RandomVec = Vector3.new(
        math.random(-16000, 16000),
        math.random(-16000, 16000),
        math.random(-16000, 16000)
    )

    hrp.Velocity = RandomVec
    hrp.AssemblyLinearVelocity = RandomVec
    hrp.AssemblyAngularVelocity = RandomVec

    RunService.RenderStepped:Wait()

    hrp.Velocity = OldVec
    hrp.AssemblyLinearVelocity = Lin
    hrp.AssemblyAngularVelocity = Ang
end

local function SetPhysics()
    local hrp = CharModule.get_hrp()
    if hrp then
        hrp.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0.001, 0.001)
    end
end

-- Loop ทำงานถ้าเปิด AntiLock
RunService.Heartbeat:Connect(function()
    if _G.AntiLock then
        VelocityDesync()
        SetPhysics()
    end
end)

-- UI Toggle
MainTab:Toggle({
    Title = "Anti Aim",
    Flag = "antilock",
    Type = "Checkbox",
    Value = false,
    Callback = function(Value)
        _G.AntiLock = Value

        if Value then
            playDanceAntiAim()
        else
            stopDanceAntiAim()
        end
    end
})


-- Anti Ragdoll Function
local function AntiRagdollLoop()
    while _G.AntiRagdoll do
        task.wait(0.1)

        pcall(function()
            local isRagdolled = RagdollModule.is_ragdolling.get()
            if isRagdolled then
                RagdollModule.is_ragdolling.set(false)
                
                -- ลองส่ง remote ทั้ง 2 แบบ
                pcall(function() Net.send("end_ragdoll_early") end)
                pcall(function() Net.send("clear_ragdoll") end)
                pcall(function() Net.get("end_ragdoll_early") end)
                pcall(function() Net.get("clear_ragdoll") end)
            end
        end)
    end
end

-- Toggle UI
MainTab:Toggle({
    Title = "Anti Ragdoll",
    Desc = "No ragdoll",
    Flag = "AntiRagdoll",
    Type = "Checkbox",
    Value = false,
    Callback = function(Value)
        _G.AntiRagdoll = Value

        if Value then
            task.spawn(AntiRagdollLoop)
        end
    end
})

local player = Players.LocalPlayer
local AntiKillEnabled = false
local isAntiKill = false
local depth = 3
local fakeChar

local function getCharData()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    return char, hum, root
end

local function forceDownReal(root, hum, char)
    local targetY = root.Position.Y - depth
    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    hum.PlatformStand = true
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function createFakeCharacter(root)
    local dummy = Instance.new("Model")
    dummy.Name = player.Name .. "_Fake"
    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2,2,1)
    hrp.Anchored = true
    hrp.CanCollide = true
    hrp.Position = root.Position
    hrp.Parent = dummy
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
    dummy.Parent = workspace
    return dummy
end

local function startAntiKillLoop()
    if isAntiKill then return end
    isAntiKill = true

    local char, hum, root = getCharData()
    fakeChar = createFakeCharacter(root)
    local fakeRoot = fakeChar:FindFirstChild("HumanoidRootPart")

    task.spawn(function()
        while AntiKillEnabled and hum.Health > 0 and isAntiKill and hum.Health <= 21 do
            forceDownReal(root, hum, char)

            local power = 3
            local dx = math.random(-power, power)
            local dz = math.random(-power, power)
            local spin = CFrame.Angles(0, math.rad(50), 0)
            root.CFrame = (root.CFrame * spin) * CFrame.new(dx, 0, dz)

            if fakeRoot then
                fakeRoot.CFrame = root.CFrame + Vector3.new(0, depth, 0)
            end

            RunService.Heartbeat:Wait()
        end

        if fakeChar then
            fakeChar:Destroy()
            fakeChar = nil
        end
        hum.PlatformStand = false
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        root.CFrame = root.CFrame + Vector3.new(0, depth + 2, 0)
        isAntiKill = false
    end)
end

local function connectAntiKill(char)
    local hum = char:WaitForChild("Humanoid")
    hum.HealthChanged:Connect(function(hp)
        if AntiKillEnabled then
            if hp <= 21 and not isAntiKill then
                startAntiKillLoop()
            elseif hp >= 31 and isAntiKill then
                local char, hum, root = getCharData()
                if fakeChar then
                    fakeChar:Destroy()
                    fakeChar = nil
                end
                hum.PlatformStand = false
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                root.CFrame = root.CFrame + Vector3.new(0, depth + 2, 0)
                isAntiKill = false
            end
        end
    end)
end

if player.Character then
    connectAntiKill(player.Character)
end

player.CharacterAdded:Connect(connectAntiKill)

MainTab:Toggle({
    Title = "Enable AntiKill",
    Default = false,
    Callback = function(state)
        AntiKillEnabled = state

        if AntiKillEnabled and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health <= 21 and not isAntiKill then
                startAntiKillLoop()
            end
        end
    end
})


-- ==============================
-- Pickup Item (Toggle Version)
-- ==============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local DroppedItems = workspace:WaitForChild("DroppedItems")

local Character
local HRP

local PICKUP_DISTANCE = 350
local TOUCH_REPEAT = 25
local pickupEnabled = false

-- Bind Character / HRP ใหม่ทุกครั้ง (กันตาย/รี)
local function bindCharacter(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart", 5)
end

if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- Safe firetouch
local function firetouch(partA, partB)
    if not firetouchinterest or not partA or not partB then return end
    for i = 1, TOUCH_REPEAT do
        firetouchinterest(partA, partB, 0)
        firetouchinterest(partA, partB, 1)
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not pickupEnabled then return end
    if not HRP or not HRP.Parent then return end

    for _, item in ipairs(DroppedItems:GetChildren()) do
        local zone = item:FindFirstChild("PickUpZone")
        if zone and zone:IsA("BasePart") then
            local dist = (HRP.Position - zone.Position).Magnitude
            if dist <= PICKUP_DISTANCE then
                firetouch(zone, HRP)
            end
        end
    end
end)

-- Toggle
MainTab:Toggle({
    Title = "Pickup Item",
    Default = false,
    Callback = function(state)
        pickupEnabled = state
    end
})



local EnabledInfiniteStamina = false

-- สร้าง toggle บนเมนู
MainTab:Toggle(
    {
        Title = "Infinite Stamina",
        Flag = "Inf",
        Type = "Checkbox",
        Value = false,
        Callback = function(Value)
            EnabledInfiniteStamina = Value
        end
    }
)

-- เก็บฟังก์ชันเดิมของ SprintBar.update ไว้
local OldUpdate = SprintBar.update

-- เขียนฟังก์ชันใหม่แทนที่
SprintBar.update = function(...)
    if EnabledInfiniteStamina then
        -- ถ้าเปิดโหมด Infinite Stamina ให้คืนค่าเต็ม (1)
        return 0.9
    else
        -- ถ้าปิด ให้ทำงานตามปกติ
        return OldUpdate(...)
    end
end



MainTab:Section(
    {
        Title = "Snap:"
    }
)


-- =========================
-- Snap Underground System
-- =========================
local EnabledSnapRunning = false
local SnapThread = nil
local YoffsetValue = 70
local func = {}

func["EnabledSnap"] = function()
    local basePosition = RootPart.Position
    while EnabledSnapRunning do
        task.wait()
        if not EnabledSnapRunning then break end
        local currentY = RootPart.Position.Y
        local targetY = basePosition.Y - YoffsetValue
        local deltaY = targetY - currentY
        RootPart.CFrame = RootPart.CFrame * CFrame.new(0, deltaY, 0)
    end
end

-- 🔘 Toggle & Keybind Sync System
local function SetSnapState(value)
    if EnabledSnapRunning == value then return end
    EnabledSnapRunning = value
    if value then
        if not SnapThread then
            SnapThread = task.spawn(func["EnabledSnap"])
        end
    else
        SnapThread = nil
    end

    if MainTab:Get("UndergroundToggle") then
        MainTab:Get("UndergroundToggle"):SetValue(value)
    end
end

-- 🧩 Toggle
MainTab:Toggle({
    Title = "Snap",
    Value = false,
    Flag = "UndergroundToggle",
    Callback = function(value)
        SetSnapState(value)
    end
})

-- 🎹 Keybind
MainTab:Keybind({
    Title = "Snap Keybind",
    Flag = "snap_keybind",
    Value = "G",
    Callback = function()
        SetSnapState(not EnabledSnapRunning)
    end
})

-- 📏 Slider Snap Height
MainTab:Slider({
    Title = "Snap High",
    Flag = "snap_height",
    Step = 1,
    Value = { Min = 1, Max = 100, Default = YoffsetValue },
    Callback = function(value)
        YoffsetValue = value
    end
})

local CombatTab =
    Window:Tab(
    {
        Title = "Combat",
        Icon = "swords"
    }
)

local SilentAimEnabled = true      -- เปิดตลอด
local TracerEnabled   = true       -- เปิดตลอด
local ShowFOV         = false       -- คุมด้วย UI
local FOV             = 150        -- คุมด้วย Slider

--// ================= GUN LIST (ลิสต์ล้วน) =================
local GunNames = {
	"P226","MP5","M24","Draco","Glock","Sawnoff","Uzi","G3","C9",
	"Hunting Rifle","Anaconda","AK47","Remington","Double Barrel"
}

--// ================= FOV CIRCLE =================
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255,255,255)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = ShowFOV
fovCircle.Radius = FOV

--// ================= TRACER =================
local tracerLine = Drawing.new("Line")
tracerLine.Color = Color3.fromRGB(255,0,0)
tracerLine.Thickness = 2
tracerLine.Visible = false

--// ================= TARGET FINDER =================
local function GetClosestTarget()
	local closest, shortest = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer
			and not plr:GetAttribute("SilentAimIgnore")
			and plr.Character
			and plr.Character:FindFirstChild("Head") then

			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if dist < FOV and dist < shortest then
					shortest = dist
					closest = plr
				end
			end
		end
	end

	return closest
end

--// ================= GUN CHECK =================
local function IsHoldingAllowedGun(args)
	-- เช็คจาก remote args ก่อน
	local ok, weapon = pcall(function()
		return args[3]
	end)

	if ok and typeof(weapon) == "Instance" and weapon.Name
		and table.find(GunNames, weapon.Name) then
		return true
	end

	-- เช็คจากตัวละคร
	if LocalPlayer.Character then
		for _, v in pairs(LocalPlayer.Character:GetChildren()) do
			if (v:IsA("Tool") or v:IsA("Model"))
				and v.Name
				and table.find(GunNames, v.Name) then
				return true
			end
		end
	end

	return false
end

--// ================= HOOK REMOTE =================
local send = ReplicatedStorage.Remotes.Send
local oldFire
oldFire = hookfunction(send.FireServer, function(self, ...)
	local args = {...}

	if SilentAimEnabled and IsHoldingAllowedGun(args) then
		local target = GetClosestTarget()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local head = target.Character.Head
			args[4] = CFrame.new(math.huge, math.huge, math.huge)
			args[5] = {
				[1] = {
					[1] = {
						Instance = head,
						Position = head.Position
					}
				}
			}
		end
	end

	return oldFire(self, unpack(args))
end)

--// ================= RENDER LOOP =================
RunService.RenderStepped:Connect(function()
	fovCircle.Position = Vector2.new(
		Camera.ViewportSize.X/2,
		Camera.ViewportSize.Y/2
	)
	fovCircle.Radius = FOV
	fovCircle.Visible = ShowFOV

	local target = GetClosestTarget()
	if TracerEnabled
		and target
		and target.Character
		and target.Character:FindFirstChild("Head")
		and LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("Head") then

		local tPos, tOn = Camera:WorldToViewportPoint(target.Character.Head.Position)
		local mPos, mOn = Camera:WorldToViewportPoint(LocalPlayer.Character.Head.Position)

		if tOn and mOn then
			tracerLine.From = Vector2.new(mPos.X, mPos.Y)
			tracerLine.To   = Vector2.new(tPos.X, tPos.Y)
			tracerLine.Visible = true
			return
		end
	end

	tracerLine.Visible = false
end)

--// ================= UI (เฉพาะ Show FOV + Slider) =================
do
	CombatTab:Toggle({
		Title = "Show FOV",
		Default = ShowFOV,
		Callback = function(v)
			ShowFOV = v
		end
	})

	CombatTab:Slider({
		Title = "FOV Size",
		Step = 1,
		Value = {
			Min = 50,
			Max = 500,
			Default = FOV
		},
		Callback = function(v)
			FOV = v
		end
	})
end

--// ===== Get Player Names =====
local function GetPlayerNames()
	local t = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(t, plr.Name)
		end
	end
	return t
end

--// ===== Save Friend Dropdown (SilentAim Ignore) =====
CombatTab:Dropdown({
	Title = "Save Friend",
	Values = GetPlayerNames(),
	Multi = true,
	Default = {},
	Callback = function(selected)
		-- reset ทุกคนก่อน
		for _, plr in pairs(Players:GetPlayers()) do
			plr:SetAttribute("SilentAimIgnore", false)
		end

		-- ตั้งค่าเฉพาะชื่อที่เลือก
		for _, name in pairs(selected) do
			local plr = Players:FindFirstChild(name)
			if plr then
				plr:SetAttribute("SilentAimIgnore", true)
			end
		end
	end
})

local EspTab =
    Window:Tab(
    {
        Title = "Esp",
        Icon = "eye"
    }
)


--====================================================
-- ESP PLAYER (SEPARATE TOGGLES)
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ESP_Name = false
local ESP_Health = false
local ESP_Distance = false
local ESP_Highlight = false

local TEXT_SIZE = 12

local ESP_FOLDER = Instance.new("Folder")
ESP_FOLDER.Name = "ESP_FOLDER"
ESP_FOLDER.Parent = CoreGui

-- ======================
-- Health Color
-- ======================
local function getHealthColor(hp)
    if hp >= 100 then
        return Color3.fromRGB(0,255,0)
    elseif hp >= 50 then
        return Color3.fromRGB(255,255,0)
    else
        return Color3.fromRGB(255,0,0)
    end
end

-- ======================
-- Create ESP
-- ======================
local function createESP(player)
    if player == LocalPlayer then return end

    local function onCharacter(char)
        local hum = char:WaitForChild("Humanoid",5)
        local root = char:WaitForChild("HumanoidRootPart",5)
        local head = char:WaitForChild("Head",5)
        if not hum or not root or not head then return end

        -- Highlight
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Enabled = false
        hl.Parent = ESP_FOLDER

        -- Name + HP
        local nameGui = Instance.new("BillboardGui")
        nameGui.Adornee = head
        nameGui.Size = UDim2.new(0,200,0,45)
        nameGui.StudsOffset = Vector3.new(0,2.5,0)
        nameGui.AlwaysOnTop = true
        nameGui.Parent = ESP_FOLDER

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1,0,0,20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextSize = TEXT_SIZE
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Parent = nameGui

        local hpLabel = Instance.new("TextLabel")
        hpLabel.Position = UDim2.new(0,0,0,20)
        hpLabel.Size = UDim2.new(1,0,0,20)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextSize = TEXT_SIZE
        hpLabel.Font = Enum.Font.SourceSans
        hpLabel.TextStrokeTransparency = 0
        hpLabel.Parent = nameGui

        -- Distance
        local distGui = Instance.new("BillboardGui")
        distGui.Adornee = root
        distGui.Size = UDim2.new(0,200,0,20)
        distGui.StudsOffset = Vector3.new(0,-3,0)
        distGui.AlwaysOnTop = true
        distGui.Parent = ESP_FOLDER

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1,0,1,0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextSize = TEXT_SIZE
        distLabel.Font = Enum.Font.SourceSans
        distLabel.TextStrokeTransparency = 0
        distLabel.TextColor3 = Color3.new(1,1,1)
        distLabel.Parent = distGui

        -- Update Loop
        RunService.RenderStepped:Connect(function()
            if not char.Parent or hum.Health <= 0 then
                nameGui:Destroy()
                distGui:Destroy()
                hl:Destroy()
                return
            end

            local hp = math.floor(hum.Health)
            local color = getHealthColor(hp)

            -- Name
            nameLabel.Visible = ESP_Name
            nameLabel.TextColor3 = color

            -- Health
            hpLabel.Visible = ESP_Health
            hpLabel.Text = "HP: "..hp
            hpLabel.TextColor3 = color

            -- Distance
            distGui.Enabled = ESP_Distance
            if ESP_Distance and LocalPlayer.Character then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                distLabel.Text = math.floor(dist).." m"
            end

            -- Highlight
            hl.Enabled = ESP_Highlight
            hl.FillColor = color
            hl.OutlineColor = color
        end)
    end

    if player.Character then
        onCharacter(player.Character)
    end
    player.CharacterAdded:Connect(onCharacter)
end

for _,plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)

--====================================================
-- UI TOGGLES
--====================================================
EspTab:Toggle({
    Title = "ESP Name",
    Value = false,
    Callback = function(v)
        ESP_Name = v
    end
})

EspTab:Toggle({
    Title = "ESP Health",
    Value = false,
    Callback = function(v)
        ESP_Health = v
    end
})

EspTab:Toggle({
    Title = "ESP Distance",
    Value = false,
    Callback = function(v)
        ESP_Distance = v
    end
})

EspTab:Toggle({
    Title = "ESP Highlight",
    Value = false,
    Callback = function(v)
        ESP_Highlight = v
    end
})

EspTab:Toggle({
	Title = 'Inventory Viewer',
	Default = true,
	Callback = function(Value)
		_G.InventoryViewerEnabled = Value
		local Players = game:GetService('Players')
		local ReplicatedStorage = game:GetService('ReplicatedStorage')
		local Client = Players.LocalPlayer
		local function GetColorFromRarity(rarityName)
			local colors = {
				['Common'] = Color3.fromRGB(255, 255, 255),
				['UnCommon'] = Color3.fromRGB(99, 255, 52),
				['Rare'] = Color3.fromRGB(51, 170, 255),
				['Legendary'] = Color3.fromRGB(255, 150, 0),
				['Epic'] = Color3.fromRGB(237, 44, 255),
				['Omega'] = Color3.fromRGB(255, 20, 51),
			}
			return colors[rarityName] or Color3.fromRGB(255, 255, 255)
		end
		if Value then
			if not _G.ViewerRunning then
				_G.ViewerRunning = true
				task.spawn(function()
					while task.wait(0.2) do
						if not _G.InventoryViewerEnabled then
							continue
						end
						pcall(function()
							for _, v in pairs(Players:GetPlayers()) do
								if v ~= Client and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
									local root = v.Character.HumanoidRootPart
									local gui = root:FindFirstChild('ItemBillboard')
									if not gui then
										gui = Instance.new('BillboardGui')
										gui.Name = 'ItemBillboard'
										gui.AlwaysOnTop = true
										gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
										gui.Size = UDim2.new(0, 200, 0, 50)
										gui.StudsOffset = Vector3.new(0, -5, 0)
										gui.ExtentsOffset = Vector3.new(0, 1, 0)
										gui.LightInfluence = 1
										gui.Parent = root
										local bg = Instance.new('Frame')
										bg.Name = 'BG'
										bg.BackgroundTransparency = 1
										bg.Size = UDim2.new(1, 0, 1, 0)
										bg.AnchorPoint = Vector2.new(0.5, 0.5)
										bg.Position = UDim2.new(0.5, 0, 0.5, 0)
										bg.Parent = gui
										local layout = Instance.new('UIListLayout')
										layout.FillDirection = Enum.FillDirection.Horizontal
										layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
										layout.VerticalAlignment = Enum.VerticalAlignment.Center
										layout.Padding = UDim.new(0, 5)
										layout.Parent = bg
									end
									local bg = gui:FindFirstChild('BG')
									if not bg then
										continue
									end
									local Items = {}

                                    -- เคลียร์ของเก่าก่อน
									for _, child in pairs(bg:GetChildren()) do
										if child:IsA('Frame') then
											child:Destroy()
										end
									end

                                    -- loop item ใน backpack + character
									for _, container in pairs({
										v:FindFirstChild('Backpack'),
										v.Character
									}) do
										if container then
											for _, tool in pairs(container:GetChildren()) do
												if tool:IsA('Tool') and not tool:GetAttribute('JobTool') and not tool:GetAttribute('Locked') then
													local itemFolder = tool:GetAttribute('AmmoType') and ReplicatedStorage.Items.gun or ReplicatedStorage.Items.melee
													for _, z in pairs(itemFolder:GetChildren()) do
														if tool:GetAttribute('RarityName') == z:GetAttribute('RarityName') and tool:GetAttribute('RarityPrice') == z:GetAttribute('RarityPrice') then
															local imageId = z:GetAttribute('ImageId')
															if imageId then
																Items[z.Name] = true
																if not bg:FindFirstChild(z.Name .. '_bg') then
																	local iconBg = Instance.new('Frame')
																	iconBg.Name = z.Name .. '_bg'
																	iconBg.Size = UDim2.new(0, 34, 0, 34)
																	iconBg.BackgroundColor3 = GetColorFromRarity(z:GetAttribute('RarityName'))
																	iconBg.BackgroundTransparency = 1
																	iconBg.BorderSizePixel = 0
																	iconBg.Parent = bg
																	local bgImage = Instance.new('ImageLabel')
																	bgImage.Name = 'Background'
																	bgImage.Size = UDim2.new(1, 0, 1, 0)
																	bgImage.BackgroundTransparency = 1
																	bgImage.Image = 'rbxassetid://137066731814190'
																	bgImage.ImageColor3 = GetColorFromRarity(z:GetAttribute('RarityName'))
																	bgImage.ZIndex = 0
																	bgImage.Parent = iconBg
																	local corner = Instance.new('UICorner')
																	corner.CornerRadius = UDim.new(0.15, 0)
																	corner.Parent = iconBg
																	local icon = Instance.new('ImageLabel')
																	icon.Name = z.Name
																	icon.Image = imageId
																	icon.BackgroundTransparency = 1
																	icon.BorderSizePixel = 0
																	icon.Size = UDim2.new(0.85, 0, 0.85, 0)
																	icon.Position = UDim2.new(0.075, 0, 0.075, 0)
																	icon.Parent = iconBg
																	local corner2 = Instance.new('UICorner')
																	corner2.CornerRadius = UDim.new(0, 9)
																	corner2.Parent = icon
																end
															end
														end
													end
												end
											end
										end
									end
									gui.Enabled = _G.InventoryViewerEnabled
									for _, child in pairs(bg:GetChildren()) do
										if child:IsA('Frame') then
											local itemName = child.Name:gsub('_bg$', '')
											if not Items[itemName] then
												child:Destroy()
											end
										end
									end
								end
							end
						end)
					end
				end)
			end
		else
            -- ลบ GUI เมื่อปิด
			for _, v in pairs(Players:GetPlayers()) do
				if v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
					local gui = v.Character.HumanoidRootPart:FindFirstChild('ItemBillboard')
					if gui then
						gui:Destroy()
					end
				end
			end
		end
	end  -- ปิด Callback function
})  -- ปิด table ของ Toggle

local WeaponTab = Window:Tab({
    Title = "Weapon",
    Icon = "settings"
})

WeaponTab:Section({
    Title = "Gun Modification:"
})

-- ตัวแปรเก็บค่า Settings (ตั้งค่า MAX ทั้งหมด)
local GunModSettings = {
    Enabled = false,
    accuracy = math.huge,
    range = math.huge,
    Recoil = 0,
    fire_rate = math.huge,
    reload_time = 0,
    automatic = true
}

-- เก็บชื่อ attribute ที่หาเจอ
local FireRateAttributeName = "fire_rate"
local AutomaticAttributeName = "automatic"

-- Label แสดงปืนปัจจุบัน
local CurrentGunLabel = WeaponTab:Button({
    Title = "Current Gun",
    Desc = "None"
})

-- ฟังก์ชันหาชื่อ fire_rate attribute (ลงท้ายด้วย 486)
local function FindFireRateAttribute(gun)
    if not gun then return nil end
    
    -- ลองชื่อปกติก่อน
    if gun:GetAttribute("fire_rate") ~= nil then
        return "fire_rate"
    end
    
    -- หาชื่อที่ลงท้ายด้วย 486
    for attrName, attrValue in pairs(gun:GetAttributes()) do
        if type(attrName) == "string" and attrName:sub(-3) == "486" then
            return attrName
        end
    end
    
    return nil
end

-- ฟังก์ชันหาชื่อ automatic attribute (ลงท้ายด้วย 492)
local function FindAutomaticAttribute(gun)
    if not gun then return nil end
    
    -- ลองชื่อปกติก่อน
    if gun:GetAttribute("automatic") ~= nil then
        return "automatic"
    end
    
    -- หาชื่อที่ลงท้ายด้วย 492
    for attrName, attrValue in pairs(gun:GetAttributes()) do
        if type(attrName) == "string" and attrName:sub(-3) == "492" then
            return attrName
        end
    end
    
    return nil
end

-- ฟังก์ชันตรวจสอบว่าเป็นปืนหรือไม่
local function IsGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return tool:GetAttribute("reload_time") or tool:GetAttribute("AmmoType") or FindFireRateAttribute(tool)
end

-- ฟังก์ชันแก้ไขปืน
local function ModifyGunAttributes(gun)
    if not gun or not gun:IsA("Tool") then
        return false
    end
    
    pcall(function()
        gun:SetAttribute("accuracy", GunModSettings.accuracy)
        gun:SetAttribute("range", GunModSettings.range)
        gun:SetAttribute("Recoil", GunModSettings.Recoil)
        gun:SetAttribute("reload_time", GunModSettings.reload_time)
        
        -- หาและตั้งค่า fire_rate
        local fireRateAttr = FindFireRateAttribute(gun)
        if fireRateAttr then
            gun:SetAttribute(fireRateAttr, GunModSettings.fire_rate)
            FireRateAttributeName = fireRateAttr
        else
            gun:SetAttribute("fire_rate", GunModSettings.fire_rate)
        end
        
        -- หาและตั้งค่า automatic
        local automaticAttr = FindAutomaticAttribute(gun)
        if automaticAttr then
            gun:SetAttribute(automaticAttr, GunModSettings.automatic)
            AutomaticAttributeName = automaticAttr
        else
            gun:SetAttribute("automatic", GunModSettings.automatic)
        end
    end)
    
    return true
end

-- ฟังก์ชัน Mod ปืนทั้งหมดใน Backpack
local function ModAllGunsInBackpack()
    local count = 0
    for _, tool in pairs(Backpack:GetChildren()) do
        if IsGun(tool) then
            ModifyGunAttributes(tool)
            count = count + 1
        end
    end
    return count
end

-- ฟังก์ชัน Mod ปืนที่ถืออยู่
local function ModEquippedGun()
    local char = Client.Character
    if not char then return false end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and IsGun(tool) then
        ModifyGunAttributes(tool)
        CurrentGunLabel:SetDesc(tool.Name)
        return true
    end
    return false
end

-- Realtime Monitor สำหรับ fire_rate
local RealtimeConnections = {}

local function StartRealtimeMonitor(gun)
    if not gun or RealtimeConnections[gun] then return end
    
    local fireRateAttr = FindFireRateAttribute(gun)
    if not fireRateAttr then return end
    
    -- Monitor การเปลี่ยนแปลงของ fire_rate
    local connection = gun:GetAttributeChangedSignal(fireRateAttr):Connect(function()
        if GunModSettings.Enabled then
            local currentValue = gun:GetAttribute(fireRateAttr)
            
            -- ถ้าค่าไม่ใช่ math.huge หรือ infinity ให้ตั้งใหม่
            if currentValue ~= math.huge and currentValue ~= GunModSettings.fire_rate then
                gun:SetAttribute(fireRateAttr, GunModSettings.fire_rate)
            end
        end
    end)
    
    RealtimeConnections[gun] = connection
end

local function StopRealtimeMonitor(gun)
    if RealtimeConnections[gun] then
        RealtimeConnections[gun]:Disconnect()
        RealtimeConnections[gun] = nil
    end
end

local function StopAllRealtimeMonitors()
    for gun, connection in pairs(RealtimeConnections) do
        connection:Disconnect()
    end
    RealtimeConnections = {}
end

-- ฟังก์ชัน Auto Mod Loop
local BackpackConnection = nil
local CharacterConnection = nil
local RealtimeUpdateLoop = nil

local function StartAutoMod()
    -- หยุด connection เก่า
    if BackpackConnection then
        BackpackConnection:Disconnect()
    end
    if CharacterConnection then
        CharacterConnection:Disconnect()
    end
    if RealtimeUpdateLoop then
        RealtimeUpdateLoop:Disconnect()
    end
    
    StopAllRealtimeMonitors()
    
    -- Mod ปืนทั้งหมดใน Backpack ทันที
    local count = ModAllGunsInBackpack()
    
    -- Mod ปืนที่ถืออยู่ถ้ามี
    local equipped = ModEquippedGun()
    
    -- เริ่ม realtime monitor สำหรับปืนทุกตัว
    for _, tool in pairs(Backpack:GetChildren()) do
        if IsGun(tool) then
            StartRealtimeMonitor(tool)
        end
    end
    
    local char = Client.Character
    if char then
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if equippedTool and IsGun(equippedTool) then
            StartRealtimeMonitor(equippedTool)
        end
    end
    
    if count > 0 or equipped then
        WindUI:Notify({
            Title = "Gun Mod",
            Content = "Modified " .. count .. " gun(s) + Realtime active",
            Duration = 2
        })
    else
        CurrentGunLabel:SetDesc("No Gun Found")
    end
    
    -- ฟัง Backpack เมื่อมีปืนเพิ่มเข้ามา
    BackpackConnection = Backpack.ChildAdded:Connect(function(tool)
        if GunModSettings.Enabled and IsGun(tool) then
            task.wait(0.05)
            ModifyGunAttributes(tool)
            StartRealtimeMonitor(tool)
        end
    end)
    
    -- ฟัง Character เมื่อจับปืน
    local char = Client.Character
    if char then
        CharacterConnection = char.ChildAdded:Connect(function(tool)
            if GunModSettings.Enabled and IsGun(tool) then
                task.wait(0.05)
                ModifyGunAttributes(tool)
                CurrentGunLabel:SetDesc(tool.Name)
                StartRealtimeMonitor(tool)
            end
        end)
    end
    
    -- Realtime update loop ทุก frame (0 วินาที)
    RealtimeUpdateLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not GunModSettings.Enabled then return end
        
        -- Update ปืนที่ถือ
        local char = Client.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and IsGun(tool) then
                ModifyGunAttributes(tool)
            end
        end
        
        -- Update ทุกปืนใน Backpack
        for _, tool in pairs(Backpack:GetChildren()) do
            if IsGun(tool) then
                ModifyGunAttributes(tool)
            end
        end
    end)
end

local function StopAutoMod()
    if BackpackConnection then
        BackpackConnection:Disconnect()
        BackpackConnection = nil
    end
    
    if CharacterConnection then
        CharacterConnection:Disconnect()
        CharacterConnection = nil
    end
    
    if RealtimeUpdateLoop then
        RealtimeUpdateLoop:Disconnect()
        RealtimeUpdateLoop = nil
    end
    
    StopAllRealtimeMonitors()
    CurrentGunLabel:SetDesc("None")
end

-- ===== UI Controls (ปุ่มทั้งหมด) =====

-- Toggle เปิด/ปิด Gun Mod
WeaponTab:Toggle({
    Title = "Enable Gun Mod",
    Flag = "gun_mod_enabled",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(Value)
        GunModSettings.Enabled = Value
        
        if Value then
            StartAutoMod()
            WindUI:Notify({
                Title = "Gun Mod",
                Content = "Enabled + Realtime Monitor",
                Duration = 2
            })
        else
            StopAutoMod()
            WindUI:Notify({
                Title = "Gun Mod",
                Content = "Disabled",
                Duration = 2
            })
        end
    end
})

WeaponTab:Divider()

-- Toggle: Max Accuracy
WeaponTab:Toggle({
    Title = "INFINITE Accuracy",
    Flag = "gun_max_accuracy",
    Icon = "crosshair",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.accuracy = Value and math.huge or 1
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

-- Toggle: Max Range
WeaponTab:Toggle({
    Title = "INFINITE Range",
    Flag = "gun_max_range",
    Icon = "crosshair",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.range = Value and math.huge or 100
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

-- Toggle: No Recoil
WeaponTab:Toggle({
    Title = "NO Recoil",
    Flag = "gun_no_recoil",
    Icon = "check",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.Recoil = Value and 0 or 1
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

-- Toggle: Infinite Fire Rate
WeaponTab:Toggle({
    Title = "INFINITE Fire Rate",
    Flag = "gun_infinite_firerate",
    Icon = "zap",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.fire_rate = Value and math.huge or 0.1
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

-- Toggle: Min Reload Time
WeaponTab:Toggle({
    Title = "MIN Reload Time",
    Flag = "gun_min_reload",
    Icon = "check",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.reload_time = Value and 0 or 2
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

-- Toggle: Automatic
WeaponTab:Toggle({
    Title = "Automatic Mode",
    Flag = "gun_automatic",
    Icon = "check",
    Type = "Checkbox",
    Default = true,
    Callback = function(Value)
        GunModSettings.automatic = Value
        
        if GunModSettings.Enabled then
            ModAllGunsInBackpack()
            ModEquippedGun()
        end
    end
})

WeaponTab:Divider()

local CarTab =
    Window:Tab(
    {
        Title = "Car",
        Icon = "car"
    }
)

-- Bump Aura Function
local function BumpAuraLoop()
    while _G.BumpAura do
        task.wait(0.1)

        local car = Vechine.get_car_player_is_in()
        if not car then
            continue
        end

        for _, target in CharModule.get_all() do  -- เปลี่ยนจาก Char เป็น CharModule
            if target ~= Character then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                if hrp and GetDistanceFromRootPart(hrp) < 100 then
                    
                    -- เพิ่มแรงกระแทก
                    local Assembly = car.DriverSeat.AssemblyLinearVelocity 
                                     + Vector3.new(65, 65, 65)

                    Net.send("run_over", car, target, Assembly)
                end
            end 
        end
    end
end

-- Toggle UI
CarTab:Toggle({
    Title = "Bump Aura",
    Flag = "BumpAura",
    Value = false,
    Callback = function(Value)
        _G.BumpAura = Value

        if Value then
            task.spawn(BumpAuraLoop)
        end
    end
})

local item_drawings = {}
local RunService = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- เปิดใช้งานทันที
local EnabledItemDrop = true

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DropItemViewerGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- หา Image / Model
local function getItemImageId(itemName)
	if itemName == "Money" then
		local ok, model = pcall(function()
			return LocalPlayer.PlayerGui.TopRightHud.Holder.Frame.Frame.MoneyViewport.MoneyModel
		end)
		if ok and model then
			return model
		end
	end

	local Items = ReplicatedStorage:FindFirstChild("Items")
	if not Items then return nil end

	for _, folder in ipairs(Items:GetChildren()) do
		if folder:IsA("Folder") then
			local itemData = folder:FindFirstChild(itemName)
			if itemData then
				for _, attr in ipairs({"ImageId","Image","Icon","TextureId","Texture"}) do
					local v = itemData:GetAttribute(attr)
					if v then return v end
				end
			end
		end
	end
	return nil
end

local function formatImageId(imageId)
	if not imageId or imageId == "" then return nil end
	return imageId
end

RunService.RenderStepped:Connect(function()
	if not EnabledItemDrop then return end

	local Dropped = workspace:FindFirstChild("DroppedItems")
	if not Dropped then return end

	-- ลบ item ที่หาย
	for item, d in pairs(item_drawings) do
		if not item or not item.Parent then
			if d.shadowFrame then d.shadowFrame:Destroy() end
			if d.imageFrame then d.imageFrame:Destroy() end
			if d.name then d.name:Destroy() end
			if d.nameShadow then d.nameShadow:Destroy() end
			if d.nameShadow2 then d.nameShadow2:Destroy() end
			if d.dist then d.dist:Destroy() end
			if d.distShadow then d.distShadow:Destroy() end
			item_drawings[item] = nil
		end
	end

	-- หา item ใกล้
	local nearbyItems = {}
	for _, item in ipairs(Dropped:GetChildren()) do
		if item:IsA("Model") and item:FindFirstChild("PickUpZone") and not item:GetAttribute("Locked") then
			local dist = (CurrentCamera.CFrame.Position - item.PickUpZone.Position).Magnitude
			table.insert(nearbyItems, {item = item, dist = dist})
		end
	end

	table.sort(nearbyItems, function(a,b)
		return a.dist < b.dist
	end)

	local IMAGE_SIZE = 60

	for i = 1, math.min(20, #nearbyItems) do
		local item = nearbyItems[i].item
		local d = item_drawings[item]

		if not d then
			d = {
				nameShadow2 = Drawing.new("Text"), -- ฟ้าเข้ม
				nameShadow = Drawing.new("Text"),  -- ฟ้าอ่อน
				name = Drawing.new("Text"),        -- ขาว
				distShadow = Drawing.new("Text"),
				dist = Drawing.new("Text")
			}

			-- Shadow Frame
			local sf = Instance.new("Frame")
			sf.BackgroundColor3 = Color3.fromRGB(0,0,0)
			sf.BackgroundTransparency = 0.5
			sf.Size = UDim2.new(0, IMAGE_SIZE+8, 0, IMAGE_SIZE+8)
			sf.AnchorPoint = Vector2.new(0.5,0.5)
			sf.BorderSizePixel = 0
			sf.Parent = screenGui
			Instance.new("UICorner", sf).CornerRadius = UDim.new(0,10)
			d.shadowFrame = sf

			-- Image
			local img = Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Size = UDim2.new(0, IMAGE_SIZE, 0, IMAGE_SIZE)
			img.AnchorPoint = Vector2.new(0.5,0.5)
			img.ScaleType = Enum.ScaleType.Fit
			img.Parent = screenGui

			local raw = getItemImageId(item.Name)

			if item.Name == "Money" and typeof(raw) == "Instance" then
				img:Destroy()
				local vp = Instance.new("ViewportFrame")
				vp.BackgroundTransparency = 1
				vp.Size = UDim2.new(0, IMAGE_SIZE, 0, IMAGE_SIZE)
				vp.AnchorPoint = Vector2.new(0.5,0.5)
				vp.Parent = screenGui

				local clone = raw:Clone()
				clone.Parent = vp

				local cam = Instance.new("Camera")
				cam.Parent = vp
				vp.CurrentCamera = cam

				local cf, size = clone:GetBoundingBox()
				cam.CFrame = cf * CFrame.new(0,0,size.Z*1.5)
				cam.Focus = cf

				img = vp
			else
				local id = formatImageId(raw)
				if id then img.Image = id end
			end

			d.imageFrame = img

			-- ตั้งค่าฟอนต์
			for _, t in ipairs({
				d.name, d.nameShadow, d.nameShadow2,
				d.dist, d.distShadow
			}) do
				t.Center = true
				t.Font = 2
				t.Outline = false
			end

			-- ชื่อ (ขาว + เงาฟ้า 2 ชั้น)
			d.name.Size = 16
			d.name.Color = Color3.new(1,1,1)

			d.nameShadow.Size = 16
			d.nameShadow.Color = Color3.fromRGB(120,200,255)
			d.nameShadow.Transparency = 0.4

			d.nameShadow2.Size = 16
			d.nameShadow2.Color = Color3.fromRGB(60,150,255)
			d.nameShadow2.Transparency = 0.6

			-- จำนวน
			d.dist.Size = 14
			d.dist.Color = Color3.new(1,1,1)

			d.distShadow.Size = 14
			d.distShadow.Color = Color3.new(0,0,0)
			d.distShadow.Transparency = 0.5

			item_drawings[item] = d
		end

		local pos, onScreen = CurrentCamera:WorldToViewportPoint(item.PickUpZone.Position)
		if onScreen then
			local x, y = pos.X, pos.Y
			local half = IMAGE_SIZE / 2

			d.shadowFrame.Position = UDim2.fromOffset(x+3,y+3)
			d.imageFrame.Position = UDim2.fromOffset(x,y)

			local nameY = y - half - 25

			-- เงาฟ้าเข้ม (หลังสุด)
			d.nameShadow2.Text = item.Name
			d.nameShadow2.Position = Vector2.new(x+3, nameY+3)
			d.nameShadow2.Visible = true

			-- เงาฟ้าอ่อน
			d.nameShadow.Text = item.Name
			d.nameShadow.Position = Vector2.new(x+1.5, nameY+1.5)
			d.nameShadow.Visible = true

			-- ตัวหลัก
			d.name.Text = item.Name
			d.name.Position = Vector2.new(x, nameY)
			d.name.Visible = true

			local amountGui = item:FindFirstChild("AmountBillboardGui")
			local txt = amountGui and amountGui:FindFirstChild("TextLabel")
			local amount = txt and txt.Text or "?"

			local distY = y + half + 10

			d.distShadow.Text = "[ "..amount.." ]"
			d.distShadow.Position = Vector2.new(x+2, distY+2)
			d.distShadow.Visible = true

			d.dist.Text = "[ "..amount.." ]"
			d.dist.Position = Vector2.new(x, distY)
			d.dist.Visible = true
		end
	end
end)

local MiscTab =
    Window:Tab(
    {
        Title = "Misc",
        Icon = "circle-ellipsis"
    }
)

local EnabledSkip = false

-- ปุ่ม Toggle
MiscTab:Toggle({
    Title = "Skip Animation",
    Flag = "skip_anim",
    Value = false,
    Callback = function(Value)
        EnabledSkip = Value

        -- ถ้าเปิดใช้งานทันที ให้ skip ทุก crate ที่กำลัง spin หรือจะ spin ใหม่
        if EnabledSkip then
            task.spawn(function()
                while EnabledSkip do
                    -- ตรวจสอบทุก crate ที่มีอยู่
                    for _, crate in pairs(CrateController.class.objects) do
                        -- ตั้งให้ skip 100%
                        crate.states.open.set(true)       -- บังคับ crate เปิด
                        CrateController.skipping.set(true) -- บังคับ skip
                    end
                    task.wait(0.05) -- เช็คต่อเนื่อง
                end
            end)
        end
    end
})

-- =========================
-- Boost FPS (ภาพกาก)
-- =========================

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local function Bootsfps()
	-- ลบท้องฟ้า + เอฟเฟกต์
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Sky")
		or v:IsA("Atmosphere")
		or v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect") then
			v:Destroy()
		end
	end

	-- ปิดเงา / แสง
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0
	Lighting.FogEnd = 9e9
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	-- Terrain กาก
	if Terrain then
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
	end

	-- ทำทั้งแมพเป็นสีเทา / plastic
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			v.CastShadow = false
			v.Color = Color3.fromRGB(120,120,120)

		elseif v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = 1

		elseif v:IsA("ParticleEmitter")
		or v:IsA("Trail")
		or v:IsA("Beam") then
			v.Enabled = false
		end
	end
end

-- =========================
-- Button ใน Tab Misc
-- =========================

MiscTab:Button({
	Title = "Bootsfps",
	Icon = "zap",
	Callback = function()
		Bootsfps()
	end
})

-- =========================
-- RTX ON ULTRA (ภาพโคตรสวย)
-- =========================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local function RTX_ON()
	-- ล้างของเก่า
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere")
		or v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect")
		or v:IsA("Sky") then
			v:Destroy()
		end
	end

	-- ===== Sky =====
	local Sky = Instance.new("Sky")
	Sky.SkyboxBk = "rbxassetid://159454299"
	Sky.SkyboxDn = "rbxassetid://159454296"
	Sky.SkyboxFt = "rbxassetid://159454293"
	Sky.SkyboxLf = "rbxassetid://159454286"
	Sky.SkyboxRt = "rbxassetid://159454300"
	Sky.SkyboxUp = "rbxassetid://159454288"
	Sky.SunAngularSize = 21
	Sky.Parent = Lighting

	-- ===== Lighting Core =====
	Lighting.Technology = Enum.Technology.Future
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 1
	Lighting.Brightness = 3
	Lighting.ExposureCompensation = 0.25
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.ClockTime = 14

	-- ===== Atmosphere =====
	local Atmosphere = Instance.new("Atmosphere")
	Atmosphere.Density = 0.35
	Atmosphere.Offset = 0.25
	Atmosphere.Color = Color3.fromRGB(190, 210, 255)
	Atmosphere.Decay = Color3.fromRGB(120, 150, 200)
	Atmosphere.Glare = 0.35
	Atmosphere.Haze = 1.2
	Atmosphere.Parent = Lighting

	-- ===== Bloom =====
	local Bloom = Instance.new("BloomEffect")
	Bloom.Intensity = 1.2
	Bloom.Size = 56
	Bloom.Threshold = 0.85
	Bloom.Parent = Lighting

	-- ===== Sun Rays =====
	local SunRays = Instance.new("SunRaysEffect")
	SunRays.Intensity = 0.25
	SunRays.Spread = 0.85
	SunRays.Parent = Lighting

	-- ===== Color Correction =====
	local CC = Instance.new("ColorCorrectionEffect")
	CC.Brightness = 0.05
	CC.Contrast = 0.25
	CC.Saturation = 0.35
	CC.TintColor = Color3.fromRGB(255, 245, 235)
	CC.Parent = Lighting

	-- ===== Depth Of Field =====
	local DOF = Instance.new("DepthOfFieldEffect")
	DOF.FarIntensity = 0.25
	DOF.NearIntensity = 0.05
	DOF.FocusDistance = 60
	DOF.InFocusRadius = 40
	DOF.Parent = Lighting

	-- ===== Terrain น้ำใส =====
	if Terrain then
		Terrain.WaterWaveSize = 1
		Terrain.WaterWaveSpeed = 15
		Terrain.WaterReflectance = 1
		Terrain.WaterTransparency = 0.05
	end

	-- ===== วัสดุเงาสวย =====
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = true
			if v.Material == Enum.Material.Plastic then
				v.Material = Enum.Material.SmoothPlastic
			end
		end
	end
end

-- =========================
-- Button (Tab Misc)
-- =========================

MiscTab:Button({
	Title = "RTX ON",
	Icon = "sparkles",
	Callback = function()
		RTX_ON()
	end
})

