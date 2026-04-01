--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Global storage (not saved)
-----
TurtleRP.TestMode = 0

-- Dev
TurtleRP.currentVersion = "unknown"
TurtleRP.latestVersion = TurtleRP.currentVersion
-- Chat
TurtleRP.channelName = "TTRP"
TurtleRP.channelIndex = 0
TurtleRP.timeBetweenPings = 30
TurtleRP.minChatLevel = 10
TurtleRP.currentlyRequestedData = nil
TurtleRP.disableMessageSending = nil
TurtleRP.sendingLongForm = nil
TurtleRP.errorMessage = nil
TurtleRP.sendWithError = nil
-- Interface
TurtleRP.iconFrames = nil
TurtleRP.directoryFrames = nil
TurtleRP.iconSelectorCreated = nil
TurtleRP.currentIconSelector = nil
TurtleRP.iconSelectorFilter = ""
TurtleRP.RPMode = 0
TurtleRP.movingIconTray = nil
TurtleRP.movingMinimapButton = nil
TurtleRP.editingChatBox = nil
TurtleRP.currentChatType = nil
TurtleRP.targetFrame = TargetFrame
TurtleRP.gameTooltip = GameTooltip
TurtleRP.shaguEnabled = nil
-- Directory
TurtleRP.currentlyViewedPlayer = nil
TurtleRP.currentlyViewedPlayerFrame = nil
TurtleRP.locationFrames = {}
TurtleRP.showDescription = nil
TurtleRP.currentProfileTab = "general"
TurtleRP.secondColumn = "Character Name"
TurtleRP.sortByKey = "status"
TurtleRP.sortByOrder = 1
TurtleRP.searchTerm = ""
TurtleRP.adminSuppressClosePrompt = nil
TurtleRP.adminUnsavedPopupPending = nil
TurtleRP.adminStateSnapshot = nil
TurtleRP.adminPendingTabSwitch = nil
TurtleRP.adminPendingBottomTabSwitch = nil
TurtleRP.previewCharacterInfo = nil
TurtleRP.previewSource = nil
-- Accounting for PFUI, Go Shagu Go
if pfUI ~= nil and pfUI.uf ~= nil and pfUI.uf.target ~= nil then
  TurtleRP.targetFrame = pfUI.uf.target
  TurtleRP.shaguEnabled = true
end

-----
-- Addon load event
-----
local TurtleRP_Parent = CreateFrame("Frame")
TurtleRP_Parent:RegisterEvent("ADDON_LOADED")
TurtleRP_Parent:RegisterEvent("PLAYER_LOGOUT")

