"""Reproducible source/fixture checks; requires liblua5.4 (not a game test)."""
from pathlib import Path
import ctypes as C
import ctypes.util
import xml.etree.ElementTree as E
import json
root=Path(__file__).resolve().parents[1]
lua=C.CDLL(ctypes.util.find_library('lua5.4'))
lua.luaL_newstate.restype=C.c_void_p
lua.luaL_openlibs.argtypes=[C.c_void_p]
lua.luaL_loadbufferx.argtypes=[C.c_void_p,C.c_char_p,C.c_size_t,C.c_char_p,C.c_char_p]
lua.lua_pcallk.argtypes=[C.c_void_p,C.c_int,C.c_int,C.c_int,C.c_longlong,C.c_void_p]
lua.lua_tolstring.argtypes=[C.c_void_p,C.c_int,C.POINTER(C.c_size_t)];lua.lua_tolstring.restype=C.c_char_p
lua.lua_settop.argtypes=[C.c_void_p,C.c_int]
lua.lua_close.argtypes=[C.c_void_p]
L=lua.luaL_newstate();lua.luaL_openlibs(L)
def run(text,name,execute=True):
    data=text.encode()
    rc=lua.luaL_loadbufferx(L,data,len(data),name.encode(),None)
    if not rc and execute:rc=lua.lua_pcallk(L,0,0,0,0,None)
    if rc:raise RuntimeError(lua.lua_tolstring(L,-1,None).decode())
    lua.lua_settop(L,0)
scripts=list((root/'gamedata/scripts').glob('*.script'))
for p in scripts:run(p.read_text(),p.name,False)
for p in root.rglob('*.xml'):E.parse(p)
run('BUILD_ROOT='+json.dumps(str(root)), 'path')
run('plmg_optional={get=function(name) if name=="ctz_mount_conversion" then return {} end end}; local e=setmetatable({},{__index=_G}); assert(loadfile(BUILD_ROOT.."/gamedata/scripts/plmg_integrations.script","t",e))(); assert(e.register("guard","actor_on_update",function()end)==false)', 'co-install guard')
print('PASS standalone disables registration when CtZ mounted feature exists')
run('plmg_optional={get=function() return nil end}', 'optional setup')
for name in ['native_fixtures.lua','mount_preview_fixtures.lua','mount_conversion_fixtures.lua','mount_pickup_fixtures.lua','api_fixtures.lua']:
    run((root/'verification'/name).read_text(),name)
lua.lua_close(L)
print(f'PASS standalone: {len(scripts)} scripts compile; all XML parsed')
import re
owned={p.stem for p in scripts}
for p in scripts:
    for name in re.findall(r'\b(plmg_[a-z_]+)\.',p.read_text()):
        assert name in owned,(p,name)
assert not (root/'gamedata/scripts/plmg_mg_probe.script').exists()
assert all(not re.search(r'ctz_(?!mount_conversion)',p.read_text()) for p in scripts)
print('PASS owned dependency closure, no CtZ runtime imports or campaign files')

# Native set_tip_text uses CStringTable translation: every requested ID must exist.
strings={e.get('id'):e.findtext('text') for e in E.parse(root/'gamedata/configs/text/eng/st_plmg.xml').getroot()}
for p in scripts:
    for key in re.findall(r'set_tip_text\("([^"\n]+)"\)',p.read_text()):
        assert key in strings and strings[key],(p.name,'unresolved native tooltip',key)
print('PASS native tooltip IDs resolve to nonempty standalone localization')
