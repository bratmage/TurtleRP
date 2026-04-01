--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

function TurtleRP.OpenProfile(openTo)
  TurtleRP_CharacterDetails_FrameTabButton1.bookType = "general"
  TurtleRP_CharacterDetails_FrameTabButton2.bookType = "description"
  TurtleRP_CharacterDetails_FrameTabButton3.bookType = "notes"

  if not TurtleRP.currentlyViewedPlayer or TurtleRP.currentlyViewedPlayer == "" then
    TurtleRP.currentlyViewedPlayer = UnitName("player")
  end

  UIPanelWindows["TurtleRP_CharacterDetails"] = { area = "left", pushable = 6 }
  ShowUIPanel(TurtleRP_CharacterDetails)

  TurtleRP.OnBottomTabProfileClick(openTo)
end

function TurtleRP.OpenProfilePreview(openTo)
  TurtleRP_CharacterDetails_FrameTabButton1.bookType = "general"
  TurtleRP_CharacterDetails_FrameTabButton2.bookType = "description"
  TurtleRP_CharacterDetails_FrameTabButton3.bookType = "notes"

  if not TurtleRP.currentlyViewedPlayer or TurtleRP.currentlyViewedPlayer == "" then
    TurtleRP.currentlyViewedPlayer = UnitName("player")
  end

  TurtleRP_CharacterDetails:ClearAllPoints()

  if TurtleRP_AdminSB and TurtleRP_AdminSB:IsShown() then
    TurtleRP_CharacterDetails:SetPoint("TOPLEFT", TurtleRP_AdminSB, "TOPRIGHT", 20, 0)
  else
    TurtleRP_CharacterDetails:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end

  TurtleRP_CharacterDetails:Show()
  TurtleRP.OnBottomTabProfileClick(openTo)
end

function TurtleRP.OnBottomTabProfileClick(bookType)
  TurtleRP.currentProfileTab = bookType or "general"

  TurtleRP_CharacterDetails_General:Hide()
  TurtleRP_CharacterDetails_DescriptionScrollBox:Hide()
  TurtleRP_CharacterDetails_Notes:Hide()

  if TurtleRP.currentProfileTab == "general" then
    TurtleRP.buildGeneral(TurtleRP.currentlyViewedPlayer)
  end

  if TurtleRP.currentProfileTab == "description" then
    TurtleRP.buildDescription(TurtleRP.currentlyViewedPlayer)
  end

  if TurtleRP.currentProfileTab == "notes" then
    TurtleRP.buildNotes(TurtleRP.currentlyViewedPlayer)
  end
end

function TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, frame, stringToShow, overrideHide)
  local frameHidden = false
  if characterInfo["keyM"] == nil or overrideHide == true or stringToShow == nil or stringToShow == "" then
    frame:Hide()
    frameHidden = true
  else
    frame:Show()
    frame:SetText(stringToShow)
    local currentHeight = frame:GetHeight()
    if frame:GetStringWidth() > 265 and floor(currentHeight + 0.5) ~= 30 then
      frame:SetHeight(30)
    elseif frame:GetStringWidth() < 265 and floor(currentHeight + 0.5) == 30 then
      frame:SetHeight(10)
    end
  end
  if lastFrame ~= nil then
    if frameHidden then
      frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
      return lastFrame
    end
    frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
  end
  return frame
end