function TurtleRP:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "TurtleRP" then

  local tocVersion = GetAddOnMetadata("TurtleRP", "Version")
  if tocVersion and tocVersion ~= "" then
    TurtleRP.currentVersion = tocVersion
  else
    TurtleRP.currentVersion = "unknown"
  end
  TurtleRP.latestVersion = TurtleRP.currentVersion

    -- Reset for testing
    -- TurtleRPCharacterInfo = nil
    -- TurtleRPCharacters = nil
    -- TurtleRPSettings = nil
    local TurtleRPCharacterInfoTemplate = {}

    TurtleRPCharacterInfoTemplate["keyM"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["nsfw"] = "0"
    TurtleRPCharacterInfoTemplate["icon"] = ""
	TurtleRPCharacterInfoTemplate["title"] = ""
    local localizedClass, classToken = UnitClass("player")

    TurtleRPCharacterInfoTemplate["full_name"] = UnitName("player")
    TurtleRPCharacterInfoTemplate["race"] = UnitRace("player")
    TurtleRPCharacterInfoTemplate["class"] = localizedClass
    TurtleRPCharacterInfoTemplate["class_token"] = classToken
    TurtleRPCharacterInfoTemplate["class_color"] = TurtleRPClassData[localizedClass][4]
    TurtleRPCharacterInfoTemplate["ic_info"] = ""
    TurtleRPCharacterInfoTemplate["ooc_info"] = ""
    TurtleRPCharacterInfoTemplate["ic_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["ooc_pronouns"] = ""
    TurtleRPCharacterInfoTemplate["currently_ic"] = "1"

    TurtleRPCharacterInfoTemplate["notes"] = ""
	TurtleRPCharacterInfoTemplate["short_note"] = ""

    TurtleRPCharacterInfoTemplate["keyT"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["atAGlance1"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance1Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance1Icon"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance2Icon"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3Title"] = ""
    TurtleRPCharacterInfoTemplate["atAGlance3Icon"] = ""
    TurtleRPCharacterInfoTemplate["experience"] = "0"
    TurtleRPCharacterInfoTemplate["walkups"] = "0"
    TurtleRPCharacterInfoTemplate["injury"] = "0"
    TurtleRPCharacterInfoTemplate["romance"] = "0"
    TurtleRPCharacterInfoTemplate["death"] = "0"

    TurtleRPCharacterInfoTemplate["keyD"] = TurtleRP.randomchars()
    TurtleRPCharacterInfoTemplate["description"] = ""

    TurtleRPCharacterInfoTemplate["character_notes"] = {}
    TurtleRPCharacterInfoTemplate["character_short_notes"] = {}
    TurtleRPCharacterInfoTemplate["character_disable_rp_color"] = {}

    local TurtleRPSettingsTemplate = {}
    TurtleRPSettingsTemplate["bgs"] = "off"
    TurtleRPSettingsTemplate["tray"] = "1"
    TurtleRPSettingsTemplate["name_size"] = "1"
    TurtleRPSettingsTemplate["minimap_icon_size"] = "0"
    TurtleRPSettingsTemplate["hide_minimap_icon"] = "1"
    TurtleRPSettingsTemplate["share_location"] = "0"
    TurtleRPSettingsTemplate["show_nsfw"] = "0"
	TurtleRPSettingsTemplate["chat_names"] = "1"
	TurtleRPSettingsTemplate["chat_colors"] = "1"
	TurtleRPSettingsTemplate["auto_emote_name"] = "1"
    TurtleRPSettingsTemplate["selected_profile"] = "0"



    -- The Player Profile Data
    local TurtleRPPlayerProfilesTemplate = {}
    TurtleRPPlayerProfilesTemplate["0"] = TurtleRPCharacterInfoTemplate
    TurtleRPPlayerProfilesTemplate["1"] = TurtleRPCharacterInfoTemplate
    TurtleRPPlayerProfilesTemplate["2"] = TurtleRPCharacterInfoTemplate
    TurtleRPPlayerProfilesTemplate["3"] = TurtleRPCharacterInfoTemplate

    if TurtleRPPlayerProfiles == nil then
      TurtleRPPlayerProfiles = TurtleRPPlayerProfilesTemplate
    end
    -- Global character defaults setup
    if TurtleRPCharacterInfo == nil then
      TurtleRPCharacterInfo = TurtleRPCharacterInfoTemplate
    end

    if TurtleRPCharacters == nil then
      TurtleRPCharacters = {}
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
    else
      for character in pairs(TurtleRPCharacters) do
        if not TurtleRPCharacters[character]["nsfw"] then
           TurtleRPCharacters[character]["nsfw"] = "0"
         end
      end
    end

    if TurtleRPSettings == nil then
      TurtleRPSettings = TurtleRPSettingsTemplate
    end
    if TurtleRPQueryablePlayers == nil then
      TurtleRPQueryablePlayers = {}
    end

    -- For adding additional settings after plugin is in use
    if TurtleRPSettings ~= nil then
      for i, field in pairs(TurtleRPSettingsTemplate) do
        if TurtleRPSettings[i] == nil then
          TurtleRPSettings[i] = TurtleRPSettingsTemplate[i]
        end
      end
    end
    -- For adding additional fields after plugin is in use
	if TurtleRPCharacterInfo["title"] == nil then
	  TurtleRPCharacterInfo["title"] = ""
	end
      if TurtleRPCharacterInfo["class_token"] == nil or TurtleRPCharacterInfo["class_token"] == "" then
        local _, classToken = UnitClass("player")
        TurtleRPCharacterInfo["class_token"] = classToken
      end
      if TurtleRPCharacterInfo["character_notes"] == nil then
        TurtleRPCharacterInfo["character_notes"] = {}
      end
      if TurtleRPCharacterInfo["character_short_notes"] == nil then
        TurtleRPCharacterInfo["character_short_notes"] = {}
      end
      if TurtleRPCharacterInfo["character_disable_rp_color"] == nil then
        TurtleRPCharacterInfo["character_disable_rp_color"] = {}
      end
      TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
      TurtleRPPlayerProfiles[TurtleRPSettings["selected_profile"]] = TurtleRPCharacterInfo

    -- TurtleRPCharacters["A°hkir"] = TurtleRPCharacters["Ashkir"]


    -- Intro message
    TurtleRP.log("Welcome, |cff8C48AB" .. TurtleRPCharacterInfo["full_name"] .. "|ccfFFFFFF, to TurtleRP.")
    TurtleRP.log("Type |cff8C48AB/ttrp |ccfFFFFFFto open the addon, or |cff8C48AB/ttrp help|ccfFFFFFF to see slash commands.")

    if not TurtleRP.canChat() and UnitLevel("player") ~= 0 then
      TurtleRP.log("Sorry, but due to Turtle WoW restrictions you can't access other player's TurtleRP profiles until level "..TurtleRP.minChatLevel..".")
    end

    TurtleRP.communication_prep()
    TurtleRP.send_ping_message()

    TurtleRP.populate_interface_user_data()
	TurtleRP_AdminSB_Content5_ChatNamesButton:SetChecked(TurtleRPSettings["chat_names"] == "1" and true or false)
	TurtleRP_AdminSB_Content5_ChatColorsButton:SetChecked(TurtleRPSettings["chat_colors"] == "1" and true or false)

    TurtleRP.tooltip_events()
    TurtleRP.mouseover_and_target_events()
    TurtleRP.communication_events()
    TurtleRP.display_nearby_players()

    TurtleRP.emote_events()
    TurtleRP_AdminSB_Content6_VersionText:SetText(TurtleRP.currentVersion)
	
    StaticPopupDialogs["TTRP_ADMIN_UNSAVED"] = {
      text = "You have unsaved changes. Continue editing, or discard them?",
      button1 = "Continue Editing",
      button2 = "Discard Changes",
      OnAccept = function()
        TurtleRP.adminPendingTabSwitch = nil
        TurtleRP.adminPendingBottomTabSwitch = nil
      end,
      OnCancel = function()
        if TurtleRP.adminPendingTabSwitch ~= nil then
          local pendingTab = TurtleRP.adminPendingTabSwitch
          TurtleRP.adminPendingTabSwitch = nil
          TurtleRP.adminPendingBottomTabSwitch = nil
          TurtleRP.populate_interface_user_data()
          TurtleRP.RefreshAdminStateSnapshot()
          TurtleRP.ApplyAdminTabClick(pendingTab)
          return
        end
        if TurtleRP.adminPendingBottomTabSwitch ~= nil then
          local pendingBottomTab = TurtleRP.adminPendingBottomTabSwitch
          TurtleRP.adminPendingBottomTabSwitch = nil
          TurtleRP.adminPendingTabSwitch = nil
          TurtleRP.populate_interface_user_data()
          TurtleRP.RefreshAdminStateSnapshot()
          TurtleRP.ApplyBottomTabAdminClick(pendingBottomTab)
          return
        end
        TurtleRP.ForceCloseAdmin()
      end,
      timeout = 0,
      whileDead = 1,
      hideOnEscape = 1,
      preferredIndex = 3,
    };
    -- SLash commands
    SLASH_TURTLERP1 = "/ttrp";
    function SlashCmdList.TURTLERP(msg)
      if msg == "help" then
        TurtleRP.log("|cff8C48AB/ttrp|ccfFFFFFF - open admin panel")
        TurtleRP.log("|cff8C48AB/ttrp dir|ccfFFFFFF - open directory panel")
        TurtleRP.log("Visit our Discord for more help.")
      elseif msg == "dir" or msg == "directory" then
        TurtleRP.OpenDirectory()
      elseif msg == "tray" then
         TurtleRP_IconTray:ClearAllPoints()
         TurtleRP_IconTray:SetPoint("CENTER", "UIParent")
         TurtleRP_IconTray:Show()
      else
        TurtleRP.OpenAdmin()
      end
    end

  end
end

TurtleRP_Parent:SetScript("OnEvent", TurtleRP.OnEvent)

-----
-- Building interfaces to display data
-----
function TurtleRP.SetTargetNameFrameWidths(playerName)
  if TurtleRPCharacters[playerName] then
    local char = TurtleRPCharacters[playerName]
    local displayName = char["full_name"]
    if char["title"] and char["title"] ~= "" then
      displayName = char["title"] .. " " .. displayName
    end
    TurtleRP_Target_TargetName:SetText(displayName)
    local stringWidth = TurtleRP_Target_TargetName:GetStringWidth()
    if stringWidth < 100 then
      stringWidth = 100
    end
    TurtleRP_Target:SetWidth(tonumber(stringWidth) + 40)
  end
end

function TurtleRP.buildTargetFrame(playerName)
  local characterInfo = TurtleRPCharacters[playerName]
  TurtleRP_Target:Hide()
  if characterInfo["keyT"] ~= nil then

    TurtleRP_Target_AtAGlance1:Hide()
    if characterInfo['atAGlance1Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance1Icon"]
      TurtleRP_Target_AtAGlance1_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance1_TextPanel_TitleText:SetText(characterInfo["atAGlance1Title"])
      TurtleRP_Target_AtAGlance1_TextPanel_Text:SetText(characterInfo["atAGlance1"])
      TurtleRP_Target_AtAGlance1:Show()
    end

    TurtleRP_Target_AtAGlance2:Hide()
    if characterInfo['atAGlance2Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance2Icon"]
      TurtleRP_Target_AtAGlance2_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance2_TextPanel_TitleText:SetText(characterInfo["atAGlance2Title"])
      TurtleRP_Target_AtAGlance2_TextPanel_Text:SetText(characterInfo["atAGlance2"])
      TurtleRP_Target_AtAGlance2:Show()
    end

    TurtleRP_Target_AtAGlance3:Hide()
    if characterInfo['atAGlance3Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance3Icon"]
      TurtleRP_Target_AtAGlance3_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_Target_AtAGlance3_TextPanel_TitleText:SetText(characterInfo["atAGlance3Title"])
      TurtleRP_Target_AtAGlance3_TextPanel_Text:SetText(characterInfo["atAGlance3"])
      TurtleRP_Target_AtAGlance3:Show()
    end

    TurtleRP.SetTargetNameFrameWidths(playerName)

    TurtleRP_Target:Show()
  end
end

-----
-- Populate data
-----
function TurtleRP.populate_interface_user_data()
  TurtleRP_AdminSB_Content1_NameInput:SetText(TurtleRPCharacterInfo["full_name"])
  TurtleRP_AdminSB_Content1_RaceInput:SetText(TurtleRPCharacterInfo["race"])
  TurtleRP_AdminSB_Content1_ClassInput:SetText(TurtleRPCharacterInfo["class"])
	TurtleRP_AdminSB_Content1_TitleInput:SetText(TurtleRPCharacterInfo["title"] or "")
  local r, g, b = TurtleRP.hex2rgb(TurtleRPCharacterInfo['class_color'])
  TurtleRP_AdminSB_Content1_ClassColorButton:SetBackdropColor(r, g, b)
  TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:SetText(TurtleRPCharacterInfo["ic_info"])
  TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:SetText(TurtleRPCharacterInfo["ooc_info"])
  TurtleRP_AdminSB_Content1_ICPronounsInput:SetText(TurtleRPCharacterInfo["ic_pronouns"])
  TurtleRP_AdminSB_Content1_OOCPronounsInput:SetText(TurtleRPCharacterInfo["ooc_pronouns"])
  TurtleRP.setCharacterIcon()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:SetText(TurtleRPCharacterInfo["atAGlance1"])
  TurtleRP_AdminSB_Content2_AAG1TitleInput:SetText(TurtleRPCharacterInfo["atAGlance1Title"])
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:SetText(TurtleRPCharacterInfo["atAGlance2"])
  TurtleRP_AdminSB_Content2_AAG2TitleInput:SetText(TurtleRPCharacterInfo["atAGlance2Title"])
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:SetText(TurtleRPCharacterInfo["atAGlance3"])
  TurtleRP_AdminSB_Content2_AAG3TitleInput:SetText(TurtleRPCharacterInfo["atAGlance3Title"])
  TurtleRP.setAtAGlanceIcons()
  local replacedLineBreaks = gsub(TurtleRPCharacterInfo["description"], "@N", "%\n")
  TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:SetText(replacedLineBreaks)
  TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:SetText(TurtleRPCharacterInfo["notes"])
  TurtleRP_AdminSB_Content4_ShortNoteBox_Input:SetText(TurtleRPCharacterInfo["short_note"] or "")

  TurtleRP_AdminSB_Content5_PVPButton:SetChecked(TurtleRPSettings["bgs"] == "on" and true or false)
  TurtleRP_AdminSB_Content5_NameButton:SetChecked(TurtleRPSettings["name_size"] == "1" and true or false)

  if TurtleRPCharacterInfo["nsfw"] == "1" then
    TurtleRP_AdminSB_Content1_NSFWButton:SetChecked(true)
  else
    TurtleRP_AdminSB_Content1_NSFWButton:SetChecked(false)
  end

  if TurtleRPCharacterInfo["currently_ic"] == "1" then
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(true)
    TurtleRP_IconTray_ICModeButton2:Show()
  else
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(false)
    TurtleRP_IconTray_ICModeButton:Show()
  end

  if TurtleRPSettings["tray"] == "1" then
    TurtleRP_AdminSB_Content5_TrayButton:SetChecked(true)
    TurtleRP_IconTray:Show()
  end

  if TurtleRPSettings["minimap_icon_size"] == "1" then
    TurtleRP_AdminSB_Content5_MinimapButton:SetChecked(true)
    TurtleRP_MinimapIcon_OpenAdmin:SetScale(1.25)
  end

  if TurtleRPSettings["hide_minimap_icon"] == "1" then
    TurtleRP_AdminSB_Content5_HideMinimapButton:SetChecked(true)
    TurtleRP_MinimapIcon:Hide()
  end

  if TurtleRPSettings["share_location"] == "1" then
    TurtleRP_AdminSB_Content5_ShareLocationButton:SetChecked(true)
    TurtleRP_MinimapIcon:Hide()
  end

  if TurtleRPSettings["show_nsfw"] == "1" then
    TurtleRP_AdminSB_Content5_ShowNSFWButton:SetChecked(true)
  else
    TurtleRP_AdminSB_Content5_ShowNSFWButton:SetChecked(false)
  end
  if TurtleRPSettings["chat_names"] == "1" then
    TurtleRP_AdminSB_Content5_ChatNamesButton:SetChecked(true)
  else
    TurtleRP_AdminSB_Content5_ChatNamesButton:SetChecked(false)
  end
  if TurtleRPSettings["chat_colors"] == "1" then
    TurtleRP_AdminSB_Content5_ChatColorsButton:SetChecked(true)
  else
    TurtleRP_AdminSB_Content5_ChatColorsButton:SetChecked(false)
  end
  -- Setup Profile Dropdown
  TurtleRP.SetProfileDropdown()
end

function TurtleRP.setCharacterIcon()
  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex
  local iconIndex = pendingIcons and pendingIcons["icon"] or TurtleRPCharacterInfo["icon"]

  if iconIndex ~= "" and iconIndex ~= nil then
    TurtleRP_AdminSB_Content1_IconButton:SetBackdrop({
      bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)]
    })
  else
    TurtleRP_AdminSB_Content1_IconButton:SetBackdrop({
      bgFile = "Interface\\Buttons\\UI-EmptySlot-White"
    })
  end
end

function TurtleRP.setAtAGlanceIcons()
  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex or {}
  local characterInfo = TurtleRPCharacters[UnitName("player")]

  local icon1 = pendingIcons["atAGlance1Icon"] or characterInfo["atAGlance1Icon"]
  local icon2 = pendingIcons["atAGlance2Icon"] or characterInfo["atAGlance2Icon"]
  local icon3 = pendingIcons["atAGlance3Icon"] or characterInfo["atAGlance3Icon"]

  if icon1 ~= "" and icon1 ~= nil then
    TurtleRP_AdminSB_Content2_AAG1IconButton:SetBackdrop({
      bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon1)]
    })
  else
    TurtleRP_AdminSB_Content2_AAG1IconButton:SetBackdrop({
      bgFile = "Interface\\Buttons\\UI-EmptySlot-White"
    })
  end
  if icon2 ~= "" and icon2 ~= nil then
    TurtleRP_AdminSB_Content2_AAG2IconButton:SetBackdrop({
      bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon2)]
    })
  else
    TurtleRP_AdminSB_Content2_AAG2IconButton:SetBackdrop({
      bgFile = "Interface\\Buttons\\UI-EmptySlot-White"
    })
  end
  if icon3 ~= "" and icon3 ~= nil then
    TurtleRP_AdminSB_Content2_AAG3IconButton:SetBackdrop({
      bgFile = "Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon3)]
    })
  else
    TurtleRP_AdminSB_Content2_AAG3IconButton:SetBackdrop({
      bgFile = "Interface\\Buttons\\UI-EmptySlot-White"
    })
  end
end

-- Profile Drop Down setup
function TurtleRP.SetProfileDropdown()
    if TurtleRPSettings['selected_profile'] ~= nil then
      local thisValue = TurtleRPSettings['selected_profile']
      local v = TurtleRP_AdminSB_Content5_ProfileDropdown
      getglobal(v:GetName() .. "_Text"):SetText(TurtleRPDropdownOptions['selected_profile'][thisValue])
      UIDropDownMenu_SetSelectedValue(v, thisValue)
    end
  end
-- Profile preview
  function TurtleRP.CopyTableShallow(source)
  local copy = {}
  if not source then
    return copy
  end

  for k, v in pairs(source) do
    if type(v) == "table" then
      local childCopy = {}
      for childK, childV in pairs(v) do
        childCopy[childK] = childV
      end
      copy[k] = childCopy
    else
      copy[k] = v
    end
  end

  return copy
end

function TurtleRP.BuildAdminProfilePreviewData()
  local preview = TurtleRP.CopyTableShallow(TurtleRPCharacterInfo)

  preview["full_name"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_NameInput:GetText()) or ""
  preview["race"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_RaceInput:GetText()) or ""
  preview["class"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_ClassInput:GetText()) or ""
  preview["title"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_TitleInput:GetText()) or ""
  preview["ic_info"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:GetText()) or ""
  preview["ooc_info"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:GetText()) or ""
  preview["ic_pronouns"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_ICPronounsInput:GetText()) or ""
  preview["ooc_pronouns"] = TurtleRP.validateBeforeSaving(TurtleRP_AdminSB_Content1_OOCPronounsInput:GetText()) or ""
  preview["keyM"] = preview["keyM"] or TurtleRP.randomchars()

  return preview
end

function TurtleRP.BuildAdminDescriptionPreviewData()
  local preview = TurtleRP.CopyTableShallow(TurtleRPCharacterInfo)

  preview["description"] = TurtleRP.validateBeforeSaving(
    TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:GetText()
  ) or ""
  preview["keyD"] = preview["keyD"] or TurtleRP.randomchars()

  return preview
end

function TurtleRP.OpenAdminProfilePreview()
  TurtleRP.previewCharacterInfo = TurtleRP.BuildAdminProfilePreviewData()
  TurtleRP.previewSource = "admin_profile"
  TurtleRP.currentlyViewedPlayer = UnitName("player")
  TurtleRP.OpenProfilePreview("general")
end

function TurtleRP.OpenAdminDescriptionPreview()
  TurtleRP.previewCharacterInfo = TurtleRP.BuildAdminDescriptionPreviewData()
  TurtleRP.previewSource = "admin_description"
  TurtleRP.currentlyViewedPlayer = UnitName("player")
  TurtleRP.OpenProfilePreview("description")
end

function TurtleRP.GetAdminPendingIconValue(key, fallback)
  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex or nil
  if pendingIcons and pendingIcons[key] ~= nil then
    return pendingIcons[key]
  end
  return fallback
end

function TurtleRP.GetAdminClassColorHex()
  local r, g, b = TurtleRP_AdminSB_Content1_ClassColorButton:GetBackdropColor()
  return TurtleRP.rgb2hex(r, g, b)
end

function TurtleRP.ClearAdminFocus()
  if not TurtleRP_AdminSB then
    return
  end

  TurtleRP_AdminSB_Content1_NameInput:ClearFocus()
  TurtleRP_AdminSB_Content1_RaceInput:ClearFocus()
  TurtleRP_AdminSB_Content1_ClassInput:ClearFocus()
  TurtleRP_AdminSB_Content1_TitleInput:ClearFocus()
  TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:ClearFocus()
  TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:ClearFocus()
  TurtleRP_AdminSB_Content1_ICPronounsInput:ClearFocus()
  TurtleRP_AdminSB_Content1_OOCPronounsInput:ClearFocus()

  TurtleRP_AdminSB_Content2_AAG1TitleInput:ClearFocus()
  TurtleRP_AdminSB_Content2_AAG2TitleInput:ClearFocus()
  TurtleRP_AdminSB_Content2_AAG3TitleInput:ClearFocus()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:ClearFocus()

  TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:ClearFocus()

  TurtleRP_AdminSB_Content4_ShortNoteBox_Input:ClearFocus()
  TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:ClearFocus()
end
function TurtleRP.CaptureAdminStateSnapshot()
  if not TurtleRP_AdminSB then
    return ""
  end

  local characterInfo = TurtleRPCharacterInfo or {}
  local playerInfo = TurtleRPCharacters[UnitName("player")] or characterInfo

  local experience = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown)
  local walkups = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown)
  local injury = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown)
  local romance = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown)
  local death = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_DeathDropdown)

  local currentExperience = experience ~= nil and tostring(experience) or (characterInfo["experience"] or "0")
  local currentWalkups = walkups ~= nil and tostring(walkups) or (characterInfo["walkups"] or "0")
  local currentInjury = injury ~= nil and tostring(injury) or (characterInfo["injury"] or "0")
  local currentRomance = romance ~= nil and tostring(romance) or (characterInfo["romance"] or "0")
  local currentDeath = death ~= nil and tostring(death) or (characterInfo["death"] or "0")

  local parts = {
    TurtleRP_AdminSB_Content1_NameInput:GetText() or "",
    TurtleRP_AdminSB_Content1_RaceInput:GetText() or "",
    TurtleRP_AdminSB_Content1_ClassInput:GetText() or "",
    TurtleRP_AdminSB_Content1_TitleInput:GetText() or "",
    TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:GetText() or "",
    TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:GetText() or "",
    TurtleRP_AdminSB_Content1_ICPronounsInput:GetText() or "",
    TurtleRP_AdminSB_Content1_OOCPronounsInput:GetText() or "",
    TurtleRP_AdminSB_Content1_NSFWButton:GetChecked() and "1" or "0",
    TurtleRP.GetAdminClassColorHex(),
    TurtleRP.GetAdminPendingIconValue("icon", characterInfo["icon"] or ""),
    currentExperience,
    currentWalkups,
    currentInjury,
    currentRomance,
    currentDeath,
    TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:GetText() or "",
    TurtleRP_AdminSB_Content2_AAG1TitleInput:GetText() or "",
    TurtleRP.GetAdminPendingIconValue("atAGlance1Icon", characterInfo["atAGlance1Icon"] or ""),
    TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:GetText() or "",
    TurtleRP_AdminSB_Content2_AAG2TitleInput:GetText() or "",
    TurtleRP.GetAdminPendingIconValue("atAGlance2Icon", characterInfo["atAGlance2Icon"] or ""),
    TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:GetText() or "",
    TurtleRP_AdminSB_Content2_AAG3TitleInput:GetText() or "",
    TurtleRP.GetAdminPendingIconValue("atAGlance3Icon", characterInfo["atAGlance3Icon"] or ""),
    TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:GetText() or "",
    TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:GetText() or "",
    TurtleRP_AdminSB_Content4_ShortNoteBox_Input:GetText() or "",
    playerInfo["notes"] or "",
    playerInfo["short_note"] or "",
  }

  return table.concat(parts, "§")
