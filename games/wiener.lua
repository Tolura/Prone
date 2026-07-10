local Menu = gui.create("Decaying Wiener", false)
Menu:set_pos(100, 100)
Menu:set_size(300, 380)

local ItemEsp = Menu:add_checkbox("Locate Items", false)
local ItemDist = Menu:add_slider("Item Distance", 0, 800, 200)
local ItemFilter = Menu:add_multicombo("Filter Items", {"Advanced", "Blueprints", "Crude", "First Aid", "Painkiller", "Speed", "Throwables/Melees"}, {})
local InvertItems = Menu:add_checkbox("Invert Item Filter", false)

local InteractEsp = Menu:add_checkbox("Locate Interacts", false)
local InteractDist = Menu:add_slider("Interacts Distance", 0, 800, 100)
local InteractFilter = Menu:add_multicombo("Filter Interacts", {"Ammo", "Barrel", "Fabricators", "Hazards", "MRE", "Medical", "Scrapper", "Soda", "Storage", "Workbench"}, {})
local InvertInteracts = Menu:add_checkbox("Invert Interacts Filter", false)

local Names = {
    ADBandage = "Aseptic Bandage", AdrStim = "Hermostatic Zanustin", AgentCA = "Lunchbox", AgentCD = "Sledge Queen Lunchbox",
    APack = "Armor", BadBat = "Baseball Bat", BHook = "Bilhook", BKnuckles = "Brass Knuckles", BPack = "Backpack",
    BPAJM = "AJM Blueprint", BPAKM = "AKM Blueprint", BPCPBow = "Milbow Blueprint", BPExec = "Executioner Blueprint",
    BPFAXE = "Fireier Axe Blueprint", BPHammer = "Decimator Blueprint", BPHook = "Billhook Blueprint", BPKSG = "KSG Blueprint",
    BPMPistol = "Pistol Blueprint", BPRifle = "Rifle Blueprint", BPRSASS = "RSASS Blueprint", BPScythe = "Reaper's Scythe Blueprint",
    BPSTI = "Hi-Capa Blueprint", CBar = "Crowbar", CCleaver = "Cleaver", CHammer = "Construction Hammer", CRBandage = "Crude Bandage",
    CRSplint = "Crude Splint", DBarrel = "Handcannon", DEFStim = "Health Stim", DStrim = "3-(cbSTM)", ESword = "Estoc",
    FAid = "Advanced IFAK", FPan = "Frying Pan", HStim = "Cocktail", IbuP = "Augmentin Antibiotics", ImpN = "Impact Grenade",
    LPipe = "Lead Pipe", MAid = "Medkit", Medkit = "First Aid Kit", MGrenade = "Grenade", Molo = "Molotov",
    MPistol = "Modded M1911A1", MShotgun = "Model 870", NSword = "Nodachi", PAxe = "Pickaxe", PBaton = "Police Baton",
    PCutter = "Pizza Cutter", PKillers = "Amoxicillin Tablets", RExplosive = "Remote Explosive", SPDStim = "Speed Stim",
    SubLMG = "M60-E6", SubPP = "PPSH", SubPS = "P90", TAxe = "Hunting Axe", TCaltrop = "Caltrop", THawk = "Tomahawk",
    Tourni = "Tourniquet",
}

