local count=0
local function check(v,label)assert(v,label);count=count+1;print('PASS '..label)end
vector=function()return {set=function(self,x,y,z)self.x=x;self.y=y;self.z=z;return self end,
    setHP=function(self,h,p)self.x=-math.cos(p)*math.sin(h);self.y=math.sin(p);self.z=math.cos(p)*math.cos(h);return self end}end
local wall,ceiling,ledge,badnormal,broken=false,false,false,false,false
local queries=0;local first
ray_pick=function()
    local r={}
    function r:set_position(p)self.p=p;if not first then first=p end end
    function r:set_direction(d)self.d=d end
    function r:set_range(n)self.length=n end
    function r:set_flags(v)assert(v==2)end
    function r:query()
        queries=queries+1;if broken then error('ray failure')end
        if self.d.y<0 then self.distance=self.p.y/-self.d.y;return not ledge and self.distance<=self.length end
        if self.d.y>0 then self.distance=0.6;return ceiling end
        self.distance=0.2;return wall
    end
    function r:get_distance()return self.distance end
    function r:get_normal()return vector():set(0,badnormal and 0 or 1,0)end
    return r
end
local env=setmetatable({},{__index=_G});assert(loadfile(BUILD_ROOT..'/gamedata/scripts/plmg_safety.script','t',env))()
local root=vector():set(0,1.15,0)
check(env.placement_clear(root,0) and queries>20,'open ground has standing volume and headroom')
check(math.abs(first.z+1.5)<0.0001,'standing test uses the native rear offset')
first=nil;check(env.placement_clear(root,90),'rotated placement checked')
check(math.abs(first.x-1.5)<0.0001 and math.abs(first.z)<0.0001,'standing volume rotates with native heading convention')
wall=true;check(not env.placement_clear(root,0),'wall or doorframe intersects body probes');wall=false
ceiling=true;check(not env.placement_clear(root,0),'low ceiling refused');ceiling=false
ledge=true;check(not env.placement_clear(root,0),'missing standing floor refused');ledge=false
badnormal=true;check(not env.placement_clear(root,0),'unsafe floor normal refused');badnormal=false
broken=true;check(not env.placement_clear(root,0),'native clearance failure refuses placement');broken=false
check(not env.placement_clear(root,0/0),'invalid rotation rejected')
local obj={get_stmgun=function()return {ExitPosition=function()return vector():set(0,0,-1.5)end}end}
check(env.exit_clear(obj),'live mounting/dismounting checks actual native ExitPosition')
wall=true;check(not env.exit_clear(obj),'live exit is refused after obstruction appears');wall=false
check(not env.exit_clear({}),'missing native exit API refuses mount safely')
print('PASS standing/exit safety: '..count..' assertions')
