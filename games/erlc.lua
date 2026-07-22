http.get("https://raw.githubusercontent.com/Tolura/Photonation/refs/heads/main/OffsetAPI/offset.lua", function(body, status)
    if status == 200 and body then
        local chunk = load(body)
        if chunk then chunk() end
    end
end)

while not GuiObject_VisibleOffset do wait(50) end

local Menu = gui.create("erlc.lua", false)
Menu:set_pos(230, 250)
Menu:set_size(310, 730)

Menu:add_label("Autosolver")
local ATM = Menu:add_checkbox("ATM Hacking", true)
local Lockpicking = Menu:add_checkbox("Lockpicking", true)
local JewelryRob = Menu:add_checkbox("Jewelry Rob", true)
local SafeRob = Menu:add_checkbox("Safe Rob", true)
local VehicleRob = Menu:add_checkbox("Vehicle Rob", true)
Menu:add_label("Bounty Vehicle")
local FlashNumbers = Menu:add_checkbox("(-) Flashing Numbers", false) -- fuck this
local WireConnect = Menu:add_checkbox("Wire Connect", true)

Menu:add_label("Robbable ESP")
local ATMEsp = Menu:add_checkbox("ATM", true)
local ATMColor = Menu:add_color("ATM Color", color(1, 0.5, 0.5, 1))
local ATMDist = Menu:add_slider("ATM Distance", 50, 800, 800)
local RegisterEsp = Menu:add_checkbox("Cash Register", false)
local RegisterColor = Menu:add_color("Register Color", color(1, 0.5, 0.5, 1))
local RegisterDist = Menu:add_slider("Register Distance", 50, 800, 800)
local BountyEsp = Menu:add_checkbox("Bounty Vehicle", true)
local BountyColor = Menu:add_color("Bounty Vehicle Color", color(1, 0.5, 0.5, 1))

Menu:add_label("Player Flags")
local TeamFlag = Menu:add_checkbox("Team Flag", true)
local TeamFlagPos = Menu:add_combo("Team Position", {"Top", "Bottom", "Right", "Left"}, 0)
local Teamcheck = Menu:add_checkbox("Teamcheck", false)
local DeviceFlag = Menu:add_checkbox("Device Flag", false)
local DeviceFlagPos = Menu:add_combo("Device Position", {"Top", "Bottom", "Right", "Left"}, 2)
local CombatFlag = Menu:add_checkbox("Combat Flag", false)
local CombatFlagPos = Menu:add_combo("Combat Position", {"Top", "Bottom", "Right", "Left"}, 2)
local WantedFlag = Menu:add_checkbox("Wanted Flag", true)
local WantedFlagPos = Menu:add_combo("Wanted Position", {"Top", "Bottom", "Right", "Left"}, 2)

local Positioned, PrevSolved, PrevSolvedTime = false, nil, 0
local PickPrevY, PickPrevClick, Picking = {}, 0, false
local CrowPrevClick = 0
local SafePrevTarget, SafePrevTime = nil, 0
local Wired = {}
local Wiring = false
local Positions = {ESP_TOP, ESP_BOTTOM, ESP_RIGHT, ESP_LEFT}
local ATMTextSize, RegisterTextSize, BountyTextSize

local function SolveATM(Menus)
    if not (Menus and Menus:isvalid()) then
        Positioned, PrevSolved = false, nil
        return false
    end
    local Frame = Menus:find_first_child("ATM")
    if not (Frame and Frame:isvalid()) then
        Positioned, PrevSolved = false, nil
        return false
    end
    local Hacking = Frame:find_first_child("Hacking")
    if not (Hacking and Hacking:isvalid() and Hacking:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true) then
        Positioned, PrevSolved = false, nil
        return false
    end
    local Button = Hacking:find_first_child("ClickButton")
    local Cycle = Hacking:find_first_child("CycleFrame")
    local Selecting = Hacking:find_first_child("SelectingCode")
    if not (Button and Button:isvalid() and Cycle and Cycle:isvalid() and Selecting and Selecting:isvalid()) then return true end
    if not Positioned then
        local Position, Size = Button.gui_position, Button.gui_size
        if Position and Size then
            input.set_mouse_position(vector2(Position.x + Size.x * 0.5, Position.y + Size.y * 0.5))
            input.set_mouse_position_rel(vector2(1, 0))
            Positioned = true
        end
    end
    if not Selecting:isvalid() then return true end
    local Target = Selecting:get_label_text()
    if not Target or Target == "" then return true end
    if PrevSolved == Target then
        if (get_tickcount() - PrevSolvedTime) > 1000 then PrevSolved = nil else return true end
    end
    local LitText
    for Index = 1, 4 do
        if not Cycle:isvalid() then break end
        local List = Cycle:find_first_child("List" .. tostring(Index))
        if List and List:isvalid() then
            for _, Label in pairs(List:get_children()) do
                if Label:isvalid() and Label.class_name == "TextLabel" then
                    local Color = Label:get_label_text_color()
                    if Color and Color.r == 0 and Color.g == 0 and Color.b == 0 then
                        if Label:isvalid() then LitText = Label:get_label_text() end
                        break
                    end
                end
            end
        end
        if LitText then break end
    end
    if LitText and LitText == Target and Hacking:isvalid() and Hacking:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true then
        input.simulate_mouse_click(MOUSE1)
        PrevSolved, PrevSolvedTime = Target, get_tickcount()
    end
    return true
