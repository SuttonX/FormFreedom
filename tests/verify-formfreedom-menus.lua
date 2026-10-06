local hooks, frames = {}, {}
local combat, form, now, npc = false, 1, 10, false
local function frame(name)
 local f={attrs={},scripts={},shown=true,id=1,type='Gossip',enabled=true}
 function f:SetAttribute(k,v) assert(not combat);self.attrs[k]=v end
 function f:GetAttribute(k) return self.attrs[k] end
 function f:RegisterForClicks() end
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:GetScript(k) return self.scripts[k] end
 function f:LockHighlight() self.highlight=true end
 function f:UnlockHighlight() self.highlight=false end
 function f:RegisterEvent() end
 function f:Hide() assert(not combat);self.hides=(self.hides or 0)+1;self.shown=false end
 function f:Show() assert(not combat);self.shows=(self.shows or 0)+1;self.shown=true end
 function f:IsVisible() return self.shown end
 function f:IsShown() return self.shown end
 function f:GetAttribute(k) return self.attrs[k] end
 function f:IsEnabled() return self.enabled end
 function f:GetID() return self.id end
 function f:GetLeft() return 10 end
 function f:GetBottom() return 20 end
 function f:GetEffectiveScale() return 2 end
 function f:GetWidth() return 100 end
 function f:GetHeight() return 20 end
 function f:GetFrameStrata() return 'HIGH' end
 function f:GetFrameLevel() return 10 end
 function f:ClearAllPoints() end
 function f:SetPoint(...) self.point={...} end
 function f:SetWidth(v) self.width=v end
 function f:SetHeight(v) self.height=v end
 function f:SetFrameStrata() end
 function f:SetFrameLevel() end
 if name then _G[name]=f;frames[name]=f end
 return f
end
CreateFrame=function(_,name) return frame(name) end
UIParent=frame();RegisterStateDriver=function(_,key,value) assert(key=='visibility' and value=='[combat] hide; show') end
hooksecurefunc=function(name,fn) hooks[name]=fn end
GetTime=function() return now end
InCombatLockdown=function() return combat end
GetShapeshiftForm=function() return form end
UnitExists=function() return npc end
GetNumGossipOptions=function() return 9 end
GetContainerItemLink=function() return 'item:9017' end
GetActionInfo=function() return 'item',9017 end
GetItemInfo=function() return 'Book of Powers','item:9017' end
NumTaxiNodes=function() return 2 end
TaxiNodeGetType=function(id) return id==1 and 'CURRENT' or 'REACHABLE' end
GossipFrame=frame();TaxiFrame=frame();TaxiFrame.shown=false
for i=1,9 do local f=frame('GossipTitleButton'..i);f.id=i end
for i=1,2 do local f=frame('TaxiButton'..i);f.id=i end
local crafted=0
TradeSkillCreateButton=frame();TradeSkillCreateButton.scripts.OnClick=function(source) assert(source==TradeSkillCreateButton);crafted=crafted+1 end
local reconciles=0
ConsolePortBar={ReconcileFormMenuState=function() reconciles=reconciles+1 end}
local ab={enabled=true,bar={ReconcileFormMenuState=function() reconciles=reconciles+1 end}};assert(loadfile('Menus.lua'))('ConsolePortBar',ab)
local function tick() ab.formMenuMonitor.scripts.OnUpdate(ab.formMenuMonitor,.2) end
tick();assert(not GossipTitleButton2.ffAutoFormClick)
hooks.UseContainerItem(0,1);hooks.GossipFrameUpdate()
assert(GossipTitleButton2.ffAutoFormClick.attrs.macrotext=='/cancelform [form]\n/run SelectGossipOption(2)')
assert(GossipTitleButton9.ffAutoFormClick);assert(not GossipTitleButton3.ffAutoFormClick)
local held=GossipTitleButton2.ffAutoFormClick;local hides,shows=held.hides,held.shows;tick();tick();assert(held.hides==hides and held.shows==shows and held.source==GossipTitleButton2)
held.scripts.OnEnter(held);assert(GossipTitleButton2.highlight);held.scripts.OnLeave(held);assert(not GossipTitleButton2.highlight);held.scripts.OnEnter(held);form=0;tick();assert(not GossipTitleButton2.highlight);form=1;tick()
local craft=TradeSkillCreateButton.ffAutoFormClick;assert(craft and craft.attrs.macrotext=='/cancelform [form]\n')
craft.scripts.PreClick(craft,'LeftButton'); form=0; tick(); assert(not craft.source); craft.scripts.PostClick(craft,'LeftButton');assert(crafted==1);form=1;tick()
now=now+1;tick();assert(reconciles==1);tick();assert(reconciles==1)
TradeSkillCreateButton.enabled=false;tick();assert(not TradeSkillCreateButton.ffAutoFormClick)
ab.formMenuMonitor.scripts.OnEvent(ab.formMenuMonitor,'GOSSIP_CLOSED');assert(not GossipTitleButton2.ffAutoFormClick)
npc=true;hooks.UseItemByName(9017);hooks.GossipFrameUpdate();assert(not GossipTitleButton2.ffAutoFormClick)
npc=false;TaxiFrame.shown=true;tick();assert(not TaxiButton1.ffAutoFormClick);assert(TaxiButton2.ffAutoFormClick.attrs.macrotext:find('TakeTaxiNode%(2%)'))
combat=true;tick();combat=false
form=0;tick();assert(not TaxiButton2.ffAutoFormClick)
print('PASS: native book context/options, unrelated gossip, enabled crafting and original callback, reachable taxi only, combat deferral, unshift cleanup')
form=1;TradeSkillCreateButton.enabled=true;tick()
local previous=TradeSkillCreateButton
TradeSkillCreateButton=frame();tick()
assert(previous.ffAutoFormClick==nil,'Reusing an overlay must clear the old source redirect')
assert(TradeSkillCreateButton.ffAutoFormClick.source==TradeSkillCreateButton)
print('PASS: replaced menu source clears stale controller redirect')
