local time, hooks, named = 10, {}, {}
local function frame()
 local f={scripts={},width=1920,height=1080}
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:RegisterEvent() end
 function f:SetPoint() end
 function f:SetFrameStrata() end
 function f:SetWidth(v) self.width=v end
 function f:SetHeight(v) self.height=v end
 function f:GetWidth() return self.width end
 function f:GetHeight() return self.height end
 function f:CreateFontString() return frame() end
 function f:SetText(v) self.text=v end
 function f:SetMultiLine() end
 function f:SetFontObject() end
 function f:SetAutoFocus() end
 function f:SetScrollChild(child) self.child=child end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false end
 function f:SetFocus() self.focus=true end
 function f:HighlightText() self.highlight=true end
 return f
end
UIParent=frame();ChatFontNormal={};UISpecialFrames={};tinsert=table.insert
CreateFrame=function(_,name) local f=frame();if name then named[name]=f end;return f end
GetTime=function() return time end
GetShapeshiftForm=function() return 1 end
GetShapeshiftFormInfo=function() return nil,'Cat Form' end
GetAddOnMetadata=function(_,key) assert(key=='Version');return '1.0.1' end
GetBuildInfo=function() return '3.3.5a','12340' end
GetRealmName=function() return 'Test Realm' end
IsAddOnLoaded=function(name) return name=='ElvUI' end
SlashCmdList={}
for _,name in ipairs({'UseContainerItem','UseItemByName','UseAction','SelectGossipOption','CastSpellByID','CastSpellByName','CastSpell','TakeTaxiNode','DoTradeSkill','DoCraft'}) do _G[name]=function() end end
hooksecurefunc=function(name,fn) assert(type(_G[name])=='function');hooks[name]=fn end
GetContainerItemLink=function() return 'item:9017' end
GetItemInfo=function() return 'Book of Powers','item:9017' end
GetActionInfo=function() return 'item',9017 end
GetGossipOptions=function() local t={}for i=1,9 do t[#t+1]='Option '..i;t[#t+1]='gossip' end return table.unpack(t) end
GetSpellLink=function() return '|Hspell:3561|h[Teleport]|h' end
local ns={enabled=true};assert(loadfile('Diagnostics.lua'))('FormFreedom',ns)
hooks.UseAction(1);assert(not named.FormFreedomReportFrame)
SlashCmdList.FORMFREEDOMREPORT();hooks.UseContainerItem(0,1);hooks.SelectGossipOption(9)
ns.diagnosticMonitor.scripts.OnEvent(nil,'UI_ERROR_MESSAGE','You are in shapeshift form')
time=time+.4;ns.diagnosticMonitor.scripts.OnUpdate()
local report=named.FormFreedomReportFrame
assert(report and report.edit.text:find('item ID=9017') and report.edit.text:find('Gossip option 9') and report.edit.text:find('You are in shapeshift form'))
assert(report.edit.highlight and report.edit.focus and #UISpecialFrames==1)
SlashCmdList.FORMFREEDOMREPORT();hooks.CastSpellByID(3561);SlashCmdList.FORMFREEDOMREPORT();assert(report.edit.text:find('spell ID=3561'))
SlashCmdList.FORMFREEDOMREPORT();time=time+31;ns.diagnosticMonitor.scripts.OnUpdate();assert(report.edit.text:find('No supported action hooks captured'))
print('PASS: opt-in diagnostic capture, item/gossip/error IDs, spell IDs, copy-window selection, manual show and timeout')

assert(report.edit.text:find("1.0.1",1,true))
