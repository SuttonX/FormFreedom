for _,name in ipairs({'Core','FormRestrictions','AutoForm','ActionBars','Menus','Diagnostics'}) do assert(loadfile(''..name..'.lua')) end
print('PASS: standalone addon Lua syntax')
