local Players = game:get_service("Players")
local Workspace = game:get_service("Workspace")

local Fusioning = true

local Main = gui.create("Main | fusion.lua", false)
Main:set_size(500, 350)
Main:set_pos(50, 50)

Main:add_label("QB Aim Assist") -- Inconsitent
local AimOn = Main:add_checkbox("Enable", false)
local AimKey = Main:add_keybind("Aim Key", 0x54)
local AimPoint = Main:add_combo("Aim Point", {"Mouse", "Center"}, 0)
local VisualOnly = Main:add_checkbox("Visual Assist Only", false)
local Interceptable = Main:add_checkbox("Interceptable Check", true)

local Fov = Main:add_slider("Field Of View", 50, 670, 350)
local Smoothness = Main:add_slider("Smoothness", 1, 50, 15)
local AutoSmoothness = Main:add_checkbox("Auto Smoothness", true)
local AutoPower = Main:add_checkbox("Auto Power", true)
local PowerFactor = Main:add_slider("Auto Power Factor", 0.1, 10.0, 1.0)
local LeadFactor = Main:add_slider("Lead Factor", -12.0, 20.0, 1.0)
local AutoLead = Main:add_checkbox("Auto Lead", false)
local Vertical = Main:add_slider("Y Offset", -10, 10, 0)
local Horizontal = Main:add_slider("X Offset", -10, 10, 0)

Main:add_label("Automation")
local AutoCatch = Main:add_checkbox("Auto Catch", false)
local CatchMode = Main:add_combo("Catch Mode", {"Move Mouse", "On Mouse"}, 0)
local CatchKey = Main:add_combo("Catch Key", {"Mouse1", "C"}, 0)
local CatchRange = Main:add_slider("Catch Range", 0, 30, 15)

local AutoSwat = Main:add_checkbox("Auto Swat", false)
local SwatRange = Main:add_slider("Swat Range", 0, 30, 15)

local AutoRush = Main:add_checkbox("Auto Rush", false)
local ToggleRush = Main:add_checkbox("Toggleable Rush", false)
local RushKey = Main:add_keybind("Rush Key", 0x59)
local RushRange = Main:add_slider("Rush Range", 10, 150, 60)
local PredictionDelay = Main:add_slider("Prediction Delay", 0.0, 3.0, 0.2) --↓ nova hub sliders, ai bullshit?
local ForwardOffset = Main:add_slider("Forward Offset", 0, 30, 5)
local SideOffset = Main:add_slider("Side Offset", -15, 15, 0)

local Visuals = gui.create("Visuals | fusion.lua", false)
Visuals:set_size(500, 350)
Visuals:set_pos(540, 50)

Visuals:add_label("Main Visuals")
local ShowFov = Visuals:add_checkbox("Show FOV", false)
local FovColor = Visuals:add_color("FOV Color", color(1, 0.6, 0.6, 0.8))
local PredictedTraj = Visuals:add_checkbox("Ball Predicted Trajectory", true)
local PredictedTrajColor = Visuals:add_color("Predicted Color", color(1, 0.6, 0.6, 1))

local CatchHelper = Visuals:add_checkbox("Catch Helper", false)
local HelperRange = Visuals:add_slider("Helper Range", 0, 30, 15)
local HelperTime = Visuals:add_slider("Helper Duration", 0.0, 3.0, 1.0)

Visuals:add_label("World Visuals")
local BallCircle = Visuals:add_checkbox("Ball Circle", true)
local CircleColor = Visuals:add_color("Circle Color", color(1, 0.45, 0.45, 1))
local CircleSize = Visuals:add_slider("Circle Size", 10, 50, 12)
local BallTraj = Visuals:add_checkbox("Ball Trajectory", true)
local BallTrajColor = Visuals:add_color("Trajectory Color", color(1, 0.45, 0.45, 1))

local LandingCircle = Visuals:add_checkbox("Landing Circle", true)
local LandingColor = Visuals:add_color("Landing Color", color(0.55, 1, 0.55, 1))

local BallHolder = Visuals:add_checkbox("Ball Holder ESP", true)
local HolderColor = Visuals:add_color("Holder Color", color(1, 0.6, 0.6, 0.5))
local ShowDistance = Visuals:add_checkbox("Show Distance", true)

local Exploits = gui.create("Player | fusion.lua", false)
Exploits:set_size(500, 350)
Exploits:set_pos(50, 380)

Exploits:add_label("Exploits")
local CatchResize = Exploits:add_checkbox("Catch Resize", false)
local CatchSize = Exploits:add_slider("Catch Size", 0, 20, 10)
local ArmResize = Exploits:add_checkbox("Arm Resize", false)
local ArmSize = Exploits:add_slider("Arm Size", 0, 15, 10)
local BallResize = Exploits:add_checkbox("Ball Resize", false)
local BallSize = Exploits:add_slider("Ball Size", 0, 20, 10)

local BlockExtender = Exploits:add_checkbox("Block Extender", false)
local BlockSize = Exploits:add_slider("Block Extend", 0, 10, 5)
local BigHead = Exploits:add_checkbox("Big Head", false)
local HeadSize = Exploits:add_slider("Big Head Size", 1.0, 5.0, 3.0)

Exploits:add_label("Movement")
local AntiJam = Exploits:add_checkbox("Anti Jam", false)
local NoJumpCD = Exploits:add_checkbox("No Jump Cooldown", false)
local InfiniteJump = Exploits:add_checkbox("Infinite Jump", false)
local JumpHeight = Exploits:add_slider("Jump Height", 10, 85, 50)

local Misc = gui.create("Misc | fusion.lua", false)
Misc:set_size(150, 240)
Misc:set_pos(540, 380)

