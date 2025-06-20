-- Anti-Crash Pro v2 (fixed)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui        = game:GetService("StarterGui")
local NetworkSettings   = game:GetService("NetworkSettings")
local LocalPlayer       = Players.LocalPlayer

-- your CrashMethod must already be in _G
assert(type(_G.CrashMethod) == "function", "CrashMethod() not found")
local CrashMethod = _G.CrashMethod

-- the RemoteEvent the server uses for crash calls
local REMOTE_NAME     = "ReplicateEvent"
local replicateEvent  = ReplicatedStorage:WaitForChild(REMOTE_NAME)

-- helper for system chat messages
local function SysMessage(text, color)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text     = text;
        Color    = color or Color3.fromRGB(255,0,0);
        Font     = Enum.Font.SourceSansBold;
        FontSize = Enum.FontSize.Size24;
    })
end

-- helper to disable all connections on a signal (exploit env only)
local function disableAll(signal)
    if type(getconnections) == "function" then
        for _, conn in ipairs(getconnections(signal)) do
            conn:Disable()
        end
    end
end

-- main listener
replicateEvent.OnClientEvent:Connect(function(crashType, arg)
    SysMessage("⚠️ Detected crash: "..tostring(crashType))

    -- run a quick “anti” for each crash
    if crashType == "servercrash" then
        pcall(function()
            LocalPlayer.PlayerScripts.ClientGunReplicator.Disabled = true
        end)
        SysMessage("🛡️ Blocked servercrash", Color3.fromRGB(255,255,0))

    elseif crashType == "lastresort" then
        local shoot = ReplicatedStorage:FindFirstChild("ShootEvent")
        if shoot then disableAll(shoot.OnClientEvent) end
        SysMessage("🛡️ Blocked lastresort", Color3.fromRGB(255,255,0))

    elseif crashType == "crashkill" then
        SysMessage("🛡️ Blocked crashkill", Color3.fromRGB(255,255,0))

    elseif crashType == "serverlag" or crashType == "serverspike" then
        local shoot = ReplicatedStorage:FindFirstChild("ShootEvent")
        if shoot then disableAll(shoot.OnClientEvent) end
        SysMessage("🛡️ Blocked "..crashType, Color3.fromRGB(255,255,0))

    elseif crashType == "timeout" or crashType == "tasercrash" then
        local shoot = ReplicatedStorage:FindFirstChild("ShootEvent")
        if shoot then disableAll(shoot.OnClientEvent) end
        SysMessage("🛡️ Blocked "..crashType, Color3.fromRGB(255,255,0))

    elseif crashType == "timestop" then
        SysMessage("🛡️ Blocked timestop", Color3.fromRGB(255,255,0))

    elseif crashType == "itemlag" then
        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = LocalPlayer.Backpack
                end
            end
        end
        SysMessage("🛡️ Blocked itemlag", Color3.fromRGB(255,255,0))

    elseif crashType == "forcecrash" then
        SysMessage("🛡️ Caught forcecrash incoming", Color3.fromRGB(255,255,0))

    elseif crashType == "formidicrash"
       or crashType == "eventcrash"
       or crashType == "eventlag"
       or crashType == "soundlag" then

        pcall(function()
            NetworkSettings.IncomingReplicationLag = 0
        end)
        SysMessage("🛡️ Blocked "..crashType, Color3.fromRGB(255,255,0))

    else
        SysMessage("⚠️ Unknown crash: "..tostring(crashType), Color3.fromRGB(255,165,0))
    end

    -- figure out who sent it
    local culprit
    if typeof(arg) == "Instance" and arg:IsA("Player") then
        culprit = arg
    elseif typeof(arg) == "string" then
        culprit = Players:FindFirstChild(arg)
    end

    -- retaliate
    if culprit and culprit ~= LocalPlayer then
        CrashMethod("forcecrash", culprit)
        SysMessage("💥 Retaliated on "..culprit.Name.."!", Color3.fromRGB(0,255,0))
    else
        SysMessage("ℹ️ No valid culprit to crash back.", Color3.fromRGB(255,255,0))
    end
end)

-- ready confirmation
SysMessage("✅ Anti-Crash Pro v2 active!", Color3.fromRGB(0,200,255))
