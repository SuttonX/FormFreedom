-- Exact localized error text, 3.3.5 event arguments, and native dismount guards.
ERR_ATTACK_MOUNTED='localized attack mounted'
ERR_NOT_WHILE_MOUNTED='localized action mounted'
ERR_TAXIPLAYERALREADYMOUNTED='localized taxi mounted'
SPELL_FAILED_NOT_MOUNTED='localized cast mounted'
local mounted,flying,taxi,combat=true,false,false,false
IsMounted=function() return mounted end
IsFlying=function() return flying end
UnitOnTaxi=function() return taxi end
InCombatLockdown=function() return combat end
CreateFrame=function()
 local f={events={},scripts={}}
 function f:RegisterEvent(event) self.events[event]=true end
 function f:SetScript(name,fn) self.scripts[name]=fn end
 return f
end
local calls=0
local ns={enabled=true,formEnabled=false}
local function send(event,msg) ns.dismountMonitor.scripts.OnEvent(nil,event,msg) end
Dismount=function() calls=calls+1;mounted=false end
assert(loadfile('Dismount.lua'))('FormFreedom',ns)
assert(ns.dismountMonitor.events.UI_ERROR_MESSAGE and ns.dismountMonitor.events.TAXIMAP_OPENED)
for _,message in ipairs({ERR_ATTACK_MOUNTED,ERR_NOT_WHILE_MOUNTED,ERR_TAXIPLAYERALREADYMOUNTED,SPELL_FAILED_NOT_MOUNTED}) do
 mounted=true;local before=calls;send('UI_ERROR_MESSAGE',message);assert(calls==before+1 and not mounted)
end
local before=calls
mounted=true
send('UI_ERROR_MESSAGE','Another unrelated error');send('UI_ERROR_MESSAGE',nil)
send('UI_ERROR_MESSAGE',123) -- Modern Classic signature must not be confused with 3.3.5.
assert(calls==before)
flying=true;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);send('TAXIMAP_OPENED');assert(calls==before);flying=false
taxi=true;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);send('TAXIMAP_OPENED');assert(calls==before);taxi=false
combat=true;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);send('TAXIMAP_OPENED');assert(calls==before);combat=false
mounted=false;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);assert(calls==before)
mounted=true;send('TAXIMAP_OPENED');assert(calls==before+1)
-- Guard against re-entrant UI_ERROR_MESSAGE raised by a modified native call.
mounted=true
Dismount=function() calls=calls+1;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);mounted=false end
before=calls;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED);assert(calls==before+1)
-- A restricted native call fails once; never floods the user or retries the action.
mounted=true
Dismount=function() calls=calls+1;error('restricted native call') end
before=calls;send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED)
send('TAXIMAP_OPENED');send('UI_ERROR_MESSAGE',ERR_NOT_WHILE_MOUNTED)
assert(calls==before+1 and ns.dismountFallbackError:find('restricted native call',1,true))
print('PASS: localized mounted errors, flight-map dismount, unrelated/nil/modern payload exclusion, ground/taxi/combat/reentrancy guards, fail-once reporting')
