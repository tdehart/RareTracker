-----------------------------------------------------------------------------------------------
-- Client Lua Script for RareTracker
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- RareTracker Module Definition
-----------------------------------------------------------------------------------------------
local RareTracker = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local normalTextColor = ApolloColor.new("xkcdBrightSkyBlue")
local selectedTextColor = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local activeTextColor = ApolloColor.new("xkcdAppleGreen")
local inactiveTextColor = ApolloColor.new("xkcdCherryRed")

-----------------------------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------------------------
function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function find(val, list)
  for _,v in pairs(list) do
    if v == val then
      return true
    end
  end

  return false
end
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function RareTracker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

	o.rareMobs = {}
  o.rareNames = {"Nomjin", "Frostshard", "Prodigy", "Beastmaster Xix", "Iiksy", "Shadowfall", "Leatherface", "Stonepile", "Stanch", "Galegut", "Gnawer", "Deadbough", "Barebones", "Wormwood the Wraithmaker", "Wormwood Acolyte", "Ashwin the Stormcrested", "Claymore XT-9", "AG5 Blitzbuster", "Nym Maiden of Mercy", "Asteria", "Acacia", "Atethys", "Mikolai the Malevolent", "The Shadow Queen", "XL-51 Goliath", "Queen Bizzelt", "Captain Fripeti", "Groundswell Guardsman", "RG3 Blitzbuster", "Brigadier Bellza", "Black Besieger", "Exterminator Cryvex", "Veshra the Eye of the Storm", "Slopper", "Gravek the Swale-Striker", "Veldrok the Vindicator", "Moreg the Mauler", "Zersa the Betrothed", "Kalifa", "Cromlech the Kilnborn", "Suul of the Silva", "Meldrid the Decrepit", "Blisterbane", "Squall", "Flamesurge", "Flamebinder Sorvel", "Rumble", "Doctor Rotthrall", "Kryne the Tidebreaker", "Quin Quickdraw", "Andara the Seer", "Crog the Smasher", "ER-7 Explorer", "AX-12 Defender", "Torgal the Devastator", "Scabclaw", "Gorax the Putrid", "Old Scrappy", "Dreadbone", "Guardian Xeltos", "Guardian Zelkix", "Augemnted Ragemaster", "Flintrock", "Gorignak", "Granitefist", "Dreich", "Beelzebug", "Whitefang", "Detritus", "Lifegrazer", "The Pink Pumera", "The Queen", "Blinky", "Drifter", "The Lobotomizer", "Abyss", "Deadpaws", "Alpha Guard One", "Alpha Guard Two", "Strainblade", "Vorgrim", "The Vultch", "Deathgrazer", "Purple Peep Eater", "The Ravagist", "Amorphomorph", "King Grimrock", "Scrabbles", "Sgt. Garog", "Excargo", "Gorganoth Prime", "The Floater", "Weapon 24", "Ghostfin", "Torrent", "Whirlwind", "Flamekin", "Dreadmorel", "Regulator 11", "Auxiliary Probe", "Sarod the Senseless", "Aeacus", "Silverhorn", "Voresk Venomgill", "The Terror of Bloodstone", "Zakan the Necroshaman", "Wrath of Niwha", "Felidax", "Terminus Rex", "Gavwyn the Verdant Defender", "Steel Jaw", "Arianna Wildgrass", "Arianna's Sentry", "Arianna's Assassin", "Subject: Rho", "The Endless Hunger", "Nakaz the Deadlord", "Hotshot Braz", "Bloodtail", "Blightbeak", "Deathpaw", "Grudder", "Quiggles", "King Cruelclaw", "Queen Kizzek", "Grovekeeper Fellia", "Razorclaw", "Chief Blackheart", "Rondo", "Rondo's Squad", "XT-9 Alpha", "Crystalback", "Rashanna the Soul Drinker", "The Embermaster", "Rotfang", "Spellmaster Verwyn", "Subject V - Tempest", "Subject J - Fiend", "Subject K - Brute", "KE-27 Sentinel", "KE-28 Energizer", "Subject Tau", "Grinder", "Bugwit", "Icefang", "Frostbite", "Grellis the Blight Queen", "Torvex the Crystal Titan", "K9 Destroyer", "Stormshell", "FR2 Blitzer", "Permafrost", "Drud the Demented", "Frosty the Snowtail", "Skorga the Frigid", "Warlord Nagvox", "Frozenclaw", "Shellshock", "Slopper", "AX-12 Defender"}
	o.selectedListItemWindow = nil -- keep track of which list item is currently selected

  return o