end

function TurtleRP.RefreshAdminStateSnapshot()
  TurtleRP.ClearAdminFocus()
  TurtleRP.adminStateSnapshot = TurtleRP.CaptureAdminStateSnapshot()
end
function TurtleRP.HasUnsavedAdminChanges()
  if not TurtleRP_AdminSB then
    return false
  end

  if TurtleRP.adminStateSnapshot == nil then
    return false
  end

  return TurtleRP.CaptureAdminStateSnapshot() ~= TurtleRP.adminStateSnapshot
end

function TurtleRP.ForceCloseAdmin()
  TurtleRP.adminSuppressClosePrompt = true
  TurtleRP.adminUnsavedPopupPending = nil
  StaticPopup_Hide("TTRP_ADMIN_UNSAVED")

  TurtleRP.previewCharacterInfo = nil
  TurtleRP.previewSource = nil
  TurtleRP_IconSelector.selectedIconIndex = {}
  TurtleRP.adminStateSnapshot = nil
  TurtleRP.adminPendingTabSwitch = nil
  TurtleRP.adminPendingBottomTabSwitch = nil

  HideUIPanel(TurtleRP_AdminSB)
  TurtleRP.populate_interface_user_data()

  TurtleRP.adminSuppressClosePrompt = nil
end

function TurtleRP.RequestCloseAdmin()
  TurtleRP.ClearAdminFocus()
  TurtleRP.adminPendingTabSwitch = nil
  TurtleRP.adminPendingBottomTabSwitch = nil
  if TurtleRP.HasUnsavedAdminChanges() then
    StaticPopup_Show("TTRP_ADMIN_UNSAVED")
  else
    TurtleRP.ForceCloseAdmin()
  end
