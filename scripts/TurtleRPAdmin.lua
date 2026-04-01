--[[
  Created by Vee (http://victortemprano.com), Drixi in-game
  See Github repo at https://github.com/tempranova/turtlerp
]]

-----
-- Interface helpers
-----

function TurtleRP.OpenAdmin()
  UIPanelWindows["TurtleRP_AdminSB"] = { area = "left", pushable = 0 }

  TurtleRP.previewCharacterInfo = nil
  TurtleRP.previewSource = nil
  if TurtleRP_IconSelector then
    TurtleRP_IconSelector.selectedIconIndex = {}
  end

  ShowUIPanel(TurtleRP_AdminSB)
  TurtleRP.populate_interface_user_data()
  TurtleRP.RefreshAdminStateSnapshot()

  local adminTabs = {
    [1] = { texture = "Interface\\Icons\\Spell_Nature_MoonGlow", tooltip = "Profile" },
    [2] = { texture = "Interface\\Icons\\INV_Misc_Head_Human_02", tooltip = "At A Glance" },
    [3] = { texture = "Interface\\Icons\\INV_Misc_StoneTablet_11", tooltip = "Description" },
    [4] = { texture = "Interface\\Icons\\INV_Letter_03", tooltip = "Notes" },
    [5] = { texture = "Interface\\Icons\\Trade_Engineering", tooltip = "Settings" },
    [6] = { texture = "Interface\\Icons\\INV_Misc_QuestionMark", tooltip = "About / Help" }
  }

  for i = 1, 6 do
    local tab = getglobal("TurtleRP_AdminSB_Tab" .. i)
    local tabData = adminTabs[i]
    tab:SetNormalTexture(tabData.texture)
    tab.tooltip = tabData.tooltip
    tab:Show()
  end

  TurtleRP_AdminSB_Content1_Tab2:Hide()

  TurtleRP_AdminSB_SpellBookFrameTabButton1:SetText("Basic Info")
  TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
  TurtleRP_AdminSB_SpellBookFrameTabButton1.bookType = "profile"
  TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
  TurtleRP_AdminSB_SpellBookFrameTabButton2:SetText("RP Style")
  TurtleRP_AdminSB_SpellBookFrameTabButton2.bookType = "rp_style"

  TurtleRP.OnAdminTabClick(1)
  TurtleRP.currentDescriptionAlign = ""

end
TurtleRP.currentDescriptionTag = "p"
TurtleRP.currentDescriptionAlign = ""

function TurtleRP.InsertDescriptionTag(tag)
    TurtleRP.currentDescriptionTag = tag
    TurtleRP.ApplyDescriptionTag()
end

function TurtleRP.SetDescriptionAlign(align)
    TurtleRP.currentDescriptionAlign = align
    if TurtleRP_AdminSB_Content3_LeftButton then
        TurtleRP_AdminSB_Content3_LeftButton:SetChecked(align == "")
    end
    if TurtleRP_AdminSB_Content3_CenterButton then
        TurtleRP_AdminSB_Content3_CenterButton:SetChecked(align == ":c")
    end
    if TurtleRP_AdminSB_Content3_RightButton then
        TurtleRP_AdminSB_Content3_RightButton:SetChecked(align == ":r")
    end
end

function TurtleRP.ApplyDescriptionTag()
    local box = TurtleRP_AdminSB_Content3_DescriptionScrollBox_DescriptionInput
    if not box then return end
    local tag = TurtleRP.currentDescriptionTag or "p"
    local align = TurtleRP.currentDescriptionAlign or ""
    local openTag = "<" .. tag .. align .. ">"
    local placeholder = "Your text here!"
    local insertText = openTag .. " " .. placeholder .. " " .. "</" .. tag .. ">"
    local existingText = box:GetText() or ""
	local startPos = string.len(existingText .. openTag .. " ")
	local endPos = startPos + string.len(placeholder)

    box:SetText(existingText .. insertText)
    box:SetFocus()

    if box.HighlightText then
        box:HighlightText(startPos, endPos)
    end
end

function TurtleRP.ApplyAdminTabClick(id)
  for i=1, 6 do
    if i ~= id then
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(0)
      getglobal("TurtleRP_AdminSB_Content"..i):Hide()
    else
      getglobal("TurtleRP_AdminSB_Tab"..i):SetChecked(1)
      getglobal("TurtleRP_AdminSB_Content"..i):Show()
    end
  end
  TurtleRP_AdminSB_Content1_Tab2:Hide()
  TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
  TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-SpellBook-Tab-Unselected")
  if id == 1 then
    TurtleRP_AdminSB_SpellBookFrameTabButton1:Show()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:Show()
  else
    TurtleRP_AdminSB_SpellBookFrameTabButton1:Hide()
    TurtleRP_AdminSB_SpellBookFrameTabButton2:Hide()
  end
end

function TurtleRP.OnAdminTabClick(id)
  local currentTab = nil
  for i=1, 6 do
    local tab = getglobal("TurtleRP_AdminSB_Tab"..i)
    if tab and tab:GetChecked() then
      currentTab = i
      break
    end
  end
  if currentTab == id then
    TurtleRP.ApplyAdminTabClick(id)
    return
  end
  TurtleRP.RequestAdminTabSwitch("main", id)
end

function TurtleRP.ApplyBottomTabAdminClick(bookType)
  if bookType == "profile" then
    TurtleRP_AdminSB_Content1:Show()
    TurtleRP_AdminSB_Content1_Tab2:Hide()
    TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
    TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\SpellBook\\UI-SpellBook-Tab-Unselected")
  elseif bookType == "rp_style" then
    TurtleRP_AdminSB_Content1:Hide()
    TurtleRP_AdminSB_Content1_Tab2:Show()
    TurtleRP_AdminSB_SpellBookFrameTabButton1:SetNormalTexture("Interface\\SpellBook\\UI-SpellBook-Tab-Unselected")
    TurtleRP_AdminSB_SpellBookFrameTabButton2:SetNormalTexture("Interface\\Spellbook\\UI-Spellbook-Tab1-Selected")
    TurtleRP.SetInitialDropdowns()
  end
end

function TurtleRP.OnBottomTabAdminClick(bookType)
  local currentBookType = "profile"
  if TurtleRP_AdminSB_Content1_Tab2 and TurtleRP_AdminSB_Content1_Tab2:IsShown() then
    currentBookType = "rp_style"
  end

  if currentBookType == bookType then
    TurtleRP.ApplyBottomTabAdminClick(bookType)
    return
  end

  TurtleRP.RequestAdminTabSwitch("bottom", bookType)
end

function TurtleRP.ShouldShareLocation()
  if TurtleRPSettings["share_location"] ~= "1" then
    return false
  end
  if TurtleRPSettings["bgs"] == "on" and UnitIsPVP("player") then
    return false
  end

  return true
end

function TurtleRP.showColorPicker(r, g, b, a, changedCallback)
 ColorPickerFrame:SetColorRGB(r, g, b);
 ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
 ColorPickerFrame.previousValues = {r,g,b,a};
 ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
 ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
 ColorPickerFrame:Show();
end

function TurtleRP.colorPickerCallback(restore)
  local newR, newG, newB, newA
  if restore then
    newR, newG, newB, newA = unpack(restore)
  else
    newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
  end

  local r, g, b, a = newR, newG, newB, newA
  TurtleRP_AdminSB_Content1_ClassColorButton:SetBackdropColor(r, g, b)
end

-----
-- Dropdown RP Style selectors
-----
function TurtleRP.InitializeRPStyleDropdown(frame, items)
  UIDropDownMenu_Initialize(frame, function()
    local frameName = frame:GetName()
    for i, v in items do
      local info = {}
      info.text = v
      info.value = i
      info.arg1 = v
      info.checked = false
      info.menuList = i
      info.hasArrow = false
      info.func = function(text)
        getglobal(frameName .. "_Text"):SetText(text)
        UIDropDownMenu_SetSelectedValue(frame, this.value)
        CloseDropDownMenus()
      end
      UIDropDownMenu_AddButton(info)
    end
  end)
end

function TurtleRP.SetInitialDropdowns()
  local dropdownsToSet = {}
  dropdownsToSet["experience"] = TurtleRP_AdminSB_Content1_Tab2_ExperienceDropdown
  dropdownsToSet["walkups"] = TurtleRP_AdminSB_Content1_Tab2_WalkupsDropdown
  dropdownsToSet["injury"] = TurtleRP_AdminSB_Content1_Tab2_InjuryDropdown
  dropdownsToSet["romance"] = TurtleRP_AdminSB_Content1_Tab2_RomanceDropdown
  dropdownsToSet["death"] = TurtleRP_AdminSB_Content1_Tab2_DeathDropdown

  for i, v in dropdownsToSet do
    if TurtleRPCharacters[UnitName("player")][i] ~= "0" then
      local thisValue = TurtleRPCharacters[UnitName("player")][i]
      getglobal(v:GetName() .. "_Text"):SetText(TurtleRPDropdownOptions[i][thisValue])
      UIDropDownMenu_SetSelectedValue(v, thisValue)
    end
  end
end

-----
-- Icon Selector
-----
function TurtleRP.create_icon_selector()
  TurtleRP_IconSelector:Show()
  TurtleRP_IconSelector:SetFrameStrata("high")
  TurtleRP_IconSelector_FilterSearchInput:SetFrameStrata("high")
  TurtleRP_IconSelector_ScrollBox:SetFrameStrata("high")
  if TurtleRP.iconFrames == nil then
    TurtleRP.iconFrames = TurtleRP.makeIconFrames()
  end
  TurtleRP.iconSelectorFilter = ""
  TurtleRP_IconSelector_FilterSearchInput:SetText("")
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_IconSelector_ScrollBox)
  TurtleRP.renderIcons((currentLine))
