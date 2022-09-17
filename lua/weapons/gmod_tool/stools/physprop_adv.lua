local goTool = TOOL
local gsTool = goTool.Mode
local gsPref = "physicsal_props_adv_"
local gclBgn = Color(0, 0, 0, 210)
local gclTxt = Color(0, 0, 0, 255)
local gclBox = Color(250, 250, 200, 255)
local gnRadm, gsSdiv = (20*0.618), "#"
local gnRadr = (gnRadm-gnRadm%2)
local gsFont = "Trebuchet24"
local gnTacn = TEXT_ALIGN_CENTER
local varLng = GetConVar("gmod_language")
local gfNotf = "GAMEMODE:AddNotify(\"%s\", NOTIFY_%s, 6)"
local gfSong = "surface.PlaySound(\"ambient/water/drip%d.wav\")"
local gtTrig, gsInvm = {Old = 0, New = 0}, "N/A"

if(CLIENT) then
  language.Add("tool."..gsTool..".category", "Construction")

  TOOL.Information = {
    { name = "info", stage = 1},
    { name = "left"  },
    { name = "left_use", icon2 = "gui/e.png"},
    { name = "right" },
    { name = "reload"}
  }

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

  function getMaterialInfo(vT, vN) -- Avoid returning a copy by list-get to make it faster
    local tT = list.GetForEdit(gsPref.."type") -- No edit though just read it
    local iT = math.Clamp(math.floor(tonumber(vT or 1)), 1, #tT)
    local sT = tT[iT]; if(not sT) then return gsInvm end
    local tN = list.GetForEdit(gsPref..sT) -- No edit though same here
    local iN = math.Clamp(math.floor(tonumber(vN or 1)), 1, #tN)
    return tostring(tN[iN] or gsInvm)
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
end

TOOL.ClientConVar = {
  [ "gravity_toggle" ] = 1,
  [ "applyall_bone"  ] = 1,
  [ "material_type"  ] = 1,
  [ "material_name"  ] = 1,
  [ "material_draw"  ] = 1,
  [ "material_info"  ] = gsInvm,
  [ "material_cash"  ] = gsInvm
}

local gtConvar = TOOL:BuildConVarList()

TOOL.Category   = language and language.GetPhrase("tool."..gsTool..".category")
TOOL.Name       = language and language.GetPhrase("tool."..gsTool..".name")
TOOL.Command    = nil -- Command on click (nil for default)
TOOL.ConfigName = nil -- Configure file name (nil for default)

-- Send notification to client that something happened
function TOOL:NotifyPlayer(sText, sType, ...)
  if(SERVER) then local mePly = self:GetOwner()
    mePly:SendLua(gfNotf:format(sText, sType))
    mePly:SendLua(gfSong:format(math.random(1, 4)))
  end; return ...
end

function TOOL:IsMaterial(sMat)
  return (sMat:len() > 0 and sMat ~= gsInvm)
end

function TOOL:GetMaterialDraw()
  return ((self:GetClientNumber("material_draw") or 0) ~= 0)
end

function TOOL:GetMaterialCash()
  return tostring(self:GetClientInfo("material_cash") or gsInvm)
end

function TOOL:GetMaterialInfo()
  return tostring(self:GetClientInfo("material_info") or gsInvm)
end

function TOOL:GetGravity()
  return ((self:GetClientNumber("gravity_toggle") or 0) ~= 0)
end

function TOOL:GetApplyBones()
  return ((self:GetClientNumber("applyall_bone") or 0) ~= 0)
end

function TOOL:GetOriginal(trEnt)
  return trEnt:GetNWString(gsPref.."matorig", gsInvm)
end

function TOOL:SetOriginal(trEnt, sOrg)
  trEnt:SetNWString(gsPref.."matorig", sOrg)
end

function TOOL:PutOriginal(trEnt, sOrg)
  local sMat, bMat = self:GetOriginal(trEnt), self:IsMaterial(sOrg)
  if(bMat and sMat == gsInvm) then -- Original is not yet set
    self:SetOriginal(trEnt, sOrg); return true -- Store original material
  end; return false
end

function TOOL:GetBoneView(oPly, iD)
  local tInf = gsSdiv:Explode(oPly:GetNWString(gsPref..iD, gsInvm))
  local sMat = tostring(tInf[1] or gsInvm):Trim()
  local bGrv = tostring(tInf[2] or gsSdiv):Trim()
        bGrv = ((tonumber(bGrv) or 0) ~= 0)
  return sMat, bGrv
end

function TOOL:SetBoneView(oPly, iD, sMat, bGrv)
  oPly:SetNWString(gsPref..iD, sMat..gsSdiv..(bGrv and 1 or 0))
end

function TOOL:SetMaterialProp(oEnt, iBone, sMat, bGrv)
  local mBone = 0; if(not (oEnt and oEnt:IsValid())) then
    return self:NotifyPlayer("Request entity invalid", "ERROR", mBone) end
  self:PutOriginal(oEnt, oEnt:GetBoneSurfaceProp(0))
  local ePly, bBone = self:GetOwner(), self:GetApplyBones()
  local tSet, mBone = {Material = sMat, GravityToggle = bGrv}, 1
  if(bBone) then mBone = oEnt:GetPhysicsObjectCount()
    for iD = 0, (mBone - 1) do -- Apply the material on all bones
      construct.SetPhysProp(ePly, oEnt, iD, nil, tSet)
    end
  else local iBone = (tonumber(iBone) or 0)
    construct.SetPhysProp(ePly, oEnt, iBone, nil, tSet)
  end; return mBone
end

function TOOL:LeftClick(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit) or tr.HitWorld) then return false end
  -- Make sure we do not apply custom physical properties on the world surface
  local trEnt, trBone = tr.Entity, tr.PhysicsBone
  if(not (trEnt and trEnt:IsValid())) then return false end
  if(trEnt:IsPlayer()) then return false end
  -- Make sure there is a physics object to manipulate
  if(not util.IsValidPhysicsObject(trEnt, trBone)) then
    return self:NotifyPlayer("Apply physics invalid", "ERROR", false) end
  local mePly, gravity, matprop = self:GetOwner(), self:GetGravity()
  if(mePly:KeyDown(IN_USE)) then -- Use the cached material
    matprop = self:GetMaterialCash() -- Read value from the convar
  else -- Use the material provided by the client control panel
    matprop = self:GetMaterialInfo() -- Read material info popylated by client
  end; DoPropSpawnedEffect(trEnt) -- Network the values for drawing when available and corect
  if(not self:IsMaterial(matprop)) then -- Check for a valid value
    return self:NotifyPlayer("Apply invalid: "..gsInvm, "ERROR", false) end
  -- Finally apply the material on the seected entities
  if(mePly:KeyDown(IN_SPEED)) then local iBone, iEnts = 0, 0
    local tEnts = constraint.GetAllConstrainedEntities(trEnt)
    for key, ent in pairs(tEnts) do iEnts = iEnts + 1
      iBone = iBone + self:SetMaterialProp(ent, trBone, matprop, gravity)
    end; return self:NotifyPlayer("Apply ["..iBone.."] bones ["..iEnts.."] entities: "..matprop, "GENERIC", true)
  else -- Apply only to the trace bone
    local iBone = self:SetMaterialProp(trEnt, trBone, matprop, gravity)
    return self:NotifyPlayer("Apply ["..iBone.."] bones: "..matprop, "GENERIC", true)
  end -- There are two glasses of water on the table. One if I am thursty and one if I'm not
end

function TOOL:RightClick(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit)) then return false end
  local mePly, iP = self:GetOwner(), tr.SurfaceProps
  local matprop = (iP and util.GetSurfacePropName(iP) or gsInvm)
  if(not self:IsMaterial(matprop)) then -- Check for a valid value
    return self:NotifyPlayer("Cache invalid: "..gsInvm, "ERROR", false) end
  mePly:ConCommand(gsTool.."_material_cash "..matprop)
  return self:NotifyPlayer("Cache material: "..matprop, "UNDO", true)
