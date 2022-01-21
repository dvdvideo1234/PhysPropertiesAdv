local gsTool = TOOL.Mode -- Filled from file name
local gsPref = gsTool.."_"
local gsMats = "OverrideMaterials"

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

	net.Receive(gsPref.."randomize", function(len)
		local ply = LocalPlayer()
		if(not ply) then return end
		if(not ply:IsValid()) then return end
		local key = GetConVar(gsPref.."customset"):GetString()
		if(not key or key == "") then return end
		key = (key == gsMats) and gsMats or (gsPref..key)
		local set = list.GetForEdit(key)
		if(not (set and set[1])) then return end
		local idx = math.random(#set)
		local mat = set[idx]
		if(mat == "") then table.remove(set, idx) end
		RunConsoleCommand(gsTool.."_randommat", mat)
	end)

	language.Add("tool."..gsTool..".category"   , "Render")
	language.Add("tool."..gsTool..".name"       , "Material Adv")
	language.Add("tool."..gsTool..".desc"       , "Advanced control over materials")
	language.Add("tool."..gsTool..".left"       , "Apply material")
	language.Add("tool."..gsTool..".right"      , "Copy material")
	language.Add("tool."..gsTool..".reload"     , "Revert material")
	language.Add("tool."..gsTool..".pattern_con", "Quick filter")
	language.Add("tool."..gsTool..".pattern"    , "Enter pattern to search")
	language.Add("tool."..gsTool..".random_con" , "Randomize material on apply")
	language.Add("tool."..gsTool..".random"     , "Enable this so the tool will pick random material for you")
	language.Add("tool."..gsTool..".type_con"   , "Material list")
	language.Add("tool."..gsTool..".type"       , "Select material source list from ones displayed here")
	language.Add("tool."..gsTool..".type_def"   , "Select list...")

	local function readMaterials(tF)
	  if(tF and tF[1]) then local tL = list.GetTable()
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

	if(not file.Exists(gsTool,"DATA")) then file.CreateDir(gsTool) end
	readMaterials(file.Find(gsTool.."/materials/*.txt","DATA")) -- Search for text files
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
	return (self:GetClientNumber("randomize", 0) ~= 0)
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
	local ent = trace.Entity
	if(IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end
	if(not IsValid(ent)) then return false end -- Entity invalid
	self:GetOwner():ConCommand(gsTool.."_override "..ent:GetMaterial())
	return true
end

-- Reload reverts the material
function TOOL:Reload(trace)
	if(CLIENT) then return true end
	local ent = trace.Entity
	if(IsValid(ent.AttachedEntity)) then ent = ent.AttachedEntity end
	if(IsValid(ent)) then return false end -- The entity is valid and isn't worldspawn
	SetMaterial(self:GetOwner(), ent, {MaterialOverride = ""})
	return true
end

function wipeMaterials(pMat)
  for iD = 1, #pMat.Controls do
  	pMat.Controls[iD]:Remove()
  end; pMat.List:CleanList()
	table.Empty(pMat.Controls)
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
  -- Randomize applied material
  pItem = CPanel:CheckBox(language.GetPhrase("tool."..gsTool..".random_con"), gsTool.."_randomize")
  pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".random"))
  -- Read the current list string identifier
  local tT = list.GetForEdit(gsPref.."type")
  local sS, nT = GetConVar(gsTool.."_customset"):GetString(), #tT
  -- Prepare combo box
  local pCombo, pItem = CPanel:ComboBox(language.GetPhrase("tool."..gsTool..".type_con"))
  pCombo:SetTooltip(language.GetPhrase("tool."..gsTool..".type"))
  pItem:SetTooltip(language.GetPhrase("tool."..gsTool..".type"))
  pCombo:SetValue(language.GetPhrase("tool."..gsTool..".type_def"))
  pCombo.DoRightClick = function(pnSelf)
	  local iD = pnSelf:GetSelectedID()
	  local vT = pnSelf:GetOptionText(iD)
	  local sV = tostring(vT or pnSelf:GetValue())
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
    local sM = tN[math.random(#tN)]
    RunConsoleCommand(gsTool.."_customset", sC)
    RunConsoleCommand(gsTool.."_randommat", sM)
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
