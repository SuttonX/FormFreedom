unpack=table.unpack
local mounted,flying,taxi,combat,form=true,false,false,false,1
local function frame()
 local f={attrs={},refs={},scripts={}}
 function f:SetAttribute(k,v) assert(not combat);self.attrs[k]=v end
 function f:GetAttribute(k) return self.attrs[k] end
 function f:SetFrameRef(k,v) self.refs[k]=v end
 function f:GetFrameRef(k) return self.refs[k] end
 function f:SetID(v) self.id=v end
 function f:GetID() return self.id end
 function f:GetParent() return self.parent end
 function f:RegisterForClicks() end
 function f:Hide() end
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:RegisterEvent() end
 return f
end
CreateFrame=function() return frame() end
UnitClass=function() return 'Warrior','WARRIOR' end
UIParent=frame()
local ns={};assert(loadfile('Core.lua'))('FormFreedom',ns)
assert(ns.enabled and ns.formEnabled==false)
assert(loadfile('FormRestrictions.lua'))('FormFreedom',ns)
assert(loadfile('MountRestrictions.lua'))('FormFreedom',ns)
assert(ns.mountRestrictions[331] and ns.mountRestrictions[7620] and ns.mountRestrictions[746])
assert(ns.mountRestrictions[2383]==false and ns.mountRestrictions[2580]==false and ns.mountRestrictions[62575]==false)
GetNumShapeshiftForms=function() error('Other classes must not classify or cancel stances') end
GetSpellInfo=function(id)
 if id==331 then return 'Healing Wave','Rank 1' end
 if id==62575 or id==7620 then return 'Ambiguous custom name','' end
end
GetShapeshiftForm=function() return form end
IsMounted=function() return mounted end
IsFlying=function() return flying end
UnitOnTaxi=function() return taxi end
InCombatLockdown=function() return combat end
GetCursorInfo=function() end
GetItemInfo=function() return 'Item' end
GetItemSpell=function(id)
 if id==10001 then return 'Bandage',746 end
 if id==10002 then return 'Healing Wave','Rank 1' end
 if id==10003 then return 'Ambiguous custom name','' end
end
GetCompanionInfo=function() return 1,'Horse',458 end
local actions={
 [1]={'spell',89,'spell',331},
 [2]={'spell',20,'spell',2383}, -- Tracking works mounted.
 [3]={'spell',21,'spell',62575}, -- Mounted combat must stay native.
 [4]={'item',10001}, -- Bandage with numeric item-spell resolution.
 [5]={'item',10002}, -- Unambiguous localized item spell.
 [6]={'spell',22,'spell',999999},
 [7]={'companion',1,'MOUNT'},
 [8]={'item',10003}, -- Same name, opposing mounted flags: reject.
}
GetActionInfo=function(slot) if actions[slot] then return unpack(actions[slot]) end end
wipe=function(t) for k in pairs(t) do t[k]=nil end end
bit={band=function(a,b) return a & b end}
ns.formLookupIDs={331,62575,7620}
local frames={}
CreateFrame=function() local f=frame();frames[#frames+1]=f;return f end
ns.formLookupIDs={331,62575,7620}
assert(loadfile('AutoForm.lua'))('FormFreedom',ns)
local monitor=frames[2]
monitor.scripts.OnUpdate(monitor,1)
for _,slot in ipairs({1,4,5,7}) do assert(ns.bar:GetAttribute('FFDismount-'..slot),slot) end
for _,slot in ipairs({2,3,6,8}) do assert(not ns.bar:GetAttribute('FFDismount-'..slot),slot) end
assert(not ns.bar:GetAttribute('FFAutoForm-1-1'))
local wrappers={}
SecureHandlerWrapScript=function(button,script,header,pre,post) wrappers[script]=post end
ElvUI_Bar1Button1=frame();ElvUI_Bar1Button1.attrs={type='action',action=1}
assert(loadfile('ActionBars.lua'))('FormFreedom',ns)
ns.actionBarMonitor.scripts.OnUpdate(ns.actionBarMonitor,1)
local button=ElvUI_Bar1Button1
local function run(script,click)
 local env=setmetatable({self=button,owner=ns.bar,button=click or 'LeftButton',control={}}, {__index=_G})
 assert(load(wrappers[script],'snippet','t',env))()
end
run('PreClick');assert(button.attrs.type=='macro')
assert(button.attrs.macrotext=='/dismount [mounted,noflying]\n/click FormFreedomActionProxy LeftButton')
assert(ns.bar.refs.FFAutoFormProxy.attrs.action==1);run('PostClick')
for _,slot in ipairs({2,3,6,8}) do button.attrs.action=slot;run('PreClick');assert(button.attrs.type=='action') end
button.attrs.action=1
run('PreClick','RightButton');assert(button.attrs.type=='action')
flying=true;run('PreClick');assert(button.attrs.type=='action');flying=false
mounted=false;run('PreClick');assert(button.attrs.type=='action');mounted=true
taxi=true;monitor.scripts.OnEvent(monitor,'PLAYER_CONTROL_LOST');run('PreClick');assert(button.attrs.type=='action')
taxi=false;monitor.scripts.OnEvent(monitor,'PLAYER_CONTROL_GAINED')
actions[1][4]=2383;run('PreClick');assert(button.attrs.type=='action','Stale mounted classification must be rejected')
combat=true;monitor.scripts.OnEvent(monitor,'SPELLS_CHANGED');monitor.scripts.OnUpdate(monitor,1)
combat=false;monitor.scripts.OnEvent(monitor,'PLAYER_REGEN_ENABLED')
assert(not ns.bar:GetAttribute('FFDismount-1'))
print('PASS: all-class mounted classification, allowed tracking/mounted combat, item ambiguity, ground-only secure dismount, taxi/right-click/stale action/combat guards')
