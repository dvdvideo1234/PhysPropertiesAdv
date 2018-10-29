local gsTool = "physprop_adv"
local gsLisp = "physics_material_adv_"
local gclBgn = Color(0, 0, 0, 210)
local gclTxt = Color(0, 0, 0, 255)
local gclBox = Color(250, 250, 200, 255)
local gsInvm = "N/A"
local gnRadm = (20*0.618)
local gnRadr = (gnRadm-gnRadm%2)
local gsFont = "Trebuchet24"
local gnTacn = TEXT_ALIGN_CENTER
local varLng = GetConVar("gmod_language")

local function setTranslate(sT)  -- Override translations file
  local tTb = {
    ["tool."..gsTool..".name"              ] =  "Physics Properties Adv",
    ["tool."..gsTool..".desc"              ] =  "Advanced and extended version of the original physics properties tool",
    ["tool."..gsTool..".left"              ] =  "Apply the selected physical property",
    ["tool."..gsTool..".right"             ] =  "Cache the selected physical property",
    ["tool."..gsTool..".right_use"         ] =  "Cache the applied physical property",
    ["tool."..gsTool..".reload"            ] =  "Reset original physical property",
    ["tool."..gsTool..".left_use"          ] =  "Apply cached physical property",
    ["tool."..gsTool..".material_type"     ] =  "Select material type from the ones listed here",
    ["tool."..gsTool..".material_type_def" ] =  "Select type...",
    ["tool."..gsTool..".material_name"     ] =  "Select material name from the ones listed here",
    ["tool."..gsTool..".material_name_def" ] =  "Select name...",
    ["tool."..gsTool..".gravity_toggle_con"] =  "Enable gravity",
    ["tool."..gsTool..".gravity_toggle"    ] =  "When checked enables the gravity for an entity",
    ["tool."..gsTool..".material_draw_con" ] =  "Enable material draw",
    ["tool."..gsTool..".material_draw"     ] =  "Show trace entity surface material"
  }
  local sT = tostring(sT or ""); if(sT ~= "en") then
    local fT = CompileFile(("%s/lang/%s.lua"):format(gsTool, sT))
    local bF, fFo = pcall(fT); if(bF) then
      local bS, tTo = pcall(fFo, gsTool); if(bS) then
        for key, val in pairs(tTb) do tTb[key] = (tTo[key] or tTb[key]) end
      else ErrorNoHalt(gsTool..": setTranslate("..sT.."): "..tostring(tTo)) end
    else ErrorNoHalt(gsTool..": setTranslate("..sT.."): "..tostring(fFo)) end
  end; for key, val in pairs(tTb) do language.Add(key, val) end
end

local function setProperties(tF)
  if(tF and tF[1]) then
    local sR, sF, sE = "rb", (gsTool.."/%s.txt"), ("%.txt") -- Path format
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
      else ErrorNoHalt(gsTool..": "..tostring(fE)) end
    end -- All the file type descriptors are processed
  end
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
end

