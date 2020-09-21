local gsTool = "physprop_adv"
local gsLisp = "physicsal_props_adv_"
local gclBgn = Color(0, 0, 0, 210)
local gclTxt = Color(0, 0, 0, 255)
local gclBox = Color(250, 250, 200, 255)
local gnRadm, gsSdiv = (20*0.618), "#"
local gnRadr = (gnRadm-gnRadm%2)
local gsFont = "Trebuchet24"
local gnTacn = TEXT_ALIGN_CENTER
local gsFLng = ("%s"..gsTool.."/lang/%s")
local varLng = GetConVar("gmod_language")
local gsInvm, goTool, gtLang = "N/A", TOOL, {}
local gfNotf = "GAMEMODE:AddNotify(\"%s\", NOTIFY_%s, 6)"
local gfSong = "surface.PlaySound(\"ambient/water/drip%d.wav\")"
local gtTrig = {Old = 0, New = 0}

local function getTranslate(sT)
  local sN = gsFLng:format("", sT..".lua")
  if(not file.Exists("lua/"..sN, "GAME")) then return nil end
  local fT = CompileFile(sN); if(not fT) then -- Try to compile the UTF-8 translations
    ErrorNoHalt(gsTool..": getTranslate("..sT.."): [1] Compile error") return nil end
  local bF, fF = pcall(fT); if(not bF) then -- Prepare the result function for return call
    ErrorNoHalt(gsTool..": getTranslate("..sT.."): [2] Prepare error: "..fF) return nil end
  local bS, tS = pcall(fF, gsTool, gsEntLimit); if(not bF) then -- Create translation table
    ErrorNoHalt(gsTool..": getTranslate("..sT.."): [3] Create error: "..tS) return nil end
  return tS -- If it all goes well it will return the translation hash phrase table
end

local function setTranslate(sT)
  table.Empty(gtLang) -- Override translations file
  local tB = getTranslate("en"); if(not tB) then
    ErrorNoHalt(gsTool..": setTranslate: English missing") end
  if(sT ~= "en") then local tC = getTranslate(sT); if(tC) then
    for key, val in pairs(tB) do tB[key] = (tC[key] or tB[key]) end end
  end -- Apply country stript. If not translated, use the base english script
  for key, val in pairs(tB) do -- Loop across the nglish translation as it have all stuff
    gtLang[key] = tB[key]  -- Register translations in the table for custom getphrase
    language.Add(key, val) -- Send the translation to the game for tool descriotion
  end
end

local function getPhrase(sK)
  local sK = tostring(sK) if(not gtLang[sK]) then
    ErrorNoHalt(gsTool..": getPhrase("..sK.."): Missing")
    return "Oops, missing ?" -- Return some default translation
  end; return gtLang[sK] -- Return the actual translated phrase
end

local function setProperties(tF)
  if(tF and tF[1]) then
    local sR, sF, sE = "rb", (gsTool.."/materials/%s.txt"), ("%.txt") -- Path format
    local sT, sM, sP, sD = (gsLisp.."type"), ("*line"), ("%S+"), ("DATA")
    for iF = 1, #tF do local sN = tF[iF]:gsub(sE, "") -- Strip extension
      if(not list.Contains(sT, sN)) then list.Add(sT, sN) end
      local fT, fE = file.Open(sF:format(sN), sR, sD) -- Read type
      if(fT) then local sL = fT:ReadLine(sM) -- Process the line
        while(sL) do sL = sL:Trim() -- Avoid putting spaces
          -- Every separate word is written to the list
          if(sL ~= "" or sL:sub(1,1) ~= "#") then
            for sW in sL:gmatch(sP) do local sI = (gsLisp..sN)
              -- File names becomes physical properties type
              if(not list.Contains(sI, sW)) then list.Add(sI, sW) end
            end -- When skip the commented lines
          end; sL = fT:ReadLine(sM) -- Read the next line
        end; fT:Close() -- Additional type is processed from descriptor
      else ErrorNoHalt(gsTool..": setProperties: "..tostring(fE)) end
    end -- All the file type descriptors are processed
  end
end

if(SERVER) then
  -- Send language definitions to the client to populate the menu
  local gtTransFile = file.Find(gsFLng:format("lua/", "*.lua"), "GAME")
  for iD = 1, #gtTransFile do AddCSLuaFile(gsFLng:format("", gtTransFile[iD])) end
end

if(CLIENT) then
  language.Add("tool."..gsTool..".category", "Construction")

  TOOL.Information = {
    { name = "info", stage = 1},
    { name = "left"  },
    { name = "left_use", icon2 = "gui/e.png"},
    { name = "right" },
    { name = "reload"}
  }
  -- Default translation string descriptions ( always english )
  setTranslate(varLng:GetString())
  -- listen for changes to the localify language and reload the tool's menu to update the localizations
  cvars.RemoveChangeCallback(varLng:GetName(), gsLisp.."lang")
  cvars.AddChangeCallback(varLng:GetName(), function(sNam, vO, vN) setTranslate(vN)
    local cPanel = controlpanel.Get(goTool.Mode); if(not IsValid(cPanel)) then return end
    cPanel:ClearControls(); goTool.BuildCPanel(cPanel)
  end, gsLisp.."lang")
end

TOOL.ClientConVar = {
  [ "gravity_toggle" ] = 1,
  [ "applyall_bone"  ] = 1,
  [ "material_type"  ] = 1,
  [ "material_name"  ] = 1,
  [ "material_draw"  ] = 1,
  [ "material_cash"  ] = gsInvm
}

TOOL.Category   = language and language.GetPhrase("tool."..gsTool..".category")
TOOL.Name       = language and language.GetPhrase("tool."..gsTool..".name")
TOOL.Command    = nil -- Command on click (nil for default)
TOOL.ConfigName = nil -- Configure file name (nil for default)

