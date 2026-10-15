local modules={};local passed=0
local function check(v,label)assert(v,label);passed=passed+1;print('PASS '..label)end
plmg_optional={get=function(name)return modules[name]end}
local env=setmetatable({},{__index=_G})
assert(loadfile(BUILD_ROOT..'/gamedata/scripts/plmg_api.script','t',env))()
check(not env.describe().available,'API unavailable before host modules load')
local calls=0;local busy=false;local active=false;local accepted=true;local item={}
modules.plmg_conversion={pending=function()return busy end}
modules.plmg_preview={active=function()return active end,start=function(v)assert(v==item);calls=calls+1;return accepted end,cancel=function()calls=calls+1 end}
check(env.describe().available and env.describe().api_version==1,'API reports version and availability')
check(not env.describe().capabilities.scripted_spawn and not env.describe().capabilities.npc_operators,'unimplemented war capabilities explicitly absent')
check(env.start_placement(item) and calls==1,'API uses existing preview transaction')
busy=true;check(not env.start_placement(item) and calls==1,'busy transfer cannot start another placement');busy=false
active=true;check(not env.start_placement(item) and calls==1,'active preview cannot be replaced');active=false
accepted=false;check(not env.start_placement(item) and calls==2,'unsupported weapon refused by existing eligibility')
check(env.cancel_placement() and calls==3,'API cancels preview through existing path')
modules.ctz_mount_conversion={}
check(not env.describe().available and env.describe().reason=='legacy-recovery','old CtZ implementation still protected by recovery guard')
check(not env.start_placement(item) and not env.cancel_placement() and calls==3,'legacy recovery cannot enter new PLMG transactions')
modules.ctz_mount_conversion=nil
check(env.describe().available,'new separated CtZ needs no disabling exception')
local info=env.describe();info.capabilities.inventory_placement=false
check(env.describe().capabilities.inventory_placement,'API returns fresh descriptor tables')
print('PASS PLMG public API: '..passed..' assertions')
