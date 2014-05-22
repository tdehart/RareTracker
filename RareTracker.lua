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
local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")

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
  o.rareNames = {"Nomjin", "Frostshard", "Prodigy", "Beastmaster Xix", "Iiksy", "Shadowfall", "Leatherface", "Stonepile", "Stanch", "Galegut", "Gnawer", "Deadbough", "Barebones", "Wormwood the Wraithmaker", "Wormwood Acolyte", "Ashwin the Stormcrested", "Claymore XT-9", "AG5 Blitzbuster", "Nym Maiden of Mercy", "Asteria", "Acacia", "Atethys", "Mikolai the Malevolent", "The Shadow Queen", "XL-51 Goliath", "Queen Bizzelt", "Captain Fripeti", "Groundswell Guardsman", "RG3 Blitzbuster", "Brigadier Bellza", "Black Besieger", "Exterminator Cryvex", "Veshra the Eye of the Storm", "Slopper", "Gravek the Swale-Striker", "Veldrok the Vindicator", "Moreg the Mauler", "Zersa the Betrothed", "Kalifa", "Cromlech the Kilnborn", "Suul of the Silva", "Meldrid the Decrepit", "Blisterbane", "Squall", "Flamesurge", "Flamebinder Sorvel", "Rumble", "Doctor Rotthrall", "Kryne the Tidebreaker", "Quin Quickdraw", "Andara the Seer", "Crog the Smasher", "ER-7 Explorer", "AX-12 Defender", "Torgal the Devastator", "Scabclaw", "Gorax the Putrid", "Old Scrappy", "Dreadbone", "Guardian Xeltos", "Guardian Zelkix", "Augemnted Ragemaster", "Flintrock", "Gorignak", "Granitefist", "Dreich", "Beelzebug", "Whitefang", "Detritus", "Lifegrazer", "The Pink Pumera", "The Queen", "Blinky", "Drifter", "The Lobotomizer", "Abyss", "Deadpaws", "Alpha Guard One", "Alpha Guard Two", "Strainblade", "Vorgrim", "The Vultch", "Deathgrazer", "Purple Peep Eater", "The Ravagist", "Amorphomorph", "King Grimrock", "Scrabbles", "Sgt. Garog", "Excargo", "Gorganoth Prime", "The Floater", "Weapon 24", "Ghostfin", "Torrent", "Whirlwind", "Flamekin", "Dreadmorel", "Regulator 11", "Auxiliary Probe", "Sarod the Senseless", "Aeacus", "Silverhorn", "Voresk Venomgill", "The Terror of Bloodstone", "Zakan the Necroshaman", "Wrath of Niwha", "Felidax", "Terminus Rex", "Gavwyn the Verdant Defender", "Steel Jaw", "Arianna Wildgrass", "Arianna's Sentry", "Arianna's Assassin", "Subject: Rho", "The Endless Hunger", "Nakaz the Deadlord", "Hotshot Braz", "Bloodtail", "Blightbeak", "Deathpaw", "Grudder", "Quiggles", "King Cruelclaw", "Queen Kizzek", "Grovekeeper Fellia", "Razorclaw", "Chief Blackheart", "Rondo", "Rondo's Squad", "XT-9 Alpha", "Crystalback", "Rashanna the Soul Drinker", "The Embermaster", "Rotfang", "Spellmaster Verwyn", "Subject V - Tempest", "Subject J - Fiend", "Subject K - Brute", "KE-27 Sentinel", "KE-28 Energizer", "Subject Tau", "Grinder", "Bugwit", "Icefang", "Frostbite", "Grellis the Blight Queen", "Torvex the Crystal Titan", "K9 Destroyer", "Stormshell", "FR2 Blitzer", "Permafrost", "Drud the Demented", "Frosty the Snowtail", "Skorga the Frigid", "Warlord Nagvox"}
	o.wndSelectedListItem = nil -- keep track of which list item is currently selected

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
    self.wndMain = Apollo.LoadForm(self.xmlDoc, "RareTrackerForm", nil, self)

	  if self.wndMain == nil then
		  Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
		  return
	  end
		
  	self.wndItemList = self.wndMain:FindChild("ItemList")
    self.wndMain:Show(false, true)

  	Apollo.RegisterSlashCommand("raretracker", "OnRareTrackerOn", self)
    Apollo.RegisterSlashCommand("rt", "OnRareTrackerOn", self)
    Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
    Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
	end
end

-----------------------------------------------------------------------------------------------
-- RareTracker Functions
-----------------------------------------------------------------------------------------------
function RareTracker:OnRareTrackerOn()
	self.wndMain:Invoke()
end