end

function TurtleRP.RequestAdminTabSwitch(tabType, value)
  TurtleRP.ClearAdminFocus()
  if not TurtleRP.HasUnsavedAdminChanges() then
    TurtleRP.adminPendingTabSwitch = nil
    TurtleRP.adminPendingBottomTabSwitch = nil
    if tabType == "main" then
      TurtleRP.ApplyAdminTabClick(value)
    elseif tabType == "bottom" then
      TurtleRP.ApplyBottomTabAdminClick(value)
    end
    return
  end
  TurtleRP.adminPendingTabSwitch = nil
  TurtleRP.adminPendingBottomTabSwitch = nil
  if tabType == "main" then
    TurtleRP.adminPendingTabSwitch = value
  elseif tabType == "bottom" then
    TurtleRP.adminPendingBottomTabSwitch = value
  end
  StaticPopup_Show("TTRP_ADMIN_UNSAVED")
end

function TurtleRP.ShowAdminUnsavedPopupDelayed()
  if TurtleRP.adminUnsavedPopupPending then
    return
  end

  TurtleRP.adminUnsavedPopupPending = true

  local popupDelayFrame = CreateFrame("Frame")
  popupDelayFrame:SetScript("OnUpdate", function()
    popupDelayFrame:SetScript("OnUpdate", nil)
    TurtleRP.adminUnsavedPopupPending = nil

    if TurtleRP_AdminSB and TurtleRP_AdminSB:IsShown() then
      StaticPopup_Show("TTRP_ADMIN_UNSAVED")
    end
  end)
