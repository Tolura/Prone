local Main = gui.create("Demonologay", false)
Main:set_pos(230, 250)
Main:set_size(290, 240)

local Info = gui.create("Ghost Info", true)
Info:set_pos(10, 150)
Info:set_size(230, 255)

local List = gui.create("Detected Evidences", true)
List:set_pos(10, 380)
List:set_size(200, 150)

local GhostESP = Main:add_checkbox("Ghost ESP", false)
local EquipmentESP = Main:add_checkbox("Equipment ESP", false)
local FilterEquip = Main:add_multicombo("Filter Equipment", {"Blacklight", "Cross", "EMF Reader", "Energy Drink", "Energy Watch", "Flashlight", "Flowers", "Holy Oil", "LIDAR Scanner", "Laser Proj.", "Photo Camera", "Plushie", "Spirit Book", "Spirit Box", "Thermometer", "Umbra Board", "Video Camera", "Fuse Box"}, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17})
local EvidenceESP = Main:add_checkbox("Evidence ESP", false)
local EvidenceNotif = Main:add_checkbox("Notify Evidence", false)
local RoomESP = Main:add_checkbox("Room ESP", false)

local RoomInfo = Info:add_label("Room: Waiting for Job")
local Favorite = Info:add_label("Favorite Room: Waiting for Job")
local GenderInfo = Info:add_label("Gender: Waiting for Job")
local AgeInfo = Info:add_label("Age: Waiting for Job")
local Headless = Info:add_label("Headless: Waiting for Job")
local Visibility = Info:add_label("Visibility: Waiting for Job")
local Hunting = Info:add_label("Hunting: Waiting for Job")
local PlayerEnergy = Info:add_label("Player Energy: Waiting for Job")
local Evidences = {}
for Index = 1, 6 do Evidences[Index] = List:add_label("") end

local Equipment = {
    ["Blacklight"] = {"Blacklight", 0}, ["Cross"] = {"Cross", 1}, ["EMF Reader"] = {"EMF Reader", 2},
    ["Energy Drink"] = {"Energy Drink", 3}, ["Energy Watch"] = {"Energy Watch", 4}, ["Flashlight"] = {"Flashlight", 5},  
    ["Fuse Box"] = {"Fuse Box", 17}, ["Flower Pot"] = {"Flowers", 6}, ["Holy Oil"] = {"Holy Oil", 7}, ["LIDAR Scanner"] = {"LIDAR Scanner", 8},
    ["Laser Projector"] = {"Laser Proj.", 9}, ["Photo Camera"] = {"Photo Camera", 10}, ["Plushie"] = {"Plushie", 11},
    ["Spirit Book"] = {"Spirit Book", 12}, ["Spirit Box"] = {"Spirit Box", 13}, ["Thermometer"] = {"Thermometer", 14},
    ["Umbra Board"] = {"Umbra Board", 15}, ["Video Camera"] = {"Video Camera", 16},
}

local Replies = {CLOSE=true,FAR=true,["FAR AWAY"]=true,AWAY=true,KILL=true,HATE=true,["DON'T TURN AROUND"]=true,BEHIND=true,["I'M BEHIND YOU"]=true,DEATH=true,ATTACK=true,HURT=true,YOUNG=true,OLD=true,ELDER=true}

local Added = {}
local Found = {}
local Num = {}
local Notified = {}
local Rooms = {}
local Roomies = {}
local Texts = {}
local PrevMap
local CurrRoom
local FavRoom
local InJob = false
local SpiritBox = false
local SpiritTime = 0

local function Get(Inst)
    if not (Inst and Inst:isvalid()) then return nil end
    if Inst.class_name == "Part" or Inst.class_name == "MeshPart" then return Inst end
    for _, Child in pairs(Inst:get_descendants()) do
        if Child:isvalid() and (Child.class_name == "Part" or Child.class_name == "MeshPart") then return Child end
    end
end

local function Track(Name, Part)
    if not (Part and Part:isvalid()) then return end
    local ID = Name .. ":" .. Part.identity
    if not Added[ID] then
        local Half = vector3(Part.size.x * 0.5, Part.size.y * 0.5, Part.size.z * 0.5)
        add_entity(Name, Part, nil_instance, false, Half, Half)
        Added[ID] = true
    end
end

local function Detect(Name, Key, Part)
    if Part and Part:isvalid() and EvidenceESP:get_value() then Track(Name, Part) end
    if Found[Key] then return end
    Found[Key] = true
    Num[Name] = (Num[Name] or 0) + 1
    if EvidenceNotif:get_value() and not Notified[Name] then
        Notified[Name] = true
        log.notification("Evidence: " .. Name, "info")
    end
