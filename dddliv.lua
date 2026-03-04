
local Players = cloneref(game:GetService("Players"))


_G.LiveriesDumperCfg = {
	GarbageCollectionPollingInterval = 1,
	MaxRetries = 60,

	DumpFolder = "dump",
	DumpFilename = "dumped_liveries.txt",
	Verbose = true,
}
-- [[  WL sys made by GPT XDD
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
	local blockedCodes = { "lanrp", "Joinmrpp", "Tnzrp", "test", "DRIFTED", "HAMP", "ncsrppp", "tcrrp", "crpnc", "ncsrpx" }

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
local ExploitEnv = getfenv(debug.info(1, "f"))
local SecureEnv = getsenv(Players.LocalPlayer.PlayerScripts:WaitForChild("Client Game Analytics", 9e9))
local GetCarById
for i, v in pairs(getgc(true)) do
	if typeof(v) ~= "table" then
		continue
	end
	if rawget(v, "GetCarById") then
		GetCarById = rawget(v, "GetCarById")
		warn("Found Vehicles Module")
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
	"========== Liveries Dumped Output Leaked by advanced leaks - discord.gg/jRgNjBh83d ==========",
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
			local Sub = FormatLivery(Value, Indent .. "    ")
			if Sub ~= "" then
				table.insert(Lines, Sub)
			end print("69")
		elseif typeof(Value) == "Color3" then
			local Stringified = string.format("RGB(%d, %d, %d)", Value.R * 255, Value.G * 255, Value.B * 255)
			table.insert(Lines, Indent .. "• " .. tostring(Key) .. ": " .. Stringified)
		elseif Key == "vehicleColor" or Key == "liveryColor" then
			local R, G, B = tostring(Value):match("([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)")
			if R and G and B then
				local R255, G255, B255 = (tonumber(R) or 0) * 255, (tonumber(G) or 0) * 255, (tonumber(B) or 0) * 255
				local Stringified = string.format("RGB(%d, %d, %d)", R255, G255, B255)
				table.insert(Lines, Indent .. "• " .. tostring(Key) .. ": " .. Stringified)
			else
				table.insert(Lines, Indent .. "• " .. tostring(Key) .. ": " .. tostring(Value))
			end
		else
			table.insert(Lines, Indent .. "• " .. tostring(Key) .. ": " .. tostring(Value))
		end
	end

	return table.concat(Lines, "\n")
end

local Retries = 0
local function LoopUp()
	while task.wait(_G.LiveriesDumperCfg.GarbageCollectionPollingInterval) and _G.ContinueLooper do
		if Retries > _G.LiveriesDumperCfg.MaxRetries then
			_G.ContinueLooper = false
			warn("Max Retries Reached (Have you tried customizing a car while dumping?)")
			warn("Max Retries Reached (Make sure you're not in a PUBLIC server!!)")
			break
		end
		Retries += 1
		local GC = filtergc("table", { Keys = { "CustomLiveries" } }, true)

		if not GC or not GC.CustomLiveries then
			warn("[LiveryDumper] No CustomLiveries found, retrying...")
			continue
		end   print("105")

		_G.ContinueLooper = false
		warn("[LiveryDumper] Found liveries, creating output...")

		if typeof(GC.CustomLiveries) ~= "table" then
			warn("[!!] Fatal Error Occured - Did not Find correct Outputs.")
			_G.ContinueLooper = true
			continue
		end

		for GroupName, Vehicles in pairs(GC.CustomLiveries) do
			table.insert(Outputs, "\n===== Category: " .. tostring(GroupName) .. " =====\n")

			local Category = CategoryMap[GroupName] or GroupName

			if type(Vehicles) == "table" then
				for VehicleId, Liveries in pairs(Vehicles) do
					local CarName = SafeGetVehicleById(Category, tonumber(VehicleId))

					table.insert(Outputs, string.rep("─", 40))
					table.insert(Outputs, "▶ Vehicle: " .. CarName .. " (ID: " .. tostring(VehicleId) .. ")")
					table.insert(Outputs, string.rep("─", 40))

					if type(Liveries) == "table" then
						for LiveryId, LiveryData in pairs(Liveries) do
							table.insert(Outputs, "  ── Livery #" .. tostring(LiveryId) .. " ──")
							if type(LiveryData) == "table" then
								table.insert(Outputs, FormatLivery(LiveryData, "    "))
							else
								table.insert(Outputs, "    " .. tostring(LiveryData))
							end
						end
					else  print("138")
						table.insert(Outputs, "  (No liveries)")
					end
				end
			end
		end

		local FinalOutput = table.concat(Outputs, "\n")

		local DumpFolder = _G.LiveriesDumperCfg.DumpFolder
		local DumpFilename = _G.LiveriesDumperCfg.DumpFilename

		pcall(makefolder, DumpFolder)
		writefile(`{DumpFolder}/{DumpFilename}`, FinalOutput)
		warn(`[LiveryDumper] Saved liveries to {DumpFolder}/{DumpFilename}`)
	end
end

LoopUp()
local asd = "Script By Advanced Leaking - https://discord.gg/bzVVk95HK8 "
print(asd)


print("Made by Advanced Leaking: discord.gg/JfV3CymTFr ") 
print("whoaboutyt and mateymate77 was here")
