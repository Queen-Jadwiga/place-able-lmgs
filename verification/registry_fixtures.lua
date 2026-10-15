local count=0
local function check(v,label)assert(v,label);count=count+1;print('PASS '..label)end
local function module()
    local env=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/plmg_conversion.script','t',env))();env.on_game_start();return env
end
local callbacks,objects,clients={}, {},{}
plmg_integrations={register=function(_,e,f)callbacks[e]=f end}
plmg_diagnostics={event=function()end};plmg_optional={get=function()return nil end}
vector=function()return {set=function(self,x,y,z)self.x=x;self.y=y;self.z=z;return self end}end
local clock,map,look=0,'test',100
time_global=function()return clock end
local actor={id=function()return 7 end,alive=function()return true end,position=function()return vector():set(0,0,0)end,level_vertex_id=function()return 4 end,game_vertex_id=function()return 5 end,get_attached_vehicle=function()return nil end}
db={actor=actor}
level={present=function()return true end,name=function()return map end,object_by_id=function(id)return clients[id]end,get_target_obj=function()return clients[look]end}
alife=function()return {object=function(_,id)return objects[id]end}end
system_ini=function()return {r_string=function(_,s)return s:match('^plmg_') and 'ammo_a,ammo_b' or 'ammo_b,ammo_a'end,r_u32=function()return 100 end}end
local ready,creates,releases,writes,newid={},0,0,0,200
local failreturn=false
local source
plmg_preview={eligible=function(obj)return obj==source end}
plmg_mounted={ready=function(id)return ready[id]==true end,spawn=function(kind,request)
    local id=110;local section=kind=='mg42' and 'plmg_mounted_mg42' or 'plmg_mounted_pkm'
    creates=creates+1
    local p=request.place.position
    objects[id]={id=id,position=p,section_name=function()return section end,name=function()return 'new110'end}
    clients[id]={id=function()return id end,section=function()return section end,name=objects[id].name,position=function()return p end,get_stmgun=function()return {GetOwner=function()return nil end}end}
    ready[id]=false
    return true,'created',id
end}
safe_release_manager={release=function(se)releases=releases+1;objects[se.id]=nil;clients[se.id]=nil end}
alife_release=function(se)releases=releases+1;objects[se.id]=nil;clients[se.id]=nil;return true end
alife_create=function(sec,p,l,g,parent)
    assert(parent==7);creates=creates+1;local id=newid;newid=newid+1
    local item={id=id,parent_id=7,condition=1,rounds=100,section_name=function()return sec end,name=function()return 'return'..id end,set_ammo_elapsed=function(self,v)self.rounds=v end,get_ammo_elapsed=function(self)return self.rounds end}
    objects[id]=item
    clients[id]={rounds=0,ammo_type=0,con=1,section=function()return sec end,name=item.name,parent=function()return actor end,set_ammo_elapsed=function(self,v)self.rounds=v;writes=writes+1 end,set_ammo_type=function(self,v)self.ammo_type=v end,set_condition=function(self,v)if failreturn then error('return failed')end;self.con=v end,get_ammo_type=function(self)return self.ammo_type end,get_ammo_in_magazine=function(self)return self.rounds end,condition=function(self)return self.con end}
    return item
end
local function record(id,kind,condition,x,z)
    return {stage='active',source_id=id-90,source_section=kind=='mg42' and 'wpn_mg42' or 'wpn_pkm_siber',source_name='original'..id,target_id=id,target_section='plmg_mounted_'..kind,target_name='mounted'..id,actor_id=7,map='test',x=x,y=1.15,z=z,rounds=100,ammo_type=0,source_ammo_type=1,condition=condition}
end
local records={record(100,'pkm',.62,0,1.2),record(101,'mg42',.81,1,0),record(102,'pkm',.37,0,-1.2)}
local rounds={[100]=11,[101]=23,[102]=37}
local c
local function tick()callbacks.actor_on_update()end
local function save()local data={};callbacks.save_state(data);return data end
local function load(data)c=module();callbacks.load_state(data)end
local function reset()
    objects={};clients={};ready={};look=100;clock=0;map='test';failreturn=false
    for _,r in ipairs(records)do
        local id=r.target_id;local p=vector():set(r.x,r.y,r.z)
        objects[id]={id=id,position=p,section_name=function()return r.target_section end,name=function()return r.target_name end}
        clients[id]={id=function()return id end,position=function()return p end,section=objects[id].section_name,name=objects[id].name,get_stmgun=function()return {GetOwner=function()return nil end,GetAmmoElapsed=function()return rounds[id]end,GetAmmoType=function()return 0 end}end}
        ready[id]=true
    end
    load({plmg_transfer={version=2,invalid=false,records=records}})
