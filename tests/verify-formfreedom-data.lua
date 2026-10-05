unpack=table.unpack
local attrs, scripts = {}, {}
local function frame()
 local f={attrs={},scripts={},id=0}
 function f:SetAttribute(k,v) self.attrs[k]=v end
 function f:GetAttribute(k) return self.attrs[k] end
 function f:SetID(id) self.id=id end
 function f:GetID() return self.id end
 function f:SetFrameRef(k,v) self.attrs[k]=v end
 function f:GetFrameRef(k) return self.attrs[k] end
 function f:RegisterForClicks() end
 function f:Hide() end
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:RegisterEvent() end
 return f
end
local frames={}
CreateFrame=function() local f=frame();frames[#frames+1]=f;return f end
local bar=frame()
local combat=false
InCombatLockdown=function() return combat end
GetCursorInfo=function() end
GetNumShapeshiftForms=function() return 1 end
GetShapeshiftFormInfo=function() return nil,'Cat Form' end
GetSpellInfo=function(id) if id==768 then return 'Cat Form','' elseif id==8690 then return 'Hearthstone','' elseif id==3561 then return 'Teleport','' end end
local actions={[1]={'item',6948},[2]={'spell',3561},[3]={'companion',1,'MOUNT'},[4]={'spell',768},[5]={'item',99999},[6]={'item',9017}}
GetActionInfo=function(slot) if actions[slot] then return unpack(actions[slot]) end end
GetItemInfo=function(id) return 'Item' end
GetItemSpell=function(id) if id==6948 then return 'Hearthstone','' elseif id==99999 then return 'Teleport','' end end
GetCompanionInfo=function() return 1,'Mount',999999 end
GetShapeshiftForm=function() return 1 end
wipe=function(t) for k in pairs(t) do t[k]=nil end end
bit={band=function(a,b) return a & b end}
local function compare(t1, t2)
	if t1 == t2 then
		return true
	elseif (t1 and not t2) or (t2 and not t1) then
		return false
	end
	if type(t1) ~= "table" then
		return false
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2)
	if not compare(mt1,mt2) then
		return false
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if not compare(v1,v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if not compare(v1,v2) then
			return false
		end
	end
	return true
end
local ab={enabled=true,bar=bar,data={table={compare=compare}}}
assert(loadfile("FormRestrictions.lua"))('ConsolePortBar',ab)
ab.formLookupIDs={768,8690,3561}
assert(loadfile("AutoForm.lua"))('ConsolePortBar',ab)
local monitor=frames[2];monitor.scripts.OnUpdate(monitor,1)
assert(bar:GetAttribute('FFAutoForm-1-1'));assert(bar:GetAttribute('FFAutoForm-2-1'));assert(bar:GetAttribute('FFAutoForm-3-1'));assert(not bar:GetAttribute('FFAutoForm-4-1'));assert(bar:GetAttribute('FFAutoForm-5-1'))
assert(not bar:GetAttribute('FFAutoForm-6-1'))
print('PASS: standalone restriction data, localized monitor classification and action fingerprints')