local Config = "prone/fusion.json"
-- Color and Keybinds not handled by getvalue/setvalue rn | TBD-2
local Elements = {
    {"Main | fusion.lua", "Enable", false},
    {"Main | fusion.lua", "Aim Point", 0},
    {"Main | fusion.lua", "Visual Assist Only", false},
    {"Main | fusion.lua", "Interceptable Check", true},
    {"Main | fusion.lua", "Field Of View", 350},
    {"Main | fusion.lua", "Smoothness", 15},
    {"Main | fusion.lua", "Auto Smoothness", true},
    {"Main | fusion.lua", "Auto Power", false},
    {"Main | fusion.lua", "Auto Power Factor", 1.0},
    {"Main | fusion.lua", "Lead Factor", 1.0},
    {"Main | fusion.lua", "Auto Lead", false},
    {"Main | fusion.lua", "Y Offset", 0},
    {"Main | fusion.lua", "X Offset", 0},
    {"Main | fusion.lua", "Auto Catch", false},
    {"Main | fusion.lua", "Catch Mode", 0},
    {"Main | fusion.lua", "Catch Key", 0},
    {"Main | fusion.lua", "Catch Range", 15},
    {"Main | fusion.lua", "Auto Swat", false},
    {"Main | fusion.lua", "Swat Range", 15},
    {"Main | fusion.lua", "Auto Rush", false},
    {"Main | fusion.lua", "Toggleable Rush", false},
    {"Main | fusion.lua", "Rush Range", 60},
    {"Main | fusion.lua", "Prediction Delay", 0.2},
    {"Main | fusion.lua", "Forward Offset", 5},
    {"Main | fusion.lua", "Side Offset", 0},
    {"Visuals | fusion.lua", "Show FOV", false},
    {"Visuals | fusion.lua", "Ball Predicted Trajectory", true},
    {"Visuals | fusion.lua", "Catch Helper", false},
    {"Visuals | fusion.lua", "Helper Range", 15},
    {"Visuals | fusion.lua", "Helper Duration", 1.0},
    {"Visuals | fusion.lua", "Ball Circle", true},
    {"Visuals | fusion.lua", "Circle Size", 12},
    {"Visuals | fusion.lua", "Ball Trajectory", true},
    {"Visuals | fusion.lua", "Landing Circle", true},
    {"Visuals | fusion.lua", "Ball Holder ESP", true},
    {"Visuals | fusion.lua", "Show Distance", true},
    {"Player | fusion.lua", "Catch Resize", false},
    {"Player | fusion.lua", "Catch Size", 10},
    {"Player | fusion.lua", "Arm Resize", false},
    {"Player | fusion.lua", "Arm Size", 10},
    {"Player | fusion.lua", "Ball Resize", false},
    {"Player | fusion.lua", "Ball Size", 10},
    {"Player | fusion.lua", "Block Extender", false},
    {"Player | fusion.lua", "Block Extend", 5},
    {"Player | fusion.lua", "Big Head", false},
    {"Player | fusion.lua", "Big Head Size", 3.0},
    {"Player | fusion.lua", "Anti Jam", false},
    {"Player | fusion.lua", "No Jump Cooldown", false},
    {"Player | fusion.lua", "Infinite Jump", false},
    {"Player | fusion.lua", "Jump Height", 50},
}

local LocalPlayer = nil
local PrevIdentity = nil
local Locked = nil
local BlockCache = nil

local Active = 0
local Clicks = 0
local Helper = 0
local Power = 0
local PowerTime = 0
local SwatTime = 0

local Rush = false
local WasQB = false
local AntiJamOn = false
local Jumping = false

local HeadCache = {}
local ArmCache = {}
local CatchCache = {}
local BallCache = {}
local BallPrev = {}

local Gravity = 196

local function Init()
    Players = game:get_service("Players")
    Workspace = game:get_service("Workspace")
    LocalPlayer = Players and Players:isvalid() and Players.local_player or nil
    PrevIdentity = (LocalPlayer and LocalPlayer:isvalid()) and LocalPlayer.identity or nil
    Active = get_tickcount() + 250
    Locked, WasQB, Power, PowerTime = nil, false, 0, 0
    if Rush then
        input.simulate_press_up(0x57)
        input.simulate_press_up(0x53)
        input.simulate_press_up(0x44)
        input.simulate_press_up(0x41)
        Rush = false
    end
    for Identity in pairs(HeadCache) do HeadCache[Identity] = nil end
        for Identity in pairs(BallCache) do BallCache[Identity] = nil end
    for Name in pairs(ArmCache) do ArmCache[Name] = nil end
    for Name in pairs(CatchCache) do CatchCache[Name] = nil end
    BlockCache, AntiJamOn = nil, false
end