end
reset();check(not c.placement_clear({x=0,y=1.15,z=1.2}) and c.placement_clear({x=3,y=1.15,z=3}),'existing tripod clearance prevents coincident placement')
local initial=creates
check(not c.pending() and #save().plmg_transfer.records==3,'restore several guns without creating items')
look=101;check(c.pickup_target()==clients[101],'pickup selection follows targeted MG42 rather than first record')
look=102;check(c.pickup_target()==clients[102],'same-model PKMs retain distinct pickup identities')
look=100;check(not c.pickup(101,'mounted101') and not c.pending(),'expected target identity cannot pick up a different looked-at gun')
check(c.pickup(),'begin pickup while other guns remain deployed')
check(c.blocks(100) and not c.blocks(101),'only transferring gun is blocked from native use')
look=101;check(not c.pickup_target() and not c.pickup(),'another pickup cannot overlap the inventory transaction')
check(creates==initial+1,'one return item created for one selected gun')
tick();tick()
check(not c.pending() and not objects[100] and objects[101] and objects[102],'packing first gun preserves both remaining emplacements')
local returned=clients[newid-1]
check(returned.rounds==11 and returned.ammo_type==1 and math.abs(returned.con-.62)<.0001,'first gun returns its own current ammo and condition')
check(#save().plmg_transfer.records==2 and rounds[101]==23 and rounds[102]==37,'other gun ammunition and metadata untouched')
look=102;check(c.pickup(),'pack third gun before second')
local saved=save();local returned_id=saved.plmg_transfer.record.return_id;local created_before=creates
load(saved);tick();local written=writes
saved=save();clients[returned_id].rounds=29;load(saved);tick()
check(creates==created_before and writes==written and clients[returned_id].rounds==29,'resume saved removal never creates/refills another inventory item')
check(#save().plmg_transfer.records==1 and objects[101] and not objects[102],'save/load preserves other active gun across pickup stages')
source={id=function()return 10 end,section=function()return 'wpn_mg42'end,name=function()return 'source10'end,get_ammo_in_magazine=function()return 7 end,get_ammo_type=function()return 0 end,condition=function()return .25 end}
objects[10]={id=10,section_name=source.section,name=source.name};clients[10]=source
check(c.begin(source,{x=3,y=1.15,z=3,lvid=4,gvid=5},0),'new placement allowed while an existing gun remains deployed')
check(not c.begin(source,{x=3,y=1.15,z=3,lvid=4,gvid=5},0),'second placement cannot overlap transfer')
saved=save();check(#saved.plmg_transfer.records==1 and saved.plmg_transfer.record.stage=='preparing','save contains active registry plus one pending placement')
load(saved);ready[110]=true;tick();tick()
check(not c.pending() and #save().plmg_transfer.records==2 and objects[101] and objects[110] and not objects[10],'restored placement commits without disturbing existing gun')
reset();map='other';tick();check(#save().plmg_transfer.records==3 and not c.pickup_target(),'offline/other-map records persist without remote pickup')
map='test';look=101;check(c.pickup_target()==clients[101],'same save returns to correct targeted gun on original map')
reset();local before=releases;objects[100].name=function()return 'unrelated-reused-id'end;tick()
check(c.pending() and releases==before and objects[100] and objects[101],'server ID reuse suspends without deleting or refunding unrelated objects')
reset();before=creates;objects[100]=nil;clients[100]=nil;tick()
check(#save().plmg_transfer.records==2 and creates==before,'confirmed absent gun pruned without fabricated refund')
reset();local bad=save();bad.plmg_transfer.records[2]=bad.plmg_transfer.records[1];before=releases;load(bad)
check(c.pending() and releases==before,'duplicate saved target identities rejected without object mutation')
reset();bad=save();bad.plmg_transfer.records[3]=nil;bad.plmg_transfer.records[1]=nil;load(bad)
check(c.pending(),'sparse registry rejected')
reset();before=creates;load({plmg_transfer={version=1,invalid=false,record=records[1]}})
check(not c.pending() and creates==before and #save().plmg_transfer.records==1 and save().plmg_transfer.version==2,'v0.8.2 active record upgrades without spawning or refunding')
reset();local legacy={};for k,v in pairs(records[1])do legacy[k]=v end;legacy.stage='preparing'
source={id=function()return 10 end,section=function()return 'wpn_pkm_siber'end,name=function()return legacy.source_name end,get_ammo_in_magazine=function()return 100 end,get_ammo_type=function()return 1 end,condition=function()return .62 end}
objects[10]={id=10,section_name=source.section,name=source.name};clients[10]=source
load({plmg_transfer={version=1,invalid=false,record=legacy}});tick();tick()
check(not c.pending() and not objects[10] and #save().plmg_transfer.records==1,'legacy preparing transaction resumes source consumption exactly once')
reset();c.pickup();saved=save();before=creates;load({plmg_transfer={version=1,invalid=false,record=saved.plmg_transfer.record}});tick();tick()
check(not c.pending() and not objects[100] and objects[101] and creates==before,'legacy returning transaction resumes without duplicate return item')
reset();failreturn=true;look=100;c.pickup();tick();tick();tick()
check(not c.pending() and #save().plmg_transfer.records==3 and objects[100] and objects[101] and objects[102],'failed return restores selected gun while preserving full registry')
reset();for _,r in ipairs(records)do objects[r.target_id]=nil;clients[r.target_id]=nil end;tick();local empty=save().plmg_transfer
check(empty.version==1 and empty.record==nil and not c.pending(),'packing/removing all guns writes downgrade-compatible idle state')
print('PASS multiple emplacement registry: '..count..' assertions')
