local n=0
local function check(v,s)assert(v,s);n=n+1 end
local function module(name)
 local e=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/'..name..'.script','t',e))();return e
end
local callbacks,objects,clients,logs={},{},{},{}
plmg_integrations={register=function(_,e,fn)callbacks[e]=fn end}
plmg_diagnostics={event=function(s)logs[#logs+1]=s end}
plmg_optional={get=function()return nil end}
vector=function()return {set=function(self,x,y,z)self.x=x;self.y=y;self.z=z;return self end}end
local now,owner,attached,ready,section=0,nil,nil,true,'wpn_pkm_siber'
time_global=function()return now end
local actor={id=function()return 7 end,alive=function()return true end,position=function()return vector():set(0,0,0)end,level_vertex_id=function()return 4 end,game_vertex_id=function()return 5 end,get_attached_vehicle=function()return attached end}
db={actor=actor}
local stm={GetOwner=function()return owner end,GetAmmoElapsed=function()return 37 end,GetAmmoType=function()return 0 end}
local prompt
local target={set_tip_text=function(_,v)prompt=v end,id=function()return 100 end,name=function()return 'plmg_mounted_pkm100' end,section=function()return 'plmg_mounted_pkm' end,position=function()return vector():set(0,1.15,1.5)end,get_stmgun=function()return stm end}
local target_se={id=100,position=vector():set(0,1.15,1.5),section_name=target.section,name=target.name}
level={present=function()return true end,name=function()return 'test' end,object_by_id=function(id)return clients[id]end}
alife=function()return {object=function(_,id)return objects[id]end}end
plmg_mounted={ready=function(id)return ready and id==100 end}
plmg_preview={eligible=function()return true end,active=function()return false end}
system_ini=function()return {r_string=function(_,s)return s:match('^plmg_') and 'ammo_a,ammo_b' or 'ammo_b,ammo_a' end,r_u32=function()return 100 end}end
local ammo_writes,removed,returned=0,0,0
local item,inventory,spawnfail,setfail,release_delay,old_ammo_type
local function restore_active()
 objects={};clients={};objects[100]=target_se;clients[100]=target
 owner=nil;attached=nil;ready=true;now=0;spawnfail=false;setfail=false;release_delay=false
 plmg_conversion=module('plmg_conversion');plmg_conversion.on_game_start()
 callbacks.load_state({plmg_transfer={version=1,invalid=false,record={stage='active',source_id=10,source_section='wpn_pkm_siber',source_name='old10',target_id=100,target_section='plmg_mounted_pkm',target_name=target:name(),actor_id=7,map='test',x=0,y=1.15,z=1.5,rounds=100,ammo_type=0,source_ammo_type=1,condition=.62}}})
end
alife_create=function(sec,p,l,g,parent)
 check(sec=='wpn_pkm_siber' and parent==7 and l==4 and g==5,'return original section to actor inventory')
 if spawnfail then return nil end
 returned=returned+1
 item={id=200,parent_id=7,condition=1,rounds=100,section_name=function()return sec end,name=function()return 'returned200' end,set_ammo_elapsed=function(self,v)self.rounds=v end,get_ammo_elapsed=function(self)return self.rounds end}
 objects[200]=item
 inventory={rounds=0,ammo_type=0,con=1,id=function()return 200 end,name=item.name,section=item.section_name,parent=function()return actor end,set_ammo_elapsed=function(self,v)if setfail then error('ammo write failed')end;self.rounds=v;ammo_writes=ammo_writes+1 end,set_ammo_type=function(self,v)self.ammo_type=v end,set_condition=function(self,v)self.con=v end,get_ammo_type=function(self)return self.ammo_type end,get_ammo_in_magazine=function(self)return self.rounds end,condition=function(self)return self.con end}
 return item
end
safe_release_manager={release=function(se)check(se==target_se,'cleanup mounted object only');removed=removed+1;if not release_delay then objects[100]=nil;clients[100]=nil end end}
alife_release=function(se)check(se==item,'return rollback removes newly created item only');objects[200]=nil;clients[200]=nil;return true end
restore_active();check(plmg_conversion.pickup_target()==target,'accepted old active transfer remains pickup eligible')
owner=actor;check(not plmg_conversion.pickup_target() and not plmg_conversion.pickup(),'occupied gun retained');owner=nil
attached=target;check(not plmg_conversion.pickup_target(),'actor already mounted cannot pickup');attached=nil
check(plmg_conversion.pickup(),'begin pickup');check(objects[100] and item.rounds==0 and item.condition==.62 and plmg_conversion.blocks(100),'target kept until empty initialized inventory item verified')
local saved={};callbacks.save_state(saved);check(saved.plmg_transfer.record.return_rounds==37 and saved.plmg_transfer.record.return_ammo_type==1,'map current mounted ammo by exact section')
clients[200]=inventory;release_delay=true;callbacks.actor_on_update();check(inventory.rounds==37 and inventory.ammo_type==1 and inventory.con==.62 and objects[100],'condition/current belt restored before target removal')
local written=ammo_writes;saved={};callbacks.save_state(saved);check(saved.plmg_transfer.record.stage=='removing_mount','removal phase persisted')
inventory.rounds=32;plmg_conversion=module('plmg_conversion');plmg_conversion.on_game_start();callbacks.load_state(saved);callbacks.actor_on_update();check(inventory.rounds==32 and ammo_writes==written,'restore removal phase never refills returned item')
objects[100]=nil;callbacks.actor_on_update();check(plmg_conversion.pending(),'server absence waits for mounted client destruction');clients[100]=nil;callbacks.actor_on_update();check(not plmg_conversion.pending() and inventory.rounds==32,'pickup commits after observed target absence')
saved={};callbacks.save_state(saved);check(saved.plmg_transfer.record==nil,'completed pickup releases shared slot')
restore_active();spawnfail=true;check(not plmg_conversion.pickup() and objects[100] and not objects[200],'spawn rejection retains emplacement')
restore_active();plmg_conversion.pickup();clients[200]=inventory;setfail=true;callbacks.actor_on_update();callbacks.actor_on_update();callbacks.actor_on_update();check(objects[100] and not objects[200] and not plmg_conversion.pending(),'inventory write failure removes return item and restores active emplacement')
restore_active();plmg_conversion.pickup();saved={};callbacks.save_state(saved);plmg_conversion=module('plmg_conversion');plmg_conversion.on_game_start();callbacks.load_state(saved);clients[200]=inventory;callbacks.actor_on_update();callbacks.actor_on_update();check(not objects[100] and inventory.rounds==37,'saved returning phase resumes without another item creation')
restore_active();plmg_conversion.pickup();now=10001;callbacks.actor_on_update();callbacks.actor_on_update();callbacks.actor_on_update();check(objects[100] and not objects[200],'missing online inventory timeout retains mounted gun')
restore_active();plmg_conversion.pickup();item.parent_id=9;callbacks.actor_on_update();check(objects[200] and objects[100] and plmg_conversion.pending(),'changed return server ownership suspends without deleting another owner item')
-- Input fixtures: multiple listeners must be preserved as native dispatch does.
local listeners={};plmg_integrations={register=function(_,e,f)listeners[e]=listeners[e] or {};table.insert(listeners[e],f)end}
local picked,mounts,valid,free,busy=0,0,true,true,false
plmg_optional={get=function(name)if name=='actor_menu' then return {is_hud_free=function()return free end}end end}
plmg_conversion={pickup_target=function()return valid and target end,pickup=function()picked=picked+1;return true,'packed' end,returning=function()return busy end}
level.get_target_obj=function()return valid and target end
actor.attach_vehicle=function(_,o,force)check(o==target and force==false,'short tap uses native non-forced holder path');mounts=mounts+1 end
key_bindings={kUSE=4,kWPN_FIRE=5,kWPN_ZOOM=6,kINVENTORY=7}
local p=module('plmg_pickup');p.on_game_start()
local function send(e,d,b,dis)
 local flags={ret_value=true};for _,f in ipairs(listeners[e] or {})do f(d,b,dis,flags)end;return flags.ret_value
end
for _,f in ipairs(listeners.actor_on_update)do f()end;check(prompt=='st_plmg_pickup_action','native combined mount/pickup prompt set on eligible converted gun')
now=0;check(not send('on_before_key_press',20,4,false) and mounts==0,'press defers native mounting')
now=100;check(not send('on_before_key_release',20,4,false) and mounts==1 and picked==0,'short release mounts once')
now=200;send('on_before_key_press',20,4,false);now=2699;send('on_before_key_hold',20,4,false);check(picked==0,'hold below 2.5 seconds does not pickup');now=2700;send('on_before_key_hold',20,4,false);send('on_before_key_hold',20,4,false);send('on_before_key_release',20,4,false);check(picked==1 and mounts==1,'2.5 second hold picks once without mounting')
now=4000;send('on_before_key_press',20,4,false);valid=false;send('on_before_key_hold',20,4,false);now=4500;send('on_before_key_release',20,4,false);check(mounts==1 and picked==1,'look-away cancels both actions');valid=true
now=5000;send('on_before_key_press',20,4,false);free=false;send('on_before_key_hold',20,4,false);send('on_before_key_release',20,4,false);check(mounts==1 and picked==1,'UI opening cancels hold');free=true
now=6000;send('on_before_key_press',20,4,false);for _,f in ipairs(listeners.load_state)do f()end;now=10000;send('on_before_key_release',20,4,false);check(mounts==1 and picked==1,'load resets incomplete hold')
valid=false;check(send('on_before_key_press',20,4,false),'ordinary native Use remains untouched');valid=true
busy=true;check(not send('on_before_key_press',0,5,false) and not send('on_before_key_hold',0,7,false),'return transfer briefly blocks fire and inventory');busy=false
check(send('on_before_key_press',0,5,false),'ordinary weapon input preserved')
print('PASS mounted pickup/return fixtures: '..n..' assertions')