end

local function SolveLockpick(Menus)
    local Lock = Menus:find_first_child("Lockpick")
    local Pick = Lock and Lock:isvalid() and Lock:find_first_child("Pick")
    if not (Lock and Lock:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true and Pick and Pick:isvalid()) then
        PickPrevY, Picking = {}, false
        return false
    end
    if not Picking then
        Picking = true
        wait(500)
        PickPrevY, PickPrevClick = {}, get_tickcount()
        return true
    end
    local RedLine = Pick:find_first_child("RedLine")
    local RedCenter = RedLine and RedLine:isvalid() and RedLine:find_first_child("Center")
    if RedCenter and RedCenter:isvalid() then
        local Chosen, Time = nil, 0.5
        for Index = 1, 6 do
            local Peg = Pick:find_first_child(tostring(Index))
            local Center = Peg and Peg:isvalid() and Peg:find_first_child("Center")
            if Center and Center:isvalid() then
                local yx = Center.gui_position.y
                local Delta = math.abs(yx - (PickPrevY[Index] or yx))
                PickPrevY[Index] = yx
                if Delta > Time then Time, Chosen = Delta, Center end
            end
        end
        if Chosen and (get_tickcount() - PickPrevClick) > 150 then
            local GetChosen = Chosen:get_parent()
            local GetRed = RedCenter:get_parent()
            if GetChosen and GetChosen:isvalid() and GetRed and GetRed:isvalid() then
                local ChosenPos, ChosenSize = Chosen.gui_position, GetChosen.gui_size
                local RedPos, RedSize = RedCenter.gui_position, GetRed.gui_size
                if (ChosenPos.y - ChosenSize.y * 0.5) <= (RedPos.y + RedSize.y * 0.5) and (RedPos.y - RedSize.y * 0.5) <= (ChosenPos.y + ChosenSize.y * 0.5) then
                    input.simulate_mouse_click(MOUSE1)
                    PickPrevClick = get_tickcount()
                end
            end
        end
    end
    return true
end

local function SolveCrowbar(Menus)
    local Crowbar = Menus:find_first_child("Crowbar")
    if not (Crowbar and Crowbar:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true) then return false end
    local Frame = Crowbar:find_first_child("Main")
    local Game = Frame and Frame:isvalid() and Frame:find_first_child("Game")
    local Indicator = Game and Game:isvalid() and Game:find_first_child("Indicator")
    local Target = Game and Game:isvalid() and Game:find_first_child("Target")
    if Indicator and Indicator:isvalid() and Target and Target:isvalid() then
        local IndicatorPos, IndicatorSize = Indicator.gui_position, Indicator.gui_size
        local TargetPos, TargetSize = Target.gui_position, Target.gui_size
        if IndicatorPos.x <= TargetPos.x + TargetSize.x and TargetPos.x <= IndicatorPos.x + IndicatorSize.x
            and (IndicatorPos.y - IndicatorSize.y * 0.5) <= (TargetPos.y + TargetSize.y * 0.5) and (TargetPos.y - TargetSize.y * 0.5) <= (IndicatorPos.y + IndicatorSize.y * 0.5)
            and (get_tickcount() - CrowPrevClick) > 120 then
            input.simulate_mouse_click(MOUSE1)
            CrowPrevClick = get_tickcount()
        end
    end
    return true
end

