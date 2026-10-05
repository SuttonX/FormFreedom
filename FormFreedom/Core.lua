-- FormFreedom: independently named standalone adaptation; see README.md and LICENSE.md.
local _, ns = ...
local _, class = UnitClass('player')
ns.enabled = class == 'DRUID'
if not ns.enabled then return end
local function Compare(a, b)
    if a == b then return true end
    if type(a) ~= 'table' or type(b) ~= 'table' then return false end
    for k, v in pairs(a) do if not Compare(v, b[k]) then return false end end
    for k in pairs(b) do if a[k] == nil then return false end end
    return true
end
ns.data = {table = {compare = Compare}}
ns.bar = CreateFrame('Frame', 'FormFreedomActionHost', UIParent, 'SecureHandlerBaseTemplate')