end

function TurtleRP.Icon_ScrollBar_Update()
  FauxScrollFrame_Update(TurtleRP_IconSelector_ScrollBox, 450, 250, 32)
  local currentLine = FauxScrollFrame_GetOffset(TurtleRP_IconSelector_ScrollBox)
  TurtleRP.renderIcons((currentLine))
end

function TurtleRP.makeIconFrames()
  local IconFrames = {}
  local numberOnRow = 0
  local currentRow = 0
  for i = 1, 36 do
    local thisIconFrame = CreateFrame("Button", "TurtleRPIcon_" .. i, TurtleRP_IconSelector_ScrollBox)
    thisIconFrame:SetWidth(32)
    thisIconFrame:SetHeight(32)
    thisIconFrame:SetPoint("TOPLEFT", TurtleRP_IconSelector_ScrollBox, numberOnRow * 32, currentRow * -32)
    thisIconFrame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    thisIconFrame:SetText(i)
    thisIconFrame:SetFont("Fonts\\FRIZQT__.ttf", 0)
    thisIconFrame:SetScript("OnClick", function()
      local thisIconIndex = thisIconFrame:GetText()
      TurtleRP_IconSelector.selectedIconIndex = TurtleRP_IconSelector.selectedIconIndex or {}
      TurtleRP_IconSelector.selectedIconIndex[TurtleRP.currentIconSelector] = thisIconIndex
      if TurtleRP.currentIconSelector == "icon" then
        TurtleRP.setCharacterIcon()
      else
        TurtleRP.setAtAGlanceIcons()
      end

      TurtleRP_IconSelector:Hide()
    end)
    IconFrames[i] = thisIconFrame
    numberOnRow = numberOnRow + 1
    if (i - math.floor(i / 6) * 6) == 0 then
      currentRow = currentRow + 1
      numberOnRow = 0
    end
  end
  return IconFrames