end

function RareTracker:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
	}
    
  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- RareTracker OnLoad
-----------------------------------------------------------------------------------------------
function RareTracker:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("RareTracker.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- RareTracker OnDocLoaded
-----------------------------------------------------------------------------------------------
function RareTracker:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
    self.mainWindow = Apollo.LoadForm(self.xmlDoc, "RareTrackerForm", nil, self)
    
	  if self.mainWindow == nil then
		  Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
		  return
	  end

  	self.itemListWindow = self.mainWindow:FindChild("ItemList")
    self.mainWindow:Show(false, true)

  	Apollo.RegisterSlashCommand("raretracker", "OnRareTrackerOn", self)
    Apollo.RegisterSlashCommand("rt", "OnRareTrackerOn", self)
    Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
    Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
    Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)

    self.timer = ApolloTimer.Create(1/60, true, "OnTimer", self)
    self.rotationTimer = ApolloTimer.Create(1/5, true, "OnTimer", self)
	end
end

-----------------------------------------------------------------------------------------------
-- RareTracker Functions
-----------------------------------------------------------------------------------------------
function RareTracker:OnRareTrackerOn()
	self.mainWindow:Invoke()
end

function RareTracker:OnUnitCreated(unit)
  local disposition = unit:GetDispositionTo(GameLib.GetPlayerUnit())

  -- Uncomment this to detect all elite mobs

  -- if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and unit:GetLevel() ~= nil and
  --    (disposition == Unit.CodeEnumDisposition.Hostile or disposition == Unit.CodeEnumDisposition.Neutral) and 
  --    (unit:GetDifficulty() >= 3 or unit:GetRank() >= 5) then
  --   local item = self.rareMobs[unit:GetName()]
  --   if not item then
  --     Event_FireGenericEvent("SendVarToRover", unit:GetName(), unit)
  --     self:AddItem(unit)
  --     self.mainWindow:Invoke()
  --     Print("Mob Found: " .. unit:GetName())
  --   elseif item.inactive == true then
  --     -- The mob was destroyed but has been found again
  --     self:EnableUnit(item, unit)      
  --   end
  -- end

  -- Comment this block to disable checking against the rare list

  if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and unit:GetLevel() ~= nil and
     (disposition == Unit.CodeEnumDisposition.Hostile or disposition == Unit.CodeEnumDisposition.Neutral) and
     find(trim(unit:GetName()), self.rareNames) then
    local item = self.rareMobs[unit:GetName()]
    if not item then
      -- Event_FireGenericEvent("SendVarToRover", unit:GetName(), unit)
      Sound.Play(Sound.PlayUIExplorerScavengerHuntAdvanced)
      self:AddItem(unit)
      self.mainWindow:Invoke()
    elseif item.inactive then
      -- The mob was destroyed but has been found again
      self:EnableUnit(item, unit)
    end
  end
end

function RareTracker:OnUnitDestroyed(unit)
  local unit = self.rareMobs[unit:GetName()]
  if unit ~= nil then
    self:DisableUnit(unit)
  end
end

function RareTracker:OnTimer()
  local trackObj, distance

  for idx,item in pairs(self.rareMobs) do
    if item.inactive or item.unit == nil then
      trackObj = item.position
    else
      trackObj = item.unit
    end

    if trackObj ~= nil then
      distance = self:GetDistance(trackObj)
      item.wnd:FindChild("Distance"):SetText(string.format("%d", distance) .. " m")
    end
    
  end
end

