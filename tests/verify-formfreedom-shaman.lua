IsMounted=function() return false end
IsFlying=function() return false end
-- Mock tests run on Lua 5.3+; addon source remains Lua 5.1 compatible.
unpack=table.unpack
local function frame()
 local f={attrs={},refs={},scripts={}}
 function f:SetAttribute(k,v) self.attrs[k]=v end
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
local created={}
CreateFrame=function() local f=frame();created[#created+1]=f;return f end
UIParent=frame()
for _,class in ipairs({'DRUID','SHAMAN','ROGUE','WARRIOR','MAGE','PRIEST','WARLOCK','HUNTER','PALADIN','DEATHKNIGHT'}) do
 UnitClass=function() return 'localized class',class end
 local ns={};local count=#created
 assert(loadfile('Core.lua'))('FormFreedom',ns)
 local enabled=class=='DRUID' or class=='SHAMAN'
 assert(ns.enabled and ns.formEnabled==enabled)
 assert(#created==count+1)
end
UnitClass=function() return 'Chaman','SHAMAN' end
local ns={};assert(loadfile('Core.lua'))('FormFreedom',ns)
assert(loadfile('FormRestrictions.lua'))('FormFreedom',ns)
assert(ns.cancellableForms[16]==2645)
local bar=ns.bar
local combat=false
InCombatLockdown=function() return combat end
GetCursorInfo=function() end
GetNumShapeshiftForms=function() return 1 end
GetShapeshiftFormInfo=function() return nil,'Loup fantome' end
GetSpellInfo=function(id) if id==2645 then return 'Loup fantome','' end end
GetItemInfo=function() return 'item' end
GetItemSpell=function() end
GetCompanionInfo=function() return 1,'Mount',999999 end
local actions={
 [1]={'spell',89,'spell',331}, -- Healing Wave, not spell 89
 [2]={'spell',12,'spell',2645}, -- Ghost Wolf itself
 [3]={'spell',13,'spell',7620}, -- Fishing
 [4]={'companion',1,'MOUNT'},
 [5]={'spell',14,'spell',999999}, -- Unknown custom action
 [6]={'spell',15,'spell'}, -- Missing global spell ID
}
GetActionInfo=function(slot) if actions[slot] then return unpack(actions[slot]) end end
local form=1
GetShapeshiftForm=function() return form end
wipe=function(t) for k in pairs(t) do t[k]=nil end end
bit={band=function(a,b) return a & b end}
ns.formLookupIDs={2645}
assert(loadfile('AutoForm.lua'))('FormFreedom',ns)
local monitor=created[#created]
monitor.scripts.OnUpdate(monitor,1)
for _,slot in ipairs({1,3,4}) do assert(bar:GetAttribute('FFAutoForm-'..slot..'-1')) end
for _,slot in ipairs({2,5,6}) do assert(not bar:GetAttribute('FFAutoForm-'..slot..'-1')) end
assert(bar:GetAttribute('FFAutoFormSpellID-1')==331)
assert(not ns:FormActionRequiresExit({false,32768,0,true,false,false},16), 'Ghost Wolf-allowed actions stay native')
local wrappers={}
SecureHandlerWrapScript=function(button,script,header,pre,post) wrappers[script]=post end
ElvUI_Bar1Button1=frame();ElvUI_Bar1Button1.attrs={type='action',action=1}
assert(loadfile('ActionBars.lua'))('FormFreedom',ns)
ns.actionBarMonitor.scripts.OnUpdate(ns.actionBarMonitor,1)
local button=ElvUI_Bar1Button1
local function run(script)
 local env=setmetatable({self=button,owner=bar,button='LeftButton',control={}}, {__index=_G})
 assert(load(wrappers[script],'snippet','t',env))()
end
run('PreClick');assert(button.attrs.type=='macro' and bar.refs.FFAutoFormProxy.attrs.action==1);run('PostClick')
button.attrs.action=2;run('PreClick');assert(button.attrs.type=='action', 'Ghost Wolf button stays native')
button.attrs.action=1;form=0;run('PreClick');assert(button.attrs.type=='action', 'Humanoid action stays native')
print('PASS: class gating, localized Ghost Wolf, restricted spell/mount/Fishing handling, native form casting/unknown actions, ElvUI secure routing')
