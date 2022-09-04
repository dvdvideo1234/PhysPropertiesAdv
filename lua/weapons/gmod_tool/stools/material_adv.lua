local goTool = TOOL
local gsTool = goTool.Mode -- Filled from file name
local gsPref = gsTool.."_"
local gsMats = "OverrideMaterials"
local varLng = GetConVar("gmod_language")

TOOL.ClientConVar = {
  ["randomize"] = 0,
  ["randommat"] = "",
  ["customset"] = gsMats,
  ["override" ] = "debug/env_cubemap_model"
}

if(CLIENT) then

  TOOL.Information = {
    { name = "left"  },
    { name = "right" },
    { name = "reload"}
  }

  language.Add("tool."..gsTool..".category", "Render")

  -- Global table for material count ( CLIENT )
  gtMCount = {Name = "", Size = 0, Data = {}, Base = {}}
  --[[
   * Calculates the random material
   * sNam > List name ( wthout prefix )
   * sMat > Current material selected
   * iCnt > Times for material to not repeat
  ]]
  function pickMaterial(sNam, sMat, iCnt)
    local ply = LocalPlayer()
    if(not ply) then return end
    if(not ply:IsValid()) then return end
    local cnt = (iCnt or GetConVar(gsTool.."_randomize"):GetInt())
    local key = (sNam or GetConVar(gsTool.."_customset"):GetString())
    local mat = (sMat or GetConVar(gsTool.."_randommat"):GetString())
    if(sNam) then RunConsoleCommand(gsTool.."_customset", key) end
    if(not key or key == "") then return end
    local key = (key == gsMats) and gsMats or (gsPref..key)
    local set = list.GetForEdit(key)
    if(not (set and set[1])) then return end
    if(key ~= gtMCount.Name) then
      gtMCount.Name = key
      table.Empty(gtMCount.Base)
    end
    if(cnt > 0) then
      local sid = tostring(SysTime()):reverse()
            sid = tonumber(sid:sub(1,6))
      local top = #set; math.randomseed(sid)
      local mxx = math.min(top, cnt)
      local idx = math.random(1, top)
      local new, brk = set[idx], (mxx + 15)
      math.random(1, top); math.random(1, top)
      if(gtMCount.Data[new]) then
        while(gtMCount.Data[new]) do
          brk = brk - 1 -- Brake the loop
          idx = math.random(1, top) -- Random
          new = set[idx] -- Index random
          if(brk <= 0) then break end
        end
      end
      if(gtMCount.Size >= mxx) then
        gtMCount.Size = 0
        table.Empty(gtMCount.Data)
      end
      gtMCount.Data[new] = true
      gtMCount.Size = gtMCount.Size + 1
      if(not gtMCount.Base[new]) then gtMCount.Base[new] = 1
      else gtMCount.Base[new] = gtMCount.Base[new] + 1 end
      RunConsoleCommand(gsTool.."_randommat", new)
    end
  end

  net.Receive(gsPref.."randomize", function() pickMaterial() end)

  local function setDatabase(tF)
    if(tF and tF[1]) then
      local sR, sF, sE = "rb", (gsTool.."/materials/%s.txt"), ("%.txt") -- Path format
      local sT, sM, sP, sD = (gsPref.."type"), ("*line"), ("%S+"), ("DATA")
      table.Empty(list.GetForEdit(sT)) -- Update the list with new values
      for iF = 1, #tF do local sN = tF[iF]:gsub(sE, "") -- Strip extension
        if(not list.Contains(sT, sN)) then list.Add(sT, sN) end
        local fT, fE = file.Open(sF:format(sN), sR, sD) -- Read type
        if(fT) then local sL = fT:ReadLine(sM) -- Process the line
          -- Update the list with new values by clearing it first
          local sI = (gsPref..sN); table.Empty(list.GetForEdit(sI))
          while(sL) do sL = sL:Trim() -- Avoid putting spaces
            -- Every separate word is written to the list
            if(sL ~= "" or sL:sub(1,1) ~= "#") then
              for sW in sL:gmatch(sP) do
                -- File names becomes entries type
                if(not list.Contains(sI, sW)) then list.Add(sI, sW) end
              end -- When skip the commented lines
            end; sL = fT:ReadLine(sM) -- Read the next line
          end; fT:Close() -- Additional type is processed from descriptor
        else ErrorNoHalt(gsTool..": "..tostring(fE)) end
      end -- All the file type descriptors are processed
    end
  end

  -- Changes to the convar so reload the tool's menu to update the localizations
  cvars.RemoveChangeCallback(varLng:GetName(), gsPref.."lang")
  cvars.AddChangeCallback(varLng:GetName(), function(sN, vO, vN)
    local cPanel = controlpanel.Get(goTool.Mode)
    if(not IsValid(cPanel)) then return end
    cPanel:ClearControls(); goTool.BuildCPanel(cPanel)
  end, gsPref.."lang")

  if(not file.Exists(gsTool,"DATA")) then file.CreateDir(gsTool) end
  setDatabase(file.Find(gsTool.."/materials/*.txt","DATA")) -- Search for text files
