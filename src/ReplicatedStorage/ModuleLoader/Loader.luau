local Loader = {}

local run = game:GetService("RunService")

function Loader.LoadAll()
	-- Get Global Scripts
	local rsmoduleLoader = script.Parent
	local rsScripts = rsmoduleLoader:WaitForChild("Scripts")

	local Server_Local

	-- Find if the caller is the server or the client

	if run:IsServer() then
		Server_Local = game:GetService("ServerScriptService"):WaitForChild("ModuleLoader"):WaitForChild("Scripts")
	elseif run:IsClient() then
		Server_Local = game:GetService("ReplicatedFirst"):WaitForChild("ModuleLoader"):WaitForChild("Scripts")
	else
		warn("Loader.LoadAll called from an unknown context")
		return
	end

	-- Load Global Modules

	for _, script in pairs(rsScripts:GetChildren()) do
		if script:IsA("ModuleScript") then
			script = require(script)
			if script["init"] then
				task.spawn(script.init)
			end
		end
	end

	-- Load Side-Specific Modules

	for _, script in pairs(Server_Local:GetChildren()) do
		if script:IsA("ModuleScript") then
			script = require(script)
			if script["init"] then
				task.spawn(script.init)
			end
		end
	end
end

function Loader.Get(moduleName)
	-- Get Global Scripts
	local rsScripts = script.Parent:WaitForChild("Scripts")
	local Server_Local

	-- Find if the caller is the server or the client

	if run:IsServer() then
		Server_Local = game:GetService("ServerScriptService"):WaitForChild("ModuleLoader"):WaitForChild("Scripts")
	elseif run:IsClient() then
		Server_Local = game:GetService("ReplicatedFirst"):WaitForChild("ModuleLoader"):WaitForChild("Scripts")
	else
		warn("Loader.Get called from an unknown context")
		return
	end

	-- Find where the module is (server/local or shared)

	local moduleScript = Server_Local:FindFirstChild(moduleName) or rsScripts:FindFirstChild(moduleName)

	-- Return the module if it does exist
	if moduleScript then
		local module = require(moduleScript)
		while not module.IsReady do
			task.wait()
		end
		return module
	else
		warn("Module not found: " .. moduleName)
	end
end

function Loader.GetPackage(PackageName)
	local rsPackages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
	local sPackages = game:GetService("ServerScriptService"):WaitForChild("ServerPackages")

	local Package = rsPackages:FindFirstChild(PackageName) or sPackages:FindFirstChild(PackageName)

	if Package then
		Package = require(Package)
		return Package
	else
		warn("Package not found: " .. PackageName)
	end
end

return Loader