function TurtleRP.buildGeneral(playerName)
  playerName = playerName or TurtleRP.currentlyViewedPlayer or UnitName("player")
  TurtleRP.currentlyViewedPlayer = playerName
  TurtleRP.currentProfileTab = "general"

  TurtleRP_CharacterDetails_DescriptionScrollBox:Hide()
  TurtleRP_CharacterDetails_Notes:Hide()

  local characterInfo = TurtleRP.previewCharacterInfo or TurtleRPCharacters[playerName]
  TurtleRP.SetNameAndIcon(playerName, characterInfo)
  if not characterInfo then
    return
  end
  local raceClassString = ""
  if characterInfo["keyM"] ~= nil then
    local classColor = TurtleRP.GetEffectiveClassColorHex(playerName, characterInfo)
    if classColor and classColor ~= "" then
      raceClassString = characterInfo["race"] .. "|cff" .. classColor .. " " .. characterInfo["class"]
    else
      raceClassString = characterInfo["race"] .. " " .. characterInfo["class"]
    end
  end

  local lastFrame = nil
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_TargetRaceClass, raceClassString)
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_ICOOC, characterInfo["currently_ic"] == "1" and "|cff40AF6FIC" or "|cffD3681EOOC")
    if TurtleRP.IsDevProfile(playerName) then
    TurtleRP_CharacterDetails_General_DevText:SetText(TurtleRP.GetDevBadgeText())
    TurtleRP_CharacterDetails_General_DevText:Show()
  else
    TurtleRP_CharacterDetails_General_DevText:SetText("")
    TurtleRP_CharacterDetails_General_DevText:Hide()
  end
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_ICInfo, "|cffCC9900IC Info" .. TurtleRP.getPronounsText(characterInfo["ic_pronouns"], "|cffffcc80"), characterInfo["ic_info"] == nil or characterInfo["ic_info"] == "")
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_ICInfoText, characterInfo["ic_info"])
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_OOCInfo, "|cffCC9900OOC Info" .. TurtleRP.getPronounsText(characterInfo["ooc_pronouns"], "|cffffcc80"), characterInfo["ooc_info"] == nil or characterInfo["ooc_info"] == "")
  lastFrame = TurtleRP.ShowOrHideProfileDetails(lastFrame, characterInfo, TurtleRP_CharacterDetails_General_OOCInfoText, characterInfo["ooc_info"])

  TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", lastFrame, "BOTTOMLEFT", 0, -10)

  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Experience, TurtleRPDropdownOptions["experience"][characterInfo["experience"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Walkups, TurtleRPDropdownOptions["walkups"][characterInfo["walkups"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Injury, TurtleRPDropdownOptions["injury"][characterInfo["injury"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Romance, TurtleRPDropdownOptions["romance"][characterInfo["romance"]])
  TurtleRP.ShowOrHideProfileDetails(nil, characterInfo, TurtleRP_CharacterDetails_General_Death, TurtleRPDropdownOptions["death"][characterInfo["death"]])

  TurtleRP_CharacterDetails_General_AtAGlance1:Hide()
  TurtleRP_CharacterDetails_General_AtAGlance2:Hide()
  TurtleRP_CharacterDetails_General_AtAGlance3:Hide()
  if characterInfo["keyT"] ~= nil then
    if characterInfo['atAGlance1Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance1Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance1_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance1_TextPanel_TitleText:SetText(characterInfo["atAGlance1Title"])
      TurtleRP_CharacterDetails_General_AtAGlance1_TextPanel_Text:SetText(characterInfo["atAGlance1"])
      TurtleRP_CharacterDetails_General_AtAGlance1:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

    if characterInfo['atAGlance2Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance2Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance2_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance2_TextPanel_TitleText:SetText(characterInfo["atAGlance2Title"])
      TurtleRP_CharacterDetails_General_AtAGlance2_TextPanel_Text:SetText(characterInfo["atAGlance2"])
      TurtleRP_CharacterDetails_General_AtAGlance2:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

    if characterInfo['atAGlance3Icon'] ~= "" then
      local iconIndex = characterInfo["atAGlance3Icon"]
      TurtleRP_CharacterDetails_General_AtAGlance3_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(iconIndex)])
      TurtleRP_CharacterDetails_General_AtAGlance3_TextPanel_TitleText:SetText(characterInfo["atAGlance3Title"])
      TurtleRP_CharacterDetails_General_AtAGlance3_TextPanel_Text:SetText(characterInfo["atAGlance3"])
      TurtleRP_CharacterDetails_General_AtAGlance3:Show()
      TurtleRP_CharacterDetails_General_DarkBack:SetPoint("BOTTOMLEFT", TurtleRP_CharacterDetails_General_OOCInfoText, "BOTTOMLEFT", 0, -40)
    end

  end

  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")

  TurtleRP_CharacterDetails_General:Show()
end

function TurtleRP.buildDescription(playerName)
  playerName = playerName or TurtleRP.currentlyViewedPlayer or UnitName("player")
  TurtleRP.currentlyViewedPlayer = playerName
  TurtleRP.currentProfileTab = "description"

  local characterInfo = TurtleRP.previewCharacterInfo or TurtleRPCharacters[playerName]
  if not characterInfo then
    return
  end

  TurtleRP_CharacterDetails_General:Hide()
  TurtleRP_CharacterDetails_Notes:Hide()

  local htmlFrame = TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML
  local plainTextFrame = TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder_DescriptionHTML_TargetDescription
  local holderFrame = TurtleRP_CharacterDetails_DescriptionScrollBox_DescriptionHolder

  htmlFrame:SetText("")
  plainTextFrame:SetText("")
  holderFrame:SetHeight(50)

  if characterInfo["keyD"] ~= nil then
    TurtleRP.SetNameAndIcon(playerName, characterInfo)

    local descriptionText = characterInfo["description"] or ""

    if TurtleRP.DescriptionHasSupportedMarkup(descriptionText) then
      htmlFrame:SetHeight(1000)
      holderFrame:SetHeight(1000)
      htmlFrame:SetText(TurtleRP.SanitizeDescriptionHTML(descriptionText))
      plainTextFrame:SetText("")
    else
      local plainText = TurtleRP.NormalizePlainDescription(descriptionText)
      htmlFrame:SetText("")
      plainTextFrame:SetText(plainText or "")

      if plainText == nil or plainText == "" then
        holderFrame:SetHeight(50)
      else
        local textHeight = plainTextFrame:GetHeight() or 0
        holderFrame:SetHeight(math.max(50, textHeight + 20))
      end
    end
  end

  TurtleRP_CharacterDetails_DescriptionScrollBox:Show()
  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
end

function TurtleRP.buildNotes(playerName)
  playerName = playerName or TurtleRP.currentlyViewedPlayer or UnitName("player")
  TurtleRP.currentlyViewedPlayer = playerName
  TurtleRP.currentProfileTab = "notes"

  TurtleRP_CharacterDetails_General:Hide()
  TurtleRP_CharacterDetails_DescriptionScrollBox:Hide()

  local characterInfo = TurtleRPCharacters[playerName]
  if not characterInfo then
    return
  end
  TurtleRP.SetNameAndIcon(playerName)
  if playerName == UnitName("player") then
    TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:SetText(
      TurtleRPCharacterInfo["notes"] or ""
    )
    TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:SetText(
      TurtleRPCharacterInfo["short_note"] or ""
    )
    TurtleRP_CharacterDetails_Notes_DisableRPColorButton:Hide()
    TurtleRP_CharacterDetails_Notes_DisableRPColorText:Hide()
  else
    if TurtleRPCharacterInfo["character_notes"][TurtleRP.currentlyViewedPlayer] ~= nil then
      TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:SetText(
        TurtleRPCharacterInfo["character_notes"][TurtleRP.currentlyViewedPlayer]
      )
    else
      TurtleRP_CharacterDetails_Notes_NotesScrollBox_NotesContent_NotesInput:SetText("")
    end
    if TurtleRPCharacterInfo["character_short_notes"]
      and TurtleRPCharacterInfo["character_short_notes"][TurtleRP.currentlyViewedPlayer] ~= nil then
      TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:SetText(
        TurtleRPCharacterInfo["character_short_notes"][TurtleRP.currentlyViewedPlayer]
      )
    else
      TurtleRP_CharacterDetails_Notes_ShortNoteBox_Input:SetText("")
    end
    TurtleRP_CharacterDetails_Notes_DisableRPColorButton:SetChecked(
      TurtleRP.IsRPColorDisabledForPlayer(playerName)
    )
    TurtleRP_CharacterDetails_Notes_DisableRPColorButton:Show()
    TurtleRP_CharacterDetails_Notes_DisableRPColorText:Show()
  end
  TurtleRP_CharacterDetails_Notes:Show()
  TurtleRP_CharacterDetails_FrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab-Unselected")
  TurtleRP_CharacterDetails_FrameTabButton3:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab1-Selected")
end

function TurtleRP.DescriptionHasSupportedMarkup(text)
  if not text or text == "" then
    return false
  end
  local lowerText = string.lower(text)
  return string.find(lowerText, "<%s*/?%s*h1[%s>]")
      or string.find(lowerText, "<%s*/?%s*h2[%s>]")
      or string.find(lowerText, "<%s*/?%s*h3[%s>]")
      or string.find(lowerText, "<%s*/?%s*p[%s>]")
      or string.find(lowerText, "<%s*br[%s/>]")
end
function TurtleRP.ExpandShortTags(text)
  if not text then return "" end

  local t = text
  t = gsub(t, "<h1:c>", '<h1 align="center">')
  t = gsub(t, "<h2:c>", '<h2 align="center">')
  t = gsub(t, "<h3:c>", '<h3 align="center">')
  t = gsub(t, "<p:c>",  '<p align="center">')

  t = gsub(t, "<h1:r>", '<h1 align="right">')
  t = gsub(t, "<h2:r>", '<h2 align="right">')
  t = gsub(t, "<h3:r>", '<h3 align="right">')
  t = gsub(t, "<p:r>",  '<p align="right">')

  t = gsub(t, "<h1:l>", '<h1 align="left">')
  t = gsub(t, "<h2:l>", '<h2 align="left">')
  t = gsub(t, "<h3:l>", '<h3 align="left">')
  t = gsub(t, "<p:l>",  '<p align="left">')

  t = gsub(t, "</h1:c>", "</h1>")
  t = gsub(t, "</h2:c>", "</h2>")
  t = gsub(t, "</h3:c>", "</h3>")
  t = gsub(t, "</p:c>",  "</p>")

  t = gsub(t, "</h1:r>", "</h1>")
  t = gsub(t, "</h2:r>", "</h2>")
  t = gsub(t, "</h3:r>", "</h3>")
  t = gsub(t, "</p:r>",  "</p>")

  t = gsub(t, "</h1:l>", "</h1>")
  t = gsub(t, "</h2:l>", "</h2>")
  t = gsub(t, "</h3:l>", "</h3>")
  t = gsub(t, "</p:l>",  "</p>")

  return t
end
function TurtleRP.SanitizeDescriptionHTML(text)
  if not text then
    return ""
  end

  local sanitized = TurtleRP.ExpandShortTags(text)
  sanitized = gsub(sanitized, "\r\n", "\n")
  sanitized = gsub(sanitized, "\r", "\n")
  sanitized = gsub(sanitized, "@N", "<br />")
  sanitized = gsub(sanitized, "\n", "<br />")

  sanitized = gsub(sanitized, "<%s*(/?)%s*([%a%d]+)(.-)>", function(closingSlash, tagName, attributes)
    local tag = string.lower(tagName or "")
    local isClosing = closingSlash == "/"
    local lowerAttributes = string.lower(attributes or "")
    if tag == "br" then
      return "<br />"
    end
    if tag ~= "h1" and tag ~= "h2" and tag ~= "h3" and tag ~= "p" then
      return ""
    end
    if isClosing then
      return "</" .. tag .. ">"
    end
    local _, _, align = string.find(lowerAttributes, 'align%s*=%s*"(.-)"')
    if not align then
      _, _, align = string.find(lowerAttributes, "align%s*=%s*'(.-)'")
    end
    if align == "left" or align == "center" or align == "right" then
      return "<" .. tag .. ' align="' .. align .. '">'
    end
    return "<" .. tag .. ">"
  end)
  return "<html><body>" .. sanitized .. "<br /><br /><br /></body></html>"
end

function TurtleRP.NormalizePlainDescription(text)
  if not text then
    return ""
  end

  local normalized = text
  normalized = gsub(normalized, "\r\n", "\n")
  normalized = gsub(normalized, "\r", "\n")
  normalized = gsub(normalized, "@N", "\n")

  return normalized
end
function TurtleRP.SetNameAndIcon(playerName, overrideCharacterInfo)
  local characterInfo = overrideCharacterInfo or TurtleRPCharacters[playerName]
  if characterInfo and characterInfo["keyM"] ~= nil then
    local nameToDisplay = characterInfo['full_name']
    if characterInfo['title'] and characterInfo['title'] ~= "" then
      nameToDisplay = characterInfo['title'] .. " " .. nameToDisplay
    end
    TurtleRP_CharacterDetails_TargetName:SetText(nameToDisplay)
    local icon = characterInfo['icon']
    if icon and TurtleRPIcons[tonumber(icon)] then
      TurtleRP_CharacterDetails_Icon:SetTexture("Interface\\Icons\\" .. TurtleRPIcons[tonumber(icon)])
      TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 65, -52)
      TurtleRP_CharacterDetails_Icon:Show()
    else
      TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 25, -52)
      TurtleRP_CharacterDetails_Icon:Hide()
    end
  else
    TurtleRP_CharacterDetails_Icon:Hide()
    TurtleRP_CharacterDetails_TargetName:SetPoint("TOPLEFT", 25, -52)
    TurtleRP_CharacterDetails_TargetName:SetText("No character info saved.")
    TurtleRP_CharacterDetails_General_TargetRaceClass:SetText("Try fetching, then re-opening this window, if the player is online.")
  end
end