else
  util.AddNetworkString(gsPref.."randomize")
end

local gtConvar = TOOL:BuildConVarList()

TOOL.Category   = language and language.GetPhrase("tool."..gsTool..".category")
TOOL.Name       = language and language.GetPhrase("tool."..gsTool..".name")
TOOL.Command    = nil -- Command on click (nil for default)
TOOL.ConfigName = nil -- Configure file name (nil for default)

local function setMaterial(oPly, oEnt, tData)
  if(CLIENT) then return true end
  if(not (game.SinglePlayer() or tData.MaterialOverride == "")) then return end
  oEnt:SetMaterial(tData.MaterialOverride)
  duplicator.StoreEntityModifier(oEnt, gsTool, tData)
  return true
end

duplicator.RegisterEntityModifier(gsTool, setMaterial)

function TOOL:IsRandom()
  return (self:GetClientNumber("randomize", 0) > 0)
end

-- Left click applies the random
function TOOL:LeftClick(trace)
  local ent, ply = trace.Entity, self:GetOwner()
  if(IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end
  if(not IsValid(ent)) then return false end -- Entity invalid
  if(self:IsRandom()) then
    local key = self:GetClientInfo("customset")
    if(not key or key == "") then return false end
    net.Start(gsPref.."randomize"); net.Send(ply)
    local mat = self:GetClientInfo("randommat")
    setMaterial(ply, ent, {MaterialOverride = mat})
    return true
  else
    local mat = self:GetClientInfo("override")
    setMaterial(ply, ent, {MaterialOverride = mat})
  end
  return true
end

-- Right click copies the material
function TOOL:RightClick(trace)
  if(CLIENT) then return true end
  local ent, ply = trace.Entity, self:GetOwner()
  if(IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end
  if(not IsValid(ent)) then return false end -- Entity invalid
  if(not IsValid(ply)) then return false end -- Player invalid
  ply:ConCommand(gsTool.."_override "..ent:GetMaterial())
  return true
end

-- Reload reverts the material
function TOOL:Reload(trace)
  if(CLIENT) then return true end
  local ent, ply = trace.Entity, self:GetOwner()
  if(IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end
  if(not IsValid(ent)) then return false end -- Entity invalid
  if(not IsValid(ply)) then return false end -- Player invalid
  setMaterial(ply, ent, {MaterialOverride = ""})
  return true
end

function wipeMaterials(pMat)
  for k, v in pairs(pMat.Controls) do
    v:Remove(); pMat.Controls[k] = nil
  end; pMat.List:CleanList()
  pMat.SelectedMaterial = nil
end

-- Enter `spawnmenu_reload` in the console to reload the panel
function TOOL.BuildCPanel(CPanel)
  -- Tool name and desctiption
  CPanel:ClearControls(); CPanel:DockPadding(5, 0, 5, 10)
  local drmSkin, pItem = CPanel:GetSkin() -- pItem is the current panel created
  pItem = CPanel:SetName(language.GetPhrase("tool."..gsTool..".name"))
  pItem = CPanel:Help   (language.GetPhrase("tool."..gsTool..".desc"))
  -- Control presets
  pItem = vgui.Create("ControlPresets", CPanel)
  pItem:SetPreset(gsTool)
  pItem:AddOption("Default", gtConvar)
  for key, val in pairs(table.GetKeys(gtConvar)) do pItem:AddConVar(val) end
  pItem:Dock(TOP); CPanel:AddItem(pItem)
  -- Randomize applied material in amout of iterations
  pItem = CPanel:NumSlider(language.GetPhrase("tool."..gsTool..".random_con"), gsTool.."_randomize", 0, 100, 0)
  pItem:SetToolTip(language.GetPhrase("tool."..gsTool..".random")); pItem:SetDefaultValue(0)
  -- Read the current list string identifier
  local tT = list.GetForEdit(gsPref.."type")
  local sS, nT = GetConVar(gsTool.."_customset"):GetString(), #tT
  -- Prepare combo box
  local pCombo, pItem = CPanel:ComboBox(language.GetPhrase("tool."..gsTool..".type_con"))
  pCombo:SetTooltip(language.GetPhrase("tool."..gsTool..".type"))
  pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".type"))
  pCombo:SetValue(language.GetPhrase("tool."..gsTool..".type_def"))
  function pCombo:DoRightClick()
    local iD = self:GetSelectedID()
    local vT = self:GetOptionText(iD)
    local sV = tostring(vT or self:GetValue())
    SetClipboardText(sV)
  end
  pCombo:Dock(TOP) -- Setting tallness gets ingnored otherwise
  pCombo:SetTall(25)
  pCombo:UpdateColours(drmSkin)
  pCombo:AddChoice(gsMats, 0, (sS == gsMats), "icon16/house.png")
  for iT = 1, nT do local sT = tT[iT]
    pCombo:AddChoice(sT, iT, (sS == sT), "icon16/palette.png")
  end
  -- Prepare search text box
  local pText, pItem = CPanel:TextEntry(language.GetPhrase("tool."..gsTool..".pattern_con"))
  pText:Dock(TOP)
  pText:SetTall(25)
  pText:SetVisible(true)
  pText:SetUpdateOnType(true)
  pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".pattern"))
  pText:SetTooltip(language.GetPhrase("tool."..gsTool..".pattern"))
  -- Create material select
  local pMater = CPanel:MatSelect(gsTool.."_override", nil, true, 0.25, 0.25)
  -- Clear previous and load materials on select
  function pCombo:OnSelect(nInd, sNam, vDat)
    local iT = math.Clamp(vDat, 0, #tT)
    local sC = ((iT == 0) and gsMats or tT[iT])
    local sN = ((iT == 0) and gsMats or (gsPref..tT[iT]))
    wipeMaterials(pMater)
    local tN = list.GetForEdit(sN)
    for iD = 1, #tN do local sM = tN[iD]
      pMater:AddMaterial(sM, sM)
    end
    pickMaterial(sC, sM)
    pMater:InvalidateChildren()
    CPanel:InvalidateChildren()
  end
  -- Hit enter to search in the list
  function pText:OnEnter(sTxt)
    for key, mat in pairs(pMater.Controls) do
      if(mat.Value:lower():find(sTxt:lower())) then
        mat:SetVisible(true)
      else mat:SetVisible(false) end
    end
    pMater:InvalidateChildren()
    CPanel:InvalidateChildren()
  end
  -- When current option is selected update the materials
  local iD = pCombo:GetSelectedID()
  if(iD and iD >= 0) then
    local nD = pCombo:GetOptionData(iD)
    pCombo:OnSelect(nil, nil, nD)
    pCombo:ChooseOption(sS, iD)
  end
end
