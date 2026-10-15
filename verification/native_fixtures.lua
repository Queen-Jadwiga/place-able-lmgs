local clock=0;time_global=function() return clock end
local passed=0
local function check(v,label) assert(v,label);passed=passed+1;print('PASS '..label) end
local records,callbacks={},{}
local clearance=true
plmg_safety={placement_clear=function()return clearance end,exit_clear=function()return clearance end}
plmg_diagnostics={event=function(s) records[#records+1]=s end}
plmg_integrations={register=function(key,event,fn) callbacks[event]=fn;return true end}
local objects,created,released={},0,0
local pos={x=10,y=2,z=20}
local actor={id=function() return 7 end,position=function() return pos end,direction=function() return {x=0,y=0,z=1} end,level_vertex_id=function() return 12 end,game_vertex_id=function() return 2103 end}
db={actor=actor}
local owner,offset=nil,nil
local stm={GetOwner=function() return owner end,SetActorOffsets=function(_,v) offset=v end}
stm.GetAmmoElapsed=function() return objects[100] and objects[100].remaining or 0 end
stm.GetAmmoMagSize=function() return 100 end
stm.GetAmmoType=function() return objects[100] and objects[100].ammo_type or 0 end
local fixed=false;local missing_root=false;local missing_rest=false;local fail_rest=false;local live_position
local rest_fixed={}
local missing_body=false
local transform_error=false
local velocity_error=false
local function linear(_,v) if velocity_error then error('velocity unavailable') end;v:set(0,-0.25,0) end
local function angular(_,v) v:set(0,0.1,0) end
local function transform()
    if transform_error then error('unsupported transform') end
    return {c={x=10,y=3.15,z=21.5},i={x=1,y=0,z=0},j={x=0,y=1,z=0},k={x=0,y=0,z=1}}
end
local root={get_linear_vel=linear,get_angular_vel=angular,global_transform=transform,fix=function() fixed=true end,is_fixed=function() return fixed end}
local exact_requests=0
local freeze_requests=0
local shell={freeze=function() freeze_requests=freeze_requests+1 end,set_force_exact_integration=function() exact_requests=exact_requests+1 end,get_element_by_bone_name=function(_,name)
    if name=='link' then return not missing_root and root or nil end
    assert(name=='joint_rotate_y' or name=='joint_rotate_x' or name=='joint_actor' or name=='wpn_body')
    if missing_rest and name=='joint_rotate_x' then return nil end
    if missing_body and name=='wpn_body' then return nil end
    return {get_linear_vel=linear,get_angular_vel=angular,global_transform=transform,fix=function() rest_fixed[name]=not fail_rest end,is_fixed=function() return rest_fixed[name] end}
end}
local joint_error=false
local anchor_shift=0
shell.get_joint_by_bone_name=function(_,name)
 assert(name=='joint_rotate_x' or name=='joint_rotate_y')
 if joint_error then error('joint getter unavailable') end
 return {get_axes_number=function() return 1 end,get_anchor=function(_,v) v:set(10,3.15+anchor_shift,21.5) end,get_axis_dir=function(_,axis,v) assert(axis==0);v:set(0,1,0) end}
end
local obj_section='plmg_mounted_pkm'
local teleports=0
local obj={get_physics_shell=function() return shell end,force_set_position=function() teleports=teleports+1;error('post-construction teleport forbidden') end,position=function() return live_position end,id=function() return 100 end,name=function()return "plmg_native100"end,section=function() return obj_section end,get_stmgun=function() return stm end}
local invalid_vertex,uneven=false,false
level={name=function() return 'l07_military' end,object_by_id=function() return obj end,vertex_id=function() return invalid_vertex and 4294967295 or 123 end,vertex_position=function() return {x=pos.x,y=pos.y+(uneven and 1 or 0),z=pos.z+1.5} end}
local sim={object=function(_,id) return objects[id] end}
alife=function() return sim end
vector=function() return {set=function(self,x,y,z) self.x=x;self.y=y;self.z=z;return self end,getH=function() return 0 end} end
local visual='plmg\\mounted_pkm.ogf'
local mesh=true;local textures=true;local mount_texture=true
local ammo_missing=false;local sound_missing=false;local sound_definition_missing=false
getFS=function() return {exist=function(_,alias,path)
 if alias=='$game_sounds$' then assert(path:match('%.ogg$'));return not sound_missing end
 if alias=='$game_textures$' then
  if path=='plmg\\mount_black.dds' then return mount_texture end
  assert(path:find('mp5lng_mod\\wpn\\mg42\\mg42_',1,true));return textures
 end
 assert(alias=='$game_meshes$' and (path==visual or path=='plmg\\mounted_mg42.ogf'));return mesh
end} end
local config=true
local contact_filter='npc'
system_ini=function() return {
 section_exist=function(_,sec)
  if not config then return false end
  if sec:match('^ammo_') then return not ammo_missing end
  if sec=='wpn_pkm_snd_shoot' or sec=='wpn_mg42_snd_shoot' then return not sound_definition_missing end
  return sec=='plmg_mounted_pkm' or sec=='plmg_mounted_mg42' or sec=='stationary_mgun'
 end,
 line_exist=function() return true end,
 line_count=function() return 2 end,
 r_line=function(_,sec,index) assert(sec:match('snd_shoot$') and (index==0 or index==1));return true,'snd_1_layer'..(index==0 and '' or '1'),'weapons\\test\\shot'..index end,
 r_string=function(_,sec,key)
  if key=='class' then return '_S_STMGU' end
  if key=='unlimited_ammo' then return 'false' end
  if key=='reload_consume' then return 'plmg_mounted.reload_consume' end
  if key=='ignore_collision' then return contact_filter end
  if key=='ammo_class' then return sec=='plmg_mounted_mg42' and 'ammo_7.92x33_fmj' or 'ammo_pkm_100' end
  if key=='snd_shoot' then return sec=='plmg_mounted_mg42' and 'wpn_mg42_snd_shoot' or 'wpn_pkm_snd_shoot' end
  if key=='snd_empty' or key=='snd_reload' then return 'weapons\\test\\'..key end
  if key=='rpm' then return sec=='plmg_mounted_mg42' and '1200' or '650' end
  if key=='hit_power' then return sec=='plmg_mounted_mg42' and '0.9' or '0.77' end
  if key=='bullet_speed' then return sec=='plmg_mounted_mg42' and '740' or '825' end
  if key=='fire_dispersion_base' then return sec=='plmg_mounted_mg42' and '0.32' or '0.34' end
  return sec=='plmg_mounted_mg42' and 'plmg\\mounted_mg42.ogf' or visual
 end} end
clsid={stmgun_s=77}
safe_release_manager={release=function(se) released=released+1 end}
local ammo_writes=0
local magazine_size=100
alife_create=function(sec,p,l,g)
 assert((sec=='plmg_mounted_pkm' or sec=='plmg_mounted_mg42') and l==123 and g==2103 and p.x==pos.x and p.z==pos.z+1.5 and math.abs(p.y-pos.y-1.15)<0.0001)
 created=created+1
 live_position={x=p.x,y=p.y,z=p.z}
 local se={id=100,name=function()return 'plmg_native100'end,online=false,position=p,remaining=0,ammo_type=0,section_name=function() return sec end,use_ai_locations=function(self,value) assert(not self.online);self.ai_locations=value end,
 get_ammo_magsize=function() return magazine_size end,get_ammo_elapsed=function(self) return self.remaining end,get_ammo_type=function(self) return self.ammo_type end,
 set_ammo_elapsed=function(self,value) assert(not self.online);ammo_writes=ammo_writes+1;self.remaining=value end,set_ammo_type=function(self,value) assert(not self.online);self.ammo_type=value end}
 objects[100]=se;return se
end
local function reload()
 local env=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/plmg_mounted.script','t',env))();return env
end
local m=reload()
check(created==0 and released==0,'mounted module loads without spawning or releasing')
local req={place={position=vector():set(pos.x,pos.y+1.15,pos.z+1.5),lvid=123,gvid=2103,heading=1.5},rounds=7,ammo_type=1}
check(not m.spawn() and created==0,'inventory-only route refuses unconfirmed placement')
config=false;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing config');config=true
clsid.stmgun_s=nil;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing native class');clsid.stmgun_s=77
mesh=false;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing model');mesh=true
mount_texture=false;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing support texture');mount_texture=true
ammo_missing=true;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing ammo');ammo_missing=false
sound_missing=true;check(not m.spawn('pkm',req) and created==0,'inventory route refuses missing sound');sound_missing=false
local ok,_,id=m.spawn('pkm',{place={position=vector():set(pos.x,pos.y+1.15,pos.z+1.5),lvid=123,gvid=2103,heading=1.5},rounds=7,ammo_type=1})
check(ok and id==100 and objects[100].remaining==7 and objects[100].ammo_type==1,'inventory creation count/type')
check(objects[100].angle.y==1.5 and not objects[100].ai_locations,'orientation and native construction-height policy')
check(m.net_spawn_after(obj) and m.ready(100),'native model setup')
check(m.before_use(obj),'configured native use')
clearance=false;check(not m.before_use(obj),'mount refused when native exit area is blocked');clearance=true
check(not m.reload_consume(obj,stm,nil),'native spawn/type initialization never consumes without an owner')
check(m.reload_consume(obj,stm,actor),'occupied reload requests native inventory consumption')
local flags={ret_value=true};actor.get_attached_vehicle=function()return obj end;key_bindings={kUSE=4};m.on_game_start();clearance=false;callbacks.on_before_key_press(1,4,false,flags)
check(not flags.ret_value,'blocked dismount does not reach native Use')
flags={ret_value=true};clearance=true;callbacks.on_before_key_press(1,4,false,flags);check(flags.ret_value,'clear dismount preserves native Use')
objects[100].remaining=5;m.net_spawn_after(obj)
check(objects[100].remaining==5,'restoration does not refill')
print('PASS standalone native lifecycle fixture: '..passed..' assertions')
-- Each online native object must keep independent readiness/anchor identity.
local old_lookup=level.object_by_id
local second_name='plmg_native101'
local second=setmetatable({id=function()return 101 end,name=function()return second_name end},{__index=obj})
objects[101]={position=objects[100].position,section_name=obj.section,name=second.name}
level.object_by_id=function(id)if id==101 then return second end;return old_lookup(id)end
check(m.net_spawn_after(second) and m.ready(100) and m.ready(101),'second client setup preserves first gun readiness')
check(m.before_use(obj) and m.before_use(second),'both tracked guns remain mountable')
missing_root=true;check(not m.net_spawn_after(second) and m.ready(100),'failed setup only invalidates its own gun');missing_root=false
m.net_spawn_after(second);second_name='reused101'
check(not m.ready(101) and m.ready(100),'client ID/name reuse cannot inherit another gun readiness')
callbacks.actor_on_update();check(m.ready(100),'pruning stale client tracking preserves other guns')
print('PASS multi-native readiness: 5 assertions')
