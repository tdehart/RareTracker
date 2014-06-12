-----------------------------------------------------------------------------------------------
-- Client Lua Script for RareTracker
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Module Definition
-----------------------------------------------------------------------------------------------
local RareTracker = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local normalTextColor = ApolloColor.new("xkcdBrightSkyBlue")
local selectedTextColor = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
local activeTextColor = ApolloColor.new("xkcdAppleGreen")
local inactiveTextColor = ApolloColor.new("xkcdCherryRed")
local customUnitColor = ApolloColor.new("xkcdBloodOrange")

-----------------------------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------------------------
function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function table.find(val, list)
  for _,v in pairs(list) do
    if v == val then
      return true
    end
  end

  return false
end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function RareTracker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

	o.rareMobs = {}

  local strCancelLocale = Apollo.GetString(1);
    if strCancelLocale == "Cancel" then
      o.defaultRareNames = {"Nomjin", "Frostshard", "Prodigy", "Beastmaster Xix", "Iiksy", "Shadowfall", "Leatherface", "Stonepile", "Stanch", "Galegut", "Gnawer", "Deadbough", "Barebones", "Wormwood the Wraithmaker", "Wormwood Acolyte", "Ashwin the Stormcrested", "Claymore XT-9", "AG5 Blitzbuster", "Nym Maiden of Mercy", "Asteria", "Acacia", "Atethys", "Mikolai the Malevolent", "The Shadow Queen", "XL-51 Goliath", "Queen Bizzelt", "Captain Fripeti", "Groundswell Guardsman", "RG3 Blitzbuster", "Brigadier Bellza", "Black Besieger", "Exterminator Cryvex", "Veshra the Eye of the Storm", "Slopper", "Gravek the Swale-Striker", "Veldrok the Vindicator", "Moreg the Mauler", "Zersa the Betrothed", "Kalifa", "Cromlech the Kilnborn", "Suul of the Silva", "Meldrid the Decrepit", "Blisterbane", "Squall", "Flamesurge", "Flamebinder Sorvel", "Rumble", "Doctor Rotthrall", "Kryne the Tidebreaker", "Quin Quickdraw", "Andara the Seer", "Crog the Smasher", "ER-7 Explorer", "AX-12 Defender", "Torgal the Devastator", "Scabclaw", "Gorax the Putrid", "Old Scrappy", "Dreadbone", "Guardian Xeltos", "Guardian Zelkix", "Augemnted Ragemaster", "Flintrock", "Gorignak", "Granitefist", "Dreich", "Beelzebug", "Whitefang", "Detritus", "Lifegrazer", "The Pink Pumera", "The Queen", "Blinky", "Drifter", "The Lobotomizer", "Abyss", "Deadpaws", "Alpha Guard One", "Alpha Guard Two", "Strainblade", "Vorgrim", "The Vultch", "Deathgrazer", "Purple Peep Eater", "The Ravagist", "Amorphomorph", "King Grimrock", "Scrabbles", "Sgt. Garog", "Excargo", "Gorganoth Prime", "The Floater", "Weapon 24", "Ghostfin", "Torrent", "Whirlwind", "Dreadmorel", "Regulator 11", "Auxiliary Probe", "Sarod the Senseless", "Aeacus", "Silverhorn", "Voresk Venomgill", "The Terror of Bloodstone", "Zakan the Necroshaman", "Wrath of Niwha", "Felidax", "Terminus Rex", "Gavwyn the Verdant Defender", "Steel Jaw", "Arianna Wildgrass", "Arianna's Sentry", "Arianna's Assassin", "Subject: Rho", "The Endless Hunger", "Flamekin", "Nakaz the Deadlord", "Hotshot Braz", "Bloodtail", "Blightbeak", "Deathpaw", "Grudder", "Quiggles", "King Cruelclaw", "Queen Kizzek", "Grovekeeper Fellia", "Razorclaw", "Chief Blackheart", "Rondo", "Rondo's Squad", "XT-9 Alpha", "Crystalback", "Rashanna the Soul Drinker", "The Embermaster", "Rotfang", "Spellmaster Verwyn", "Subject V - Tempest", "Subject J - Fiend", "Subject K - Brute", "KE-27 Sentinel", "KE-28 Energizer", "Subject Tau", "Grinder", "Bugwit", "Icefang", "Frostbite", "Grellis the Blight Queen", "Torvex the Crystal Titan", "K9 Destroyer", "Stormshell", "FR2 Blitzer", "Permafrost", "Drud the Demented", "Frosty the Snowtail", "Skorga the Frigid", "Warlord Nagvox", "Shellshock", "AX-12 Defender", "Blubbergut", "Frozenclaw", "Stonegut", "Savageclaw", "Grug the Executioner", "Blightfang", "Basher Grogek", "FlameBinder Trovin", "Queen Tizzet"}
    elseif strCancelLocale == "Annuler" then
      o.defaultRareNames = {"Nomjin", "Éclat de givre", "Petit doigt", "Dompteur Xix", "Iiksy", "Ombrechute", "Tas de pierres", "Endigueur", "Souffletripe", "Rongeur", "Mortebranche", "Ossanu", "Verbois le Courrouceur", "Acolytes verbois", "Ashwin le Crêtetempête", "Claymore XT-9","AG5 Blitzbuster","Nym, vierge de la pitié","Asteria","Acacia","Atethys","Mikolai le malfaisant","La reine des ombres","Goliath XL-51","Reine Bizzbizze","Capitaine Fripeti","Garde du Tellurixe","Bombardeur RG3","Brigadier Bellza","Assiégeant noir","Exterminateur Cryvex","Veshra l'œil du cyclone","Renverseur","Gravek le Frappefosse","Veldrok le Vengeur","Moreg le Déchiqueteur","Zersa la Promise","Kalifa","Cromlech l'Enfourné","Meldrid la Décatie","Cloquepoil","Brise-bourrasque","Retour de flamme","Bave de Grondeur","Docteur Vilserf","Kryne le Brisemarée","Quin fine gâchette","Andara le Devin","Crog le Fracasseur","Explorateur ER-7","Défenseur AX-12","Torgal le Dévasteur","Corrugriffe","Gorax le Putride","Vieux tas de ferraille","Épouvantos","Gardien Xeltos","Gardien Zelkix","Silex","Gorignak","Poings de granit","Dreich","Bourdard","Croblanc","Détritus","Viverelle","L'Antre de la reine","Cligneur","Drifter","Le Lobotomiseur","Écran abyssal","Mortes-poignes","Garde Alpha 1","Garde Alpha 2","Souille-lame","Vorgrim","Le Vautour","Morterelle","Le Ravageur","Amorphomorphe","Roi Sinistroche","Scrabbles","Sergent Garog","Excargo","Primo Gorganoth","Le Flotteur","Arme 24","Spectraileron","Torrent - Reduced movement speed.","Tourbillon","Soucheflamme","Effroimorille","Régulateur11","Sonde auxiliaire","Sarod l'Insensé","Aeacus","Cornargent","Voresk Branchivenin","La Terreur de Rochesang","Zakan le Nécrochaman","Courroux du Niwha","Froc de Felidax","Terminus Rex","Gavwyn le Défenseur verdoyant","Mâchoire d'acier","Arianna Herbefolle","Sentinelle d'Arianna","Assassin d'Arianna","Sujets: Rho","La faim sans fin","Nakaz le Seigneur mort","Sanguifouet","Rouillebec","Donnemort","Grapace","Grouillis","Roi Lacérace","Reine Kizzek","Protectrice du bosquet Fellia","Acèregriffe","Chef de Noircœur","Rondo","Équipe de Rondo","Alpha XT-9","Crystalback Bull","Rashanna la Buveuse d'âmes","Le Maître des braises","Putrecroc","Maître des sorts Verwyn","SujetV: tempête","SujetJ: démon","SujetK: brute","SentinelleKE-27","Source d'énergieKE-28","Sujet: Tau","Monture Broyeur","Bugwit","Croc-de-glace","Morglace","Torvex le Titan de cristal","DestructeurK9","Coquetempête","Pilonneur FR2","Permafrost","Drud le Dément","Skorga le Glacé","Seigneur de guerre Nagvox","Griffegel","Commotionneur","Renverseur","Défenseur AX-12"}
    elseif strCancelLocale == "Abbrechen" then
      o.defaultRareNames = {"Der Schrecken von Blutstein", "Zakan der Nekroschamane", "Zorn von Niwha", "Felidax", "Terminus Rex", "Gavwyn der Grüne Verteidiger", "Stahlkiefer", "Arianna Wildgras", "Ariannas Wachposten", "Ariannas Assassinin", "Subject: Rho", "Der unstillbare Hunger", "Nakaz der Totenherr", "Teufelskerl Braz", "Geistflosse", "Strömung", "Wirbelwind", "Flammensippe", "Furchtmorchel", "Regulator11", "Hilfssonde", "Sarod der Sinnlose", "Aeacus", "Silberhorn", "Vorsek Giftkiemen", "Blutschwanz", "Faulschnabel", "Todespfote", "Grudder", "Quiggles", "König Grausamklaue", "Königin Kizzek", "Hainbeschützerin", "Scharfkralle", "Häuptlich Schwarzherz", "Rondo", "Rondos Trupp", "XT-9 Alpha", "Kristallrücken", "Rashanna die Seelentrinkerin", "Der Glutmeister", "Faulzahn", "Spruchmeister Verwyn", "Kalifa", "Cromlech der Brennofengeborene", "Seele der Silva", "Meldrid die Altersschwache", "Blasenfluch", "Böe", "Flammenwoge", "Flammenbinder Sorvel", "Rumpeln", "Doktor Faulsklave", "Kryne der Wellenbrecher", "Quin Flinkhand", "Andara die Seherin", "Crog der Schmetterer", "ER-7 Kundschafter", "AX-12 Verteidiger", "Schorfklaue", "Gorax der Faulige", "Torgal der Verwüster", "Alte Rumpelkiste", "Schreckensknochen", "Wächter Xeltos", "Wächter Zelkix", "Augmentierter Zornmeister", "Steingedärm", "Wildklaue", "Grug der Scharfrichter", "Faulzahn", "Spalter Grogek", "Flammenbinder Trovin", "Königin Tizzet", "Feuerstein", "Grignak", "Granitfaust", "Dreich", "Summuel", "Weißzahn", "Geröll", "Lebensgraser", "Blutmähne", "Die Königin", "Blinzli", "Gammler", "Der Lobotomisierer", "Abgrund", "Totenpfoten", "Alphawache Eins", "Alphawache Zwei", "Transmutationsklinge", "Vorgrimm", "Der Vultch", "Todgraser", "Endlosschlund", "SubjektV-Sturm", "SubjektJ-Scheusal", "SubjektK-Widerling", "SubjektV - Sturm", "SubjektJ - Scheusal", "SubjektK - Widerling", "Subjekt V-Sturm", "Subjekt J-Scheusal", "Subjekt K-Widerling", "Subjekt V - Sturm", "Subjekt J - Scheusal", "Subjekt K - Widerling", "Schleifer", "Kleinsinn", "Wache KE-27", "Auflader KE-28", "Subjekt: Tau"}
    else
      o.defaultRareNames = {}
    end

  table.sort(o.defaultRareNames)

	o.selectedRareWindow = nil

  return o
