local function check(v,label)assert(v,label);print('PASS '..label)end
local writes,opens,console={},{},{}
local oldio,oldfs,oldprintf=io,getFS,printf
getFS=function()return {update_path=function(_,alias,name)assert(alias=='$logs$');return name end}end
io={open=function(path,mode)
    opens[#opens+1]={path,mode}
    return {write=function(_,s)writes[#writes+1]=s;return true end,close=function()return true end}
end}
printf=function(_,s)console[#console+1]=s end
local env=setmetatable({},{__index=_G})
assert(loadfile(BUILD_ROOT..'/gamedata/scripts/plmg_diagnostics.script','t',env))()
env.event('MOUNT_CONVERSION committed target=100 rounds=100')
env.event('MOUNT_PREVIEW surface state=valid')
check(#opens==0 and #console==0,'normal play neither opens log nor writes main log')
env.event('MOUNT_CONVERSION transfer_error reason=failed')
check(#opens==1 and #writes==2 and #console==1,'failure retains concise logfile and main-log reporting')
check(not env.status().failed and env.status().started,'failure logging completes and closes handle')
io,getFS,printf=oldio,oldfs,oldprintf
