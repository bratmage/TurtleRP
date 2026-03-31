--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

function TurtleRP.OpenDirectory()
  UIPanelWindows["TurtleRP_DirectoryFrame"] = { area = "left", pushable = 0 }
  if TurtleRP.cleanDirectory then
    TurtleRP.cleanDirectory()
  end
  ShowUIPanel(TurtleRP_DirectoryFrame)
  TurtleRP.UpdateOfflineToggleButton()
  TurtleRP.directorySearchHasFocus = false
  TurtleRP.UpdateDirectorySearchPlaceholder()
  TurtleRP.updateDirectorySearch()
  TurtleRP.Directory_ScrollBar_Update()
end

TurtleRP.directorySortMode = TurtleRP.directorySortMode or "default"
TurtleRP.previousDirectorySortMode = TurtleRP.previousDirectorySortMode or "character_name"
TurtleRP.directoryStatusOrder = TurtleRP.directoryStatusOrder or "online_first"
TurtleRP.hideOfflineDirectory = TurtleRP.hideOfflineDirectory or false
TurtleRP.secondColumn = TurtleRP.secondColumn or "Character Name"
TurtleRP.sortByOrder = TurtleRP.sortByOrder or 0
TurtleRP.directorySearchHasFocus = false

function TurtleRP.SetDirectoryButtonsActive(enable)
  -- Delete button was removed from the directory UI. Keeping this as a no-op because row clicks still call it. if you dont like it you can fix it for me, lovely <3
end

function TurtleRP.UpdateOfflineToggleButton()
  local button = getglobal("TurtleRP_DirectoryFrame_Directory_OfflineToggleButton")
  if not button then
    return
  end
  if TurtleRP.hideOfflineDirectory then
    button:SetText("Show Offline")
  else
    button:SetText("Hide Offline")
  end
end

function TurtleRP.ToggleOfflineDirectoryVisibility()
  TurtleRP.hideOfflineDirectory = not TurtleRP.hideOfflineDirectory
  TurtleRP.UpdateOfflineToggleButton()
  TurtleRP.updateDirectorySearch()
  TurtleRP_DirectoryFrame_Directory_ScrollFrameScrollBar:SetValue(0)
  TurtleRP.Directory_ScrollBar_Update()
end
function TurtleRP.GetDirectorySearchPlaceholderText()
  if TurtleRP.secondColumn == "Zone" then
    return "Search zone..."
  elseif TurtleRP.secondColumn == "Short Note" then
    return "Search notes..."
  end
  return "Search players..."
end

function TurtleRP.UpdateDirectorySearchPlaceholder()
  local editBox = getglobal("TurtleRP_DirectoryFrame_Directory_EditBox")
  local placeholder = getglobal("TurtleRP_DirectoryFrame_Directory_EditBoxPlaceholderFrameText")
  if not editBox or not placeholder then
    return
  end
  placeholder:SetText(TurtleRP.GetDirectorySearchPlaceholderText())
  if TurtleRP.directorySearchHasFocus or editBox:GetText() ~= "" then
    placeholder:Hide()
  else
    placeholder:Show()
  end
end
-- 1.4 directory update. Full refractor that builds normalized row data, computes offline/lineline, applies search filtering, applies selected active sort mode, adds a hide offline toggle functionality, and returns live totals for the filtered result. 
TurtleRP.DirectorySearchResults = nil
TurtleRP.DirectoryLiveTotals = { total = 0, online = 0 }

local function TurtleRP_DirectorySafeString(value)
    if type(value) == "string" then
        return value
    end
    return ""
end

local function TurtleRP_DirectoryIsOnline(playerName, currentTime)
    return type(TurtleRPQueryablePlayers[playerName]) == "number"
       and TurtleRPQueryablePlayers[playerName] > (currentTime - 65)
end

local function TurtleRP_DirectoryStripColorCodes(text)
    text = TurtleRP_DirectorySafeString(text)
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    return text
end

