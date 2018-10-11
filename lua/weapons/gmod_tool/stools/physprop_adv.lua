local gsTool = "physprop_adv"
local gsLisp = "physicsmaterialsadv_"
local gclBgn = Color(0, 0, 0, 210)
local gclTxt = Color(0, 0, 0, 255)
local gclBox = Color(250, 250, 200, 255)
local gsInvm = "N/A"
local gnRadm = (20*0.618)
local gnRadr = (gnRadm-gnRadm%2)
local gsFont = "Trebuchet24"
local gnTacn = TEXT_ALIGN_CENTER 

TOOL.Category = "Construction"
TOOL.Name = "Physical Properties Adv"

TOOL.ClientConVar = {
  [ "gravity_toggle" ] = 1,
  [ "material_type"  ] = 1,
  [ "material_name"  ] = 1,
  [ "material_draw"  ] = 1,
  [ "material_cash"  ] = 1
}

-- This list contains surface property types and it is used to index property name lists
table.Empty(list.GetForEdit(gsLisp.."type"))
list.Add(gsLisp.."type", "special"      )
list.Add(gsLisp.."type", "concrete"     )
list.Add(gsLisp.."type", "metal"        )
list.Add(gsLisp.."type", "wood"         )
list.Add(gsLisp.."type", "terrain"      )
list.Add(gsLisp.."type", "liquid"       )
list.Add(gsLisp.."type", "frozen"       )
list.Add(gsLisp.."type", "miscellaneous")
list.Add(gsLisp.."type", "organic"      )
list.Add(gsLisp.."type", "manufactured" )

-- These are the property name lists indexed by a property type used
table.Empty(list.GetForEdit(gsLisp.."special"))
list.Add(gsLisp.."special",  "default"            )
list.Add(gsLisp.."special",  "default_silent"     )
list.Add(gsLisp.."special",  "floatingstandable"  )
list.Add(gsLisp.."special",  "item"               )
list.Add(gsLisp.."special",  "ladder"             )
list.Add(gsLisp.."special",  "no_decal"           )
list.Add(gsLisp.."special",  "player"             )
list.Add(gsLisp.."special",  "player_control_clip")

table.Empty(list.GetForEdit(gsLisp.."concrete"))
list.Add(gsLisp.."concrete", "brick"         )
list.Add(gsLisp.."concrete", "concrete"      )
list.Add(gsLisp.."concrete", "concrete_block")
list.Add(gsLisp.."concrete", "gravel"        )
list.Add(gsLisp.."concrete", "rock"          )

table.Empty(list.GetForEdit(gsLisp.."metal"))
list.Add(gsLisp.."metal","canister"             )
list.Add(gsLisp.."metal","chain"                )
list.Add(gsLisp.."metal","chainlink"            )
list.Add(gsLisp.."metal","combine_metal"        )
list.Add(gsLisp.."metal","crowbar"              )
list.Add(gsLisp.."metal","floating_metal_barrel")
list.Add(gsLisp.."metal","grenade"              )
list.Add(gsLisp.."metal","gunship"              )
list.Add(gsLisp.."metal","metal"                )
list.Add(gsLisp.."metal","metal_barrel"         )
list.Add(gsLisp.."metal","metal_bouncy"         )
list.Add(gsLisp.."metal","Metal_Box"            )
list.Add(gsLisp.."metal","metal_seafloorcar"    )
list.Add(gsLisp.."metal","metalgrate"           )
list.Add(gsLisp.."metal","metalpanel"           )
list.Add(gsLisp.."metal","metalvent"            )
list.Add(gsLisp.."metal","metalvehicle"         )
list.Add(gsLisp.."metal","paintcan"             )
list.Add(gsLisp.."metal","popcan"               )
list.Add(gsLisp.."metal","roller"               )
list.Add(gsLisp.."metal","slipperymetal"        )
list.Add(gsLisp.."metal","solidmetal"           )
list.Add(gsLisp.."metal","strider"              )
list.Add(gsLisp.."metal","weapon"               )

