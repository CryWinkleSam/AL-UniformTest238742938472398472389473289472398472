local function Log(...)
    warn("[Advanced-Leaking]", ...)
end
Log("Initializing Dumper...")

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local PrivateServerFolder = ReplicatedStorage:WaitForChild("PrivateServers", 9e9)
local CustomTeams = PrivateServerFolder:WaitForChild("CustomTeams", 9e9)
local PrivInfo = PrivateServerFolder:WaitForChild("Info", 9e9)
local IsReserved = PrivateServerFolder:WaitForChild("IsReserved", 9e9) :: BoolValue
local ReplicatedState = ReplicatedStorage:WaitForChild("ReplicatedState", 9e9)
local Uniforms = ReplicatedState:WaitForChild("Uniforms", 9e9)
local JoinCode = PrivInfo:WaitForChild("Code", 9e9).Value :: StringValue

local Cfg = {
    DumpFolder = "dump",
    UniDumpFilename = "dumped_uniforms.txt",
    TeamsDumpFilename = "dumped_teams.txt",
    Features = {
        UseCodeIDSorting = true,
    },
}
wait(1)
local function CheckServerCode() -- dont change
    local blockedCodes = { "lanrp", "Joinmrpp", "Tnzrp", "test", "DRIFTED", "HAMP", "ncsrppp", "tcrrp", "crpnc", "ncsrpx" }
    
    for _, code in ipairs(blockedCodes) do
        if JoinCode == code then
            print("[!!] Whitelisted. WL Code:", code)
            return false
        end
    end
    return true
end

Log("Starting stuff")

-- yes sam jalish kalish bans u if u grab EZ
if not CheckServerCode() then
    return
end

local function removeAssetProtocol(strWithProto: string): string
    return strWithProto:gsub("^rbxasset(id)?://", "")
end

local function WaitForReserve()
    if not IsReserved or not IsReserved.Value then
        Log("Error: Server is not a private server.")
        return false
    end
    return true
end

task.spawn(function()
    Log("Task started:", coroutine.running(), "→ CUSTOM TEAMS")
    if not WaitForReserve() then return end
    task.wait(1)

    local ServerName = (PrivInfo:FindFirstChild("ServerName") and PrivInfo.ServerName.Value) or "||UnknownServer||"
    Log("Dumping Server:", ServerName)

    local Output = { "-- CustomTeamsDumper MADE WITH CARE! by https://discord.gg/uTjWUtzXjd --", "", ("Dumping Server: %s"):format(ServerName), "" }
    for _, Team in ipairs(CustomTeams:GetChildren()) do
        local TeamName = Team:FindFirstChild("TeamName") and Team.TeamName.Value or "N/A"
        local LogoId = Team:FindFirstChild("Logo") and Team.Logo.Value or "N/A"
        local Line = ("[Teams] - [%s] - [%s] - [Logo Asset Id: %s]"):format(Team.Name, TeamName, LogoId)
        table.insert(Output, Line)
        Log(Line)
    end

    local TeamsDumpFolder = Cfg.DumpFolder
    if Cfg.Features.UseCodeIDSorting then
        TeamsDumpFolder ..= "/" .. (JoinCode or "UnknownCode")
    end
    pcall(makefolder, TeamsDumpFolder)
    local TeamsFilePath = TeamsDumpFolder .. "/" .. Cfg.TeamsDumpFilename
    writefile(TeamsFilePath, table.concat(Output, "\n"))
    Log(`[Dumper] Saved teams to {TeamsFilePath}`)
end)

task.spawn(function()
    Log("Task started:", coroutine.running(), "→ UNIFORMS")
    if not WaitForReserve() then return end

    local ServerName = (PrivInfo:FindFirstChild("ServerName") and PrivInfo.ServerName.Value) or "||UnknownServer||"
    local Output = { "-- CustomUniformsDumper MADE WITH CARE! by Advanced Leaking -- https://discord.gg/uTjWUtzXjd --", "", ("Dumping Server: %s"):format(ServerName), "" }

    local function DumpDepartment(DeptName: string)
        local DeptFolder = Uniforms:FindFirstChild(DeptName)
        if not DeptFolder then
            Log(("No uniforms found for department: %s"):format(DeptName))
            return
        end
        for _, Uniform in ipairs(DeptFolder:GetChildren()) do
            if not Uniform:FindFirstChild("CustomUniform") then continue end
            local Pants = (Uniform:FindFirstChild("Pants") and Uniform.Pants.PantsTemplate) or "N/A"
            local Shirt = (Uniform:FindFirstChild("Shirt") and Uniform.Shirt.ShirtTemplate) or "N/A"
            local Line = ("[Uniforms_%s] - [%s] - Shirt=%s, Pants=%s"):format(
                DeptName:upper(),
                Uniform.Name or "N/A",
                removeAssetProtocol(Shirt),
                removeAssetProtocol(Pants)
            )
            table.insert(Output, Line)
            Log(Line)
        end
    end

    for _, Department in pairs({ "DOT", "Fire", "Police", "Sheriff" }) do
        DumpDepartment(Department)
    end

    local UniDumpFolder = Cfg.DumpFolder
    if Cfg.Features.UseCodeIDSorting then
        UniDumpFolder ..= "/" .. (JoinCode or "UnknownCode")
    end
    pcall(makefolder, UniDumpFolder)
    local UniFilePath = UniDumpFolder .. "/" .. Cfg.UniDumpFilename
    writefile(UniFilePath, table.concat(Output, "\n"))
    Log(`[Good] Saved uniforms to {UniFilePath}`)
end)
print(JoinCode)
wait(1)
print("Script made by Advanced leaking no other discord.gg/28X3mDuQ")
print("Backup DC: discord.gg/CBJPSjgDsB ")