local function TurtleRP_DirectoryNormalizeAlpha(text)
    text = TurtleRP_DirectoryStripColorCodes(text)
    text = string.lower(text)
    text = string.gsub(text, "[^%w%s]", "")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function TurtleRP_DirectoryNormalizeSearch(text)
    return TurtleRP_DirectoryNormalizeAlpha(text)
end

local function TurtleRP_DirectoryBuildRow(playerName, profile, currentTime)
    local fullName = TurtleRP_DirectorySafeString(profile["full_name"])
    local title = TurtleRP_DirectorySafeString(profile["title"])
    local zone = TurtleRP_DirectorySafeString(profile["zone"])
    local shortNote = ""

    if TurtleRPCharacterInfo
    and TurtleRPCharacterInfo["character_short_notes"]
    and type(TurtleRPCharacterInfo["character_short_notes"][playerName]) == "string" then
        shortNote = TurtleRPCharacterInfo["character_short_notes"][playerName]
    end

    local characterDisplayName = fullName
    if title ~= "" and fullName ~= "" then
        characterDisplayName = title .. " " .. fullName
    elseif title ~= "" then
        characterDisplayName = title
    end
    local characterSortName = fullName
    if characterSortName == "" then
        characterSortName = characterDisplayName
    end

    local isOnline = TurtleRP_DirectoryIsOnline(playerName, currentTime)

    return {
        player_name = playerName,
        full_name = fullName,
        title = title,
        zone = zone,
        character_short_notes = shortNote,
        character_display_name = characterDisplayName,
        status = isOnline and "Online" or "Offline",
        is_online = isOnline,
        profile = profile,

        sort_player_name = TurtleRP_DirectoryNormalizeAlpha(playerName),
        sort_character_name = TurtleRP_DirectoryNormalizeAlpha(characterSortName),
        sort_zone = TurtleRP_DirectoryNormalizeAlpha(zone),
        sort_short_note = TurtleRP_DirectoryNormalizeAlpha(shortNote),
    }
end

local function TurtleRP_DirectoryMatchesSearch(row, searchTerm)
    if searchTerm == "" then
        return true
    end
    if TurtleRP.secondColumn == "Zone" then
        return string.find(TurtleRP_DirectoryNormalizeSearch(row.zone), searchTerm, 1, true)
    elseif TurtleRP.secondColumn == "Short Note" then
        return string.find(TurtleRP_DirectoryNormalizeSearch(row.character_short_notes), searchTerm, 1, true)
    end
    return string.find(TurtleRP_DirectoryNormalizeSearch(row.character_display_name), searchTerm, 1, true)
end

local function TurtleRP_DirectoryCompareText(a, b, key, descending)
    local valueA = a[key] or ""
    local valueB = b[key] or ""
    local emptyA = valueA == ""
    local emptyB = valueB == ""
    if emptyA ~= emptyB then
        return not emptyA
    end
    if valueA ~= valueB then
        if descending then
            return valueA > valueB
        end
        return valueA < valueB
    end
    if descending then
        return (a.sort_player_name or "") > (b.sort_player_name or "")
    end
    return (a.sort_player_name or "") < (b.sort_player_name or "")
end

local function TurtleRP_DirectoryCompareStatus(a, b, onlineFirst)
    if a.is_online ~= b.is_online then
        if onlineFirst then
            return a.is_online
        end
        return b.is_online
    end
	
    local fallbackMode = TurtleRP.previousDirectorySortMode or "character_name"
    local descending = TurtleRP.sortByOrder == 1
    if fallbackMode == "player_name" then
        return TurtleRP_DirectoryCompareText(a, b, "sort_player_name", descending)
    elseif fallbackMode == "zone" then
        return TurtleRP_DirectoryCompareText(a, b, "sort_zone", descending)
    elseif fallbackMode == "short_note" then
        return TurtleRP_DirectoryCompareText(a, b, "sort_short_note", descending)
    else
        return TurtleRP_DirectoryCompareText(a, b, "sort_character_name", descending)
    end
end

