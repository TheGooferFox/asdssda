-- Debug Anti-Crash v2

local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local StarterGui  = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- grab and verify your real crash function
local globalCrash = _G.CrashMethod
assert(globalCrash, "❌ _G.CrashMethod is nil")
print("DBG → _G.CrashMethod is a", typeof(globalCrash), globalCrash)

-- fresh, collision-free msg helper
local function dbgMsg(txt, col)
    print("DBG Msg:", txt)
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text     = txt;
        Color    = col or Color3.fromRGB(255,0,0);
        Font     = Enum.Font.SourceSansBold;
        FontSize = Enum.FontSize.Size24;
    })
end
print("DBG → dbgMsg is a", typeof(dbgMsg), dbgMsg)

-- safe wrapper so we never accidentally call a string
local function safeCrash(...)
    if typeof(globalCrash) ~= "function" then
        error("❌ globalCrash is not a function but a "..typeof(globalCrash))
    end
    return globalCrash(...)
end

-- hook the server event
local ev = RS:WaitForChild("ReplicateEvent")
ev.OnClientEvent:Connect(function(crashType, instigator)
    dbgMsg("⚠ Caught crashType="..tostring(crashType), Color3.fromRGB(255,200,0))
    print(debug.traceback("Traceback at catch",2))

    -- (optional) your per-crash blocking logic here…

    -- figure out culprit
    local culprit
    if typeof(instigator)=="Instance" and instigator:IsA("Player") then
        culprit = instigator
    elseif typeof(instigator)=="string" then
        culprit = Players:FindFirstChild(instigator)
    end
    print("DBG → culprit is", culprit, typeof(culprit))

    -- retaliate safely
    if culprit and culprit~=LocalPlayer then
        print("DBG → about to call safeCrash")
        local ok,err = pcall(safeCrash, "forcecrash", culprit)
        if not ok then
            dbgMsg("💥 safeCrash failed: "..tostring(err), Color3.fromRGB(255,0,0))
        else
            dbgMsg("💥 Retaliated on "..culprit.Name, Color3.fromRGB(0,255,0))
        end
    else
        dbgMsg("ℹ No valid culprit", Color3.fromRGB(255,255,255))
    end
end)

dbgMsg("✅ Debug Anti-Crash v2 loaded", Color3.fromRGB(0,200,255))