end

function TurtleRP.renderIcons(iconOffset)
  if TurtleRP.iconFrames == nil then
    return
  end
  local filteredIcons = {}
  local numberAdded = 0
  local filterText = string.lower(TurtleRP.iconSelectorFilter or "")

  if filterText ~= "" then
    for i, iconName in ipairs(TurtleRPIcons) do
      if iconName and string.find(string.lower(iconName), filterText, 1, true) then
        numberAdded = numberAdded + 1
        filteredIcons[numberAdded] = i
      end
    end
  else
    for i, iconName in ipairs(TurtleRPIcons) do
      numberAdded = numberAdded + 1
      filteredIcons[numberAdded] = i
    end
  end

  for i, iconFrame in ipairs(TurtleRP.iconFrames) do
    local iconListIndex = filteredIcons[i + iconOffset]
    local iconName = iconListIndex and TurtleRPIcons[iconListIndex]
    if iconName then
      iconFrame:SetText(iconListIndex)
      iconFrame:SetBackdrop({ bgFile = "Interface\\Icons\\" .. iconName })
    else
      iconFrame:SetText("")
      iconFrame:SetBackdrop(nil)
    end
  end
end

function TurtleRP.ToggleChatNames()
  if TurtleRPSettings["chat_names"] == "1" then
    TurtleRPSettings["chat_names"] = "0"
    TurtleRP_AdminSB_Content5_ChatNamesButton:SetChecked(false)
  else
    TurtleRPSettings["chat_names"] = "1"
    TurtleRP_AdminSB_Content5_ChatNamesButton:SetChecked(true)
  end
end