end

function RareTracker:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "RareTracker"
	local tDependencies = {
	}
    
  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

function RareTracker:OnLoad()
	self.xmlDoc = XmlDoc.CreateFromFile("RareTracker.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

function RareTracker:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
    self.mainWindow = Apollo.LoadForm(self.xmlDoc, "RareTrackerForm", nil, self)
    
	  if self.mainWindow == nil then
		  Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
		  return
	  end

  	self.trackedRaresWindow = self.mainWindow:FindChild("TrackedRaresList")
    self.mainWindow:Show(false, true)

  	Apollo.RegisterSlashCommand("raretracker", "OnRareTrackerOn", self)
    Apollo.RegisterSlashCommand("rt", "OnRareTrackerOn", self)
    Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
    Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
    Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)

    self.timer = ApolloTimer.Create(1/60, true, "OnTimer", self)
    self.rotationTimer = ApolloTimer.Create(1/5, true, "OnTimer", self)

    self:InitConfigOptions()
	end
end

function RareTracker:InitConfigOptions()
  if self.minLevel == nil then
    self.minLevel = 1
  end

  if self.maxTrackingDistance == nil then
    self.maxTrackingDistance = 1000
  end  

  if self.broadcastToParty == nil then
    self.broadcastToParty = true
  end

  if self.playSound == nil then
    self.playSound = true
  end

  if self.showIndicator == nil then
    self.showIndicator = true
  end

  if self.customNames == nil then
    self.customNames = {}
  end

  if self.rareNames == nil then
    self.rareNames = self.defaultRareNames
  end  
