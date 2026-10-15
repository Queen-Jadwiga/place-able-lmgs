local passed=0
local function check(v,s) assert(v,s);passed=passed+1 end
local function module(name)
 local e=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/'..name..'.script','t',e))();return e
end
local callbacks,logs,objects={}, {},{}
plmg_integrations={register=function(_,e,fn)callbacks[e]=fn end}
plmg_diagnostics={event=function(s)logs[#logs+1]=s end}
plmg_optional={get=function()return nil end}
vector=function()return {set=function(self,x,y,z)self.x=x;self.y=y;self.z=z;return self end}end
local clock,map,alive=0,'test',true;time_global=function()return clock end
local owned,rounds,ammo,condition,source_name,section=true,7,1,.65,'pkm10','wpn_pkm_siber'
local available,ready,failspawn=true,false,false
local creates,releases,cleanup=0,0,0
local request
local source={id=10,section_name=function()return section end,name=function()return source_name end}
local obj={id=function()return 10 end,section=function()return section end,name=function()return source_name end,get_ammo_in_magazine=function()return rounds end,get_ammo_type=function()return ammo end,condition=function()return condition end}
db={actor={id=function()return 7 end,alive=function()return alive end}}
level={present=function()return true end,name=function()return map end,object_by_id=function(id)if id==10 and available then return obj end end}
alife=function()return {object=function(_,id)return objects[id]end}end
plmg_preview={eligible=function(o)return o==obj and owned end}
local source_ammo='ammo_b,ammo_a'
system_ini=function()return {r_string=function(_,s,k)assert(k=='ammo_class');return s:match('^plmg_') and 'ammo_a,ammo_b' or source_ammo end}end
plmg_mounted={spawn=function(kind,r)
 if failspawn then return false,'spawn failed' end
 request=r;creates=creates+1
 local s='plmg_mounted_'..kind
 objects[100]={id=100,position=r.place.position,section_name=function()return s end,name=function()return s..'100' end}
 return true,'spawned',100
end,ready=function(id)return id==100 and ready end}
alife_release=function(se)check(se==source,'only source removed');releases=releases+1;objects[10]=nil;available=false;return true end
safe_release_manager={release=function(se)check(se.id==100,'cleanup only created target');cleanup=cleanup+1;objects[100]=nil end}
local c
local place={x=0,y=1.15,z=2,lvid=4,gvid=5}
local function reset()
 objects={};objects[10]=source;owned=true;available=true;ready=false;rounds=7;ammo=1;condition=.65;map='test';alive=true;source_name='pkm10';section='wpn_pkm_siber';source_ammo='ammo_b,ammo_a';failspawn=false;clock=0
 c=module('plmg_conversion');c.on_game_start()
end
reset();check(not c.pending() and not c.blocks(100),'idle permits action')
check(c.begin(obj,place,270),'begin base Siber conversion')
check(request.rounds==7 and request.ammo_type==0,'map loaded ammo by section not index')
check(math.abs(request.place.heading-math.pi*1.5)<1e-10,'preview HPB degrees to server Y radians')
check(objects[10] and releases==0 and c.blocks(100),'source retained and target blocked before setup')
check(not c.begin(obj,place,0),'duplicate begin rejected')
callbacks.actor_on_update();check(objects[10] and c.pending(),'wait for native setup')
local saved={};callbacks.save_state(saved);check(saved.plmg_transfer.record.stage=='preparing' and saved.plmg_transfer.record.condition==.65,'pending record preserves source metadata')
ready=true;callbacks.actor_on_update();check(not objects[10] and c.pending() and c.blocks(100),'release once then await absence')
callbacks.actor_on_update();check(not c.pending() and not c.blocks(100),'commit only after source absence')
local before=releases;callbacks.actor_on_update();check(releases==before,'no repeat consumption')
saved={};callbacks.save_state(saved);check(saved.plmg_transfer.record==nil and saved.plmg_transfer.records[1].stage=='active','active transfer saved')
c=module('plmg_conversion');c.on_game_start();callbacks.load_state(saved);callbacks.actor_on_update();check(not c.pending() and releases==before and request.rounds==7,'restore active never refills or removes again')
objects[100]=nil;callbacks.actor_on_update();objects[10]=source;available=true;check(c.begin(obj,place,0),'observed removed emplacement allows next conversion')
reset();source_ammo='unsupported';check(not c.begin(obj,place,0) and objects[10] and not objects[100],'incompatible loaded ammo retains gun')
rounds=0;check(c.begin(obj,place,0) and request.rounds==0,'empty gun converts without free ammunition')
reset();rounds=101;check(not c.begin(obj,place,0),'oversize belt rejected')
reset();owned=false;check(not c.begin(obj,place,0),'foreign item rejected')
reset();failspawn=true;check(not c.begin(obj,place,0) and objects[10] and not c.pending(),'spawn rejection retains source')
reset();check(c.begin(obj,place,0),'begin timeout case');clock=10001;callbacks.actor_on_update();check(c.pending() and objects[10],'setup timeout does not consume');callbacks.actor_on_update();check(not objects[100] and objects[10],'rollback removes target only');callbacks.actor_on_update();check(not c.pending(),'rollback finishes on observed absence')
reset();c.begin(obj,place,0);ready=true;rounds=6;callbacks.actor_on_update();callbacks.actor_on_update();check(objects[10] and not objects[100],'changed source ammo rolls back')
reset();c.begin(obj,place,0);ready=true;condition=.4;callbacks.actor_on_update();callbacks.actor_on_update();check(objects[10] and not objects[100],'changed condition rolls back')
reset();c.begin(obj,place,0);map='other';callbacks.actor_on_update();callbacks.actor_on_update();check(objects[10] and not objects[100],'map change before consume rolls back')
reset();c.begin(obj,place,0);saved={};callbacks.save_state(saved);c=module('plmg_conversion');c.on_game_start();callbacks.load_state(saved);ready=true;callbacks.actor_on_update();callbacks.actor_on_update();check(not objects[10] and not c.pending(),'restore preparing resumes validated transfer')
reset();c.begin(obj,place,0);ready=true;local goodrelease=alife_release;alife_release=function()error('release failed')end;callbacks.actor_on_update();callbacks.actor_on_update();check(objects[10] and not objects[100],'release exception retaining source cleans target');alife_release=goodrelease
reset();c.begin(obj,place,0);objects[100].name=function()return 'different' end;callbacks.actor_on_update();callbacks.actor_on_update();check(objects[100] and objects[10] and c.pending(),'target identity reuse suspends without deleting unrelated object')
reset();callbacks.load_state({plmg_transfer={version=99,invalid=false}});check(c.pending() and c.blocks(100) and not c.begin(obj,place,0),'unknown save version fails closed')
reset();c.begin(obj,place,0);saved={};callbacks.save_state(saved);saved.plmg_transfer.record.extra=function()end;callbacks.load_state(saved);check(c.pending() and objects[10],'invalid extra saved value fails closed without item mutation')
reset();c.begin(obj,place,0);ready=true;alife_release=function()return false end;callbacks.actor_on_update();callbacks.actor_on_update();check(objects[10] and not objects[100],'explicit release rejection rolls back');alife_release=goodrelease
print('PASS mount conversion fixtures: '..passed..' assertions')
