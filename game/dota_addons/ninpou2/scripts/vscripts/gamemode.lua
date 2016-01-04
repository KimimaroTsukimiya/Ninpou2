-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')


-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  --local item = CreateItem("item_example_item", hero, hero)
  --hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
  
  -- Set player gold to zero
  hero:SetGold(0, false)
end

-- Spawn creeps for a determined lane
function SpawnCreepsLane(units, unitsCount, path, team, spawnerName)
	local spawner = Entities:FindByName(nil, spawnerName)
	if IsValidEntity(spawner) and spawner:IsAlive() then -- Only spawn units from which spawner is alive
		for unitKey, unitValue in pairs(units) do 
            --print("Spawning " .. tostring(unitsCount[unitKey]) .. " " .. unitValue .. " at " .. spawnerName .. "...")
			for i = 1, unitsCount[unitKey] do 
				Timers:CreateTimer(function()
					local unit = CreateUnitByName(unitValue, path[1] + RandomVector(RandomInt(100, 200)), true, nil, nil, team)
					for j = 2, #path do 
						ExecuteOrderFromTable({
							UnitIndex = unit:GetEntityIndex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
							Position = path[j],
							Queue = true
						})
					end
				end)
			end
		end
	end
end

-- Spawn creeps for the whole map
function SpawnCreeps(count)
    -- Getting info points 
    local konohaLeftLane     = Entities:FindByName(nil, "spawn_konoha_left_lane"):GetAbsOrigin()
    local konohaRightLane    = Entities:FindByName(nil, "spawn_konoha_right_lane"):GetAbsOrigin()
    local konohaMidLane      = Entities:FindByName(nil, "spawn_konoha_mid_lane"):GetAbsOrigin()
    local otoLeftLane        = Entities:FindByName(nil, "spawn_oto_left_lane"):GetAbsOrigin()
    local otoRightLane       = Entities:FindByName(nil, "spawn_oto_right_lane"):GetAbsOrigin()
    local otoMidLane         = Entities:FindByName(nil, "spawn_oto_mid_lane"):GetAbsOrigin()
    local akatsukiLeftLane   = Entities:FindByName(nil, "spawn_akatsuki_left_lane"):GetAbsOrigin()
    local akatsukiRightLane  = Entities:FindByName(nil, "spawn_akatsuki_right_lane"):GetAbsOrigin()
    local akatsukiMidLane    = Entities:FindByName(nil, "spawn_akatsuki_mid_lane"):GetAbsOrigin()
    local konohaOtoLane      = Entities:FindByName(nil, "spawn_konoha_oto_lane"):GetAbsOrigin()
    local otoAkatsukiLane    = Entities:FindByName(nil, "spawn_oto_akatsuki_lane"):GetAbsOrigin()
    local akatsukiKonohaLane = Entities:FindByName(nil, "spawn_akatsuki_konoha_lane"):GetAbsOrigin()
    local midLane            = Entities:FindByName(nil, "spawn_mid_lane"):GetAbsOrigin()
    -- Define the units for each team 
    local konohaUnits = { chunnin = "npc_konoha_chunnin_unit", 
        jounin = "npc_konoha_jounin_unit", 
        medical = "npc_medical_ninja_unit", 
        anbu = "npc_anbu_unit" }
    local otoUnits = { chunnin = "npc_oto_chunnin_unit",
        jounin = "npc_oto_jounin_unit",
        medical = "npc_medical_ninja_unit",
        anbu = "npc_anbu_unit" }
    local akatsukiUnits = { chunnin = "npc_akatsuki_chunnin_unit",
        jounin = "npc_akatsuki_jounin_unit",
        medical = "npc_medical_ninja_unit",
        anbu = "npc_anbu_unit" }
    local anbusSpawnFrequency = 2 -- How often will Anbus spawn? 2 = half the time, 3 = a third of the time, etc...
    -- How much units will be spawned?
    local spawnCountSide = { chunnin = 2,
        jounin = 3, 
        medical = 1,
        anbu = (math.fmod(count, anbusSpawnFrequency) == 0 and 1 or 0) }
    local spawnCountMid = { chunnin = 3,
        jounin = 4, 
        medical = 1,
        anbu = (math.fmod(count, anbusSpawnFrequency) == 0 and 1 or 0) }
    -- Define the path for which the units will walk 
    local konohaLeftLanePath    = {konohaLeftLane, konohaOtoLane, otoLeftLane, otoMidLane, otoRightLane, otoAkatsukiLane, akatsukiRightLane, akatsukiMidLane, akatsukiLeftLane, akatsukiKonohaLane, konohaRightLane, konohaMidLane, konohaLeftLane}
    local konohaRightLanePath   = {konohaRightLane, akatsukiKonohaLane, akatsukiLeftLane, akatsukiMidLane, akatsukiRightLane, otoAkatsukiLane, otoRightLane, otoMidLane, otoLeftLane, konohaOtoLane, konohaLeftLane, konohaMidLane, konohaRightLane}
    local konohaMidLanePath     = {konohaMidLane, midLane, otoMidLane, otoRightLane, otoAkatsukiLane, akatsukiRightLane, akatsukiMidLane, akatsukiLeftLane, akatsukiKonohaLane, konohaLeftLane, konohaMidLane}
    local otoLeftLanePath       = {otoLeftLane, konohaOtoLane, konohaLeftLane, konohaMidLane, konohaRightLane, akatsukiKonohaLane, akatsukiLeftLane, akatsukiMidLane, akatsukiRightLane, otoAkatsukiLane, otoRightLane, otoMidLane, otoLeftLane}
    local otoRightLanePath      = {otoRightLane, otoAkatsukiLane, akatsukiRightLane, akatsukiMidLane, akatsukiLeftLane, akatsukiKonohaLane, konohaRightLane, konohaMidLane, konohaLeftLane, konohaOtoLane, otoLeftLane, otoMidLane, otoRightLane}
    local otoMidLanePath        = {otoMidLane, midLane, akatsukiMidLane, akatsukiLeftLane, akatsukiKonohaLane, konohaRightLane, konohaMidLane, konohaLeftLane, konohaOtoLane, otoLeftLane, otoMidLane}
    local akatsukiLeftLanePath  = {akatsukiLeftLane, akatsukiKonohaLane, konohaRightLane, konohaMidLane, konohaLeftLane, otoAkatsukiLane, otoLeftLane, otoMidLane, otoRightLane, otoAkatsukiLane, akatsukiRightLane, akatsukiMidLane, akatsukiLeftLane}
    local akatsukiRightLanePath = {akatsukiRightLane, otoAkatsukiLane, otoRightLane, otoMidLane, otoLeftLane, konohaOtoLane, konohaLeftLane, konohaMidLane, konohaRightLane, akatsukiKonohaLane, akatsukiLeftLane, akatsukiMidLane, akatsukiRightLane}
    local akatsukiMidLanePath   = {akatsukiMidLane, midLane, konohaMidLane, konohaLeftLane, konohaOtoLane, otoLeftLane, otoMidLane, otoRightLane, otoAkatsukiLane, akatsukiRightLane, akatsukiMidLane}
    -- Spawn creeps 
    SpawnCreepsLane(konohaUnits, spawnCountSide, konohaLeftLanePath, DOTA_TEAM_GOODGUYS, "konoha_academy_left")
    SpawnCreepsLane(konohaUnits, spawnCountSide, konohaRightLanePath, DOTA_TEAM_GOODGUYS, "konoha_academy_right")
    SpawnCreepsLane(konohaUnits, spawnCountMid, konohaMidLanePath, DOTA_TEAM_GOODGUYS, "konoha_base")
    SpawnCreepsLane(otoUnits, spawnCountSide, otoLeftLanePath, DOTA_TEAM_BADGUYS, "oto_academy_left")
    SpawnCreepsLane(otoUnits, spawnCountSide, otoRightLanePath, DOTA_TEAM_BADGUYS, "oto_academy_right")
    SpawnCreepsLane(otoUnits, spawnCountMid, otoMidLanePath, DOTA_TEAM_BADGUYS, "oto_base")
    SpawnCreepsLane(akatsukiUnits, spawnCountSide, akatsukiLeftLanePath, DOTA_TEAM_CUSTOM_1, "akatsuki_academy_left")
    SpawnCreepsLane(akatsukiUnits, spawnCountSide, akatsukiRightLanePath, DOTA_TEAM_CUSTOM_1, "akatsuki_academy_right")
    SpawnCreepsLane(akatsukiUnits, spawnCountMid, akatsukiMidLanePath, DOTA_TEAM_CUSTOM_1, "akatsuki_base")
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  local repeatInterval = 30    -- Return this timer every few seconds in game-time 
  local startAfter     = 0.05  -- Start this timer after few seconds 
  local count          = 0     -- Count how much spawn cycles were ran 
  DebugPrint("[BAREBONES] The game has officially begun")
  Timers:CreateTimer(startAfter, 
    function()
      SpawnCreeps(count)
      count = count + 1
      return repeatInterval 
    end)
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
  
  -- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end