local function SolveGlasscut(Menus)
    local GlassCutting = Menus:find_first_child("GlassCutting")
    if not (GlassCutting and GlassCutting:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true) then return false end
    local Green = GlassCutting:find_first_child("GreenBox")
    if Green and Green:isvalid() then
        local Position, Size = Green.gui_position, Green.gui_size
        if Position and Size then
            input.set_mouse_position(vector2(Position.x + Size.x * 0.5, Position.y + Size.y * 0.5))
            input.set_mouse_position_rel(vector2(1, 0))
        end
    end
    return true
end

local function SolveSafe(Menus)
    local Frame = Menus:find_first_child("Safe")
    if not (Frame and Frame:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true) then
        SafePrevTarget = nil
        return false
    end
    local Inner = Frame:find_first_child("Safe")
    local Dial = Inner and Inner:isvalid() and Inner:find_first_child("Dial")
    local DialButton = Dial and Dial:isvalid() and Dial:find_first_child("ImageLabel")
    local TopSection = Frame:find_first_child("Top2")
    local TargetLabel = TopSection and TopSection:isvalid() and TopSection:find_first_child("TargetNum")
    if Dial and DialButton and DialButton:isvalid() and TargetLabel and TargetLabel:isvalid() then
        local Position, Size = DialButton.gui_position, DialButton.gui_size
        if Position and Size then
            input.set_mouse_position(vector2(Position.x + Size.x * 0.5, Position.y + Size.y * 0.5))
            input.set_mouse_position_rel(vector2(1, 0))
        end
        local TargetText = TargetLabel:get_label_text()
        local Target = tonumber(TargetText)
        if Target then
            local Rotation = Dial:read_memory(GuiObject_RotationOffset, MEMORY_FLOAT) or 0
            if Rotation > 360 then Rotation = Rotation - 360 elseif Rotation < -360 then Rotation = Rotation + 360 end
            local Number = math.floor(((Rotation > 0) and (100 - Rotation / 360 * 100) or (Rotation < 0) and (math.abs(Rotation) / 360 * 100) or 0) + 0.5)
            if ((Target - 3 <= Number and Number <= Target + 3) or (Target == 0 and Number >= 97)) and SafePrevTarget ~= TargetText then
                input.simulate_mouse_down(MOUSE1) wait(30)
                input.simulate_mouse_up(MOUSE1)
                SafePrevTarget, SafePrevTime = TargetText, get_tickcount()
            elseif SafePrevTarget == TargetText and (get_tickcount() - SafePrevTime) > 1500 then
                SafePrevTarget = nil
            end
        end
    end
    return true
end