local function TurtleRP_DirectoryGetComparator()
    local mode = TurtleRP.directorySortMode or "default"
    local descending = TurtleRP.sortByOrder == 1
    local onlineFirst = TurtleRP.directoryStatusOrder ~= "offline_first"
    if mode == "player_name" then
        return function(a, b)
            return TurtleRP_DirectoryCompareText(a, b, "sort_player_name", descending)
        end
    elseif mode == "character_name" then
        return function(a, b)
            return TurtleRP_DirectoryCompareText(a, b, "sort_character_name", descending)
        end
    elseif mode == "zone" then
        return function(a, b)
            if a.is_online ~= b.is_online then
                return a.is_online
            end
            return TurtleRP_DirectoryCompareText(a, b, "sort_zone", descending)
        end
    elseif mode == "short_note" then
        return function(a, b)
            return TurtleRP_DirectoryCompareText(a, b, "sort_short_note", descending)
        end
    elseif mode == "status" then
        return function(a, b)
            return TurtleRP_DirectoryCompareStatus(a, b, onlineFirst)
        end
    else
        return function(a, b)
            if a.is_online ~= b.is_online then
                return a.is_online
            end
            return TurtleRP_DirectoryCompareText(a, b, "sort_player_name", false)
        end
    end
end

function TurtleRP.SetDirectorySortMode(mode)
    if mode == "status" then
        if TurtleRP.directorySortMode ~= "status" then
            TurtleRP.previousDirectorySortMode = TurtleRP.directorySortMode or "character_name"
        end
        TurtleRP.directorySortMode = "status"

        if TurtleRP.directoryStatusOrder == "offline_first" then
            TurtleRP.directoryStatusOrder = "online_first"
        else
            TurtleRP.directoryStatusOrder = "offline_first"
        end
    else
        if TurtleRP.directorySortMode == mode then
            TurtleRP.sortByOrder = TurtleRP.sortByOrder == 0 and 1 or 0
        else
            TurtleRP.sortByOrder = 0
        end
        TurtleRP.directorySortMode = mode
        TurtleRP.previousDirectorySortMode = mode
    end
    TurtleRP.updateDirectorySearch()
    TurtleRP_DirectoryFrame_Directory_ScrollFrameScrollBar:SetValue(0)
    TurtleRP.Directory_ScrollBar_Update()
end

function TurtleRP.BuildDirectoryResults()
    local results = {}
    local totalVisible = 0
    local totalOnlineVisible = 0
    local currentTime = time()
    local showNSFW = TurtleRPSettings["show_nsfw"] == "1"
    local hideOffline = TurtleRP.hideOfflineDirectory == true
    local searchTerm = TurtleRP_DirectoryNormalizeSearch(TurtleRP.searchTerm or "")
    for playerName, profile in pairs(TurtleRPCharacters) do
        if profile and (showNSFW or profile["nsfw"] == "0" or profile["nsfw"] == "" or profile["nsfw"] == nil) then
            local row = TurtleRP_DirectoryBuildRow(playerName, profile, currentTime)

            if (not hideOffline or row.is_online) and TurtleRP_DirectoryMatchesSearch(row, searchTerm) then
                table.insert(results, row)
                totalVisible = totalVisible + 1

                if row.is_online then
                    totalOnlineVisible = totalOnlineVisible + 1
                end
            end
        end
    end
    if table.getn(results) > 1 then
        table.sort(results, TurtleRP_DirectoryGetComparator())
    end
    return results, totalVisible, totalOnlineVisible
end

function TurtleRP.updateDirectorySearch()
    local searchResults, totalVisible, totalOnlineVisible = TurtleRP.BuildDirectoryResults()
    TurtleRP.DirectorySearchResults = searchResults
    TurtleRP.DirectoryLiveTotals.total = totalVisible
    TurtleRP.DirectoryLiveTotals.online = totalOnlineVisible
    TurtleRP.UpdateOfflineToggleButton()
    TurtleRP_DirectoryFrame_Directory_Total:SetText(
        totalVisible .. " adventurers found (" .. totalOnlineVisible .. " online)"
    )
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

-- ----
-- -- Directory Scroll Manager
-- ----
-- TurtleRP.DirectorySearchResults = nil

