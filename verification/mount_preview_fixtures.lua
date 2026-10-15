local count=0
local function check(v,s) assert(v,s);count=count+1 end
local function module(name)
 local env=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/'..name..'.script','t',env))();return env
end
local callbacks,logs={},{}
plmg_safety={placement_clear=function()return true end}
plmg_integrations=module('plmg_integrations')
RegisterScriptCallback=function(e,f) callbacks[e]=f end;axr_main=nil
plmg_diagnostics={event=function(s) logs[#logs+1]=s end}
local free,alive,map,clock=true,true,'test',100
local opts={actor_menu={is_hud_free=function() return free end}}
plmg_optional={get=function(n) return opts[n] end}
vector=function() return {set=function(self,x,y,z) self.x=x;self.y=y;self.z=z;return self end} end
local actor={id=function()return 7 end,alive=function()return alive end,position=function()return vector():set(0,0,0)end,game_vertex_id=function()return 2 end}
db={actor=actor}
local section,attachment,upgrade,owned='wpn_pkm',false,false,true
local obj={id=function()return 10 end,section=function()return section end,parent=function()return owned and actor or nil end,weapon_is_scope=function()return attachment end,weapon_is_silencer=function()return false end,weapon_is_grenadelauncher=function()return false end,iterate_installed_upgrades=function(_,fn)if upgrade then fn()end end}
local visual,creates,removes,rays=nil,0,0,0
local missing=false
getFS=function()return {exist=function()return not missing end}end
script_attachment_type={World=3}
level={present=function()return true end,name=function()return map end,object_by_id=function()return owned and obj end,vertex_id=function()return 4 end,vertex_position=function()return vector():set(0,0,2)end,remove_attachment=function()visual=nil;removes=removes+1 end,get_attachment=function()return visual end,add_attachment=function()creates=creates+1;visual={set_type=function(_,v)check(v==3,'world attachment')end,set_shader=function(_,id,s,t)check(id==0 and t=='plmg\\placement_preview','instance silhouette')end,set_position=function(self,v)self.pos=v end,set_rotation=function(self,v)self.rot=v end};return visual end}
time_global=function()return clock end
device=function()return {cam_pos=vector():set(0,1,0),cam_dir=vector():set(0,-1,2)}end
local hit=true;local slope=1
ray_pick=function()
 local p={}
 p.set_position=function(self,v)self.origin=v end;p.set_direction=function(self,v)self.dir=v end;p.set_range=function(self,v)self.range=v end
 p.set_flags=function(_,v)check(v==2,'native enum static geometry is bit 1 (value 2)')end
 p.query=function()rays=rays+1;return hit end
 p.get_distance=function(self)return self.origin.y/-self.dir.y end
 p.get_normal=function()return vector():set(0,slope,0)end
 return p
end
DIK_keys={DIK_Q=1,DIK_E=2,DIK_ESCAPE=3};key_bindings={kUSE=4,kWPN_FIRE=5,kWPN_ZOOM=6}
plmg_conversion={placement_clear=function()return true end,pending=function()return false end,begin=function()return true,"Conversion test accepted" end}
plmg_preview=module('plmg_preview');plmg_preview.on_game_start()
check(creates==0,'load creates nothing')
check(plmg_preview.eligible(obj),'base supported gun eligible')
section='wpn_pkm_siber';check(plmg_preview.eligible(obj),'GAMMA Siber base PKM eligible');section='wpn_pkm_zenit_siber';check(not plmg_preview.eligible(obj),'Zenit variant not silently converted to base PKM');section='wpn_other';check(not plmg_preview.eligible(obj),'unsupported excluded');section='wpn_pkm'
attachment=true;check(not plmg_preview.eligible(obj),'attachment excluded');attachment=false
upgrade=true;check(not plmg_preview.eligible(obj),'upgrade excluded');upgrade=false
owned=false;check(not plmg_preview.eligible(obj),'foreign owner excluded');owned=true
missing=true;check(not plmg_preview.start(obj),'missing asset excluded');missing=false
check(plmg_preview.start(obj),'start preview');check(not plmg_preview.start(obj),'single preview')
free=false;callbacks.actor_on_update();check(creates==0,'inventory open defers attachment');free=true
callbacks.actor_on_update();check(visual and math.abs(visual.pos.y-1.15)<.001,'ground root offset')
local previous=rays;callbacks.actor_on_update();check(rays==previous,'bounded cadence')
local f={ret_value=true};callbacks.on_before_key_press(2,0,false,f);check(not f.ret_value,'rotate consumed');clock=200;callbacks.actor_on_update();check(visual.rot.x==15 and visual.rot.y==0,'HPB heading degrees')
f={ret_value=true};callbacks.on_before_key_press(0,5,false,f);check(not f.ret_value,'fire blocked')
f={ret_value=true};callbacks.on_before_key_hold(0,6,false,f);check(not f.ret_value,'zoom hold blocked')
f={ret_value=true};callbacks.on_before_key_press(3,0,true,f);check(f.ret_value and plmg_preview.active(),'disabled input preserved')
hit=false;callbacks.on_before_key_press(0,4,false,{ret_value=true});check(plmg_preview.active(),'confirmation rechecks current surface');hit=true
callbacks.on_before_key_press(0,4,false,{ret_value=true});check(not plmg_preview.active() and not visual and owned,'check does not consume gun')
local found=false;for _,s in ipairs(logs)do if s:find('validated section=wpn_pkm',1,true)then found=true end end;check(not found,'release preview omits placement debug output')
plmg_preview.start(obj);hit=false;clock=300;callbacks.actor_on_update();check(not visual,'miss hides preview');callbacks.on_before_key_press(0,4,false,{ret_value=true});check(plmg_preview.active(),'invalid cannot confirm');callbacks.load_state();check(not plmg_preview.active(),'load clears')
hit=true;plmg_preview.start(obj);map='other';clock=400;callbacks.actor_on_update();check(not plmg_preview.active(),'map change cancels');map='test'
plmg_preview.start(obj);alive=false;callbacks.actor_on_update();check(not plmg_preview.active(),'death cancels');alive=true
plmg_preview.start(obj);owned=false;callbacks.actor_on_update();check(not plmg_preview.active(),'source loss cancels');owned=true
plmg_preview.start(obj);slope=.5;clock=500;callbacks.actor_on_update();check(not visual,'steep surface hidden');plmg_preview.cancel();slope=1
f={ret_value=true};callbacks.on_before_key_press(0,5,false,f);check(f.ret_value,'ordinary input preserved')
local menu=module('plmg_menu');menu.on_game_start();callbacks.actor_on_update();check(not opts.ui_inventory,'optional UI absence safe')
local seen
local closes=0
local cls={Close=function()check(plmg_preview.active(),'preview starts before inventory close');closes=closes+1;free=true end,InitProperties=function(self)seen=self.properties.plmg_mount;return 'original-return' end,CheckItem=function()return obj end}
opts.ui_inventory={UIInventory=cls};callbacks.actor_on_update()
local self=setmetatable({properties={old={index=20}}},{__index=cls})
check(self:InitProperties()=='original-return' and seen.index==21,'append before original and preserve return')
self:InitProperties();check(self.properties.plmg_mount.index==21,'repeat no index creep')
opts.context_menu_overhaul={get_icon=function()return 'old-icon','extra' end,get_group=function()return 2 end,ini={collect_section=function()return {a='9',b='2'}end}}
callbacks.actor_on_update();local cmo=opts.context_menu_overhaul
check(cmo.get_icon('plmg_mount')=='ui_plmg_mount','own icon')
local a,b=cmo.get_icon('other');check(a=='old-icon' and b=='extra','foreign icon return forwarded')
check(cmo.get_group('plmg_mount')==10 and cmo.get_group('other')==2,'own group bottom and foreign group preserved')
check(self:Cond_PLMGMount(obj),'condition available')
section='wpn_mg42';free=false;check(self:Action_PLMGMount(10),'MG42 menu start');check(closes==1 and free,'successful Mount closes native inventory');plmg_preview.cancel()
section='wpn_other';check(not self:Action_PLMGMount(10) and closes==1,'failed start leaves inventory open')
section='wpn_mg42';cls.Close=function()error('close failed')end;check(not self:Action_PLMGMount(10) and not plmg_preview.active(),'close failure cancels pending preview')
print('PASS mount preview/menu fixtures: '..count..' assertions')