end

-----------------------------------------------------------------------------------------------
-- Carbine Event Callbacks
-----------------------------------------------------------------------------------------------
function RareTracker:OnSave(saveLevel)
  if saveLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
    return nil
  end

  local savedData = {}

  if (type(self.minLevel) == 'number') then
    savedData.minLevel = math.floor(self.minLevel)
  end

  if (type(self.maxTrackingDistance) == 'number') then
    savedData.maxTrackingDistance = math.floor(self.maxTrackingDistance)
  end

  savedData.broadcastToParty = self.broadcastToParty
  savedData.playSound = self.playSound
  savedData.showIndicator = self.showIndicator
  savedData.rareNames = self.rareNames
  savedData.customNames = self.customNames

  return savedData
end

function RareTracker:OnRestore(saveLevel, savedData)
  if (savedData.minLevel ~= nil) then
    self.minLevel = savedData.minLevel
  end

  if (savedData.maxTrackingDistance ~= nil) then
    self.maxTrackingDistance = savedData.maxTrackingDistance
  end  

  if (savedData.playSound ~= nil) then
    self.playSound = savedData.playSound
  end

  if (savedData.showIndicator ~= nil) then
    self.showIndicator = savedData.showIndicator
  end

  if (savedData.broadcastToParty ~= nil) then
    self.broadcastToParty = savedData.broadcastToParty
  end

  if (savedData.rareNames ~= nil) then
    self.rareNames = savedData.rareNames
  end  

  if (savedData.customNames ~= nil) then
    self.customNames = savedData.customNames
  end
