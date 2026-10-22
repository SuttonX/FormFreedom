for _,name in ipairs({'Core','FormRestrictions','MountRestrictions','AutoForm','ActionBars','Dismount','Menus','Diagnostics'}) do assert(loadfile(''..name..'.lua')) end
print('PASS: standalone addon Lua syntax')