end

function TOOL:Reload(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit) or tr.HitWorld) then return false end
  local trEnt, trBone = tr.Entity, tr.PhysicsBone
  local mePly, trPro = self:GetOwner(), tr.SurfaceProps
  if(not util.IsValidPhysicsObject(trEnt, trBone)) then
    return self:NotifyPlayer("Reset physics invalid", "ERROR", false) end
  if(mePly:KeyDown(IN_SPEED)) then local iBone, iEnts = 0, 0
    local tEnts = constraint.GetAllConstrainedEntities(trEnt)
    for key, ent in pairs(tEnts) do iEnts = iEnts + 1
      local matprop = self:GetOriginal(ent); if(not self:IsMaterial(matprop)) then
        return self:NotifyPlayer("Reset invalid: "..gsInvm, "ERROR", false) end
      iBone = iBone + self:SetMaterialProp(ent, trBone, matprop)
    end; return self:NotifyPlayer("Reset ["..iBone.."] bones ["..iEnts.."] entities", "CLEANUP", true)
  else -- Reset only to the trace bone
    local matprop = self:GetOriginal(trEnt); if(not self:IsMaterial(matprop)) then
      return self:NotifyPlayer("Reset invalid: "..gsInvm, "ERROR", false) end
    local iBone = self:SetMaterialProp(trEnt, trBone, matprop)
    return self:NotifyPlayer("Reset ["..iBone.."] bones: "..matprop, "CLEANUP", true)
  end