end

function TurtleRP.HandleAdminHidden()
  if TurtleRP.adminSuppressClosePrompt then
    return
  end
  TurtleRP.ClearAdminFocus()
  if not TurtleRP.HasUnsavedAdminChanges() then
    return
  end

  ShowUIPanel(TurtleRP_AdminSB)
  TurtleRP.ShowAdminUnsavedPopupDelayed()
end
-----
-- Saving
-----

function TurtleRP.change_character_profile()
  -- Save Existing Profile
  local selected_profile = TurtleRPSettings["selected_profile"]
  TurtleRPPlayerProfiles[selected_profile] = TurtleRPCharacterInfo
  -- Get Profile to Swap To
  selected_profile = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content5_ProfileDropdown)
  TurtleRPSettings["selected_profile"] = selected_profile ~= nil and selected_profile or 0
  -- Swap Profiles
  TurtleRPCharacterInfo = TurtleRPPlayerProfiles[selected_profile]
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setCharacterIcon()
  TurtleRP.RefreshAdminStateSnapshot()
end

function TurtleRP.change_nsfw_status()
  if TurtleRP_AdminSB_Content1_NSFWButton:GetChecked() then
    TurtleRP_AdminSB_Content1_NSFWButton:SetChecked(true)
  else
    TurtleRP_AdminSB_Content1_NSFWButton:SetChecked(false)
  end
end

function TurtleRP.change_ic_status()
  if TurtleRPCharacterInfo["currently_ic"] ~= "1" then
    TurtleRPCharacterInfo["currently_ic"] = "1"
    TurtleRP_IconTray_ICModeButton2:Show()
    TurtleRP_IconTray_ICModeButton:Hide()
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(true)
  else
    TurtleRPCharacterInfo["currently_ic"] = "0"
    TurtleRP_IconTray_ICModeButton:Show()
    TurtleRP_IconTray_ICModeButton2:Hide()
    TurtleRP_AdminSB_Content1_ICButton:SetChecked(false)
  end
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.save_general()
end

function TurtleRP.save_general()
  TurtleRPCharacterInfo['keyM'] = TurtleRP.randomchars()
  local full_name = TurtleRP_AdminSB_Content1_NameInput:GetText()
  TurtleRP_AdminSB_Content1_NameInput:ClearFocus()
  TurtleRPCharacterInfo["full_name"] = TurtleRP.validateBeforeSaving(full_name)
  local race = TurtleRP_AdminSB_Content1_RaceInput:GetText()
  TurtleRP_AdminSB_Content1_RaceInput:ClearFocus()
  TurtleRPCharacterInfo["race"] = TurtleRP.validateBeforeSaving(race)
  local class = TurtleRP_AdminSB_Content1_ClassInput:GetText()
  TurtleRP_AdminSB_Content1_ClassInput:ClearFocus()
  TurtleRPCharacterInfo["class"] = TurtleRP.validateBeforeSaving(class)
  local _, classToken = UnitClass("player")
  TurtleRPCharacterInfo["class_token"] = classToken
  local title = TurtleRP_AdminSB_Content1_TitleInput:GetText()
  TurtleRP_AdminSB_Content1_TitleInput:ClearFocus()
  TurtleRPCharacterInfo["title"] = TurtleRP.validateBeforeSaving(title)
  local r, g, b = TurtleRP_AdminSB_Content1_ClassColorButton:GetBackdropColor()
  TurtleRPCharacterInfo["class_color"] = TurtleRP.rgb2hex(r, g, b)
  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex or {}
  if pendingIcons["icon"] ~= nil then
    TurtleRPCharacterInfo["icon"] = pendingIcons["icon"]
  end
  local ic_info = TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:GetText()
  TurtleRP_AdminSB_Content1_ICScrollBox_ICInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ic_info"] = TurtleRP.validateBeforeSaving(ic_info)
  local ooc_info = TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:GetText()
  TurtleRP_AdminSB_Content1_OOCScrollBox_OOCInfoInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_info"] = TurtleRP.validateBeforeSaving(ooc_info)
  local ic_pronouns = TurtleRP_AdminSB_Content1_ICPronounsInput:GetText()
  TurtleRP_AdminSB_Content1_ICPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ic_pronouns"] = TurtleRP.validateBeforeSaving(ic_pronouns)
  local ooc_pronouns = TurtleRP_AdminSB_Content1_OOCPronounsInput:GetText()
  TurtleRP_AdminSB_Content1_OOCPronounsInput:ClearFocus()
  TurtleRPCharacterInfo["ooc_pronouns"] = TurtleRP.validateBeforeSaving(ooc_pronouns)

  TurtleRPCharacterInfo["nsfw"] = TurtleRP_AdminSB_Content1_NSFWButton:GetChecked() and "1" or "0"

  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setCharacterIcon()
  TurtleRP.RefreshAdminStateSnapshot()
end

function TurtleRP.save_style()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local experience = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown)
  TurtleRPCharacterInfo["experience"] = experience ~= nil and experience or 0
  local walkups = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown)
  TurtleRPCharacterInfo["walkups"] = walkups ~= nil and walkups or 0
  local injury = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown)
  TurtleRPCharacterInfo["injury"] = injury ~= nil and injury or 0
  local romance = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown)
  TurtleRPCharacterInfo["romance"] = romance ~= nil and romance or 0
  local death = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_DeathDropdown)
  TurtleRPCharacterInfo["death"] = death ~= nil and death or 0
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.RefreshAdminStateSnapshot()
end

function TurtleRP.save_at_a_glance()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local aag1Text = TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1"] = TurtleRP.validateBeforeSaving(aag1Text)
  local aag1TitleText = TurtleRP_AdminSB_Content2_AAG1TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG1TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1Title"] = TurtleRP.validateBeforeSaving(aag1TitleText)
  local aag2Text = TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2"] = TurtleRP.validateBeforeSaving(aag2Text)
  local aag2TitleText = TurtleRP_AdminSB_Content2_AAG2TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG2TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2Title"] = TurtleRP.validateBeforeSaving(aag2TitleText)
  local aag3Text = TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3"] = TurtleRP.validateBeforeSaving(aag3Text)
  local aag3TitleText = TurtleRP_AdminSB_Content2_AAG3TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG3TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3Title"] = TurtleRP.validateBeforeSaving(aag3TitleText)

  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex or {}
  if pendingIcons["atAGlance1Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance1Icon"] = pendingIcons["atAGlance1Icon"]
  end
  if pendingIcons["atAGlance2Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance2Icon"] = pendingIcons["atAGlance2Icon"]
  end
  if pendingIcons["atAGlance3Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance3Icon"] = pendingIcons["atAGlance3Icon"]
  end

  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setAtAGlanceIcons()
  TurtleRP.RefreshAdminStateSnapshot()
end