TOOL.ClientConVar = {
  [ "gravity_toggle" ] = 1,
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
setProperties(file.Find(gsTool.."/*.txt","DATA")) -- Search for text files

if(SERVER) then
  duplicator.RegisterEntityModifier(gsLisp.."dupe", function(oPly, oEnt, tData)
    oEnt:SetNWBool(gsLisp.."gravity", tData[1]); oEnt:SetNWString(gsLisp.."matprop", tData[2])
  end)
end

-- Send notification to client that something happened
function TOOL:NotifyPlayer(sText, sType, vRet)
  if(SERVER) then local mePly = self:GetOwner()
    mePly:SendLua("GAMEMODE:AddNotify(\""..sText.."\", NOTIFY_"..sType..", 6)")
    mePly:SendLua("surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
  end; return vRet
end

local function getConvar(sN)
  return GetConVar(gsTool.."_"..sN)
end

local function getMaterialInfo(vT, vN) -- Avoid returning a copy by list-get to make it faster
  local tT = list.GetForEdit(gsLisp.."type") -- No edit though just read it
  local iT = math.Clamp(math.floor(tonumber(vT or 1)), 1, #tT)
  local tN = list.GetForEdit(gsLisp..tT[iT]) -- No edit though same here
  local iN = math.Clamp(math.floor(tonumber(vN or 1)), 1, #tN)
  return tostring(tN[iN] or gsInvm)
end

function TOOL:GetMaterialDraw()
  return ((self:GetClientNumber("material_draw") or 0) ~= 0)
end

function TOOL:GetMaterialCash()
  return tostring(self:GetClientInfo("material_cash") or gsInvm)
end

function TOOL:CheckButton(iIn)
  local cmdPress = self:GetOwner():GetCurrentCommand()
  return (bit.band(cmdPress:GetButtons(),iIn) ~= 0)
end

function TOOL:GetGravity()
  return ((self:GetClientNumber("gravity_toggle") or 0) ~= 0)
end

function TOOL:LeftClick(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit) or tr.HitWorld) then return false end
  -- Make sure we do not apply custom physical properties on the world surface
  local trEnt, trBon = tr.Entity, tr.PhysicsBone
  if(not (trEnt and trEnt:IsValid())) then return false end
  if(trEnt:IsPlayer() or trEnt:IsWorld()) then return false end
  -- Make sure there is a physics object to manipulate
  if(not util.IsValidPhysicsObject(trEnt, trBon)) then
    return self:NotifyPlayer("Reset physics invalid: "..matprop, "ERROR", false) end
  local mePly, gravity, matprop = self:GetOwner(), self:GetGravity()
  if(self:CheckButton(IN_SPEED)) then matprop = self:GetMaterialCash()
  else matprop = getMaterialInfo(self:GetClientNumber("material_type"),
                                 self:GetClientNumber("material_name")) end
  if(matprop:len() == 0 or matprop == gsInvm) then -- Check for a valid value
    return self:NotifyPlayer("Apply invalid: "..matprop, "ERROR", false) end
  -- Zhu Li, do the thing and hand me a screwdriver. Network the values for drawing
  construct.SetPhysProp(mePly, trEnt, trBon, nil, {GravityToggle = gravity, Material = matprop})
  trEnt:SetNWBool(gsLisp.."gravity", gravity); trEnt:SetNWString(gsLisp.."matprop", matprop)
  DoPropSpawnedEffect(trEnt); duplicator.StoreEntityModifier(trEnt, gsLisp.."dupe", {gravity, matprop})
  return self:NotifyPlayer("Material apply: "..matprop, "GENERIC", true)
end

function TOOL:RightClick(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit)) then return false end
  local mePly, trPro, trEnt = self:GetOwner(), tr.SurfaceProps, tr.Entity
  local matprop = (trPro and util.GetSurfacePropName(trPro) or gsInvm)
  if(self:CheckButton(IN_SPEED) and (trEnt and trEnt:IsValid())) then
    matprop = trEnt:GetNWString(gsLisp.."matprop", matprop) end
  if(matprop:len() == 0 or matprop == gsInvm) then -- Check for a valid value
    return self:NotifyPlayer("Cache invalid: "..matprop, "ERROR", false) end
  mePly:ConCommand(gsTool.."_material_cash "..matprop)
  return self:NotifyPlayer("Material copy: "..matprop, "UNDO", true)
end

function TOOL:Reload(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit) or tr.HitWorld) then return false end
  local trEnt, trBon = tr.Entity, tr.PhysicsBone
  local mePly, trPro = self:GetOwner(), tr.SurfaceProps
  local matprop = (trPro and util.GetSurfacePropName(trPro) or gsInvm)
  if(matprop:len() == 0 or matprop == gsInvm) then
    return self:NotifyPlayer("Reset invalid: "..matprop, "ERROR", false) end
  if(not util.IsValidPhysicsObject(trEnt, trBon)) then
    return self:NotifyPlayer("Reset physics invalid: "..matprop, "ERROR", false) end
  construct.SetPhysProp(mePly, trEnt, trBon, nil, {Material = matprop})
  trEnt:SetNWString(gsLisp.."matprop", matprop) -- Apply only the matprop on reload
  return self:NotifyPlayer("Material reset: "..matprop, "GENERIC", true)
end

function TOOL:DrawHUD(w, h)
  if(not self:GetMaterialDraw()) then return end
  local oTr = LocalPlayer():GetEyeTrace()
  local trEnt, nP = oTr.Entity, oTr.SurfaceProps
  if(not (trEnt and trEnt:IsValid())) then return end
  local xyP = oTr.HitPos:ToScreen()
        xyP.x, xyP.y = (xyP.x + gnRadm), (xyP.y - gnRadm)  
  local mAt = getMaterialInfo(self:GetClientNumber("material_type"),
                              self:GetClientNumber("material_name"))
  local gRv = tostring(self:GetGravity()); surface.SetFont(gsFont)
  local sTx = (nP and util.GetSurfacePropName(nP) or gsInvm)
  local bNw = tostring(trEnt:GetNWBool  (gsLisp.."gravity", true))
  local sNw = tostring(trEnt:GetNWString(gsLisp.."matprop",  sTx))
  sTx = sTx.." [ "..bNw.." | "..sNw.." ] ( "..gRv.." | "..mAt.." )"
  local tw, th = surface.GetTextSize(sTx)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 12, xyP.y - th/2 - 4, tw + 24, th + 8, gclBgn)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 10, xyP.y - th/2 - 2, tw + 20, th + 4, gclBox)
  draw.SimpleText(sTx, gsFont, xyP.x, xyP.y, gclTxt, gnTacn, gnTacn)
