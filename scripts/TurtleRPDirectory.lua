--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

function TurtleRP.OpenDirectory()
  UIPanelWindows["TurtleRP_DirectoryFrame"] = { area = "left", pushable = 0 }
  ShowUIPanel(TurtleRP_DirectoryFrame)
  TurtleRP.updateDirectorySearch()
  TurtleRP.Directory_ScrollBar_Update()
end

function TurtleRP.SetDirectoryButtonsActive(enable)
  if enable then
    TurtleRP_DirectoryFrame_Directory_DeleteButton:Enable()
  else
    TurtleRP_DirectoryFrame_Directory_DeleteButton:Disable()
  end
end
function sort_users_by_key(user1, user2, sort_key, sort_by_order)
    local online1 = (user1.status == "Online") and 1 or 0
    local online2 = (user2.status == "Online") and 1 or 0
    if online1 ~= online2 then
        return online1 > online2
    end
		local rawValue1 = user1[sort_key]
		local rawValue2 = user2[sort_key]
			if type(rawValue1) ~= "string" then rawValue1 = "" end
			if type(rawValue2) ~= "string" then rawValue2 = "" end
		local value1 = string.lower(rawValue1)
		local value2 = string.lower(rawValue2)
    if value1 ~= value2 then
        if sort_by_order == 1 then
            return value1 > value2
        else
            return value1 < value2
        end
    end
    local name1 = string.lower(user1.player_name or "")
    local name2 = string.lower(user2.player_name or "")
    if sort_by_order == 1 then
        return name1 > name2
    end
    return name1 < name2
end
----
-- Map Directory Display
----
function TurtleRP.display_nearby_players()

  local zoneListener = CreateFrame("Frame", "TurtleRPZoneListener")
  zoneListener:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  zoneListener:RegisterEvent("WORLD_MAP_UPDATE")
  zoneListener:SetScript("OnEvent", function()
    for i, frame in TurtleRP.locationFrames do
      frame:Hide()
    end
    TurtleRP.show_player_locations()
  end)
end

function TurtleRP.show_player_locations()
  if not WorldMapFrame:IsVisible() then
    return
  end
  local locationFrames = TurtleRP.locationFrames
  for _, frame in ipairs(locationFrames) do
    frame:Hide()
  end
  local onlinePlayers = TurtleRP.get_players_online()
  local frameCount = 1
  local zonesByID = TurtleRP.GetZones(GetCurrentMapContinent())
  local currentZone = GetCurrentMapZone()
  local selfName = UnitName("player")
  for charName, character in pairs(onlinePlayers) do
    if charName ~= selfName then
      local zone = character["zone"]
      local zoneX = tonumber(character["zoneX"])
      local zoneY = tonumber(character["zoneY"])
      if zone == zonesByID[currentZone] and zoneX and zoneY then
        local playerPositionFrame = locationFrames[frameCount]
        if playerPositionFrame == nil then
          playerPositionFrame = CreateFrame("Frame", "TurtleRP_MapPlayerPosition_" .. frameCount, WorldMapDetailFrame, "TurtleRP_WorldMapUnitTemplate")
          locationFrames[frameCount] = playerPositionFrame
        end
        local mapWidth = WorldMapDetailFrame:GetWidth()
        local mapHeight = WorldMapDetailFrame:GetHeight()
        playerPositionFrame.full_name = charName
        if character["full_name"] ~= nil and character["full_name"] ~= "" then
          playerPositionFrame.full_name = character["full_name"]
        end
        playerPositionFrame:ClearAllPoints()
        playerPositionFrame:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", zoneX * mapWidth, zoneY * mapHeight * -1)
        local icon = getglobal(playerPositionFrame:GetName() .. "Icon")
        if icon then
          if character["currently_ic"] == "1" then
            icon:SetTexture("Interface\\Addons\\TurtleRP\\images\\WorldMapPlayerIconIC")
          else
            icon:SetTexture("Interface\\Addons\\TurtleRP\\images\\WorldMapPlayerIconTRP")
          end
        end
        playerPositionFrame:Show()
        frameCount = frameCount + 1
      end
    end
  end