function RareTracker:OnUnitCreated(unit)
  -- Uncomment this to detect all elite mobs

  -- if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and unit:GetLevel() ~= nil and
  --    unit:GetDispositionTo(GameLib.GetPlayerUnit()) == Unit.CodeEnumDisposition.Hostile and 
  --    (unit:GetDifficulty() >= 3 or unit:GetRank() >= 5) then
  --   local item = self.rareMobs[unit:GetName()]
  --   if not item then
  --     Event_FireGenericEvent("SendVarToRover", unit:GetName(), unit)
  --     self:AddItem(unit)
  --     self.wndMain:Invoke()
  --     Print("Mob Found: " .. unit:GetName())
  --   end
  -- end

  if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and unit:GetLevel() ~= nil and
     unit:GetDispositionTo(GameLib.GetPlayerUnit()) == Unit.CodeEnumDisposition.Hostile and
     find(trim(unit:GetName()), self.rareNames) then
    local item = self.rareMobs[unit:GetName()]
    if not item then
      -- Event_FireGenericEvent("SendVarToRover", unit:GetName(), unit)
      Print("Rare Found: " .. unit:GetName())
      Sound.Play(Sound.PlayUIExplorerScavengerHuntAdvanced)
      self:AddItem(unit)
      self.wndMain:Invoke()
    elseif item.disabled == true then
      -- The mob was destroyed but has been found again
      self:EnableItem(item, unit)
    end
  end
end

function RareTracker:OnUnitDestroyed(unit)
  local unit = self.rareMobs[unit:GetName()]
  if unit ~= nil then
    self:DisableItem(unit)
  end
end

-----------------------------------------------------------------------------------------------
-- RareTrackerForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function RareTracker:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function RareTracker:OnCancel()
	self.wndMain:Close() -- hide the window
end

-- clear the item list
function RareTracker:ClearList()
	-- destroy all the wnd inside the list
	for idx,item in pairs(self.rareMobs) do
		item.wnd:Destroy()
	end

	-- clear the list item array
	self.rareMobs = {}
	self.wndSelectedListItem = nil
end

function RareTracker:AddItem(item)
  -- load the window item for the list item
  local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndItemList, self)
  -- keep track of the window item created
  self.rareMobs[item:GetName()] = {}

  local i = self.rareMobs[item:GetName()]
  i.unit = item
  i.wnd = wnd

  -- give it a piece of data to refer to 
  local wndItemText = wnd:FindChild("Text")

  if wndItemText then -- make sure the text wnd exist
    local target = item:GetPosition()
    local posString = string.format("(%d, %d, %d)", math.floor(target.x, 0.5), math.floor(target.y, 0.5), math.floor(target.z, 0.5))
    wndItemText:SetText(item:GetName() .. " " .. posString) 
    wndItemText:SetTextColor(kcrNormalText)
  end

  wnd:SetData(item)
  self.wndItemList:ArrangeChildrenVert()
end


function RareTracker:EnableItem(item, unit)
  local wnd = item.wnd
  item.unit = unit
  item.disabled = false
  wnd:SetData(unit)
  wnd:FindChild("Text"):SetTextColor(kcrNormalText)
end

function RareTracker:DisableItem(item)
  local wnd = item.wnd
  item.unit = nil
  item.disabled = true
  wnd:SetData(nil)
  if wnd == self.wndSelectedListItem then
    self.wndSelectedListItem = nil
  end
  wnd:FindChild("Text"):SetTextColor(ApolloColor.new("red"))
end

function RareTracker:OnListItemSelected(wndHandler, wndControl)
  if wndHandler ~= wndControl then
    return
  end

  local unit = wndControl:GetData()

  -- If GetData() is nil then don't allow selection
  if unit ~= nil then
    -- change the old item's text color back to normal color
    local wndItemText
    if self.wndSelectedListItem ~= nil then
      wndItemText = self.wndSelectedListItem:FindChild("Text")
      wndItemText:SetTextColor(kcrNormalText)
    end  

    self.wndSelectedListItem = wndControl
    wndItemText = self.wndSelectedListItem:FindChild("Text")
    wndItemText:SetTextColor(kcrSelectedText)

    local trackMaster = Apollo.GetAddon("TrackMaster")

    if trackMaster ~= nil then
      trackMaster:SetTarget(unit, -1)
    end
    if unit:IsDead() or not unit:IsValid() then
      Print("Unit is dead or not valid")
    end
  else
    Print("Unit was destroyed and is no longer trackable")
  end
end

-----------------------------------------------------------------------------------------------
-- RareTracker Instance
-----------------------------------------------------------------------------------------------
local RareTrackerInst = RareTracker:new()
RareTrackerInst:Init()