-- function TurtleRP.updateDirectorySearch()
    -- local totalDirectoryChars = 0
    -- local totalDirectoryOnline = 0
    -- local searchResults = {}
    -- local currentArrayNumber = 1
    -- local showNSFW = TurtleRPSettings["show_nsfw"] == "1"
    -- local currentTime = time()
    -- local lowerSearch = string.lower(TurtleRP.searchTerm or "")
    -- for playerName, profile in pairs(TurtleRPCharacters) do
        -- if profile and (showNSFW or profile["nsfw"] == "0" or profile["nsfw"] == "" or profile["nsfw"] == nil) then
            -- totalDirectoryChars = totalDirectoryChars + 1
            -- local isOnline = false
            -- if type(TurtleRPQueryablePlayers[playerName]) == "number" and TurtleRPQueryablePlayers[playerName] > (currentTime - 65) then
                -- totalDirectoryOnline = totalDirectoryOnline + 1
                -- isOnline = true
            -- end
            -- local fullName = profile["full_name"] or ""
				-- local title = profile["title"] or ""
				-- local zone = profile["zone"] or ""
				-- local shortNote = ""
				-- if TurtleRPCharacterInfo["character_short_notes"]
				-- and type(TurtleRPCharacterInfo["character_short_notes"][playerName]) == "string" then
					-- shortNote = TurtleRPCharacterInfo["character_short_notes"][playerName]
				-- end
				-- local playerNameLower = string.lower(playerName or "")
            -- local playerNameLower = string.lower(playerName or "")
            -- local resultShown = true
            -- if lowerSearch ~= "" then
                -- local fullNameLower = string.lower(fullName)
                -- local titleLower = string.lower(title)
                -- local zoneLower = string.lower(zone)
                -- local shortNoteLower = string.lower(shortNote)

                -- local playerMatch = string.find(playerNameLower, lowerSearch, 1, true)
                -- local nameMatch = string.find(fullNameLower, lowerSearch, 1, true)
                -- local titleMatch = string.find(titleLower, lowerSearch, 1, true)
                -- local zoneMatch = string.find(zoneLower, lowerSearch, 1, true)
                -- local shortNoteMatch = string.find(shortNoteLower, lowerSearch, 1, true)

                -- if not (playerMatch or nameMatch or titleMatch or zoneMatch or shortNoteMatch) then
                    -- resultShown = false
                -- end
            -- end
            -- if resultShown then
                -- searchResults[currentArrayNumber] = {
                    -- player_name = playerName,
                    -- full_name = fullName,
                    -- character_short_notes = shortNote,
                    -- title = title,
                    -- zone = zone,
                    -- status = isOnline and "Online" or "Offline",
                    -- profile = profile,
                -- }
                -- currentArrayNumber = currentArrayNumber + 1
            -- end
        -- end
    -- end

    -- if TurtleRP.sortByKey ~= nil and table.getn(searchResults) > 1 then
        -- table.sort(searchResults, function(a, b)
            -- return sort_users_by_key(a, b, TurtleRP.sortByKey, TurtleRP.sortByOrder)
        -- end)
    -- end
    -- TurtleRP.DirectorySearchResults = searchResults
    -- TurtleRP_DirectoryFrame_Directory_Total:SetText(
        -- totalDirectoryChars .. " adventurers found (" .. totalDirectoryOnline .. " online)"
    -- )
-- end
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
      local secondColumnText = thisCharacter.character_display_name
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
  local selectedText = this:GetText()
  UIDropDownMenu_SetSelectedID(TurtleRP_Directory_FrameDropDown, this:GetID())
  TurtleRP.secondColumn = selectedText
  TurtleRP.UpdateDirectorySearchPlaceholder()
  if selectedText == "Zone" then
    TurtleRP.SetDirectorySortMode("zone")
  elseif selectedText == "Short Note" then
    TurtleRP.SetDirectorySortMode("short_note")
  else
    TurtleRP.SetDirectorySortMode("character_name")
  end
end