end

function TOOL:Think()
  local mePly = self:GetOwner()
  local oTr   = mePly:GetEyeTrace()
  if(not (oTr and oTr.Hit)) then return nil end
  local trEnt, trBone, trSurf = oTr.Entity, oTr.PhysicsBone, oTr.SurfaceProps
  if(not ((trEnt and trEnt:IsValid()) or oTr.HitWorld)) then return nil end
  if(SERVER) then gtTrig.Old, gtTrig.New = gtTrig.New, trEnt
    if(gtTrig.Old ~= gtTrig.New or mePly:KeyDown(IN_ATTACK) or mePly:KeyDown(IN_RELOAD)) then
      self:PutOriginal(trEnt, (trSurf and util.GetSurfacePropName(trSurf) or gsInvm))
      -- Update the player vision for the entity
      for iB = 0, (trEnt:GetPhysicsObjectCount() - 1) do
        local phEnt = trEnt:GetPhysicsObjectNum(iB)
        if(phEnt and phEnt:IsValid()) then
          local matprop = phEnt:GetMaterial()
          local gravity = phEnt:IsGravityEnabled()
          self:SetBoneView(mePly, iB, matprop, gravity)
        end
      end
    end
  end
end

function TOOL:DrawHUD(w, h)
  if(not self:GetMaterialDraw()) then return end
  local mePly = LocalPlayer()
  local oTr = mePly:GetEyeTrace()
  local trEnt, iB = oTr.Entity, oTr.PhysicsBone
  if(not (trEnt and trEnt:IsValid())) then return end
  local sNw, bNw = self:GetBoneView(mePly, iB)
  if(not self:IsMaterial(sNw)) then return end
  local xyP = oTr.HitPos:ToScreen(); xyP.x, xyP.y = (xyP.x + gnRadm), (xyP.y - gnRadm)
  local mAt = getMaterialInfo(self:GetClientNumber("material_type") or 0,
                              self:GetClientNumber("material_name") or 0)
  local gRv = tostring(self:GetGravity()); surface.SetFont(gsFont)
  local mAo = self:GetOriginal(trEnt); bNw = tostring(bNw) -- Original material
  local sTx = "["..iB.."] { "..bNw.." | "..sNw.." } ( "..gRv.." | "..mAt.." ) "..mAo
  local tw, th = surface.GetTextSize(sTx)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 12, xyP.y - th/2 - 4, tw + 24, th + 8, gclBgn)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 10, xyP.y - th/2 - 2, tw + 20, th + 4, gclBox)
  draw.SimpleText(sTx, gsFont, xyP.x, xyP.y, gclTxt, gnTacn, gnTacn)
end