end

----
-- Directory Scroll Manager
----
TurtleRP.DirectorySearchResults = nil

function TurtleRP.updateDirectorySearch()
    local totalDirectoryChars = 0
    local totalDirectoryOnline = 0
    local searchResults = {}
    local currentArrayNumber = 1
    local showNSFW = TurtleRPSettings["show_nsfw"] == "1"
    local currentTime = time()
    local lowerSearch = string.lower(TurtleRP.searchTerm or "")
    for playerName, profile in pairs(TurtleRPCharacters) do
        if profile and (showNSFW or profile["nsfw"] == "0" or profile["nsfw"] == "" or profile["nsfw"] == nil) then
            totalDirectoryChars = totalDirectoryChars + 1
            local isOnline = false
            if type(TurtleRPQueryablePlayers[playerName]) == "number" and TurtleRPQueryablePlayers[playerName] > (currentTime - 65) then
                totalDirectoryOnline = totalDirectoryOnline + 1
                isOnline = true
            end
            local fullName = profile["full_name"] or ""
				local title = profile["title"] or ""
				local zone = profile["zone"] or ""
				local shortNote = ""
				if TurtleRPCharacterInfo["character_short_notes"]
				and type(TurtleRPCharacterInfo["character_short_notes"][playerName]) == "string" then
					shortNote = TurtleRPCharacterInfo["character_short_notes"][playerName]
				end
				local playerNameLower = string.lower(playerName or "")
            local playerNameLower = string.lower(playerName or "")
            local resultShown = true
            if lowerSearch ~= "" then
                local fullNameLower = string.lower(fullName)
                local titleLower = string.lower(title)
                local zoneLower = string.lower(zone)
                local shortNoteLower = string.lower(shortNote)

                local playerMatch = string.find(playerNameLower, lowerSearch, 1, true)
                local nameMatch = string.find(fullNameLower, lowerSearch, 1, true)
                local titleMatch = string.find(titleLower, lowerSearch, 1, true)
                local zoneMatch = string.find(zoneLower, lowerSearch, 1, true)
                local shortNoteMatch = string.find(shortNoteLower, lowerSearch, 1, true)

                if not (playerMatch or nameMatch or titleMatch or zoneMatch or shortNoteMatch) then
                    resultShown = false
                end
            end
            if resultShown then
                searchResults[currentArrayNumber] = {
                    player_name = playerName,
                    full_name = fullName,
                    character_short_notes = shortNote,
                    title = title,
                    zone = zone,
                    status = isOnline and "Online" or "Offline",
                    profile = profile,
                }
                currentArrayNumber = currentArrayNumber + 1
            end
        end
    end

    if TurtleRP.sortByKey ~= nil and table.getn(searchResults) > 1 then
        table.sort(searchResults, function(a, b)
            return sort_users_by_key(a, b, TurtleRP.sortByKey, TurtleRP.sortByOrder)
        end)
    end
    TurtleRP.DirectorySearchResults = searchResults
    TurtleRP_DirectoryFrame_Directory_Total:SetText(
        totalDirectoryChars .. " adventurers found (" .. totalDirectoryOnline .. " online)"
    )
end
function TurtleRP.TrySearchUnknownPlayer()
    local search = string.lower(TurtleRP.searchTerm or "")
    if search == "" then
        return
    end
    local queued = 0
    for playerName, _ in pairs(TurtleRP.rpSeenSpeakers or {}) do
        local playerNameLower = string.lower(playerName or "")
        if string.find(playerNameLower, search, 1, true) then
            TurtleRP.QueueDirectorySearchRequest(playerName)
            queued = queued + 1
        end
        if queued >= 5 then
            break
        end
    end