function TurtleRP.save_style()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local experience = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown)
  TurtleRPCharacterInfo["experience"] = experience ~= nil and experience or 0
  local walkups = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown)
  TurtleRPCharacterInfo["walkups"] = walkups ~= nil and walkups or 0
  local injury = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown)
  TurtleRPCharacterInfo["injury"] = injury ~= nil and injury or 0
  local romance = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown)
  TurtleRPCharacterInfo["romance"] = romance ~= nil and romance or 0
  local death = UIDropDownMenu_GetSelectedValue(TurtleRP_AdminSB_Content1_Tab2_DeathDropdown)
  TurtleRPCharacterInfo["death"] = death ~= nil and death or 0
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
end
function TurtleRP.save_at_a_glance()
  TurtleRPCharacterInfo['keyT'] = TurtleRP.randomchars()
  local aag1Text = TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance1ScrollBox_AAG1Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1"] = TurtleRP.validateBeforeSaving(aag1Text)
  local aag1TitleText = TurtleRP_AdminSB_Content2_AAG1TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG1TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance1Title"] = TurtleRP.validateBeforeSaving(aag1TitleText)
  local aag2Text = TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance2ScrollBox_AAG2Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2"] = TurtleRP.validateBeforeSaving(aag2Text)
  local aag2TitleText = TurtleRP_AdminSB_Content2_AAG2TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG2TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance2Title"] = TurtleRP.validateBeforeSaving(aag2TitleText)
  local aag3Text = TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:GetText()
  TurtleRP_AdminSB_Content2_AtAGlance3ScrollBox_AAG3Input:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3"] = TurtleRP.validateBeforeSaving(aag3Text)
  local aag3TitleText = TurtleRP_AdminSB_Content2_AAG3TitleInput:GetText()
  TurtleRP_AdminSB_Content2_AAG3TitleInput:ClearFocus()
  TurtleRPCharacterInfo["atAGlance3Title"] = TurtleRP.validateBeforeSaving(aag3TitleText)

  local pendingIcons = TurtleRP_IconSelector and TurtleRP_IconSelector.selectedIconIndex or {}
  if pendingIcons["atAGlance1Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance1Icon"] = pendingIcons["atAGlance1Icon"]
  end
  if pendingIcons["atAGlance2Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance2Icon"] = pendingIcons["atAGlance2Icon"]
  end
  if pendingIcons["atAGlance3Icon"] ~= nil then
    TurtleRPCharacterInfo["atAGlance3Icon"] = pendingIcons["atAGlance3Icon"]
  end

  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.setAtAGlanceIcons()
end
function TurtleRP.save_description()
  TurtleRPCharacterInfo['keyD'] = TurtleRP.randomchars()
  local description = TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:GetText()
  TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput:ClearFocus()
  TurtleRPCharacterInfo["description"] = TurtleRP.validateBeforeSaving(description)
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRP.RefreshAdminStateSnapshot()
end
function TurtleRP.save_notes()
  local short_note = TurtleRP_AdminSB_Content4_ShortNoteBox_Input:GetText()
  TurtleRP_AdminSB_Content4_ShortNoteBox_Input:ClearFocus()
  TurtleRPCharacterInfo["short_note"] = TurtleRP.validateBeforeSaving(short_note) or ""
  local notes = TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:GetText()
  TurtleRP_AdminSB_Content4_NotesScrollBox_NotesInput:ClearFocus()
  TurtleRPCharacterInfo["notes"] = notes
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  if TurtleRP.currentlyViewedPlayer == UnitName("player") and TurtleRP_CharacterDetails_Notes:IsShown() then
    TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:SetText(TurtleRPCharacterInfo["notes"] or "")
    TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:SetText(TurtleRPCharacterInfo["short_note"] or "")
  end
  TurtleRP.RefreshAdminStateSnapshot()
end
function TurtleRP.save_character_notes()
  local notes = TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:GetText()
  TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:ClearFocus()
  local short_note = TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:GetText()
  TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:ClearFocus()
  if TurtleRP.currentlyViewedPlayer == UnitName("player") then
    TurtleRPCharacterInfo["notes"] = notes
    TurtleRPCharacterInfo["short_note"] = TurtleRP.validateBeforeSaving(short_note) or ""
    TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  else
    TurtleRPCharacterInfo["character_notes"][TurtleRP.currentlyViewedPlayer] = notes
    if TurtleRPCharacterInfo["character_short_notes"] == nil then
      TurtleRPCharacterInfo["character_short_notes"] = {}
    end
    TurtleRPCharacterInfo["character_short_notes"][TurtleRP.currentlyViewedPlayer] =
      TurtleRP.validateBeforeSaving(short_note) or ""
  end
end
-- This entire function is being implemented in March/April of 2026. It exists only to migrate old data. This can be removed in like, 6 months+.
function TurtleRP.migrate_self_notes()
  local playerName = UnitName("player")
  if TurtleRPCharacterInfo["character_notes"] == nil then
    TurtleRPCharacterInfo["character_notes"] = {}
  end
  if TurtleRPCharacterInfo["character_short_notes"] == nil then
    TurtleRPCharacterInfo["character_short_notes"] = {}
  end
  if TurtleRPCharacterInfo["notes"] == nil then
    TurtleRPCharacterInfo["notes"] = ""
  end
  if TurtleRPCharacterInfo["short_note"] == nil then
    TurtleRPCharacterInfo["short_note"] = ""
  end
  local old_self_notes = TurtleRPCharacterInfo["character_notes"][playerName]
  if (TurtleRPCharacterInfo["notes"] == nil or TurtleRPCharacterInfo["notes"] == "")
    and old_self_notes ~= nil and old_self_notes ~= "" then
    TurtleRPCharacterInfo["notes"] = old_self_notes
  end
  local old_self_short = TurtleRPCharacterInfo["character_short_notes"][playerName]
  if (TurtleRPCharacterInfo["short_note"] == nil or TurtleRPCharacterInfo["short_note"] == "")
    and old_self_short ~= nil and old_self_short ~= "" then
    TurtleRPCharacterInfo["short_note"] = old_self_short
  end
  TurtleRPCharacters[UnitName("player")] = TurtleRPCharacterInfo
  TurtleRPPlayerProfiles[TurtleRPSettings["selected_profile"]] = TurtleRPCharacterInfo
end

function TurtleRP.canChat()
    return UnitLevel("player") >= TurtleRP.minChatLevel
end

function TurtleRP.GetVersionNumberParts(versionString)
  versionString = versionString or ""
  local _, _, major, minor, patch = string.find(versionString, "^(%d+)%.(%d+)%.(%d+)$")
  return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
end

function TurtleRP.IsVersionOlder(versionA, versionB)
  local a1, a2, a3 = TurtleRP.GetVersionNumberParts(versionA)
  local b1, b2, b3 = TurtleRP.GetVersionNumberParts(versionB)

  if a1 ~= b1 then
    return a1 < b1
  end
  if a2 ~= b2 then
    return a2 < b2
  end
  return a3 < b3
end

-- Offer to join /rp channel upon reaching level 10, or first login after installing/update.
function TurtleRP.CheckLevelForChannel(newLevel, isLogin)
    local id, name = GetChannelName("rp")
    if id > 0 then 
        TurtleRPSettings["seen_rp_prompt"] = "1"
        return 
    end
    if newLevel >= 10 and TurtleRPSettings["seen_rp_prompt"] ~= "1" then
        local delay = isLogin and 30 or 10;
        
        local timerFrame = CreateFrame("Frame");
        timerFrame:SetScript("OnUpdate", function()
            delay = delay - arg1; 
            if delay <= 0 then
                TurtleRP.ShowRPPopup(isLogin);
                this:Hide(); 
                this:SetScript("OnUpdate", nil);
            end
        end);
    end
end