-- Enter `spawnmenu_reload` in the console to reload the panel
function TOOL.BuildCPanel(CPanel)
  CPanel:ClearControls(); CPanel:DockPadding(5, 0, 5, 10)
  local drmSkin, bNow, pItem = CPanel:GetSkin(), true -- pItem is the current panel created
  pItem = CPanel:SetName(language.GetPhrase("tool."..gsTool..".name"))
  pItem = CPanel:Help   (language.GetPhrase("tool."..gsTool..".desc"))

  pItem = vgui.Create("ControlPresets", CPanel)
  pItem:SetPreset(gsTool)
  pItem:AddOption("Default", gtConvar)
  for key, val in pairs(table.GetKeys(gtConvar)) do pItem:AddConVar(val) end
  pItem:Dock(TOP); CPanel:AddItem(pItem)
  local iType = GetConVar(gsTool.."_material_type"):GetInt()
  local iName = GetConVar(gsTool.."_material_name"):GetInt()
  local matprop = getMaterialInfo(iType, iName)
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local tT = list.GetForEdit(gsPref.."type")
  local pComboType, pItem = CPanel:ComboBox(language.GetPhrase("tool."..gsTool..".material_type_con"))
        pComboType:Dock(TOP)
        pComboType:SetTall(25)
        pComboType:SetSortItems(false)
        pComboType:UpdateColours(drmSkin)
        pComboType:SetTooltip(language.GetPhrase("tool."..gsTool..".material_type"))
        pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".material_type"))
        pComboType:SetValue(language.GetPhrase("tool."..gsTool..".material_type_def"))
        for iT = 1, #tT do pComboType:AddChoice(tT[iT], iT, (iT == iType), "icon16/package.png") end
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local pComboName, pItem = CPanel:ComboBox(language.GetPhrase("tool."..gsTool..".material_name_con"))
        pComboName:Dock(TOP)
        pComboName:SetTall(25)
        pComboName:SetSortItems(false)
        pComboName:UpdateColours(drmSkin)
        pComboName:SetTooltip(language.GetPhrase("tool."..gsTool..".material_name"))
        pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".material_name"))
        pComboName:SetValue(language.GetPhrase("tool."..gsTool..".material_name_def").." "..matprop)
  -- It is called when material name is selected from the menu
  function pComboName:OnSelect(nInd, sVal, vDat)
    local nIdx = GetConVar(gsTool.."_material_type"):GetInt()
    local sMat = getMaterialInfo(nIdx, vDat)
    RunConsoleCommand(gsTool.."_material_name", vDat)
    RunConsoleCommand(gsTool.."_material_info", sMat)
  end
  -- Material list selection. Selects category and updates name list
  function pComboType:OnSelect(nInd, sVal, vDat)
    local iT = math.Clamp(vDat, 1, #tT)
    local tN = list.GetForEdit(gsPref..tT[iT]); pComboName:Clear()
    pComboName:SetValue(language.GetPhrase("tool."..gsTool..".material_name_def"))
    for iN = 1, #tN do
      local bS = (bNow and (iN == iName) or false)
      pComboName:AddChoice(tN[iN], iN, bS, "icon16/brick.png")
    end
    if(bNow) then bNow = false end -- Retest on panel creation
    RunConsoleCommand(gsTool.."_material_type", iT)
  end
  -- Support copy via right click
  function pComboType:DoRightClick()
    local iD = self:GetSelectedID()
    local vT = self:GetOptionText(iD)
    local sV = tostring(vT or self:GetValue())
    SetClipboardText(sV)
  end
  function pComboName:DoRightClick()
    local iD = self:GetSelectedID()
    local vT = self:GetOptionText(iD)
    local sV = tostring(vT or self:GetValue())
    SetClipboardText(sV)
  end

  pItem = CPanel:CheckBox (language.GetPhrase("tool."..gsTool..".gravity_toggle_con"), gsTool.."_gravity_toggle")
          pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".gravity_toggle"))
  pItem = CPanel:CheckBox (language.GetPhrase("tool."..gsTool..".material_draw_con"), gsTool.."_material_draw")
          pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".material_draw"))
  pItem = CPanel:CheckBox (language.GetPhrase("tool."..gsTool..".applyall_bone_con"), gsTool.."_applyall_bone")
          pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".applyall_bone"))

  pComboType:OnSelect(nil, nil, iType)
end
