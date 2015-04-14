OoI_LastUpdate = GetTime();
function OoI_OnUpdate()
	if OoI_LastUpdate + 0.1 <= GetTime()
	then
		--OoI_RecastBuff();
		OoI_LastUpdate = GetTime();
	end;
end


SLASH_OoI1 = "/OoI";


SlashCmdList["OoI"] = function(args)
	if args == nil or args == ""
	then
		OoI_("/ooi use|toggle|lock");
	else
		if args == "toggle"
		then
			OoI_Settings["UseOil"] = not OoI_Settings["UseOil"]; -- Toggle the bool.
			if OoI_Settings["UseOil"]
			then
				OoI_("ENABLED")
			else
				OoI_("DISABLED")
			end;
		elseif args == "use"
		then
			if OoI_Settings["UseOil"]
			then
				OoI_RecastBuff();
			end
		elseif args == "lock"
		then
			OoI_Settings["FrameLock"] = not OoI_Settings["FrameLock"];
			if OoI_Settings["FrameLock"]
			then
				OoI_("LOCKED")
				OoI_Frame_Checkbox:SetMovable(false);
				--OoI_Frame_Checkbox:EnableMouse(false);
				OoI_Frame_Checkbox:SetResizable(false);
				
				local labelString = getglobal(OoI_Frame_Checkbox:GetName() .. "Text")
				labelString:SetText("");
			else
				OoI_("UNLOCKED")
				OoI_Frame_Checkbox:SetMovable(true);
				--OoI_Frame_Checkbox:EnableMouse(true);
				OoI_Frame_Checkbox:SetResizable(true);
				
				local labelString = getglobal(OoI_Frame_Checkbox:GetName() .. "Text")
				labelString:SetText("OoI");
			end;
		end;
	end
end;



OoI_LastResponsSent = 0;

function OoI_OnEvent()
	if event == "ADDON_LOADED" and arg1 == "OoI"
	then
		if OoI_Settings == nil or not OoI_Settings
		then
			OoI_Settings = {};
			OoI_Settings["UseOil"] = false;
			OoI_Settings["frameRelativePos"] = "TOPLEFT";
			OoI_Settings["frameXPos"] = 0;
			OoI_Settings["frameYPos"] = 0;
		end
		
		OoI_MakeFrame();
	end
end

function OoI_RecastBuff()
	if not OoI_CheckBuff()
	then
		OoI_UseItemByName("Oil of Immolation");
		--OoI_("Time to recast buff!");
	end;
end

function OoI_CheckBuff()
	if OoI_HaveBuff("player", "Fire Shield")
	then
		--OoI_("Have Buff");
		return true;
	end;
	return false;
end

function OoI_HaveBuff(targetUnit, str)
	for i=1,40
	do
		local buffName = OoI_GetBuffName(targetUnit, i);
		
		if(buffName == nil or str == nil)
		then
			return false;
		end;
		
		--OoI_(buffName);
		if str == buffName
		then
			local buffTexture, _, _ = UnitBuff(targetUnit, i);
			
			if(buffTexture == nil or str == nil)
			then
				return false;
			end;
			
			--OoI_(buffTexture);
			if buffTexture == "Interface\\Icons\\Spell_Fire_Immolation"
			then
				return true;
			end
		end;
	end;
end;

function OoI_GetBuffName(unit, nr)
	OoI_tooltip:ClearLines();
	OoI_tooltip:SetUnitBuff(unit,nr);
	local buff_name = OoI_tooltipTextLeft1:GetText();
	return buff_name;
end

