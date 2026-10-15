from pathlib import Path
import struct,xml.etree.ElementTree as E,json,hashlib
root=Path(__file__).resolve().parents[1]
for path,size,levels,fmt,block in [('ui/plmg_mount_icon.dds',64,7,b'DXT5',16),('plmg/placement_preview.dds',16,5,b'DXT1',8),('plmg/mount_black.dds',1024,11,b'DXT1',8)]:
 data=(root/'gamedata/textures'/path).read_bytes()
 assert data[:4]==b'DDS ' and struct.unpack_from('<II',data,12)==(size,size)
 assert data[84:88]==fmt and struct.unpack_from('<I',data,28)[0]==levels
 assert len(data)==128+sum(max(1,((size>>i)+3)//4)**2*block for i in range(levels))
keys={n.get('id'):n.findtext('text')for n in E.parse(root/'gamedata/configs/text/eng/st_plmg.xml').getroot()}
assert keys['st_plmg_mount_pickup_action']=='$$ACTION_USE$$ Mount\\nHold $$ACTION_USE$$ Pickup'
ini=(root/'gamedata/configs/mod_system_plmg.ltx').read_text()
assert '[plmg_mounted_pkm]' in ini and '[plmg_mounted_mg42]' in ini
assert ini.count('class = _S_STMGU')==1 and 'plmg_mounted.net_spawn_after' in ini
for kind in ['pkm','mg42']:
 data=(root/f'gamedata/configs/models/plmg/mounted_{kind}.ltx').read_text()
 assert f'wpn_section = plmg_mounted_{kind}' in data and 'ignore_static = true' in data
for name,sha in json.loads((root/'PRIVATE_MODELS.json').read_text())['model_sha256'].items():
 p=root/name
 if p.exists():assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
print('PASS standalone profiles, prompt, userdata routes and DDS assets; private model hashes when present')

# Regression contracts for reported free reload/slow slew/backward exit bugs.
assert 'unlimited_ammo = false' in ini
assert 'reload_consume = plmg_mounted.reload_consume' in ini
for kind in ['pkm','mg42']:
    body=(root/f'gamedata/configs/models/plmg/mounted_{kind}.ltx').read_text()
    assert 'rotate_x_speed = 60' in body and 'rotate_y_speed = 90' in body
    assert 'exit_position = 0, -1.15, -1.5' in body
print('PASS consuming reload, explicit native aiming speeds and aligned exit profiles')