end

function RareTracker:OnWindowManagementReady()
  Event_FireGenericEvent("WindowManagementAdd", {wnd = self.mainWindow, strName = "RareTracker"})
end

-----------------------------------------------------------------------------------------------
-- RareTracker Functions
-----------------------------------------------------------------------------------------------
function RareTracker:OnRareTrackerOn()
	self.mainWindow:Invoke()
end

function RareTracker:OnClose()
  self.mainWindow:Close()
end

function RareTracker:OnTimer()
  local trackObj, distance

  for idx,item in pairs(self.rareMobs) do
    if item.inactive or item.unit == nil then
      if self:GetDistance(item.position) > self.maxTrackingDistance then
        trackObj = nil
        self:RemoveTrackedRare(item.wnd)
      else
        trackObj = item.position
      end
      
    elseif item.unit:IsDead() then
      trackObj = nil
      self:RemoveTrackedRare(item.wnd)
    else --alive and active
      trackObj = item.unit
    end

    if trackObj ~= nil then
      distance = self:GetDistance(trackObj)
      item.wnd:FindChild("Distance"):SetText(string.format("%d", distance) .. " m")
    end
  end
end

function RareTracker:OnUnitCreated(unit)
  local disposition = unit:GetDispositionTo(GameLib.GetPlayerUnit())
  local unitName = trim(unit:GetName())

  -- Uncomment this to detect all elite mobs

  -- if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and unit:GetLevel() ~= nil and
  --    (disposition == Unit.CodeEnumDisposition.Hostile or disposition == Unit.CodeEnumDisposition.Neutral) and 
  --    (unit:GetDifficulty() >= 3 or unit:GetRank() >= 5) then
  --   local item = self.rareMobs[unit:GetName()]
  --   if not item then
  --     Event_FireGenericEvent("SendVarToRover", unit:GetName(), unit)
  --     self:AddTrackedRare(unit)
  --     self.mainWindow:Invoke()
  --     Print("Mob Found: " .. unit:GetName())
  --   elseif item.inactive == true then
  --     -- The mob was destroyed but has been found again
  --     self:ActivateUnit(item, unit)      
  --   end
  -- end

  -- Comment this block to disable checking against the rare list

  if unit:IsValid() and not unit:IsDead() and not unit:IsACharacter() and 
     (unit:GetLevel() ~= nil and unit:GetLevel() >= self.minLevel) and
     (disposition == Unit.CodeEnumDisposition.Hostile or disposition == Unit.CodeEnumDisposition.Neutral) and
     (table.find(unitName, self.rareNames) or table.find(unitName, self.customNames)) then
    local item = self.rareMobs[unit:GetName()]
    if not item then
      self:AddTrackedRare(unit)

      if self.playSound then
        Sound.Play(Sound.PlayUIExplorerScavengerHuntAdvanced)  
      end

      if self.broadcastToParty and GroupLib.InGroup() then
        -- no quick way to party chat, need to find the channel first
        for _,channel in pairs(ChatSystemLib.GetChannels()) do
          if channel:GetType() == ChatSystemLib.ChatChannel_Party then
            channel:Send("Rare detected: " .. unit:GetName())
          end
        end
      end
      
      self.mainWindow:Invoke()
    elseif item.inactive then
      -- The mob was destroyed but has been found again
      self:ActivateUnit(item, unit)
    end
  end