-- credit to Caedo for this function, taken from his TrackMaster addon
function RareTracker:GetDistance(target)
  if GameLib.GetPlayerUnit() ~= nil then
    local playerPos = GameLib.GetPlayerUnit():GetPosition()
    local playerVec = Vector3.New(playerPos.x, playerPos.y, playerPos.z)
    if Vector3.Is(target) then
      return (playerVec - target):Length()
    elseif Unit.is(target) then
      local targetPos = target:GetPosition()
      if targetPos == nil then
        return 0
      end
      local targetVec = Vector3.New(targetPos.x, targetPos.y, targetPos.z)
      return (playerVec - targetVec):Length()
    else
      local targetVec = Vector3.New(target.x, target.y, target.z)
      return (playerVec - targetVec):Length()
    end
  else
    return 0
  end
end

function RareTracker:OnWindowManagementReady()
  Event_FireGenericEvent("WindowManagementAdd", {wnd = self.mainWindow, strName = "RareTracker"})
end

-----------------------------------------------------------------------------------------------
-- RareTrackerForm Functions
-----------------------------------------------------------------------------------------------
function RareTracker:OnClose()
	self.mainWindow:Close()
end

function RareTracker:ClearList()
	for idx,item in pairs(self.rareMobs) do
		item.wnd:Destroy()
	end

	self.rareMobs = {}
	self.selectedListItemWindow = nil
end

function RareTracker:AddItem(unit)
  -- Make a new list item window
  local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.itemListWindow, self)

  local name = unit:GetName()

  self.rareMobs[name] = {
    wnd = wnd,
    position = unit:GetPosition(),
    name = name
  }

  local wndItemText = wnd:FindChild("Name")
  local wndItemDistanceText = wnd:FindChild("Distance")

  if wndItemText then
    wndItemText:SetText(name) 
  end

  self.itemListWindow:ArrangeChildrenVert()
  self:EnableUnit(self.rareMobs[name], unit)
end


function RareTracker:EnableUnit(item, unit)
  local wnd = item.wnd

  item.unit = unit
  item.position = unit:GetPosition()
  item.inactive = false

  item.wnd:FindChild("Distance"):SetTextColor(activeTextColor)

  wnd:SetData(item)
end

function RareTracker:DisableUnit(item)
  local wnd = item.wnd

  item.unit = nil
  item.inactive = true

  -- if the selected unit is destroyed then deselect its list item if it's selected
  if item.wnd == self.selectedListItemWindow then
    self.selectedListItemWindow = nil
    item.wnd:FindChild("Name"):SetTextColor(normalTextColor)    
  end

  item.wnd:FindChild("Distance"):SetTextColor(inactiveTextColor)

  wnd:SetData(item)
end

function RareTracker:OnListItemClick(wndHandler, wndControl, mouseButton)
  if wndHandler ~= wndControl then
    return
  end

  local trackMaster = Apollo.GetAddon("TrackMaster")

  if mouseButton == GameLib.CodeEnumInputMouse.Left then
    if trackMaster ~= nil then
      -- change the old item's text color back to normal color
      local wndItemText
      if self.selectedListItemWindow ~= nil then
        wndItemText = self.selectedListItemWindow:FindChild("Name")
        wndItemText:SetTextColor(normalTextColor)
      end

      -- set new selected item's text color
      self.selectedListItemWindow = wndControl
      wndItemText = self.selectedListItemWindow:FindChild("Name")
      wndItemText:SetTextColor(selectedTextColor)      
    end
    
    local unit = wndControl:GetData().unit
    local trackObj

    -- either track the unit or its original position
    if unit ~= nil then
      unit:ShowHintArrow()
      trackObj = unit
    else
      local pos = wndControl:GetData().position
      trackObj = Vector3.New(pos.x, pos.y, pos.z)
    end

    if trackMaster ~= nil then
      trackMaster:SetTarget(trackObj, -1)
    end
  elseif mouseButton == GameLib.CodeEnumInputMouse.Right then
    if wndControl == self.selectedListItemWindow then
      self.selectedListItemWindow = nil
    end

    self.rareMobs[wndControl:GetData().name] = nil
    wndControl:Destroy()
    trackMaster:SetTarget(nil, -1)
    
    self.itemListWindow:ArrangeChildrenVert()
  end

  
end

-----------------------------------------------------------------------------------------------
-- RareTracker Instance
-----------------------------------------------------------------------------------------------
local RareTrackerInst = RareTracker:new()
RareTrackerInst:Init()