hook.add("init_custom_entity", "decay", function()
    force_custom_players()
    add_custom_hitparts({"Head", "ClosestPart", "HumanoidRootPart", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"})

    local Workspace = game:get_service("Workspace")
    if not (Workspace and Workspace:isvalid()) then return end
    local Camera = Workspace:find_first_child_class("Camera")
    local CamPos = Camera and Camera:isvalid() and Camera.camera_position

    local Enemies = Workspace:find_first_child("activeHostiles")
    if Enemies and Enemies:isvalid() then
        for _, NPC in pairs(Enemies:get_children()) do
            if NPC:isvalid() and NPC.class_name == "Model" then
                local Head = NPC:find_first_child("Head")
                local HRP = NPC:find_first_child("HumanoidRootPart")
                local Humanoid = NPC:find_first_child("Humanoid")
                local Type = NPC:find_first_child("ai_type")
                local Name = Type and Type:isvalid() and Type:get_value_string() or "Enemy"

                if Humanoid and Humanoid:isvalid() then
                    add_entity_ex(
                        Names[Name] or Name,
                        NPC,
                        Humanoid,
                        Head,
                        true,
                        vector3(1.8, 4.5, 1.8),
                        vector3(1.8, 0.7, 1.8),
                        {
                        {"Head", Head},
                        {"HumanoidRootPart", HRP},
                        {"Torso", NPC:find_first_child("Torso")},
                        {"Right Arm", NPC:find_first_child("Right Arm")},
                        {"Left Arm", NPC:find_first_child("Left Arm")},
                        {"Right Leg", NPC:find_first_child("Right Leg")},
                        {"Left Leg", NPC:find_first_child("Left Leg")}
                    })
                end
            end
        end
    end

    if ItemEsp:get_value() and CamPos then
        local Drops = Workspace:find_first_child("WeaponDrops")
        if Drops and Drops:isvalid() then
            local MaxDist = ItemDist:get_value()
            local Selected = {}
            for _, I in pairs(ItemFilter:get_selected()) do Selected[I] = true end
            for _, Item in pairs(Drops:get_children()) do
                if Item:isvalid() then
                    local Name = Item.name
                    local Filter
                    if string.sub(Name, 1, 2) == "AD" then Filter = 0
                    elseif string.sub(Name, 1, 2) == "BP" then Filter = 1
                    elseif string.sub(Name, 1, 2) == "CR" then Filter = 2
                    elseif string.sub(Name, 1, 4) == "FAid" then Filter = 3
                    elseif string.sub(Name, 1, 8) == "PKillers" then Filter = 4
                    elseif string.sub(Name, 1, 3) == "SPD" then Filter = 5
                    elseif Name == "TAxe" or Name == "NSword" or Name == "ESword" then Filter = 6
                    end

                    local Match = Filter ~= nil and Selected[Filter] == true
                    local Filtered
                    if InvertItems:get_value() then Filtered = not Match else Filtered = Match end

                    if not Filtered then
                        local Part
                        if Item.class_name == "Part" or Item.class_name == "MeshPart" then
                            Part = Item
                        else
                            for _, Child in pairs(Item:get_descendants()) do
                                if Child:isvalid() and (Child.class_name == "Part" or Child.class_name == "MeshPart") then
                                    Part = Child
                                    break
                                end
                            end
                        end

                        if Part and Part:isvalid() and (Part.position:subtract(CamPos)):length() <= MaxDist then
                            local Half = vector3(Part.size.x * 0.5, Part.size.y * 0.5, Part.size.z * 0.5)
                            add_entity(Names[Name] or Name, Part, nil_instance, false, Half, Half)
                        end
                    end
                end
            end
        end
    end

    if InteractEsp:get_value() and CamPos then
        local Interacts = Workspace:find_first_child("Interactables")
        if Interacts and Interacts:isvalid() then
            local MaxDist = InteractDist:get_value()
            local Selected = {}
            for _, I in pairs(InteractFilter:get_selected()) do Selected[I] = true end
            for _, Item in pairs(Interacts:get_children()) do
                if Item:isvalid() and Item.name ~= "HarvestPiles" then
                    local Name = Item.name
                    local Lower = string.lower(Name)
                    local Filter
                    if string.find(Lower, "ammo") then Filter = 0
                    elseif Name == "Barrel" then Filter = 1
                    elseif string.find(Lower, "fabricator") then Filter = 2
                    elseif Name == "snare" or Name == "tripwire" or Name == "punji" then Filter = 3
                    elseif Name == "MRE" then Filter = 4
                    elseif string.find(Lower, "medical") then Filter = 5
                    elseif Name == "Scrapper" then Filter = 6
                    elseif Name == "Soda" then Filter = 7
                    elseif string.find(Lower, "locker") or string.find(Lower, "crate") then Filter = 8
                    elseif Name == "Workbench" then Filter = 9
                    end

                    local Match = Filter ~= nil and Selected[Filter] == true
                    local Filtered
                    if InvertInteracts:get_value() then Filtered = not Match else Filtered = Match end

                    if not Filtered then
                        local Part
                        if Item.class_name == "Part" or Item.class_name == "MeshPart" then
                            Part = Item
                        else
                            for _, Child in pairs(Item:get_descendants()) do
                                if Child:isvalid() and (Child.class_name == "Part" or Child.class_name == "MeshPart") then
                                    Part = Child
                                    break
                                end
                            end
                        end

                        if Part and Part:isvalid() and (Part.position:subtract(CamPos)):length() <= MaxDist then
                            local Half = vector3(Part.size.x * 0.5, Part.size.y * 0.5, Part.size.z * 0.5)
                            add_entity(Names[Name] or Name, Part, nil_instance, false, Half, Half)
                        end
                    end
                end
            end
        end
    end
end)

Menu:add_button("Unload", function()
    gui.remove("Decaying Wiener")
    hook.remove("init_custom_entity", "decay")
end)