end

function RareTracker:OnUnitDestroyed(unit)
  local unit = self.rareMobs[unit:GetName()]
  if unit ~= nil then
    self:DeactivateUnit(unit)
  end
end

function RareTracker:AddTrackedRare(unit)
  local wnd = Apollo.LoadForm(self.xmlDoc, "TrackedRare", self.trackedRaresWindow, self)

  local name = unit:GetName()

  self.rareMobs[name] = {
    wnd = wnd,
    position = unit:GetPosition(),
    name = name
  }

  local itemText = wnd:FindChild("Name")
  local wndItemDistanceText = wnd:FindChild("Distance")

  if itemText then
    itemText:SetText(name) 
  end

  self.trackedRaresWindow:ArrangeChildrenVert()
  self:ActivateUnit(self.rareMobs[name], unit)
end

function RareTracker:RemoveTrackedRare(windowControl)
  local trackMaster = Apollo.GetAddon("TrackMaster")

  if windowControl == self.selectedRareWindow then
    self.selectedRareWindow = nil
  end

  self.rareMobs[windowControl:GetData().name] = nil
  windowControl:Destroy()

  if trackMaster ~= nil then
    trackMaster:SetTarget(nil, -1)
  end
    
  self.trackedRaresWindow:ArrangeChildrenVert()
end

function RareTracker:ActivateUnit(item, unit)
  local wnd = item.wnd

  item.unit = unit
  item.position = unit:GetPosition()
  item.inactive = false

  item.wnd:FindChild("Distance"):SetTextColor(activeTextColor)

  wnd:SetData(item)
end

function RareTracker:DeactivateUnit(item)
  local wnd = item.wnd

  item.unit = nil
  item.inactive = true

  -- if the selected unit is destroyed then deselect its list item if it's selected
  if item.wnd == self.selectedRareWindow then
    self.selectedRareWindow = nil
    item.wnd:FindChild("Name"):SetTextColor(normalTextColor)    
  end

  item.wnd:FindChild("Distance"):SetTextColor(inactiveTextColor)

  wnd:SetData(item)
end

function RareTracker:OnTrackedRareClick(windowHandler, windowControl, mouseButton)
  if windowHandler ~= windowControl then
    return
  end

  if mouseButton == GameLib.CodeEnumInputMouse.Left then
    local trackMaster = Apollo.GetAddon("TrackMaster")

    if trackMaster ~= nil then
      -- change the old item's text color back to normal color
      local itemText
      if self.selectedRareWindow ~= nil then
        itemText = self.selectedRareWindow:FindChild("Name")
        itemText:SetTextColor(normalTextColor)
      end

      -- set new selected item's text color
      self.selectedRareWindow = windowControl
      itemText = self.selectedRareWindow:FindChild("Name")
      itemText:SetTextColor(selectedTextColor)      
    end
    
    local unit = windowControl:GetData().unit
    local trackObj

    -- either track the unit or its original position
    if unit ~= nil then
      trackObj = unit

      if self.showIndicator then
        unit:ShowHintArrow()
      end
    else
      local pos = windowControl:GetData().position
      trackObj = Vector3.New(pos.x, pos.y, pos.z)
    end

    if trackMaster ~= nil then
      trackMaster:SetTarget(trackObj, -1)
    end
  elseif mouseButton == GameLib.CodeEnumInputMouse.Right then
    self:RemoveTrackedRare(windowControl)
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