table.Empty(list.GetForEdit(gsLisp.."type"))
if(not file.Exists(gsTool,"DATA")) then file.CreateDir(gsTool) end
setProperties(file.Find(gsTool.."/materials/*.txt","DATA")) -- Search for text files

local function getMaterialInfo(vT, vN) -- Avoid returning a copy by list-get to make it faster
  local tT = list.GetForEdit(gsLisp.."type") -- No edit though just read it
  local iT = math.Clamp(math.floor(tonumber(vT or 1)), 1, #tT)
  local sT = tT[iT]; if(not sT) then return gsInvm end
  local tN = list.GetForEdit(gsLisp..sT) -- No edit though same here
  local iN = math.Clamp(math.floor(tonumber(vN or 1)), 1, #tN)
  return tostring(tN[iN] or gsInvm)
end

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

function TOOL:GetGravity()
  return ((self:GetClientNumber("gravity_toggle") or 0) ~= 0)
end

function TOOL:GetApplyBones()
  return ((self:GetClientNumber("applyall_bone") or 0) ~= 0)
end

function TOOL:GetOriginal(trEnt)
  return trEnt:GetNWString(gsLisp.."matorig", gsInvm)
end

function TOOL:SetOriginal(trEnt, sOrg)
  trEnt:SetNWString(gsLisp.."matorig", sOrg)
end

function TOOL:PutOriginal(trEnt, sOrg)
  local sMat, bMat = self:GetOriginal(trEnt), self:IsMaterial(sOrg)
  if(bMat and sMat == gsInvm) then -- Original is not yet set
    self:SetOriginal(trEnt, sOrg); return true -- Store original material
  end; return false
end

function TOOL:GetBoneView(oPly, iD)
  local tInf = gsSdiv:Explode(oPly:GetNWString(gsLisp..iD, gsInvm))
  local sMat = tostring(tInf[1] or gsInvm):Trim()
  local bGrv = tostring(tInf[2] or gsSdiv):Trim()
        bGrv = ((tonumber(bGrv) or 0) ~= 0)
  return sMat, bGrv
end

function TOOL:SetBoneView(oPly, iD, sMat, bGrv)
  oPly:SetNWString(gsLisp..iD, sMat..gsSdiv..(bGrv and 1 or 0))
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
    matprop = self:GetMaterialCash()  -- Read value from the convar
  else -- Use the material provided by the client control panel
    matprop = getMaterialInfo(self:GetClientNumber("material_type") or 0,
                              self:GetClientNumber("material_name") or 0)
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

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel(CPanel)
  CPanel:ClearControls()
  local nY, pItem = 0 -- pItem is the current panel created
          CPanel:SetName(getPhrase("tool."..gsTool..".name"))
  pItem = CPanel:Help   (getPhrase("tool."..gsTool..".desc")); nY = nY + pItem:GetTall() + 2

  pItem = CPanel:AddControl("ComboBox",{
    MenuButton = 1,
    Folder     = gsTool,
    Options    = {["Default"] = ConVarsDefault},
    CVars      = table.GetKeys(ConVarsDefault)
  }); nY = pItem:GetTall() + 2
  local matprop = getMaterialInfo(GetConVar(gsTool.."_material_type"):GetInt(),
                                  GetConVar(gsTool.."_material_name"):GetInt())
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local tT = list.GetForEdit(gsLisp.."type")
  local pComboType = vgui.Create("DComboBox", CPanel)
        pComboType:SetPos(2, nY)
        pComboType:SetSortItems(false)
        pComboType:SetTall(20)
        pComboType:SetTooltip(getPhrase("tool."..gsTool..".material_type"))
        pComboType:SetValue(getPhrase("tool."..gsTool..".material_type_def"))
        for iT = 1, #tT do pComboType:AddChoice(tT[iT], iT) end
  nY = nY + pComboType:GetTall() + 2
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local pComboName = vgui.Create("DComboBox", CPanel)
        pComboName:SetPos(2, nY)
        pComboName:SetSortItems(false)
        pComboName:SetTall(20)
        pComboName:SetTooltip(getPhrase("tool."..gsTool..".material_name"))
        pComboName:SetValue(getPhrase("tool."..gsTool..".material_name_def").." "..matprop)
        pComboName.OnSelect = function(pnSelf, nInd, sVal, anyData)
          RunConsoleCommand(gsTool.."_material_name", anyData) end
  -- Material list selection
  pComboType.OnSelect = function(pnSelf, nInd, sVal, anyData)
    local iT = math.Clamp(anyData, 1, #tT)
    local tN = list.GetForEdit(gsLisp..tT[iT]); pComboName:Clear()
    pComboName:SetValue(getPhrase("tool."..gsTool..".material_name_def"))
    for iN = 1, #tN do pComboName:AddChoice(tN[iN], iN) end
    RunConsoleCommand(gsTool.."_material_type", anyData)
  end
  CPanel:AddItem(pComboType)
  CPanel:AddItem(pComboName)

  pItem = CPanel:CheckBox (getPhrase("tool."..gsTool..".gravity_toggle_con"), gsTool.."_gravity_toggle")
          pItem:SetTooltip(getPhrase("tool."..gsTool..".gravity_toggle"))
  pItem = CPanel:CheckBox (getPhrase("tool."..gsTool..".material_draw_con"), gsTool.."_material_draw")
          pItem:SetTooltip(getPhrase("tool."..gsTool..".material_draw"))
  pItem = CPanel:CheckBox (getPhrase("tool."..gsTool..".applyall_bone_con"), gsTool.."_applyall_bone")
          pItem:SetTooltip(getPhrase("tool."..gsTool..".applyall_bone"))
end