function TurtleRP.ShowRPPopup(isLogin)
    local id, name = GetChannelName("rp")
    if id > 0 then 
        TurtleRPSettings["seen_rp_prompt"] = "1"
        return 
    end
    local popupText = "You've reached level 10! Would you like to join the RP channel to find other roleplayers?";
    if isLogin then
        popupText = "Thank you for installing TurtleRP! Would you like to join the global /rp channel to find other roleplayers?";
    end

    StaticPopupDialogs["TTRP_JOIN_PROMPT"] = {
        text = popupText,
        button1 = "Join /rp",
        button2 = "Maybe Later",
        OnAccept = function()
            JoinChannelByName("rp")
            ChatFrame_AddChannel(ChatFrame1, "rp")
            TurtleRPSettings["seen_rp_prompt"] = "1"
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRP: Joined /rp channel. You may always leave with /leave rp |r")
        end,
        OnCancel = function()
            TurtleRPSettings["seen_rp_prompt"] = "1" 
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopup_Show("TTRP_JOIN_PROMPT");
end
--just a debugging command
SLASH_RPRESET1 = "/rpreset";
SlashCmdList["RPRESET"] = function(msg)
    TurtleRPSettings["seen_rp_prompt"] = "0";
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00TurtleRP: RP Channel prompt has been reset. It will appear again on next login or level up.|r");
end
  -- i am so vain
function TurtleRP.IsDevProfile(playerName)
  if not playerName or playerName == "" then
    return false
  end
  local function normalize(str)
    str = string.lower(str or "")
    str = string.gsub(str, "%s+", "")
    return str
  end
  local realmName = normalize(GetRealmName())
  local loweredName = normalize(playerName)
  if realmName ~= "nordanaar" then
    return false
  end
  return loweredName == "prynn" or loweredName == "bratmage" or loweredName == "celryn" or loweredName == "niane"
end
function TurtleRP.GetDevBadgeText()
  return "|cff5bcefaT|cff70d4fbu|cff84dafbr|cff98e0fct|cffade6fcl|cffc2edfde|cffd6f3feR|cffeaf9feP|cffffffff |cffffffffD|cfffde8ede|cfffbd2e3v|cfff9bdd9e|cfff7a7cfl|cfff591c5o|cfff37bbbp|cfff165b1e|cfff04fa7r"
end
-----
-- Utility
-----
local setn = table.setn
local strFind = string.find
local strSub = string.sub
function TurtleRP.splitString(str, delimiter, t)
    local result
    if t then
        -- Reuse this table
        for k, v in ipairs(t) do
            t[k] = nil
        end
        result = t
    else
        result = {}
    end
    local from = 1
    local delim_from, delim_to = strFind(str, delimiter, from, true)
    local i = 1
    while delim_from do
        result[i] = strSub(str, from, delim_from - 1)
        i = i + 1
        from = delim_to + 1
        delim_from, delim_to = strFind(str, delimiter, from, true)
    end
    result[i] = strSub(str, from)
    setn(result, i)
    return result
end

function TurtleRP.randomchars()
	local res = ""
	for i = 1, 5 do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function TurtleRP.hex2rgb(hex)
  return tonumber(strsub(hex, 1, 2), 16)/255, tonumber(strsub(hex, 3, 4), 16)/255, tonumber(strsub(hex, 5, 6), 16)/255
end

function TurtleRP.rgb2hex(r, g, b)
	return string.format("%02x%02x%02x",
		math.floor(r*255),
		math.floor(g*255),
		math.floor(b*255))
end

function TurtleRP.validateBeforeSaving(data)
  if string.find(data, '~') or string.find(data, '°') or string.find(data, '§') then
    _ERRORMESSAGE('Please do not use the characters "~", "°", or "§" in your text. Thanks!')
  else
    return data
  end
end

function TurtleRP.cleanDirectory()
  for i, v in TurtleRPCharacters do
    if string.find(i, '°') or string.find(i, '§') then
      local fixedName = TurtleRP.DrunkDecode(i)
      TurtleRPCharacters[fixedName] = TurtleRPCharacters[i]
      TurtleRPCharacters[i] = nil
    end
  end
end
-- allowing for blizzard raid colors based on rp colors setting being off
function TurtleRP.GetClassTokenFromCharacter(character)
    if not character then
        return nil
    end
    if character["class_token"] and character["class_token"] ~= "" then
        local token = string.upper(character["class_token"])
        if RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
            return token
        end
    end

    if character["class"] and character["class"] ~= "" then
        local classValue = string.upper(character["class"])
        if RAID_CLASS_COLORS and RAID_CLASS_COLORS[classValue] then
            return classValue
        end
        if LOCALIZED_CLASS_NAMES_MALE then
            for token, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
                if localized == character["class"] then
                    return token
                end
            end
        end
        if LOCALIZED_CLASS_NAMES_FEMALE then
            for token, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
                if localized == character["class"] then
                    return token
                end
            end
        end
    end
	
    if character["class_color"] and character["class_color"] ~= "" and TurtleRPClassData then
        local wanted = string.lower(character["class_color"])
        for localizedClass, classData in pairs(TurtleRPClassData) do
            if classData and classData[4] and string.lower(classData[4]) == wanted then
                local token = string.upper(localizedClass)
                if RAID_CLASS_COLORS and RAID_CLASS_COLORS[token] then
                    return token
                end
                if LOCALIZED_CLASS_NAMES_MALE then
                    for raidToken, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
                        if localized == localizedClass then
                            return raidToken
                        end
                    end
                end
                if LOCALIZED_CLASS_NAMES_FEMALE then
                    for raidToken, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
                        if localized == localizedClass then
                            return raidToken
                        end
                    end
                end
            end
        end
    end
    return nil
end

function TurtleRP.GetRaidClassColorHex(character)
    local classToken = TurtleRP.GetClassTokenFromCharacter(character)
    if not classToken or not RAID_CLASS_COLORS or not RAID_CLASS_COLORS[classToken] then
        return nil
    end
    local color = RAID_CLASS_COLORS[classToken]
    return string.format("%02x%02x%02x",
        math.floor(color.r * 255),
        math.floor(color.g * 255),
        math.floor(color.b * 255))
end

function TurtleRP.IsRPColorDisabledForPlayer(playerName)
    if not playerName or not TurtleRPCharacterInfo then
        return false
    end
    if not TurtleRPCharacterInfo["character_disable_rp_color"] then
        TurtleRPCharacterInfo["character_disable_rp_color"] = {}
    end
    return TurtleRPCharacterInfo["character_disable_rp_color"][playerName] == "1"
end

function TurtleRP.ToggleRPColorDisabledForPlayer(playerName)
    if not playerName or playerName == "" or playerName == UnitName("player") then
        return
    end
    if not TurtleRPCharacterInfo["character_disable_rp_color"] then
        TurtleRPCharacterInfo["character_disable_rp_color"] = {}
    end

    if TurtleRPCharacterInfo["character_disable_rp_color"][playerName] == "1" then
        TurtleRPCharacterInfo["character_disable_rp_color"][playerName] = "0"
    else
        TurtleRPCharacterInfo["character_disable_rp_color"][playerName] = "1"
    end

    if TurtleRP_CharacterDetails and TurtleRP_CharacterDetails:IsShown() then
        if TurtleRP.currentProfileTab == "notes" then
            TurtleRP.buildNotes(playerName)
        elseif TurtleRP.currentProfileTab == "general" then
            TurtleRP.buildGeneral(playerName)
        end
    end
end

function TurtleRP.GetEffectiveClassColorHex(playerName, character)
    character = character or (TurtleRPCharacters and playerName and TurtleRPCharacters[playerName]) or nil
    if not character then
        return nil
    end

    if playerName and TurtleRP.IsRPColorDisabledForPlayer(playerName) then
        return TurtleRP.GetRaidClassColorHex(character)
    end

    if character["class_color"] and character["class_color"] ~= "" then
        return character["class_color"]
    end

    return TurtleRP.GetRaidClassColorHex(character)
end
-- replacing the IGN with turtle rp name, using the full_name variable
function TurtleRP.GetChatDisplayName(playerName, displayedName, includeTitle)
    local fallbackName = displayedName or playerName or ""
    local showNames = TurtleRPSettings and TurtleRPSettings["chat_names"] == "1"
    local showColors = TurtleRPSettings and TurtleRPSettings["chat_colors"] == "1"
    local character = TurtleRPCharacters and playerName and TurtleRPCharacters[playerName] or nil

    local fallbackStripped = string.gsub(fallbackName, "|[cC][fF][fF]%x%x%x%x%x%x", "")
    fallbackStripped = string.gsub(fallbackStripped, "|[rR]", "")
    if not showNames then
        local effectiveColor = TurtleRP.GetEffectiveClassColorHex(playerName, character)
        if showColors and effectiveColor and effectiveColor ~= "" then
            return "|cff" .. effectiveColor .. fallbackStripped .. "|r"
        end
        return fallbackName
    end
    if not character or not character.full_name or character.full_name == "" then
        local effectiveColor = TurtleRP.GetEffectiveClassColorHex(playerName, character)
        if showColors and effectiveColor and effectiveColor ~= "" then
            return "|cff" .. effectiveColor .. fallbackStripped .. "|r"
        end
        return fallbackName
    end
    local baseName = character.full_name
    local rawName = baseName
    if includeTitle and character.title and character.title ~= "" then
        rawName = character.title .. " " .. rawName
    end
    local strippedName = string.gsub(rawName, "|[cC][fF][fF]%x%x%x%x%x%x", "")
    strippedName = string.gsub(strippedName, "|[rR]", "")
    if showColors then
        if string.find(baseName, "|[cC][fF][fF]%x%x%x%x%x%x") and not TurtleRP.IsRPColorDisabledForPlayer(playerName) then
            return rawName
        end
        local effectiveColor = TurtleRP.GetEffectiveClassColorHex(playerName, character)
        if effectiveColor and effectiveColor ~= "" then
            return "|cff" .. effectiveColor .. strippedName .. "|r"
        end
        return strippedName
    end
    local raidColorHex = TurtleRP.GetRaidClassColorHex(character)
    if raidColorHex then
        return "|cff" .. raidColorHex .. strippedName .. "|r"
    end
    return strippedName
end

function TurtleRP.ReplaceNamesInChat(text)
    if not text or not TurtleRPCharacters then
        return text
    end
    local showNames = TurtleRPSettings["chat_names"] == "1"
    local showColors = TurtleRPSettings["chat_colors"] == "1"
    if not showNames and not showColors then
        return text
    end
    text = string.gsub(text, "(|Hplayer:([^:|]+)[^|]*|h%[)([^%]]+)(%]|h)", function(prefix, rawName, displayedName, suffix)
        if strlower(rawName) == "usertag" then
            return prefix .. "" .. suffix
        end
        local finalName = TurtleRP.GetChatDisplayName(rawName, displayedName, false)
        return prefix .. finalName .. suffix
    end)
    return text
end

function TurtleRP.HookChatFrames()
    for i = 1, 7 do
        local frame = getglobal("ChatFrame" .. i)
        if frame and not frame.TurtleRPHooked then
            local originalAddMessage = frame.AddMessage
            frame.AddMessage = function(self, text, r, g, b, id)
                local skipReplace = false
                if text then
                    local checkText = text
                    checkText = string.gsub(checkText, "|c%x%x%x%x%x%x%x%x", "")
                    checkText = string.gsub(checkText, "|r", "")
                    checkText = string.gsub(checkText, "|H.-|h(.-)|h", "%1")
                    checkText = string.lower(checkText)
                    if string.find(checkText, "general")
                    or string.find(checkText, "trade")
                    or string.find(checkText, "world")
                    or string.find(checkText, "hardcore")
                    or string.find(checkText, "lookingforgroup")
                    or string.find(checkText, "%f[%a]lfg%f[%A]") then
                        skipReplace = true
                    end
                end
                if not skipReplace then
                    text = TurtleRP.ReplaceNamesInChat(text)
                end
                originalAddMessage(self, text, r, g, b, id)
            end
            frame.TurtleRPHooked = true
        end
    end
end
function TurtleRP.ShowProfileFromChatLink(playerName)
    if not playerName or playerName == "" then
        return
    end

    TurtleRP.currentlyViewedPlayer = playerName
    TurtleRP.sendRequestForData("M", playerName)
    TurtleRP.OpenProfile("general")
end

function TurtleRP.ShowChatPlayerMenu(playerName)
    if not playerName or playerName == "" then
        return
    end

    if not TurtleRP.ChatPlayerMenu then
        TurtleRP.ChatPlayerMenu = CreateFrame("Frame", "TurtleRP_ChatPlayerMenu", UIParent, "UIDropDownMenuTemplate")
    end

    TurtleRP.chatMenuPlayerName = playerName

    UIDropDownMenu_Initialize(TurtleRP.ChatPlayerMenu, function()
        local info = UIDropDownMenu_CreateInfo()

        info.text = playerName
        info.isTitle = 1
        info.notCheckable = 1
        info.disabled = 1
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Whisper"
        info.notCheckable = 1
        info.func = function()
            ChatFrame_SendTell(TurtleRP.chatMenuPlayerName)
        end
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Invite"
        info.notCheckable = 1
        info.func = function()
            InviteByName(TurtleRP.chatMenuPlayerName)
        end
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Target"
        info.notCheckable = 1
        info.func = function()
            TargetByName(TurtleRP.chatMenuPlayerName, true)
        end
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
		info.text = "Report Player"
		info.notCheckable = 1
		info.func = function()
			CloseDropDownMenus()
			if ToggleHelpFrame then
				ToggleHelpFrame()
			end
			if HelpFrame and HelpFrame:IsShown() then
				if HelpFrame_ShowFrame and HelpFrameOpenTicket then
					HelpFrame_ShowFrame(HelpFrameOpenTicket)
				end
			end
		end
		UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Show TurtleRP Profile"
        info.notCheckable = 1
        info.func = function()
            TurtleRP.ShowProfileFromChatLink(TurtleRP.chatMenuPlayerName)
        end
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Ignore Player"
        info.notCheckable = 1
        info.func = function()
            AddIgnore(TurtleRP.chatMenuPlayerName)
        end
        UIDropDownMenu_AddButton(info)

        info = UIDropDownMenu_CreateInfo()
        info.text = "Cancel"
        info.notCheckable = 1
        info.func = function()
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end)

    if TurtleRP.ChatPlayerMenuDelayFrame then
        TurtleRP.ChatPlayerMenuDelayFrame:SetScript("OnUpdate", nil)
    else
        TurtleRP.ChatPlayerMenuDelayFrame = CreateFrame("Frame")
    end

    local opened = false
    TurtleRP.ChatPlayerMenuDelayFrame:SetScript("OnUpdate", function()
        if opened then
            TurtleRP.ChatPlayerMenuDelayFrame:SetScript("OnUpdate", nil)
            return
        end
        opened = true
        ToggleDropDownMenu(1, nil, TurtleRP.ChatPlayerMenu, "cursor", 24, -24)
    end)
end

--New chat message to show player_name variable when shift clicking due to the hook overriding it
function TurtleRP.HookPlayerLinkClicks()
    if TurtleRP.playerLinkHooked then
        return
    end
    TurtleRP.playerLinkHooked = true
    TurtleRP.originalSetItemRef = SetItemRef

    SetItemRef = function(link, text, button)
        if link then
            local _, _, linkType, playerName = string.find(link, "^(%a+):([^:]+)")
            if linkType == "player" and playerName then
                if button == "RightButton" then
                    TurtleRP.ShowChatPlayerMenu(playerName)
                    return
                end

                if IsShiftKeyDown() then
                    local message = "|cff999999Player:|r " .. playerName
                    if TurtleRP.IsDevProfile(playerName) then
                        message = message .. " [" .. TurtleRP.GetDevBadgeText() .. "|r]"
                    end
                    DEFAULT_CHAT_FRAME:AddMessage(message)
                end
            end
        end

        TurtleRP.originalSetItemRef(link, text, button)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
        TurtleRP.HookChatFrames()
        TurtleRP.HookPlayerLinkClicks()
        if TurtleRP.OnLoad then
            TurtleRP.OnLoad()
        end
    elseif event == "PLAYER_LEVEL_UP" then
        TurtleRP.CheckLevelForChannel(arg1, false)
    elseif event == "PLAYER_ENTERING_WORLD" then
        TurtleRP.HookChatFrames()
        TurtleRP.CheckLevelForChannel(UnitLevel("player"), true)
    end
end)

function TurtleRP.log(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg)
end