table.Empty(list.GetForEdit(gsLisp.."wood"))
list.Add(gsLisp.."wood", "wood"          )
list.Add(gsLisp.."wood", "Wood_Box"      )
list.Add(gsLisp.."wood", "Wood_Furniture")
list.Add(gsLisp.."wood", "Wood_Plank"    )
list.Add(gsLisp.."wood", "Wood_Panel"    )
list.Add(gsLisp.."wood", "Wood_Solid"    )

table.Empty(list.GetForEdit(gsLisp.."terrain"))
list.Add(gsLisp.."terrain", "dirt"         )
list.Add(gsLisp.."terrain", "grass"        )
list.Add(gsLisp.."terrain", "gravel"       )
list.Add(gsLisp.."terrain", "mud"          )
list.Add(gsLisp.."terrain", "quicksand"    )
list.Add(gsLisp.."terrain", "sand"         )
list.Add(gsLisp.."terrain", "slipperyslime")
list.Add(gsLisp.."terrain", "antlionsand"  )

table.Empty(list.GetForEdit(gsLisp.."liquid"))
list.Add(gsLisp.."liquid", "slime")
list.Add(gsLisp.."liquid", "water")
list.Add(gsLisp.."liquid", "wade" )

table.Empty(list.GetForEdit(gsLisp.."frozen"))
list.Add(gsLisp.."frozen", "snow"    )
list.Add(gsLisp.."frozen", "ice"     )
list.Add(gsLisp.."frozen", "gmod_ice")

table.Empty(list.GetForEdit(gsLisp.."miscellaneous"))
list.Add(gsLisp.."miscellaneous", "carpet"      )
list.Add(gsLisp.."miscellaneous", "ceiling_tile")
list.Add(gsLisp.."miscellaneous", "computer"    )
list.Add(gsLisp.."miscellaneous", "pottery"     )

table.Empty(list.GetForEdit(gsLisp.."organic"))
list.Add(gsLisp.."organic", "alienflesh" )
list.Add(gsLisp.."organic", "antlion"    )
list.Add(gsLisp.."organic", "armorflesh" )
list.Add(gsLisp.."organic", "bloodyflesh")
list.Add(gsLisp.."organic", "flesh"      )
list.Add(gsLisp.."organic", "foliage"    )
list.Add(gsLisp.."organic", "watermelon" )
list.Add(gsLisp.."organic", "zombieflesh")

table.Empty(list.GetForEdit(gsLisp.."manufactured"))
list.Add(gsLisp.."manufactured", "jeeptire"               )
list.Add(gsLisp.."manufactured", "jalopytire"             )
list.Add(gsLisp.."manufactured", "rubber"                 )
list.Add(gsLisp.."manufactured", "rubbertire"             )
list.Add(gsLisp.."manufactured", "slidingrubbertire"      )
list.Add(gsLisp.."manufactured", "slidingrubbertire_front")
list.Add(gsLisp.."manufactured", "slidingrubbertire_rear" )
list.Add(gsLisp.."manufactured", "brakingrubbertire"      )
list.Add(gsLisp.."manufactured", "tile"                   )
list.Add(gsLisp.."manufactured", "paper"                  )
list.Add(gsLisp.."manufactured", "papercup"               )
list.Add(gsLisp.."manufactured", "cardboard"              )
list.Add(gsLisp.."manufactured", "plaster"                )
list.Add(gsLisp.."manufactured", "plastic_barrel"         )
list.Add(gsLisp.."manufactured", "plastic_barrel_buoyant" )
list.Add(gsLisp.."manufactured", "Plastic_Box"            )
list.Add(gsLisp.."manufactured", "plastic"                )
list.Add(gsLisp.."manufactured", "glass"                  )
list.Add(gsLisp.."manufactured", "glassbottle"            )
list.Add(gsLisp.."manufactured", "combine_glass"          )

