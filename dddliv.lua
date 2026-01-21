print("Maxes out at 60 attempts even tho the warnings keep going please ask for help in GC if confused")
-- WL sys made by GPT XDD
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local PrivateServers = ReplicatedStorage:WaitForChild("PrivateServers", 9e9)
local Info = PrivateServers:WaitForChild("Info", 9e9)
local JoinCode = Info:WaitForChild("Code", 9e9).Value :: StringValue
local IsReserved = PrivateServers:WaitForChild("IsReserved", 9e9) :: BoolValue
local function KickClient(msg)
	pcall(function()
		Players.LocalPlayer:Kick(msg)
	end)
end

local function WaitForReserve()
	if not IsReserved or not IsReserved.Value then
		KickClient("nigga r u dumb u need to be in a private server")
		return false
	end
	return true
end

local function CheckServerCode()
	local blockedCodes = { "lanrp", "Joinmrpp", "Tnzrp", "test", "DRIFTED", "HAMP" }

	for _, code in ipairs(blockedCodes) do
		if JoinCode == code then
			KickClient("Server has a WL")
			return false
		end
	end
	return true
end

if not WaitForReserve() then return end
if not CheckServerCode() then return end

_G.LiveriesDumperCfg = {
	GarbageCollectionPollingInterval = 1,
	MaxRetries = 60,

	DumpFolder = "dump",
	DumpFilename = "dumped_liveries.txt",

	Verbose = false,

	Features = {
		UseCodeIDSorting = true,
	},
}

local ExploitEnv = getfenv(debug.info(1, "f"))
local SecureEnv = getsenv(Players.LocalPlayer.PlayerScripts:WaitForChild("Client Game Analytics", 9e9))
local GetCarById
local keepWarning = false
local oldWarn = warn

warn = function(msg, ...)
	if typeof(msg) == "string" and msg:find("Closure Success") then
		keepWarning = false
	end
	oldWarn(msg, ...)
end

for _, v in pairs(getgc(true)) do
	if typeof(v) ~= "table" then
		continue
	end

	if rawget(v, "GetCarById") then
		GetCarById = rawget(v, "GetCarById")
		oldWarn("Found Vehicles Module")

		keepWarning = true
		task.spawn(function()
			while keepWarning do
				oldWarn("Customize a car on a team but civilian")
				task.wait(3)
			end
		end)

		break
	end
end

local SafeGetVehicleById = newcclosure(function(Category: string, Id: string | number)
	for i = 0, 25 do
		pcall(setfenv, i, SecureEnv)
	end

	local ToReturn = coroutine.wrap(GetCarById)(Category, Id)

	for i = 0, 25 do
		pcall(setfenv, i, ExploitEnv)
	end

	warn(`[Safe_GetCarById] - Closure Success - {ToReturn} - Len={#ToReturn}`)
	return ToReturn and ToReturn.Name or `Unknown_{tostring(Id)}`
end)

_G.ContinueLooper = true

local Outputs = {
	"========== Liveries Dumped Output ==========",
	"\n",
}

local CategoryMap = {
	Police = "Law",
	Sheriff = "Law",
	Fire = "Fire",
	DOT = "DOT",
	Job = "Job",
}

local function FormatLivery(TableData, Indent)
	Indent = Indent or ""
	local Lines = {}

	for Key, Value in pairs(TableData) do
		if type(Value) == "table" then
			table.insert(Lines, Indent .. "• " .. tostring(Key) .. ":")
			table.insert(Lines, FormatLivery(Value, Indent .. "    "))
		elseif typeof(Value) == "Color3" then
			table.insert(
				Lines,
				Indent .. "• " .. tostring(Key) ..
				string.format(": RGB(%d, %d, %d)", Value.R * 255, Value.G * 255, Value.B * 255)
			)
		else
			table.insert(Lines, Indent .. "• " .. tostring(Key) .. ": " .. tostring(Value))
		end
	end

	return table.concat(Lines, "\n")
end

local Retries = 0
while task.wait(_G.LiveriesDumperCfg.GarbageCollectionPollingInterval) and _G.ContinueLooper do
	if Retries > _G.LiveriesDumperCfg.MaxRetries then
		break
	end

	Retries += 1
	local GC = filtergc("table", { Keys = { "CustomLiveries" } }, true)

	if not GC or not GC.CustomLiveries then
		continue
	end

	for GroupName, Vehicles in pairs(GC.CustomLiveries) do
		table.insert(Outputs, "\n===== Category: " .. tostring(GroupName) .. " =====\n")
		local Category = CategoryMap[GroupName] or GroupName

		for VehicleId, Liveries in pairs(Vehicles) do
			local CarName = SafeGetVehicleById(Category, tonumber(VehicleId))
			table.insert(Outputs, "▶ Vehicle: " .. CarName .. " (ID: " .. VehicleId .. ")")

			for LiveryId, LiveryData in pairs(Liveries) do
				table.insert(Outputs, "  ── Livery #" .. LiveryId)
				table.insert(Outputs, FormatLivery(LiveryData, "    "))
			end
		end
	end

	local DumpFolder = _G.LiveriesDumperCfg.DumpFolder .. "/" .. (JoinCode or "UnknownCode")
	pcall(makefolder, DumpFolder)
	writefile(DumpFolder .. "/" .. _G.LiveriesDumperCfg.DumpFilename, table.concat(Outputs, "\n"))
	print(string.format("[LiveryDumper] Saved Liveries to %s", DumpFolder .. "/" .. _G.LiveriesDumperCfg.DumpFilename)) -- idk if this works 
    break
end


wait(1)


print("Made by Advanced Leaking: discord.gg/JfV3CymTFr ") 
print("whoaboutyt and mateymate77 was here")
