local combat=false
InCombatLockdown=function() return combat end
local function frame()
 local f={attrs={},scripts={},id=1,refs={}}
 function f:SetAttribute(k,v) self.attrs[k]=v end
 function f:GetAttribute(k) return self.attrs[k] end
 function f:GetID() return self.id end
 function f:GetParent() return self.parent end
 function f:GetFrameRef(k) return self.refs[k] end
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:RegisterEvent() end
 return f
end
local created={}
CreateFrame=function() local f=frame();created[#created+1]=f;return f end
local host=frame();local proxy=frame();host.refs.FFAutoFormProxy=proxy
local actions={[1]={'spell',3561},[13]={'spell',33095},[73]={'spell',3561}}
GetActionInfo=function(slot) local a=actions[slot];if a then return table.unpack(a) end end
GetShapeshiftForm=function() return 1 end
GetActionBarPage=function() return 1 end
local bonus=1
GetBonusBarOffset=function() return bonus end
local function flags(slot)
 host.attrs['FFAutoForm-'..slot..'-1']=true
 host.attrs['FFAutoFormKind-'..slot]='spell'
 host.attrs['FFAutoFormID-'..slot]=actions[slot][2]
end
for _,slot in ipairs({1,13,73}) do flags(slot) end
ActionButton1=frame();ActionButton1.attrs.type='action';ActionButton1.parent=frame();ActionButton1.parent.attrs.actionpage=1
BonusActionButton1=frame();BonusActionButton1.attrs.type='action';BonusActionButton1.parent=frame()
ElvUI_Bar1Button1=frame();ElvUI_Bar1Button1.attrs={type='action',action=13,macro=55,macrotext='original',UpdateState='update',state=2,checkselfcast=true};ElvUI_Bar1Button1.parent=frame()
local wraps={}
SecureHandlerWrapScript=function(button,script,header,pre,post)
 assert(type(pre)=='string' and type(post)=='string' and (header==host or header==ConsolePortBar))
 local _,message=assert(load(pre))();assert(message==true)
 wraps[button]=wraps[button] or {};wraps[button][script]=post
 assert(load('return function(self,control,button,down)\n'..post..'\nend'))
end
local ns={enabled=true,bar=host}
assert(loadfile('ActionBars.lua'))('FormFreedom',ns)
ns.actionBarMonitor.scripts.OnUpdate(ns.actionBarMonitor,1)
local activeControlHost=host
local control={}
function control:GetAttribute(k) return host:GetAttribute(k) end
function control:GetFrameRef(k) return activeControlHost:GetFrameRef(k) end
function control:RunFor(button,code,state) assert(code=='update');button.attrs.type='action';button.attrs.action=(state-1)*12+1 end
local function run(button,script,mouse,down)
 local env=setmetatable({self=button,control=control,button=mouse or 'LeftButton',down=down}, {__index=_G})
 assert(load(wraps[button][script],'snippet','t',env))()
end
run(ActionButton1,'PreClick');assert(ActionButton1.attrs.type=='macro' and proxy.attrs.action==1)
run(ActionButton1,'PostClick');assert(ActionButton1.attrs.type=='action' and not ActionButton1.attrs.FFActive)
run(BonusActionButton1,'PreClick');assert(proxy.attrs.action==73);run(BonusActionButton1,'PostClick')
run(ElvUI_Bar1Button1,'PreClick');assert(proxy.attrs.action==13 and ElvUI_Bar1Button1.attrs.macro==nil and proxy.attrs.checkselfcast)
ElvUI_Bar1Button1.attrs.state=1
run(ElvUI_Bar1Button1,'PostClick');assert(ElvUI_Bar1Button1.attrs.macro==55 and ElvUI_Bar1Button1.attrs.macrotext=='original' and ElvUI_Bar1Button1.attrs.action==1)
host.attrs.FFAutoFormCursorBusy=true;run(ActionButton1,'PreClick');assert(ActionButton1.attrs.type=='action');host.attrs.FFAutoFormCursorBusy=nil
run(ActionButton1,'PreClick','RightButton');assert(ActionButton1.attrs.type=='action')
actions[1]={'spell',768};run(ActionButton1,'PreClick');assert(ActionButton1.attrs.type=='action')
combat=true;ns.actionBarMonitor.scripts.OnEvent();ns.actionBarMonitor.scripts.OnUpdate(ns.actionBarMonitor,1)
print('PASS: 3.3.5 wrapper message contract, stock/bonus/ElvUI absolute slots, original attributes/current page restored, selfcast, cursor editing/right click/stale slot excluded, combat deferral')

combat=false
local cp=frame();cp.attrs={type='action',action=1,actionpage=2,state=2,UpdateState='update'}
ConsolePortBar=frame();ConsolePortBar.Buttons={{Buttons={['']=cp}}};cp.parent=ConsolePortBar
function ConsolePortBar:SetFrameRef(k,v) self.refs[k]=v end
ns.actionBarMonitor.scripts.OnEvent();ns.actionBarMonitor.scripts.OnUpdate(ns.actionBarMonitor,1)
assert(cp.attrs.FFCPButton and ConsolePortBar.refs.FFHost==host)
activeControlHost=ConsolePortBar
run(cp,'PreClick','ControllerInput',true);assert(cp.attrs.type=='macro' and proxy.attrs.action==13)
run(cp,'PostClick','ControllerInput',true);assert(cp.attrs.type=='action')
run(cp,'PreClick','ControllerInput',false);assert(cp.attrs.type=='action' and not cp.attrs.FFActive)
print('PASS: CPLK header bridge, page-relative controller press snapshot, release excluded')