end

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel(CPanel)
  local nY, pItem = 0 -- pItem is the current panel created
          CPanel:SetName(language.GetPhrase("tool."..gsTool..".name"))
  pItem = CPanel:Help   (language.GetPhrase("tool."..gsTool..".desc")); nY = nY + pItem:GetTall() + 2

  pItem = CPanel:AddControl("ComboBox",{
    MenuButton = 1,
    Folder     = gsTool,
    Options    = {["Default"] = ConVarsDefault},
    CVars      = table.GetKeys(ConVarsDefault)
  }); nY = pItem:GetTall() + 2
  local matprop = getMaterialInfo(getConvar("material_type"):GetInt(),
                                  getConvar("material_name"):GetInt())
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local tT = list.GetForEdit(gsLisp.."type")
  local pComboType = vgui.Create("DComboBox", CPanel)
        pComboType:SetPos(2, nY)
        pComboType:SetSortItems(false)
        pComboType:SetTall(20)
        pComboType:SetTooltip(language.GetPhrase("tool."..gsTool..".material_type"))
        pComboType:SetValue(language.GetPhrase("tool."..gsTool..".material_type_def"))
        for iT = 1, #tT do pComboType:AddChoice(tT[iT], iT) end
  nY = nY + pComboType:GetTall() + 2
    -- http://wiki.garrysmod.com/page/Category:DComboBox
  local pComboName = vgui.Create("DComboBox", CPanel)
        pComboName:SetPos(2, nY)
        pComboName:SetSortItems(false)
        pComboName:SetTall(20)
        pComboName:SetTooltip(language.GetPhrase("tool."..gsTool..".material_name"))
        pComboName:SetValue(language.GetPhrase("tool."..gsTool..".material_name_def").." "..matprop)
        pComboName.OnSelect = function(pnSelf, nInd, sVal, anyData)
          RunConsoleCommand(gsTool.."_material_name", anyData) end
  -- Material list selection
  pComboType.OnSelect = function(pnSelf, nInd, sVal, anyData)
    local iT = math.Clamp(anyData, 1, #tT)
    local tN = list.GetForEdit(gsLisp..tT[iT]); pComboName:Clear()
    pComboName:SetValue(language.GetPhrase("tool."..gsTool..".material_name_def"))
    for iN = 1, #tN do pComboName:AddChoice(tN[iN], iN) end
    RunConsoleCommand(gsTool.."_material_type", anyData)
  end
  CPanel:AddItem(pComboType)
  CPanel:AddItem(pComboName)

  pItem = CPanel:CheckBox (language.GetPhrase("tool."..gsTool..".gravity_toggle_con"), gsTool.."_gravity_toggle")
          pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".gravity_toggle"))
  pItem = CPanel:CheckBox (language.GetPhrase("tool."..gsTool..".material_draw_con"), gsTool.."_material_draw")
          pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".material_draw"))
end

-- listen for changes to the localify language and reload the tool's menu to update the localizations
if(CLIENT) then
  cvars.AddChangeCallback(varLng:GetName(), function(sNam, vO, vN)
    setTranslate(vN); TOOL.Name = language and language.GetPhrase("tool."..gsTool..".name")
    local cPanel  = controlpanel.Get(TOOL.Mode); if(not IsValid(cPanel)) then return end
    cPanel:ClearControls(); TOOL.BuildCPanel(cPanel)
  end, gsLisp.."lang")
end
