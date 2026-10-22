-- Native mounted-error fallback. No action retry and no form cancellation.
-- Reference behavior: jb-dijkstra/dismounter-tbc-wrath; see CREDITS.md.
local _, ns = ...
if not ns.enabled then return end
local errors = {}
for _, name in ipairs({'ERR_ATTACK_MOUNTED', 'ERR_NOT_WHILE_MOUNTED',
    'ERR_TAXIPLAYERALREADYMOUNTED', 'SPELL_FAILED_NOT_MOUNTED'}) do
    local message = _G[name]
    if type(message) == 'string' then errors[message] = true end
end
local busy, disabled = false, false
local function DismountGrounded()
    if busy or disabled or InCombatLockdown() or not IsMounted() or IsFlying()
    or (UnitOnTaxi and UnitOnTaxi('player')) then return end
    busy = true
    -- Some modified clients restrict native calls further. Fail once, record
    -- the reason for /ffreport, and retain secure click helpers as a fallback.
    local ok, reason = pcall(Dismount)
    busy = false
    if not ok then
        disabled = true
        ns.dismountFallbackError = tostring(reason)
    end
end
local monitor = CreateFrame('Frame')
monitor:RegisterEvent('UI_ERROR_MESSAGE')
monitor:RegisterEvent('TAXIMAP_OPENED')
monitor:SetScript('OnEvent', function(self, event, message)
    -- Original 3.3.5 provides the text as the first event argument.
    if event == 'TAXIMAP_OPENED' or (event == 'UI_ERROR_MESSAGE' and errors[message]) then
        DismountGrounded()
    end
end)
ns.dismountMonitor = monitor
