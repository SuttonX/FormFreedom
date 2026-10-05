-- FormFreedom: independently named standalone adaptation; see README.md and LICENSE.md.
local _, ns = ...
if not ns.enabled then return end
local host = ns.bar
local installed = setmetatable({}, {__mode = 'k'})
local before = [[
    local manager = control:GetFrameRef('FFHost') or control
    if (button ~= 'LeftButton' and button ~= 'ControllerInput') or manager:GetAttribute('FFAutoFormCursorBusy') then return end
    if self:GetAttribute('FFCPButton') and not down then return end
    if self:GetAttribute('type') ~= 'action' then return end
    local slot = self:GetAttribute('action')
    if self:GetAttribute('FFStockButton') then
        local page = self:GetAttribute('actionpage') or self:GetParent():GetAttribute('actionpage') or GetActionBarPage()
        if self:GetAttribute('FFStockBonus') and GetBonusBarOffset() > 0 then page = 6 + GetBonusBarOffset() end
        slot = self:GetID() + (page - 1) * 12
    end
    if self:GetAttribute('FFCPButton') and self:GetID() > 0 then
        slot = self:GetID() + ((self:GetAttribute('actionpage') - 1) * 12)
    end
    local form = GetShapeshiftForm()
    if not slot or form == 0 or not manager:GetAttribute('FFAutoForm-'..slot..'-'..form) then return end
    local kind, id, subtype = GetActionInfo(slot)
    if kind ~= manager:GetAttribute('FFAutoFormKind-'..slot)
    or id ~= manager:GetAttribute('FFAutoFormID-'..slot)
    or subtype ~= manager:GetAttribute('FFAutoFormSubtype-'..slot) then return end
    local proxy = manager:GetFrameRef('FFAutoFormProxy')
    if not proxy then return end
    proxy:SetAttribute('action', slot)
    local unit = self:GetAttribute('unit')
    if not unit and self:GetAttribute('useparent-unit') then unit = self:GetParent():GetAttribute('unit') end
    proxy:SetAttribute('unit', unit)
    proxy:SetAttribute('checkselfcast', self:GetAttribute('checkselfcast'))
    proxy:SetAttribute('checkfocuscast', self:GetAttribute('checkfocuscast'))
    self:SetAttribute('FFActive', true)
    self:SetAttribute('FFOldMacro', self:GetAttribute('macro'))
    self:SetAttribute('FFOldText', self:GetAttribute('macrotext'))
    self:SetAttribute('macro', nil)
    self:SetAttribute('type', 'macro')
    self:SetAttribute('macrotext', '/cancelform [form]\n/click FormFreedomActionProxy LeftButton')
]]
local after = [[
    if not self:GetAttribute('FFActive') then return end
    self:SetAttribute('FFActive', nil)
    self:SetAttribute('macro', self:GetAttribute('FFOldMacro'))
    self:SetAttribute('macrotext', self:GetAttribute('FFOldText'))
    self:SetAttribute('FFOldMacro', nil)
    self:SetAttribute('FFOldText', nil)
    local update = self:GetAttribute('UpdateState')
    if update then
        control:RunFor(self, update, self:GetAttribute('state'))
    else
        self:SetAttribute('type', 'action')
    end
]]
local function Install(button, stock, bonus, cp)
    if not button or installed[button] then return end
    button:SetAttribute('FFStockButton', stock and true or nil)
    button:SetAttribute('FFStockBonus', bonus and true or nil)
    button:SetAttribute('FFCPButton', cp and true or nil)
    local header = cp and ConsolePortBar or host
    if cp then header:SetFrameRef('FFHost', host) end
    -- Run after existing PreClick and PostClick scripts; preserve native drag
    -- and ElvUI LibActionButton state processing without replacing handlers.
    SecureHandlerWrapScript(button, 'PreClick', header, 'return nil, true', before)
    SecureHandlerWrapScript(button, 'PostClick', header, 'return nil, true', after)
    installed[button] = true
end
local monitor = CreateFrame('Frame')
local pending = true
local function Discover()
    if InCombatLockdown() then return end
    for _, prefix in ipairs({'BonusActionButton', 'ActionButton', 'MultiBarBottomLeftButton', 'MultiBarBottomRightButton', 'MultiBarRightButton', 'MultiBarLeftButton'}) do
        for i = 1, 12 do Install(_G[prefix..i], true, prefix == 'BonusActionButton') end
    end
    for bar = 1, 10 do
        for i = 1, 12 do Install(_G['ElvUI_Bar'..bar..'Button'..i], false) end
    end
    if ConsolePortBar and ConsolePortBar.Buttons then
        for _, wrapper in ipairs(ConsolePortBar.Buttons) do
            for _, button in pairs(wrapper.Buttons or {}) do Install(button, false, false, true) end
        end
    end
    pending = false
end
for _, event in ipairs({'PLAYER_LOGIN', 'ADDON_LOADED', 'PLAYER_REGEN_ENABLED'}) do monitor:RegisterEvent(event) end
monitor:SetScript('OnEvent', function() pending = true end)
monitor:SetScript('OnUpdate', function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < .5 then return end
    self.elapsed = 0
    if pending or ConsolePortBar then Discover() end
end)
ns.actionBarMonitor = monitor