if(CLIENT) then
  TOOL.Information = {
    { name = "info", stage = 1},
    { name = "left"  },
    { name = "left_use", icon2 = "gui/e.png"},
    { name = "right" },
    { name = "reload"}
  }
  language.Add("tool."..gsTool..".name"              , "Physics Properties Adv")
  language.Add("tool."..gsTool..".desc"              , "Advanced and extended version of the original physics properties tool")
  language.Add("tool."..gsTool..".left"              , "Apply the selected physical property")
  language.Add("tool."..gsTool..".right"             , "Cache the selected physical property")
  language.Add("tool."..gsTool..".right_use"         , "Cache the applied physical property")
  language.Add("tool."..gsTool..".reload"            , "Reset original physical property")
  language.Add("tool."..gsTool..".left_use"          , "Apply cached physical property")
  language.Add("tool."..gsTool..".material_type"     , "Select material type from the ones listed here")
  language.Add("tool."..gsTool..".material_type_def" , "Select type...")
  language.Add("tool."..gsTool..".material_name"     , "Select material name from the ones listed here")
  language.Add("tool."..gsTool..".material_name_def" , "Select name...")
  language.Add("tool."..gsTool..".gravity_toggle_con", "Enable gravity")
  language.Add("tool."..gsTool..".gravity_toggle"    , "When checked turns enables the gravity for an entity")
  language.Add("tool."..gsTool..".material_draw_con" , "Enable material draw")
  language.Add("tool."..gsTool..".material_draw"     , "Show trace entity surface material")  
end

if(SERVER) then
  duplicator.RegisterEntityModifier(gsLisp.."dupe", function(oPly, oEnt, tData)
    oEnt:SetNWBool(gsLisp.."gravity", tData[1]); oEnt:SetNWString(gsLisp.."matprop", tData[2])
  end)
end

function TOOL:NotifyPlayer(sText, sType, vRet)
  if(SERVER) then -- Send notification to client that something happened
    local mePly = self:GetOwner()
    mePly:SendLua("GAMEMODE:AddNotify(\""..sText.."\", NOTIFY_"..sType..", 6)")
    mePly:SendLua("surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
  end; return vRet
end

local function getConvar(sN)
  return GetConVar(gsTool.."_"..sN)
end

local function getMaterialInfo(vT, vN) -- Avoid returning a copy by list-get to make it faster
  local tT = list.GetForEdit(gsLisp.."type") -- No edit though just read it
  local iT = math.Clamp(tonumber(vT or 1), 1, #tT)
  local tN = list.GetForEdit(gsLisp..tT[iT]) -- No edit though same here
  local iN = math.Clamp(tonumber(vN or 1), 1, #tN)
  return tostring(tN[iN] or "")
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

function TOOL:LeftClick(tr)
  if(CLIENT) then return true end -- The client has nothing to do
  if(not (tr and tr.Hit) or tr.HitWorld) then return false end
  -- Make sure we don mot apply custom physical properties on the world surface
  local trEnt, trBon = tr.Entity, tr.PhysicsBone
  if(not (trEnt and trEnt:IsValid())) then return false end
  if(trEnt:IsPlayer() or trEnt:IsWorld()) then return false end
  -- Make sure there's a physics object to manipulate
  if(SERVER and not util.IsValidPhysicsObject(trEnt, trBon)) then return false end
  local mePly, matprop = self:GetOwner()
  local gravity = (self:GetClientNumber("gravity_toggle") == 1)
  if(self:CheckButton(IN_USE)) then matprop = self:GetMaterialCash()
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
  if(self:CheckButton(IN_USE) and (trEnt and trEnt:IsValid())) then
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
  if(SERVER and not util.IsValidPhysicsObject(trEnt, trBon)) then
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
  local xyP = trEnt:LocalToWorld(trEnt:OBBCenter()):ToScreen()
  local text = (nP and util.GetSurfacePropName(nP) or gsInvm); surface.SetFont(gsFont)
  text = text.." [ "..tostring(trEnt:GetNWBool  (gsLisp.."gravity", true)).." | "..
                      tostring(trEnt:GetNWString(gsLisp.."matprop", text)).." ]"
  local tw, th = surface.GetTextSize(text)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 12, xyP.y - th/2 - 4, tw + 24, th + 8, gclBgn)
  draw.RoundedBox(gnRadr, xyP.x - tw/2 - 10, xyP.y - th/2 - 2, tw + 20, th + 4, gclBox)
  draw.SimpleText(text, gsFont, xyP.x, xyP.y, gclTxt, gnTacn, gnTacn)
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )
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