function OoI_UseItemByName(search)
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag,slot)
			if item
			then
				--local found, _, itemString = string.find(item, "^|%x+|Hitem\:(.+)\:%[.+%]");
				local a, b, color, d, name = string.find(item, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r")
				--printDebug(a .. " - " .. b .. " - " .. color .. " - " .. d .. " - " .. name);
				if name and name == search then
					UseContainerItem(bag,slot)
					return;
				end
			end
		end
	end
end


function OoI_(str)
	local c = ChatFrame1;
	
	if str == nil
	then
		c:AddMessage('OoI: NIL'); --ChatFrame1
	elseif type(str) == "boolean"
	then
		if str == true
		then
			c:AddMessage('OoI: true');
		else
			c:AddMessage('OoI: false');
		end;
	elseif type(str) == "table"
	then
		c:AddMessage('OoI: array');
		OoI_printArray(str);
	else
		c:AddMessage('OoI: '..str);
	end;
end;

function OoI_printArray(arr, n)
	if n == nil
	then
		 n = "arr";
	end
	for key,value in pairs(arr)
	do
		if type(arr[key]) == "table"
		then
			OoI_printArray(arr[key], n .. "[\"" .. key .. "\"]");
		else
			if type(arr[key]) == "string"
			then
				OoI_(n .. "[\"" .. key .. "\"] = \"" .. arr[key] .."\"");
			elseif type(arr[key]) == "number" 
			then
				OoI_(n .. "[\"" .. key .. "\"] = " .. arr[key]);
			elseif type(arr[key]) == "boolean" 
			then
				if arr[key]
				then
					OoI_(n .. "[\"" .. key .. "\"] = true");
				else
					OoI_(n .. "[\"" .. key .. "\"] = false");
				end;
			else
				OoI_(n .. "[\"" .. key .. "\"] = " .. type(arr[key]));
				
			end;
		end;
	end
end;

function __strsplit(sep,str)
	if str == nil
	then
		return false;
	end;
	local arr = {}
	local tmp = "";
	
	--printDebug(string.len(str));
	local chr;
	for i = 1, string.len(str)
	do
		chr = string.sub(str, i, i);
		if chr == sep
		then
			table.insert(arr,tmp);
			tmp = "";
		else
			tmp = tmp..chr;
		end;
	end
	table.insert(arr,tmp);
	
	return arr
end

-- UI stuff, should be it's own file

function OoI_UI_MoveFrameStart(arg1, frame)
	if not frame.isMoving
	then
		if arg1 == "LeftButton" and frame:IsMovable()
		then
			frame:StartMoving();
			frame.isMoving = true;
		end
	end;
end;

function OoI_UI_MoveFrameStop(arg1, frame)
	if frame.isMoving
	then
		local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
		OoI_Settings["frameRelativePos"] = relativePoint;
		OoI_Settings["frameXPos"] = xOfs;
		OoI_Settings["frameYPos"] = yOfs;
		
		frame:StopMovingOrSizing();
		frame.isMoving = false;
	end
end;

function OoI_MakeFrame()
	--[[
	local f = OoI_Frame;
	f.texture = f:CreateTexture(nil,"background");
	f.texture:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background");
	f:SetWidth(500)
	f:SetHeight(30)
	f:SetPoint("TOPLEFT", 0, 0)
	f:SetFrameStrata("MEDIUM")
	f.texture:SetVertexColor(0,0,0,0.4)
	f:SetMovable(true);
	f:EnableMouse(true);
	f:SetResizable(true);
	f.texture:SetAllPoints(f)
	]]
	
	local button = CreateFrame("CheckButton", "OoI_Frame_Checkbox", f, "UICheckButtonTemplate")
	button:ClearAllPoints()
	button:SetPoint(OoI_Settings["frameRelativePos"], OoI_Settings["frameXPos"], OoI_Settings["frameYPos"])
	--button:SetPoint("CENTER", 0, 0)
	if not OoI_Settings["FrameLock"]
	then
		local labelString = getglobal(button:GetName() .. "Text")
		labelString:SetText("OoI");
	end;
	
	if not OoI_Settings["UseOil"] or nil
	then
		button:SetChecked(nil);
	else
		button:SetChecked(true);
	end
	
	button:SetScript("OnClick", function() OoI_UI_Toggle("UseOil"); end)
	button:SetScript("OnMouseDown", function() OoI_UI_MoveFrameStart(arg1, this); end)
	button:SetScript("OnMouseUp", function() OoI_UI_MoveFrameStop(arg1, this); end)
	button:SetMovable(not OoI_Settings["FrameLock"]);
	--button:EnableMouse(OoI_Settings["FrameLock"]);
	button:EnableMouse(true);
	button:SetResizable(not OoI_Settings["FrameLock"]);
	
	button:Show();
	--OoI_Frame:Show();
	
end

function OoI_UI_Toggle(boolName)
	local checked = this:GetChecked();
	OoI_Settings["UseOil"] = checked;
	if OoI_Settings["UseOil"]
	then
		OoI_("ENABLED")
	else
		OoI_("DISABLED")
	end;
end

OoI_Frame = CreateFrame("FRAME", "OoI_Frame");
OoI_Frame:RegisterEvent("ADDON_LOADED");
OoI_Frame:RegisterEvent("PLAYER_LOGIN");
OoI_Frame:RegisterEvent("CHAT_MSG_SYSTEM");
OoI_Frame:RegisterEvent("CHAT_MSG_ADDON");
OoI_Frame:SetScript("OnUpdate", OoI_OnUpdate);
OoI_Frame:SetScript("OnEvent", OoI_OnEvent);