local function SolveWires(Menus)
    local ConnectWires = Menus:find_first_child("ConnectWires")
    if not (ConnectWires and ConnectWires:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true) then
        Wired, Wiring = {}, false
        return false
    end
    if not Wiring then
        Wiring = true
        wait(500)
        return true
    end
    local Tangled = ConnectWires:find_first_child("TangledWires")
    local TangledVis
    if Tangled and Tangled:isvalid() then
        for _, Tangle in pairs(Tangled:get_children()) do
            if Tangle:isvalid() and Tangle.class_name == "Frame" and Tangle:read_memory(GuiObject_VisibleOffset, MEMORY_BOOL) == true then TangledVis = Tangle break end
        end
    end
    if TangledVis then
        for _, Wire in pairs(ConnectWires:get_children()) do
            if not WireConnect:get_value() then break end
            if Wire:isvalid() and Wire.class_name == "Frame" and string.find(Wire.name, "Wire") and string.sub(Wire.name, -1) == "L" then
                local WireLabel = Wire.name
                local Drag = Wire:find_first_child("Drag")
                local DragContact = Drag and Drag:isvalid() and Drag:find_first_child("Contact")
                local Connected = Drag and Drag:isvalid() and Drag:get_attribute("Connected", attribute_type.BOOL)
                if Drag and Drag:isvalid() and DragContact and DragContact:isvalid() and not Connected and not Wired[WireLabel] and Drag.gui_size.x >= 2 and Drag.gui_size.y >= 2 and Drag.gui_position.x > 1 and Drag.gui_position.y > 1 then
                    local RightSide = ConnectWires:find_first_child(string.sub(WireLabel, 1, #WireLabel - 1) .. "R")
                    local WireName = RightSide and RightSide:isvalid() and RightSide:get_attribute("WireName", attribute_type.STRING)
                    local TargetWire = (type(WireName) == "string" and WireName ~= "") and TangledVis:find_first_child(WireName)
                    local TargetContact = TargetWire and TargetWire:isvalid() and TargetWire:find_first_child("Contact")
                    if TargetContact and TargetContact:isvalid() and TargetContact.gui_size.x >= 1 then
                        local TargetPos = TargetContact.gui_position
                        local Clicked = false
                        for _ = 1, 6 do
                            if not WireConnect:get_value() or not (Drag:isvalid() and DragContact:isvalid()) then break end
                            local DragPos, DragSize = Drag.gui_position, Drag.gui_size
                            if DragPos and DragSize then
                                input.set_mouse_position(vector2(DragPos.x + DragSize.x * 0.5, DragPos.y + DragSize.y * 0.5))
                                input.set_mouse_position_rel(vector2(1, 0))
                            end
                            wait(200)
                            if not DragContact:isvalid() then break end
                            local Before = DragContact.gui_position
                            input.simulate_mouse_down(MOUSE1) wait(100)
                            input.set_mouse_position_rel(vector2(2, 0)) wait(80)
                            if not DragContact:isvalid() then input.simulate_mouse_up(MOUSE1) break end
                            local After = DragContact.gui_position
                            if math.abs(After.x - Before.x) > 1 or math.abs(After.y - Before.y) > 1 then Clicked = true break end
                            input.simulate_mouse_up(MOUSE1) wait(150)
                        end
                        if not Clicked then
                            input.simulate_mouse_up(MOUSE1) wait(300)
                        elseif not TargetContact:isvalid() then
                            input.simulate_mouse_up(MOUSE1) wait(300)
                        else
                            local Position, Size = TargetContact.gui_position, TargetContact.gui_size
                            if Position and Size then
                                input.set_mouse_position(vector2(Position.x + Size.x * 0.5, Position.y + Size.y * 0.5))
                                input.set_mouse_position_rel(vector2(1, 0))
                            end
                            wait(150)
                            for _ = 1, 5 do
                                if not WireConnect:get_value() or not DragContact:isvalid() then break end
                                local Current = DragContact.gui_position
                                if math.abs(Current.x - TargetPos.x) + math.abs(Current.y - TargetPos.y) < 30 then break end
                                input.set_mouse_position_rel(vector2((TargetPos.x - Current.x) * 0.3, (TargetPos.y - Current.y) * 0.3))
                                wait(50)
                            end
                            wait(100)
                            input.simulate_mouse_up(MOUSE1) wait(200)
                            if Drag:isvalid() and Drag:get_attribute("Connected", attribute_type.BOOL) then
                                Wired[WireLabel] = true
                            else
                                wait(350)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    return true
end

spawn(function()
    while true do
        local Players = game:get_service("Players")
        local LocalPlayer = Players and Players:isvalid() and Players.local_player
        local PlayerGui = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer:find_first_child("PlayerGui")
        local Menus = PlayerGui and PlayerGui:isvalid() and PlayerGui:find_first_child("GameMenus")
        local Active = false
        if Menus and Menus:isvalid() then
            if ATM:get_value() and SolveATM(Menus) then Active = true end
            if Lockpicking:get_value() and SolveLockpick(Menus) then Active = true end
            if VehicleRob:get_value() and SolveCrowbar(Menus) then Active = true end
            if JewelryRob:get_value() and SolveGlasscut(Menus) then Active = true end
            if SafeRob:get_value() and SolveSafe(Menus) then Active = true end
            if WireConnect:get_value() and SolveWires(Menus) then Active = true end
        end
        if Active then wait(16) else wait(150) end
    end
end)

hook.add("render", "esp", function()
    local Workspace = game:get_service("Workspace")
    local Camera = Workspace and Workspace:isvalid() and Workspace:find_first_child_class("Camera")
    if not (Camera and Camera:isvalid()) then return end
    local CamPos = Camera.camera_position

    if ATMEsp:get_value() then
        if not ATMTextSize then ATMTextSize = render.get_text_size("ATM", 11) end
        local Folder = Workspace:find_first_child("ATMs")
        if Folder and Folder:isvalid() then
            local Selected = ATMColor:get_color()
            local MaxDist = ATMDist:get_value()
            for _, Object in pairs(Folder:get_children()) do
                local Part = Object:isvalid() and Object:find_first_child("ClickPart")
                if Part and Part:isvalid() then
                    local Position = Part.position
                    local Distance = math.floor(CamPos:distance(Position))
                    if Distance <= MaxDist then
                        local Screen = world_to_screen(Position)
                        if in_screen(Screen) then
                            local DistText = "[" .. Distance .. "M]"
                            local DistSize = render.get_text_size(DistText, 11)
                            render.add_text(vector2(Screen.x - ATMTextSize.x * 0.5, Screen.y - ATMTextSize.y), "ATM", Selected, 11, true)
                            render.add_text(vector2(Screen.x - DistSize.x * 0.5, Screen.y), DistText, Selected, 11, true)
                        end
                    end
                end
            end
        end
    end

    if RegisterEsp:get_value() then
        if not RegisterTextSize then RegisterTextSize = render.get_text_size("Register", 11) end
        local Folder = Workspace:find_first_child("CashRegisters")
        if Folder and Folder:isvalid() then
            local Selected = RegisterColor:get_color()
            local MaxDist = RegisterDist:get_value()
            for _, Object in pairs(Folder:get_children()) do
                local Part = Object:isvalid() and Object:find_first_child("register_Cube.003")
                if Part and Part:isvalid() then
                    local Position = Part.position
                    local Distance = math.floor(CamPos:distance(Position))
                    if Distance <= MaxDist then
                        local Screen = world_to_screen(Position)
                        if in_screen(Screen) then
                            local DistText = "[" .. Distance .. "M]"
                            local DistSize = render.get_text_size(DistText, 11)
                            render.add_text(vector2(Screen.x - RegisterTextSize.x * 0.5, Screen.y - RegisterTextSize.y), "Register", Selected, 11, true)
                            render.add_text(vector2(Screen.x - DistSize.x * 0.5, Screen.y), DistText, Selected, 11, true)
                        end
                    end
                end
            end
        end
    end

    if BountyEsp:get_value() then
        if not BountyTextSize then BountyTextSize = render.get_text_size("Bounty Vehicle", 11) end
        local Bounty = Workspace:find_first_child("BountyVehicles")
        local Vehicles = Bounty and Bounty:isvalid() and Bounty:find_first_child("Vehicles")
        if Vehicles and Vehicles:isvalid() then
            local Selected = BountyColor:get_color()
            for _, Vehicle in pairs(Vehicles:get_children()) do
                if Vehicle:isvalid() and Vehicle.class_name == "Model" then
                    local Body = Vehicle:find_first_child("Body")
                    local Base = Body and Body:isvalid() and Body:find_first_child("Base") or nil
                    if Base and Base:isvalid() then
                        local Position = Base.position
                        local Screen = world_to_screen(Position)
                        if in_screen(Screen) then
                            local DistText = "[" .. math.floor(CamPos:distance(Position)) .. "M]"
                            local DistSize = render.get_text_size(DistText, 11)
                            render.add_text(vector2(Screen.x - BountyTextSize.x * 0.5, Screen.y - BountyTextSize.y), "Bounty Vehicle", Selected, 11, true)
                            render.add_text(vector2(Screen.x - DistSize.x * 0.5, Screen.y), DistText, Selected, 11, true)
                        end
                    end
                end
            end
        end
    end
end)

hook.add("esp_drawextra", "flags", function(Player)
    if not (Player and Player:isvalid()) then return end

    local Team = Player:get_team()
    local TeamName = Team and Team:isvalid() and Team.name

    if Teamcheck:get_value() then
        local Players = game:get_service("Players")
        local LocalPlayer = Players and Players:isvalid() and Players.local_player
        local LocalTeam = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer:get_team()
        local LocalTeamName = LocalTeam and LocalTeam:isvalid() and LocalTeam.name
        if TeamName and LocalTeamName and TeamName == LocalTeamName then return end
    end

    if TeamFlag:get_value() then
        if TeamName and #TeamName > 0 then render.add_extra(TeamName, Positions[TeamFlagPos:get_value() + 1], color(1, 0.5, 0.5, 1)) end
    end

    if DeviceFlag:get_value() then
        local Device = Player:find_first_child("Device")
        local Text = Device and Device:isvalid() and Device:get_value_string()
        if Text and #Text > 0 then render.add_extra(Text, Positions[DeviceFlagPos:get_value() + 1], color(1, 0.5, 0.5, 1)) end
    end

    if CombatFlag:get_value() and Player:get_attribute("CombatReady", attribute_type.BOOL) == true then
        render.add_extra("In Combat", Positions[CombatFlagPos:get_value() + 1], color(1, 0.5, 0.5, 1))
    end

    if WantedFlag:get_value() then
        local Wanted = Player:find_first_child("Is_Wanted")
        if Wanted and Wanted:isvalid() then render.add_extra("Wanted", Positions[WantedFlagPos:get_value() + 1], color(1, 0.5, 0.5, 1)) end
    end
end)