end

local function GetRoom(Name)
    return Name and string.gsub(string.lower(Name), "%s", "") or nil
end

local function Resolve(RoomName)
    if not RoomName then return nil end
    local Part = Rooms[RoomName]
    if Part then return Part end
    local Area = GetRoom(RoomName)
    for _, Room in pairs(Roomies) do
        if Room.Area == Area then return Room.Part end
    end
end

local function UpdateList()
    local Names = {}
    for Name in pairs(Num) do Names[#Names + 1] = Name end
    table.sort(Names)
    for Index, Info in pairs(Evidences) do
        local Name = Names[Index]
        local Count = Name and Num[Name] or 0
        local Text = Name and (Count > 1 and string.format("%s (%dx)", Name, Count) or Name) or ""
        if Texts[Index] ~= Text then
            Texts[Index] = Text
            Info:set_label(Text)
        end
    end
end

local function Reset()
    Added = {}
    Found = {}
    Num = {}
    Notified = {}
    Rooms = {}
    Roomies = {}
    Texts = {}
    CurrRoom = nil
    FavRoom = nil
    SpiritBox = false
    SpiritTime = 0
    UpdateList()
end

hook.add("init_custom_entity", "demongay", function()
    force_custom_players()
    Added = {}
    Rooms = {}
    Roomies = {}
    local Workspace = game:get_service("Workspace")
    if not (Workspace and Workspace:isvalid()) then
        if InJob then Reset() end
        InJob = false
        PrevMap = nil
        return
    end

    local Map = Workspace:find_first_child("Map")
    local CheckMap = Map and Map:isvalid() and Map.identity
    if CheckMap ~= PrevMap then
        Reset()
        PrevMap = CheckMap
    end

    if Map and Map:isvalid() then
        local MapRooms = Map:find_first_child("Rooms")
        if MapRooms and MapRooms:isvalid() then
            for _, Room in pairs(MapRooms:get_children()) do
                if Room and Room:isvalid() then
                    local Part
                    if Room.class_name == "Part" or Room.class_name == "MeshPart" then
                        if Room.name ~= "BoundingBox" then Part = Room end
                    else
                        for _, Child in pairs(Room:get_children()) do
                            if Child:isvalid() and Child.name ~= "BoundingBox" and (Child.class_name == "Part" or Child.class_name == "MeshPart") then
                                Part = Child
                                break
                            end
                        end
                    end
                    if not Part then Part = Get(Room) end
                    if Part then
                        Rooms[Room.name] = Part
                        Roomies[#Roomies + 1] = {Name = Room.name, Area = GetRoom(Room.name), Part = Part}
                    end
                end
            end
        end
    end

    local Ghost = Workspace:find_first_child("Ghost")
    local HasGhost = Ghost and Ghost:isvalid()
    if InJob and not HasGhost then Reset() end
    InJob = HasGhost

    local Players = game:get_service("Players")
    local LocalPlayer = Players and Players:isvalid() and Players.local_player
    local Energy = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer:get_attribute("Energy", attribute_type.NUMBER)
    PlayerEnergy:set_label(Energy and string.format("Player Energy: %.0f%%", Energy) or "Player Energy: Waiting for Job")

    if HasGhost then
        local Humanoid = Ghost:find_first_child("Humanoid")
        local Head = Ghost:find_first_child("Head")
        local HRP = Ghost:find_first_child("HumanoidRootPart")

        if GhostESP:get_value() and Humanoid and Humanoid:isvalid() then
            add_entity_ex(
                "Ghost",
                Ghost,
                Humanoid,
                Head,
                false,
                vector3(1.8, 4.5, 1.8),
                vector3(1.8, 0.7, 1.8),
                {
                {"Head", Head},
                {"HumanoidRootPart", HRP},
                {"Torso", Ghost:find_first_child("Torso")},
                {"Right Arm", Ghost:find_first_child("Right Arm")},
                {"Left Arm", Ghost:find_first_child("Left Arm")},
                {"Right Leg", Ghost:find_first_child("Right Leg")},
                {"Left Leg", Ghost:find_first_child("Left Leg")}
            })
        end

        local CurrentRoom = Ghost:get_attribute("CurrentRoom", attribute_type.STRING)
        local FavoriteRoom = Ghost:get_attribute("FavoriteRoom", attribute_type.STRING)
        CurrRoom = GetRoom(CurrentRoom)
        FavRoom = GetRoom(FavoriteRoom)

        RoomInfo:set_label("Room: " .. (CurrentRoom or "?"))
        Favorite:set_label("Favorite Room: " .. (FavoriteRoom or "?"))
        Hunting:set_label("Hunting: " .. tostring(Ghost:get_attribute("Hunting", attribute_type.BOOL) == true))
        Headless:set_label("Headless: " .. tostring(Ghost:get_attribute("Headless", attribute_type.BOOL) == true))
        local Transparency = Ghost:get_attribute("Transparency", attribute_type.NUMBER)
        Visibility:set_label("Visibility: " .. (Transparency and (Transparency < 1.0 and "Visible" or "Hidden") or "Hidden"))
        local Age = Ghost:get_attribute("Age", attribute_type.NUMBER)
        AgeInfo:set_label(Age and string.format("Age: %.0f", Age) or "Age: Waiting for Job")
        GenderInfo:set_label("Gender: " .. (Ghost:get_attribute("Gender", attribute_type.STRING) or "Waiting for Job"))

        if HRP and HRP:isvalid() then
            if Ghost:get_attribute("LaserVisible", attribute_type.BOOL) == true then
                Detect("Laser Projector", "Laser Projector", HRP)
            end
            local EMF = Ghost:get_attribute("LastEMFLevel5Time", attribute_type.NUMBER)
            if EMF and EMF > 0 then
                Detect("EMF Level 5", "EMF Level 5", HRP)
            end
        end
    else
        RoomInfo:set_label("Room: Waiting for Job")
        Favorite:set_label("Favorite Room: Waiting for Job")
        GenderInfo:set_label("Gender: Waiting for Job")
        AgeInfo:set_label("Age: Waiting for Job")
        Headless:set_label("Headless: Waiting for Job")
        Visibility:set_label("Visibility: Waiting for Job")
        Hunting:set_label("Hunting: Waiting for Job")
    end

    if EquipmentESP:get_value() then
        local Selected = {}
        for _, Index in pairs(FilterEquip:get_selected()) do Selected[Index] = true end
        local Items = Workspace:find_first_child("Items")
        if Items and Items:isvalid() then
            for _, Item in pairs(Items:get_children()) do
                if Item:isvalid() then
                    local Raw = Item:get_attribute("ItemName", attribute_type.STRING)
                    local Details = Equipment[Raw]
                    if Details and Selected[Details[2]] then
                        local Part = Get(Item)
                        if Part and Part:isvalid() then Track(Details[1], Part) end
                    end
                end
            end
        end

        if Map and Map:isvalid() then
            for _, Item in pairs(Map:get_descendants()) do
                if Item:isvalid() and string.find(string.lower(Item.name), "fuse") then
                    local Part = Get(Item)
                    if Part and Selected[17] then Track("Fuse Box", Part) break end
                end
            end
        end
    end

    local Orb = Workspace:find_first_child("GhostOrb")
    if Orb and Orb:isvalid() then
        local Part = Get(Orb)
        if Part then Detect("Ghost Orb", "GhostOrb:" .. Orb.identity, Part) end
    end

    local Prints = Workspace:find_first_child("Handprints")
    if Prints and Prints:isvalid() then
        for _, Child in pairs(Prints:get_children()) do
            if Child:isvalid() and (Child.class_name == "Part" or Child.class_name == "MeshPart") then
                Detect("Prints", "Prints:" .. Child.identity, Child)
            end
        end
    end

    local Scratch = Workspace:find_first_child("ScratchText")
    if Scratch and Scratch:isvalid() then
        for _, Child in pairs(Scratch:get_children()) do
            if Child:isvalid() and Child.class_name == "Model" then
                local Part = Get(Child)
                if Part then Detect("Inscription", "Scratch:" .. Child.identity, Part) end
            end
        end
    end

    local PlayerGui = LocalPlayer and LocalPlayer:isvalid() and LocalPlayer:find_first_child("PlayerGui")
    local Subtitles = PlayerGui and PlayerGui:isvalid() and PlayerGui:find_first_child("Subtitles")
    local Holder = Subtitles and Subtitles:isvalid() and Subtitles:find_first_child("Holder")
    local TextInfo = Holder and Holder:isvalid() and (Holder:find_first_child("TextLabel") or Holder:find_first_child_class("TextLabel"))
    local Text = TextInfo and TextInfo:isvalid() and TextInfo:get_label_text()
    if Text then Text = string.upper(string.gsub(Text, "^%s*(.-)%s*$", "%1")) end
    local IsSpiritActive = Text and Replies[Text] or false
    if IsSpiritActive and Ghost and Ghost:isvalid() then
        if not SpiritBox then SpiritTime = SpiritTime + 1 end
        local Room = Ghost:get_attribute("CurrentRoom", attribute_type.STRING)
        Detect("Spirit Box", "SpiritBox:" .. SpiritTime, Resolve(Room))
    end
    SpiritBox = IsSpiritActive

    if Map and Map:isvalid() then
        local MapRooms = Map:find_first_child("Rooms")
        if MapRooms and MapRooms:isvalid() then
            local Set = 0
            local Unit = Workspace:get_attribute("TemperatureUnit", attribute_type.STRING)
            if not Unit then Unit = game:get_attribute("TemperatureUnit", attribute_type.STRING) end
            if Unit then Unit = string.lower(string.gsub(Unit, "%s", "")) end
            if Unit == "f" or Unit == "fahrenheit" then
                Set = 32
            elseif Unit ~= "c" and Unit ~= "celsius" then
                for _, Room in pairs(MapRooms:get_children()) do
                    if Room and Room:isvalid() then
                        local Temperature = Room:get_attribute("Temperature", attribute_type.NUMBER)
                        if Temperature and Temperature > 40 then Set = 32 break end
                    end
                end
            end
            for _, Room in pairs(MapRooms:get_children()) do
                if Room and Room:isvalid() then
                    local Temperature = Room:get_attribute("Temperature", attribute_type.NUMBER)
                    if Temperature and Temperature < Set then
                        Detect("Freezing Temps", "Freezing:" .. Room.name, Rooms[Room.name])
                    end
                end
            end
        end
    end

    local Items = Workspace:find_first_child("Items")
    if Items and Items:isvalid() then
        for _, Item in pairs(Items:get_children()) do
            if Item and Item:isvalid() then
                local ItemName = Item:get_attribute("ItemName", attribute_type.STRING)
                if ItemName == "Spirit Book" then
                    local Reward = Item:get_attribute("PhotoRewardType", attribute_type.STRING)
                    local GetReward = Item:get_attribute("PhotoRewardAvailable", attribute_type.STRING)
                    local IsReward = Item:get_attribute("PhotoRewardAvailable", attribute_type.BOOL)
                    local Available = GetReward == "true" or IsReward == true or GetReward == true
                    local Inscription = Available and Reward == "Inscription"
                    if not Inscription then
                        for _, Child in pairs(Item:get_descendants()) do
                            if Child:isvalid() and (Child.class_name == "TextLabel" or Child.class_name == "TextButton") then
                                local Label = Child:get_label_text()
                                if Label and #Label > 0 and Label ~= " " then
                                    Inscription = true
                                    break
                                end
                            end
                        end
                    end
                    if Inscription then
                        Detect("Inscription", "Book:" .. Item.identity, Get(Item))
                    end
                elseif ItemName == "Flower Pot" then
                    local Reward = Item:get_attribute("PhotoRewardType", attribute_type.STRING)
                    local GetReward = Item:get_attribute("PhotoRewardAvailable", attribute_type.STRING)
                    local IsReward = Item:get_attribute("PhotoRewardAvailable", attribute_type.BOOL)
                    local Available = GetReward == "true" or IsReward == true or GetReward == true
                    local Withered = Available and Reward == "WitheredFlowers"
                    if not Withered then
                        local Parts = 0
                        local Transparents = 0
                        for _, Child in pairs(Item:get_descendants()) do
                            if Child:isvalid() and (Child.class_name == "Part" or Child.class_name == "MeshPart") then
                                Parts = Parts + 1
                                if Child.transparency > 0.8 then Transparents = Transparents + 1 end
                            end
                        end
                        if Parts > 0 and Parts == Transparents then Withered = true end
                    end
                    if Withered then
                        Detect("Wither", "Wither:" .. Item.identity, Get(Item))
                    end
                end
            end
        end
    end

    UpdateList()
end)

hook.add("render", "demonrooms", function()
    if not RoomESP:get_value() then return end
    if #Roomies == 0 then return end
    local White = color(1, 1, 1, 0.9)
    local Orange = color(1, 0.65, 0, 0.9)
    local Red = color(1, 0, 0, 0.9)
    for _, Room in pairs(Roomies) do
        local Part = Room.Part
        if Part and Part:isvalid() then
            local Pos = Part.position
            if Pos then
                local Screen = world_to_screen(Pos)
                if Screen then
                    local RoomColor = White
                    if CurrRoom and Room.Area == CurrRoom then RoomColor = Orange end
                    if FavRoom and Room.Area == FavRoom then RoomColor = Red end
                    render.add_text(Screen, Room.Name, RoomColor, 13, true)
                end
            end
        end
    end
end)