end
function TurtleRP.Directory_ScrollBar_Update()
  FauxScrollFrame_Update(TurtleRP_DirectoryFrame_Directory_ScrollFrame, table.getn(TurtleRP.DirectorySearchResults), 17, 16)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_DirectoryFrame_Directory_ScrollFrame)
  TurtleRP.renderDirectory(currentLine)
end

function TurtleRP.renderDirectory(directoryOffset)
  local searchResults = TurtleRP.DirectorySearchResults
  local currentFrameNumber = 1
  if directoryOffset == 0 then
    directoryOffset = directoryOffset + 1
  end
  for i = directoryOffset, directoryOffset + 16 do
    local thisFrameName = "TurtleRP_DirectoryFrame_Directory_Button" .. currentFrameNumber
    getglobal(thisFrameName):Hide()
    if searchResults[i] then
      local thisCharacter = searchResults[i]
      getglobal(thisFrameName):Show()
      getglobal(thisFrameName .. "Name"):SetText(thisCharacter.player_name)
      local secondColumnText = thisCharacter.full_name
      if TurtleRP.secondColumn == "Zone" then
        secondColumnText = thisCharacter.zone
      elseif TurtleRP.secondColumn == "Short Note" then
        secondColumnText = thisCharacter.character_short_notes
      end
      getglobal(thisFrameName .. "Variable"):SetText(secondColumnText or "")
      getglobal(thisFrameName .. "_StatusOffline"):Show()
      getglobal(thisFrameName .. "_StatusOnline"):Hide()
      if thisCharacter.status == "Online" then
        getglobal(thisFrameName .. "_StatusOffline"):Hide()
        getglobal(thisFrameName .. "_StatusOnline"):Show()
      end
    end
    currentFrameNumber = currentFrameNumber + 1
  end
end

local onlinePlayers = {}
function TurtleRP.get_players_online()
  for k, v in pairs(onlinePlayers) do
    onlinePlayers[k] = nil
  end
  local currentTime = time()
  for name, time in pairs(TurtleRPQueryablePlayers) do
    if type(time) == "number" and time > (currentTime - 65) then
        onlinePlayers[name] = TurtleRPCharacters[name]
    else
        TurtleRPQueryablePlayers[name] = nil -- Clean up queryable players that are no longer queryable
    end
  end
  return onlinePlayers
end

function TurtleRP.OpenDirectoryListing(frame)
  if TurtleRP.OpenProfile then
    TurtleRP.OpenProfile("general")
  else
    UIPanelWindows["TurtleRP_CharacterDetails"] = { area = "left", pushable = 6 }
    ShowUIPanel(TurtleRP_CharacterDetails)
    if TurtleRP.OnBottomTabProfileClick then
      TurtleRP.OnBottomTabProfileClick("general")
    end
  end
end

function TurtleRP.Directory_FrameDropDown_Initialize()
  local info;
  local buttonTexts = { "Character Name", "Zone", "Short Note" }
  for i=1, getn(buttonTexts), 1 do
    info = {};
    info.text = buttonTexts[i];
    info.func = TurtleRP.Directory_FrameDropDown_OnClick;
    UIDropDownMenu_AddButton(info);
  end
end

function TurtleRP.LoadZones(...)
  local info = {}
  for i=1, arg.n, 1 do
    info[i] = arg[i]
  end
  return info
end

TurtleRP.ContinentCache = {}
function TurtleRP.GetZones(continentID)
    if not TurtleRP.ContinentCache[continentID] then
        TurtleRP.ContinentCache[continentID] = TurtleRP.LoadZones(GetMapZones(continentID))
    end
    return TurtleRP.ContinentCache[continentID]
end

function TurtleRP.Directory_FrameDropDown_OnClick()
  UIDropDownMenu_SetSelectedID(TurtleRP_Directory_FrameDropDown, this:GetID());
  TurtleRP.secondColumn = this:GetText()
  TurtleRP.updateDirectorySearch()
  TurtleRP.Directory_ScrollBar_Update()
end