local function Scan(Pos)
    local Out = {}
    local LocalTeam = LocalPlayer:get_team()
    local CheckLocal = LocalTeam and LocalTeam:isvalid() and LocalTeam.identity or nil

    for _, Player in ipairs(Players:get_children()) do
        if Player:isvalid() and Player.identity ~= LocalPlayer.identity then
            local Character = Player.character
            if Character and Character:isvalid() then
                local HRP = Character:find_first_child("HumanoidRootPart")
                local Head = Character:find_first_child("Head")
                if HRP and HRP:isvalid() then
                    local Screen = world_to_screen(vector3(HRP.position.x, HRP.position.y, HRP.position.z))
                    if Screen and in_screen(Screen) then
                        local Ball = Character:find_first_child("Football")
                        local PlayerTeam = Player:get_team()
                        local CheckPlayer = PlayerTeam and PlayerTeam:isvalid() and PlayerTeam.identity or nil
                        Out[#Out + 1] = {
                            Name = Player.name,
                            HrpPos = HRP.position,
                            HeadPos = (Head and Head:isvalid()) and Head.position or HRP.position,
                            Velocity = HRP.linear_velocity,
                            Screen = Screen,
                            WorldDist = math.sqrt((Pos.x - HRP.position.x) ^ 2 + (Pos.y - HRP.position.y) ^ 2 + (Pos.z - HRP.position.z) ^ 2),
                            HasBall = Ball and Ball:isvalid() or false,
                            Teammate = (not CheckLocal) or (CheckPlayer == CheckLocal),
                        }
                    end
                end
            end
        end
    end

    local NPC = Workspace:find_first_child("npcwr")
    if NPC and NPC:isvalid() then
        for _, Name in ipairs({"a", "b"}) do
            local Folder = NPC:find_first_child(Name)
            if Folder and Folder:isvalid() then
                for _, Bot in ipairs(Folder:get_children()) do
                    local Uniform = Bot:isvalid() and Bot:find_first_child("Uniform")
                    local Shirt = Uniform and Uniform:isvalid() and Uniform:find_first_child("Shirt")
                    local FrontNum = Shirt and Shirt:isvalid() and Shirt:find_first_child("FrontNum")
                    local Label = FrontNum and FrontNum:isvalid() and FrontNum:find_first_child("TextLabel")
                    if Label and Label:isvalid() then
                        local Number = Label:get_label_text()
                        if Number == "1" or Number == "3" then
                            local HRP = Bot:find_first_child("HumanoidRootPart")
                            local Head = Bot:find_first_child("Head")
                            if HRP and HRP:isvalid() then
                                local Screen = world_to_screen(vector3(HRP.position.x, HRP.position.y, HRP.position.z))
                                if Screen and in_screen(Screen) then
                                    local Ball = Bot:find_first_child("Football")
                                    Out[#Out + 1] = {
                                        Name = Bot.name,
                                        HrpPos = HRP.position,
                                        HeadPos = (Head and Head:isvalid()) and Head.position or HRP.position,
                                        Velocity = HRP.linear_velocity,
                                        Screen = Screen,
                                        WorldDist = math.sqrt((Pos.x - HRP.position.x) ^ 2 + (Pos.y - HRP.position.y) ^ 2 + (Pos.z - HRP.position.z) ^ 2),
                                        HasBall = Ball and Ball:isvalid() or false,
                                        Teammate = true,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return Out
end

local function SaveConfig()
    local Data = {}
    for _, Element in ipairs(Elements) do
        local Value = ui.getvalue(Element[1], Element[2])
        if Value ~= nil then
            if not Data[Element[1]] then Data[Element[1]] = {} end
            Data[Element[1]][Element[2]] = Value
        end
    end
    file.write(Config, table_to_JSON(Data))
    log.notification("Config Saved", "info")
end

local function LoadConfig()
    if not file.exists(Config) then return end
    local Data = JSON_to_table(file.read(Config))
    if not Data then return end
    for _, Element in ipairs(Elements) do
        local Window = Data[Element[1]]
        local Value = Window and Window[Element[2]]
        if Value ~= nil then ui.setvalue(Element[1], Element[2], Value) end
    end
    log.notification("Config Loaded", "success")
end

local function ResetConfig()
    for _, Element in ipairs(Elements) do
        ui.setvalue(Element[1], Element[2], Element[3])
    end
    log.notification("Config Reset to Defaults", "warning")
end

Misc:add_button("Save Config", SaveConfig)
Misc:add_button("Reset Config", ResetConfig)
Misc:add_button("Reload", function()
    Init()
    log.notification("soccer fusioning", "success")
end)
Misc:add_button("Unload", function()
    Fusioning = false
    if Rush then
        input.simulate_press_up(0x57)
        input.simulate_press_up(0x53)
        input.simulate_press_up(0x44)
        input.simulate_press_up(0x41)
        Rush = false
    end
    for _, Player in ipairs(Players:get_children()) do
        if Player:isvalid() then
            local Character = Player.character
            if Character and Character:isvalid() then
                for _, Part in ipairs(Character:get_children()) do
                    if Part:isvalid() and Part.class_name == "Part" then Part:set_collision(true) end
                end
            end
        end
    end
    if LocalPlayer and LocalPlayer:isvalid() then
        local Character = LocalPlayer.character
        if Character and Character:isvalid() then
            for Name, Size in pairs(ArmCache) do
                local Arm = Character:find_first_child(Name)
                if Arm and Arm:isvalid() then Arm:set_size(Size) end
            end
            for Name, Size in pairs(CatchCache) do
                local Part = Character:find_first_child(Name)
                if Part and Part:isvalid() then Part:set_size(Size) end
            end
            if BlockCache then
                local Block = Character:find_first_child("BlockPart")
                if Block and Block:isvalid() then Block:set_size(BlockCache) end
            end
        end
    end
    for Identity, Size in pairs(HeadCache) do
        for _, Player in ipairs(Players:get_children()) do
            if Player:isvalid() and Player.identity == Identity then
                local Head = Player.character and Player.character:isvalid() and Player.character:find_first_child("Head")
                if Head and Head:isvalid() then Head:set_size(Size) end
            end
        end
    end
    for _, Child in ipairs(Workspace:get_children()) do
        if Child:isvalid() and Child.name == "Football" and BallCache[Child.identity] then
            Child:set_size(BallCache[Child.identity])
        end
    end
    hook.remove("render", "balling")
    gui.remove("Main | fusion.lua")
    gui.remove("Visuals | fusion.lua")
    gui.remove("Player | fusion.lua")
    gui.remove("Misc | fusion.lua")
end)

spawn(function()
    local PrevReload = 0
    while Fusioning do
        local Time = get_tickcount()

                if Time - PrevReload >= 250 then
            PrevReload = Time
            local Players = game:get_service("Players")
            local Current = Players and Players:isvalid() and Players.local_player or nil
            local CheckCurr = (Current and Current:isvalid()) and Current.identity or nil
            if CheckCurr and CheckCurr ~= PrevIdentity then
                Init()
            elseif not CheckCurr and PrevIdentity then
                PrevIdentity = nil
            end
        end

        local Character = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer.character or nil
        local CheckChar = Character and Character:isvalid()

        if CatchResize:get_value() and CheckChar then
            local Size = CatchSize:get_value()
            for _, Name in ipairs({"CatchLeft", "CatchRight"}) do
                local Part = Character:find_first_child(Name)
                if Part and Part:isvalid() then
                    if not CatchCache[Name] then CatchCache[Name] = Part.size end
                    if math.abs(Part.size.x - Size) > 0.1 then Part:set_size(vector3(Size, Size, Size)) end
                end
            end
        elseif next(CatchCache) then
            if CheckChar then
                for Name, Size in pairs(CatchCache) do
                    local Part = Character:find_first_child(Name)
                    if Part and Part:isvalid() then Part:set_size(Size) end
                end
            end
            for Name in pairs(CatchCache) do CatchCache[Name] = nil end
        end

        if ArmResize:get_value() and CheckChar then
            local Size = ArmSize:get_value()
            for _, Name in ipairs({"Left Arm", "Right Arm"}) do
                local Arm = Character:find_first_child(Name)
                if Arm and Arm:isvalid() then
                    if not ArmCache[Name] then ArmCache[Name] = Arm.size end
                    if math.abs(Arm.size.y - Size) > 0.05 then
                        Arm:set_size(vector3(Arm.size.x, Size, Arm.size.z))
                    end
                end
            end
        elseif next(ArmCache) then
            if CheckChar then
                for Name, Size in pairs(ArmCache) do
                    local Arm = Character:find_first_child(Name)
                    if Arm and Arm:isvalid() then Arm:set_size(Size) end
                end
            end
            for Name in pairs(ArmCache) do ArmCache[Name] = nil end
        end

        -- Taken from an old script, Noba Hub and other shit probably use network ownership funcs now TBD-3
        if BlockExtender:get_value() and CheckChar then
            local Size = BlockSize:get_value()
            local Block = Character:find_first_child("BlockPart")
            if Block and Block:isvalid() then
                if not BlockCache then BlockCache = Block.size end
                if math.abs(Block.size.x - Size) > 0.05 then Block:set_size(vector3(Size, Size, Size)) end
            end
        elseif BlockCache then
            if CheckChar then
                local Block = Character:find_first_child("BlockPart")
                if Block and Block:isvalid() then Block:set_size(BlockCache) end
            end
            BlockCache = nil
        end

        if BallResize:get_value() then
            local Size = BallSize:get_value()
            for _, Child in ipairs(Workspace:get_children()) do
                if Child:isvalid() and Child.name == "Football" then
                    if not BallCache[Child.identity] then BallCache[Child.identity] = Child.size end
                    if math.abs(Child.size.x - Size) > 0.05 then Child:set_size(vector3(Size, Size, Size)) end
                end
            end
        elseif next(BallCache) then
            for _, Child in ipairs(Workspace:get_children()) do
                if Child:isvalid() and Child.name == "Football" and BallCache[Child.identity] then
                    Child:set_size(BallCache[Child.identity])
                end
            end
            for Identity in pairs(BallCache) do BallCache[Identity] = nil end
        end

        if BigHead:get_value() then
            local Size = HeadSize:get_value()
            for _, Player in ipairs(Players:get_children()) do
                if Player:isvalid() and LocalPlayer and Player.identity ~= LocalPlayer.identity then
                    local Character = Player.character
                    local Head = Character and Character:isvalid() and Character:find_first_child("Head")
                    if Head and Head:isvalid() then
                        if not HeadCache[Player.identity] then HeadCache[Player.identity] = Head.size end
                        Head:set_size(vector3(Size, Size, Size))
                    end
                end
            end
        elseif next(HeadCache) then
            for Identity, Size in pairs(HeadCache) do
                for _, Player in ipairs(Players:get_children()) do
                    if Player:isvalid() and Player.identity == Identity then
                        local Head = Player.character and Player.character:isvalid() and Player.character:find_first_child("Head")
                        if Head and Head:isvalid() then Head:set_size(Size) end
                    end
                end
            end
            for Identity in pairs(HeadCache) do HeadCache[Identity] = nil end
        end

        if AntiJam:get_value() then
            AntiJamOn = true
            for _, Player in ipairs(Players:get_children()) do
                if Player:isvalid() and LocalPlayer and Player.identity ~= LocalPlayer.identity then
                    local Character = Player.character
                    if Character and Character:isvalid() then
                        for _, Part in ipairs(Character:get_children()) do
                            if Part:isvalid() and Part.class_name == "Part" and Part.collision then
                                Part:set_collision(false)
                            end
                        end
                    end
                end
            end
        elseif AntiJamOn then
            AntiJamOn = false
            for _, Player in ipairs(Players:get_children()) do
                if Player:isvalid() then
                    local Character = Player.character
                    if Character and Character:isvalid() then
                        for _, Part in ipairs(Character:get_children()) do
                            if Part:isvalid() and Part.class_name == "Part" then Part:set_collision(true) end
                        end
                    end
                end
            end
        end

        local RushHeld = (not ToggleRush:get_value()) or RushKey:get_state()
        if AutoRush:get_value() and RushHeld then
            local LocalTeam = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer:get_team()
            local CheckLocal = LocalTeam and LocalTeam:isvalid() and LocalTeam.identity or nil
            local Enemy
            if CheckLocal then
                for _, Player in ipairs(Players:get_children()) do
                    if Player:isvalid() and Player.identity ~= LocalPlayer.identity then
                        local Character = Player.character
                        local HRP = Character and Character:isvalid() and Character:find_first_child("HumanoidRootPart")
                        local Ball = Character and Character:isvalid() and Character:find_first_child("Football")
                        local Team = Player:get_team()
                        local CheckTeam = Team and Team:isvalid() and Team.identity or nil
                        if HRP and HRP:isvalid() and Ball and Ball:isvalid() and CheckTeam ~= CheckLocal then
                            Enemy = {Pos = HRP.position, Velocity = HRP.linear_velocity}
                            break
                        end
                    end
                end
            end
            if Enemy and LocalPlayer and LocalPlayer:isvalid() then
                local Character = LocalPlayer.character
                local HRP = Character and Character:isvalid() and Character:find_first_child("HumanoidRootPart")
                local Camera = Workspace:find_first_child_class("Camera")
                if HRP and HRP:isvalid() and Camera and Camera:isvalid() then
                    local Pos = HRP.position
                    local Lead = PredictionDelay:get_value()
                    local PredX = Enemy.Pos.x + Enemy.Velocity.x * Lead
                    local PredZ = Enemy.Pos.z + Enemy.Velocity.z * Lead
                    local RushDist = math.sqrt((PredX - Pos.x) ^ 2 + (PredZ - Pos.z) ^ 2)
                    if RushDist <= RushRange:get_value() then
                        local EnemyX, EnemyZ = PredX - Pos.x, PredZ - Pos.z
                        local EnemyL = math.sqrt(EnemyX * EnemyX + EnemyZ * EnemyZ)
                        if EnemyL > 0.1 then
                            local nx, nz = EnemyX / EnemyL, EnemyZ / EnemyL
                            local Forward, Side = ForwardOffset:get_value(), SideOffset:get_value()
                            local TargetX = PredX + nx * Forward + (-nz) * Side
                            local TargetZ = PredZ + nz * Forward + nx * Side
                            local dx, dz = TargetX - Pos.x, TargetZ - Pos.z
                            local DirectionLength = math.sqrt(dx * dx + dz * dz)
                            if DirectionLength > 3 then
                                dx, dz = dx / DirectionLength, dz / DirectionLength
                                local Look = Camera.camera_lookvector
                                local CameraX, CameraZ = Look.x, Look.z
                                local CameraL = math.sqrt(CameraX * CameraX + CameraZ * CameraZ)
                                if CameraL > 0.01 then CameraX, CameraZ = CameraX / CameraL, CameraZ / CameraL end
                                local RightX, RightZ = -CameraZ, CameraX
                                local ForwardDot = dx * CameraX + dz * CameraZ
                                local RightDot = dx * RightX + dz * RightZ
                                if ForwardDot > 0.2 then input.simulate_press_down(0x57) else input.simulate_press_up(0x57) end
                                if ForwardDot < -0.2 then input.simulate_press_down(0x53) else input.simulate_press_up(0x53) end
                                if RightDot > 0.2 then input.simulate_press_down(0x44) else input.simulate_press_up(0x44) end
                                if RightDot < -0.2 then input.simulate_press_down(0x41) else input.simulate_press_up(0x41) end
                                Rush = true
                            elseif Rush then
                                input.simulate_press_up(0x57)
                                input.simulate_press_up(0x53)
                                input.simulate_press_up(0x44)
                                input.simulate_press_up(0x41)
                                Rush = false
                            end
                        end
                    elseif Rush then
                        input.simulate_press_up(0x57)
                        input.simulate_press_up(0x53)
                        input.simulate_press_up(0x44)
                        input.simulate_press_up(0x41)
                        Rush = false
                    end
                end
            elseif Rush then
                input.simulate_press_up(0x57)
                input.simulate_press_up(0x53)
                input.simulate_press_up(0x44)
                input.simulate_press_up(0x41)
                Rush = false
            end
        elseif Rush then
            input.simulate_press_up(0x57)
            input.simulate_press_up(0x53)
            input.simulate_press_up(0x44)
            input.simulate_press_up(0x41)
            Rush = false
        end

        wait(50)
    end
end)

spawn(function()
    while Fusioning do
        if (NoJumpCD:get_value() or InfiniteJump:get_value()) and input.key_down(0x20)
            and LocalPlayer and LocalPlayer:isvalid() then
            local Character = LocalPlayer.character
            local CheckChar = Character and Character:isvalid()
            local HRP = CheckChar and Character:find_first_child("HumanoidRootPart")
            local Humanoid = CheckChar and Character:find_first_child_class("Humanoid")
            if HRP and HRP:isvalid() and Humanoid and Humanoid:isvalid() then
                local Velocity = HRP.velocity
                local Height = JumpHeight:get_value()
                if InfiniteJump:get_value() then
                    if not Jumping then
                        HRP:set_velocity(vector3(Velocity.x, Height, Velocity.z))
                        Jumping = true
                    end
                else
                    local State = Humanoid:get_state()
                    local Grounded = State == humanoid_state.RUNNING or State == humanoid_state.LANDED
                    if Grounded and not Jumping then
                        HRP:set_velocity(vector3(Velocity.x, Height, Velocity.z))
                        Jumping = true
                    elseif not Grounded then
                        Jumping = true
                    else
                        Jumping = false
                    end
                end
            end
        else
            Jumping = false
        end
        wait(8)
    end
end)

local cx = get_screen_size().x / 2
local cy = get_screen_size().y / 2

hook.add("render", "balling", function()
    if not (LocalPlayer and LocalPlayer:isvalid()) then return end
    local Time = get_tickcount()
    if Time < Active then return end

    local Character = LocalPlayer.character
    if not (Character and Character:isvalid()) then return end
    local HRP = Character:find_first_child("HumanoidRootPart")
    if not (HRP and HRP:isvalid()) then return end
    local Pos = HRP.position

    local Football = Character:find_first_child("Football")
    local Throwable = false
    local PlayerGui = LocalPlayer:find_first_child("PlayerGui")
    if PlayerGui and PlayerGui:isvalid() then
        local BallGui = PlayerGui:find_first_child("BallGui")
        Throwable = BallGui and BallGui:isvalid() or false
    end
    local IsQB = (Football and Football:isvalid() and Throwable) or false
    if IsQB and not WasQB then Power, PowerTime = 0, 0 end
    WasQB = IsQB

    local Balls = {}
    local CachedBalls = {}
    for _, Ball in ipairs(Workspace:get_children()) do
        if Ball:isvalid() and Ball.name == "Football" then
            local ID = Ball.identity
            local Pos = Ball.position
            local Velocity = Ball.linear_velocity
            local Cached = BallPrev[ID]
            if Cached then
                local Delta = (Time - Cached.SampleTime) / 1000
                if Delta >= 0.12 and Delta <= 0.5 then
                    local nx = (Pos.x - Cached.x) / Delta
                    local ny = (Pos.y - Cached.y) / Delta
                    local nz = (Pos.z - Cached.z) / Delta
                    local bx = Cached.vx * 0.82 + nx * 0.18
                    local by = Cached.vy * 0.82 + ny * 0.18
                    local bz = Cached.vz * 0.82 + nz * 0.18
                    Velocity = vector3(bx, by, bz)
                    CachedBalls[ID] = {x = Pos.x, y = Pos.y, z = Pos.z, vx = bx, vy = by, vz = bz, SampleTime = Time}
                else
                    Velocity = vector3(Cached.vx, Cached.vy, Cached.vz)
                    CachedBalls[ID] = Cached
                end
            else
                CachedBalls[ID] = {x = Pos.x, y = Pos.y, z = Pos.z, vx = Velocity.x, vy = Velocity.y, vz = Velocity.z, SampleTime = Time}
            end
            local Speed = math.sqrt(Velocity.x * Velocity.x + Velocity.y * Velocity.y + Velocity.z * Velocity.z)
            Balls[#Balls + 1] = {Pos = Pos, Velocity = Velocity, OnAir = Speed > 10}
        end
    end
    for ID in pairs(BallPrev) do
        if not CachedBalls[ID] then BallPrev[ID] = nil end
    end
    for ID, Data in pairs(CachedBalls) do BallPrev[ID] = Data end

    local Targets = (BallHolder:get_value() or AimOn:get_value()) and Scan(Pos) or {}
    local Pulse = (math.sin(Time / 300) + 1) / 2

    if BallCircle:get_value() then
        local BallClr = CircleColor:get_color()
        local BallTrajClr = BallTrajColor:get_color()
        local LandingClr = LandingColor:get_color()
        local CircleScale = CircleSize:get_value()
        for _, Ball in ipairs(Balls) do
            local Screen = world_to_screen(vector3(Ball.Pos.x, Ball.Pos.y, Ball.Pos.z))
            if Screen and in_screen(Screen) then
                local BallDist = math.sqrt((Pos.x - Ball.Pos.x) ^ 2 + (Pos.y - Ball.Pos.y) ^ 2 + (Pos.z - Ball.Pos.z) ^ 2)
                local Radius = math.max(CircleScale * 0.35, math.min(CircleScale, CircleScale * (60 / math.max(BallDist, 1))))
                render.add_circle(Screen, Radius + 2, color(1, 1, 1, 0.35))
                render.add_circle(Screen, Radius, color(BallClr.r, BallClr.g, BallClr.b, BallClr.a))
                if ShowDistance:get_value() then
                    local DistText = math.floor(BallDist) .. "m"
                    render.add_text(vector2(Screen.x - render.get_text_size(DistText).x / 2, Screen.y + Radius + 4),
                        DistText, color(BallClr.r, BallClr.g, BallClr.b, BallClr.a), 13, true)
                end
            end
            if Ball.OnAir and BallTraj:get_value() then
                local Points = {}
                for Time = 0, 3.0, 0.03 do
                    local Height = Ball.Pos.y + Ball.Velocity.y * Time - 0.5 * Gravity * Time * Time
                    if Height <= 3 then break end
                    local Point = world_to_screen(vector3(Ball.Pos.x + Ball.Velocity.x * Time, Height, Ball.Pos.z + Ball.Velocity.z * Time))
                    if Point then Points[#Points + 1] = Point end
                end
                if #Points > 1 then
                    render.add_polyline(Points, color(1, 1, 1, 0.35), 4)
                    render.add_polyline(Points, color(BallTrajClr.r, BallTrajClr.g, BallTrajClr.b, BallTrajClr.a), 2)
                end
            end
            if Ball.OnAir and LandingCircle:get_value() then

                local Landing
                for Step = 1, 100 do
                    local Time = Step * 0.05
                    if Ball.Pos.y + Ball.Velocity.y * Time - 0.5 * Gravity * Time * Time <= 3 then
                        Landing = {x = Ball.Pos.x + Ball.Velocity.x * Time, y = 3, z = Ball.Pos.z + Ball.Velocity.z * Time, Time = Time}
                        break
                    end
                end
                if Landing then
                    local Screen = world_to_screen(vector3(Landing.x, Landing.y, Landing.z))
                    if Screen then
                        local LandDist = math.sqrt((Pos.x - Landing.x) ^ 2 + (Pos.y - Landing.y) ^ 2 + (Pos.z - Landing.z) ^ 2)
                        local Radius = math.max(7, math.min(20, 20 * (60 / math.max(LandDist, 1))))
                        render.add_circle(Screen, Radius + 2, color(1, 1, 1, 0.35))
                        render.add_circle(Screen, Radius, color(LandingClr.r, LandingClr.g, LandingClr.b, LandingClr.a))
                    end
                end
            end
        end
    end

    if BallHolder:get_value() then
        local HolderClr = HolderColor:get_color()
        for _, Target in ipairs(Targets) do
            if Target.HasBall and Target.Screen then
                local Radius = math.max(8.75, math.min(25, 25 * (60 / math.max(Target.WorldDist, 1))))
                render.add_circle(Target.Screen, Radius + 2, color(1, 1, 1, 0.35))
                render.add_circle_filled(Target.Screen, Radius, color(HolderClr.r, HolderClr.g, HolderClr.b, HolderClr.a * 0.5))
                render.add_circle(Target.Screen, Radius, color(HolderClr.r, HolderClr.g, HolderClr.b, HolderClr.a))
                if ShowDistance:get_value() then
                    local Text = math.floor(Target.WorldDist) .. "m"
                    render.add_text(vector2(Target.Screen.x - render.get_text_size(Text).x / 2, Target.Screen.y + Radius + 4),
                        Text, color(HolderClr.r, HolderClr.g, HolderClr.b, HolderClr.a), 13, true)
                end
            end
        end
    end

    if CatchHelper:get_value() then
        local Range = HelperRange:get_value()
        for _, Ball in ipairs(Balls) do
            if Ball.OnAir and math.sqrt((Pos.x - Ball.Pos.x) ^ 2 + (Pos.y - Ball.Pos.y) ^ 2 + (Pos.z - Ball.Pos.z) ^ 2) <= Range then
                Helper = Time + HelperTime:get_value() * 1000
                break
            end
        end
        if Time <= Helper then
            local Text = "CATCH THE FUCKING BALL"
            render.add_text(vector2(cx - render.get_text_size(Text).x / 2, cy - 9),
                Text, color(1, 0.15, 0.15, Pulse), 18, true)
        end
    end

    local SwattedBall = nil
    if AutoSwat:get_value() then
        local Range = SwatRange:get_value()
        for _, Ball in ipairs(Balls) do
            if Ball.OnAir then
                local BallDist = math.sqrt((Pos.x - Ball.Pos.x) ^ 2 + (Pos.y - Ball.Pos.y) ^ 2 + (Pos.z - Ball.Pos.z) ^ 2)
                if BallDist <= Range then
                    local Speed = math.sqrt(Ball.Velocity.x * Ball.Velocity.x + Ball.Velocity.y * Ball.Velocity.y + Ball.Velocity.z * Ball.Velocity.z)
                    local Dist = BallDist / math.max(Speed, 1)
                    if Dist <= 0.12 and Time - SwatTime > 250 then
                        input.simulate_press(0x52)
                        SwatTime = Time
                    end
                    SwattedBall = Ball
                    break
                end
            end
        end
    end

    if AutoCatch:get_value() then
        local Range = CatchRange:get_value()
        local Mode = CatchMode:get_value()
        for _, Ball in ipairs(Balls) do
            if Ball.OnAir and Ball ~= SwattedBall and math.sqrt((Pos.x - Ball.Pos.x) ^ 2 + (Pos.y - Ball.Pos.y) ^ 2 + (Pos.z - Ball.Pos.z) ^ 2) <= Range then
                local Screen = world_to_screen(vector3(Ball.Pos.x, Ball.Pos.y, Ball.Pos.z))
                if Screen and in_screen(Screen) and Time / 1000 - Clicks > 0.3 then
                    if Mode == 0 then input.set_mouse_position(Screen) end
                    if CatchKey:get_value() == 0 then
                        input.simulate_mouse_click(MOUSE1)
                    else
                        input.simulate_press(0x43)
                    end
                    Clicks = Time / 1000
                end
                break
            end
        end
    end

    if AimOn:get_value() then
        local Fov = Fov:get_value()
        local FovClr = FovColor:get_color()
        local Mouse = input.get_mouse_position()
        local OriginX = AimPoint:get_value() == 0 and Mouse.x or cx
        local OriginY = AimPoint:get_value() == 0 and Mouse.y or cy
        local KeyHeld = AimKey:get_state()

        if ShowFov:get_value() then
            render.add_circle(vector2(OriginX, OriginY), Fov + 1, color(1, 1, 1, 0.25))
            render.add_circle(vector2(OriginX, OriginY), Fov, color(FovClr.r, FovClr.g, FovClr.b, FovClr.a))
        end

        if IsQB then
            if Locked then
                local Held
                for _, Target in ipairs(Targets) do
                    if Target.Name == Locked then Held = Target break end
                end
                if not Held or not Held.Teammate then
                    Locked = nil
                elseif not KeyHeld and Held.Screen then
                    local dx, dy = Held.Screen.x - OriginX, Held.Screen.y - OriginY
                    if math.sqrt(dx * dx + dy * dy) > Fov then Locked = nil end
                end
            end

            if not KeyHeld then
                local GudDistance = Fov
                local New
                for _, Target in ipairs(Targets) do
                    if Target.Teammate and Target.Screen then
                        local dx, dy = Target.Screen.x - OriginX, Target.Screen.y - OriginY
                        local ScreenDistance = math.sqrt(dx * dx + dy * dy)
                        if ScreenDistance < GudDistance then GudDistance = ScreenDistance New = Target.Name end
                    end
                end
                if New then Locked = New end
            end

            local Gud
            if Locked then
                for _, Target in ipairs(Targets) do
                    if Target.Name == Locked then Gud = Target break end
                end
            end

            local Live
            local BallGui = PlayerGui and PlayerGui:isvalid() and PlayerGui:find_first_child("BallGui")
            local Frame = BallGui and BallGui:isvalid() and BallGui:find_first_child("Frame0")
            local Text = Frame and Frame:isvalid() and Frame:find_first_child("Disp")
            if Text and Text:isvalid() then
                Live = tonumber((string.gsub(Text:get_label_text(), "%D", "")))
            end
            if Live then Power = Live end
            local ThrowSpeed = 60 + Power

            if Gud then
                local Velocity = Gud.Velocity
                local TargetDist = math.sqrt((Pos.x - Gud.HeadPos.x) ^ 2 + (Pos.y - Gud.HeadPos.y) ^ 2 + (Pos.z - Gud.HeadPos.z) ^ 2)
                local TravelTime = TargetDist / math.max(ThrowSpeed, 1)
                local Lead
                -- Probably should be repurposed
                if AutoLead:get_value() then
                    Lead = TravelTime * LeadFactor:get_value()
                else
                    Lead = math.sqrt(Velocity.x * Velocity.x + Velocity.z * Velocity.z) > 2 and LeadFactor:get_value() or 0
                end
                local ArcUp = TargetDist * 0.34
                local AimPos = vector3(
                    Gud.HeadPos.x + Velocity.x * Lead,
                    Gud.HeadPos.y + ArcUp + Vertical:get_value(),
                    Gud.HeadPos.z + Velocity.z * Lead
                )
                local AimScreen = world_to_screen(vector3(AimPos.x, AimPos.y, AimPos.z))
                local TargetScreen = world_to_screen(vector3(Gud.HeadPos.x, Gud.HeadPos.y, Gud.HeadPos.z))

                if AimScreen then
                    if KeyHeld and not VisualOnly:get_value() then
                        local dx = AimScreen.x - Mouse.x + Horizontal:get_value()
                        local dy = AimScreen.y - Mouse.y
                        local Smooth
                        if AutoSmoothness:get_value() then
                            local PixelGap = math.sqrt(dx * dx + dy * dy)
                            Smooth = math.max(2, math.min(20, PixelGap / 25))
                        else
                            Smooth = math.max(1, Smoothness:get_value())
                        end
                        input.set_mouse_position_rel(vector2(dx / Smooth, dy / Smooth))
                    end
                    local MarkerColor = PredictedTrajColor:get_color()
                    if TargetScreen then
                        render.add_line(TargetScreen, AimScreen, color(1, 1, 1, 0.35), 4)
                        render.add_line(TargetScreen, AimScreen, color(MarkerColor.r, MarkerColor.g, MarkerColor.b, MarkerColor.a), 2)
                    end
                    render.add_circle(AimScreen, 9, color(1, 1, 1, 0.35))
                    render.add_circle(AimScreen, 7, color(MarkerColor.r, MarkerColor.g, MarkerColor.b, MarkerColor.a))
                    if Interceptable:get_value() then
                        local Risky = false
                        for _, Other in ipairs(Targets) do
                            if not Other.Teammate and math.sqrt((Other.HrpPos.x - Gud.HeadPos.x) ^ 2 + (Other.HrpPos.y - Gud.HeadPos.y) ^ 2 + (Other.HrpPos.z - Gud.HeadPos.z) ^ 2) <= 15 then Risky = true break end
                        end
                        if Risky then
                            render.add_text(vector2(AimScreen.x + 12, AimScreen.y - 6), "Interceptable",
                                color(MarkerColor.r, MarkerColor.g, MarkerColor.b, MarkerColor.a), 14, true)
                        end
                    end
                end

                if KeyHeld and AutoPower:get_value() and TargetDist > 5 then
                    local Goal = math.min(95, math.max(5, math.floor(TargetDist * PowerFactor:get_value() / 5 + 0.5) * 5))
                    local Current = Live or Power
                    if Time - PowerTime > 70 then
                        if Current < Goal then
                            input.simulate_press(0x52)
                            Power = math.min(95, Current + 5)
                            PowerTime = Time
                        elseif Current > Goal then
                            input.simulate_press(0x46)
                            Power = math.max(0, Current - 5)
                            PowerTime = Time
                        end
                    end
                end
            end

            if PredictedTraj:get_value() then
                local Handle = Football:find_first_child("Handle")
                local Camera = Workspace:find_first_child_class("Camera")
                if Handle and Handle:isvalid() and Camera and Camera:isvalid() then
                    local StartPos = Handle.position
                    local LandX, LandY, LandZ
                    if Gud then
                        local Velocity = Gud.Velocity
                        local TargetDist = math.sqrt((Pos.x - Gud.HeadPos.x) ^ 2 + (Pos.y - Gud.HeadPos.y) ^ 2 + (Pos.z - Gud.HeadPos.z) ^ 2)
                        local Lead
                        if AutoLead:get_value() then
                            Lead = TargetDist / math.max(ThrowSpeed, 1) * LeadFactor:get_value()
                        else
                            Lead = math.sqrt(Velocity.x * Velocity.x + Velocity.z * Velocity.z) > 2 and LeadFactor:get_value() or 0
                        end
                        LandX = Gud.HeadPos.x + Velocity.x * Lead
                        LandY = Gud.HeadPos.y + TargetDist * 0.34 + Vertical:get_value()
                        LandZ = Gud.HeadPos.z + Velocity.z * Lead
                    else
                        local Look = Camera.camera_lookvector
                        LandX = StartPos.x + Look.x * 120
                        LandY = StartPos.y + Look.y * 120
                        LandZ = StartPos.z + Look.z * 120
                    end
                    local FlatDist = math.sqrt((LandX - StartPos.x) ^ 2 + (LandZ - StartPos.z) ^ 2)
                    local TravelTime = math.max(FlatDist / math.max(ThrowSpeed, 1), 0.3)
                    local VelX = (LandX - StartPos.x) / TravelTime
                    local VelZ = (LandZ - StartPos.z) / TravelTime
                    local VelY = (LandY - StartPos.y) / TravelTime + 0.5 * Gravity * TravelTime
                    local TrajectoryClr = PredictedTrajColor:get_color()
                    local Points = {}
                    for Step = 0, 60 do
                        local Time = Step / 60 * TravelTime
                        local Height = StartPos.y + VelY * Time - 0.5 * Gravity * Time * Time
                        if Height < 0 then break end
                        local Point = world_to_screen(vector3(StartPos.x + VelX * Time, Height, StartPos.z + VelZ * Time))
                        if Point then Points[#Points + 1] = Point end
                    end
                    if #Points > 1 then
                        render.add_polyline(Points, color(1, 1, 1, 0.35), 4)
                        render.add_polyline(Points, color(TrajectoryClr.r, TrajectoryClr.g, TrajectoryClr.b, TrajectoryClr.a), 2)
                    end
                end
            end
        else
            Locked = nil
        end
    else
        Locked = nil
    end
end)

Init()
LoadConfig()