-----------------------------------------------------------------------------------------------
-- Config Menu Functions
-----------------------------------------------------------------------------------------------
function RareTracker:OnConfigure()
  if self.configWindow ~= nil then
    self.configWindow:Destroy()
    self.configWindow = nil
  else
    self.configWindow = Apollo.LoadForm(self.xmlDoc, "ConfigForm", nil, self)
    self.configRaresList = self.configWindow:FindChild("RareListContainer:RareList")

    self:AddAllUnits()

    self.configWindow:FindChild("BroadcastContainer:RadioButton"):SetCheck(self.broadcastToParty)
    self.configWindow:FindChild("PlaySoundContainer:RadioButton"):SetCheck(self.playSound)
    self.configWindow:FindChild("ShowHintArrowContainer:RadioButton"):SetCheck(self.showIndicator)
    self.configWindow:FindChild("MinLevelContainer:DaysContainer:minLevelInput"):SetText(self.minLevel)
    self.configWindow:FindChild("MaxTrackingDistanceContainer:DistanceContainer:maxDistanceInput"):SetText(self.maxTrackingDistance)
  end
end

function RareTracker:AddAllUnits()
  for _,item in pairs(self.rareNames) do
    self:AddConfigRareItem(item, false)
  end

  for _,item in pairs(self.customNames) do
    self:AddConfigRareItem(item, true)
  end
end

function RareTracker:AddConfigRareItem(item, isCustom)
  local wnd = Apollo.LoadForm(self.xmlDoc, "ConfigListItem", self.configRaresList, self)
  wnd:FindChild("Name"):SetText(item)
  if isCustom then
    wnd:FindChild("Name"):SetTextColor(customUnitColor)
    wnd:SetData({isCustom = isCustom})
  else
    wnd:SetData({isCustom = isCustom})
  end

  self.configRaresList:ArrangeChildrenVert()
end

function RareTracker:OnAddUnit()
  local inputWindow = self.configWindow:FindChild("RareListContainer:InputContainer:UnitInput")
  local unitName = inputWindow:GetText()
  if unitName ~= "Enter unit name..." then
    self:AddConfigRareItem(unitName, true)
    table.insert(self.customNames, trim(unitName))
    inputWindow:SetText("Enter unit name...")
    self.configRaresList:SetVScrollPos(self.configRaresList:GetVScrollRange())
  end
  
end

function RareTracker:OnDeleteUnit(windowHandler, windowControl)
  local listItem = windowHandler:GetParent()
  local isCustom = listItem:GetData().isCustom
  local name = listItem:FindChild("Name"):GetText()
  local unitList

  if isCustom then
    unitList = self.customNames
  else
    unitList = self.rareNames
  end

  for idx,item in pairs(unitList) do
    if item == name then
      table.remove(unitList, idx)
      listItem:Destroy()
      self.configRaresList:ArrangeChildrenVert()
      break
    end
  end
end

function RareTracker:OnResetButton()
  self.rareNames = table.shallow_copy(self.defaultRareNames)
  self.configRaresList:DestroyChildren()

  self:AddAllUnits()
  self.configRaresList:SetVScrollPos(0)
end

function RareTracker:OnBroadcastCheck(windowHandler, windowControl)
  self.broadcastToParty = true
end

function RareTracker:OnBroadcastUncheck(windowHandler, windowControl)
  self.broadcastToParty = false
end

function RareTracker:OnPlaySoundCheck(windowHandler, windowControl)
  self.playSound = true
end

function RareTracker:OnPlaySoundUncheck(windowHandler, windowControl)
  self.playSound = false
end

function RareTracker:OnShowIndicatorCheck(windowHandler, windowControl)
  self.showIndicator = true
end

function RareTracker:OnShowIndicatorUncheck(windowHandler, windowControl)
  self.showIndicator = false
end

function RareTracker:OnMinLevelChange(windowHandler, windowControl, strText)
  local minLevel = tonumber(strText)
  if minLevel ~= nil then
    self.minLevel = math.floor(minLevel)
  else
    self.minLevel = 1
  end
end

function RareTracker:OnMaxDistanceChange(windowHandler, windowControl, strText)
  local maxDistance = tonumber(strText)
  if maxDistance ~= nil then
    self.maxTrackingDistance = math.floor(maxDistance)
  else
    self.maxTrackingDistance = 1000
  end
end

function RareTracker:OnOptionsClose()
  self.configWindow:Close()
end

-----------------------------------------------------------------------------------------------
-- RareTracker Instance
-----------------------------------------------------------------------------------------------
local RareTrackerInst = RareTracker:new()
RareTrackerInst:Init()
