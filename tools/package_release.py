"""Build the player package; source tests, tools and private metadata stay in Git."""
from pathlib import Path
import zipfile,xml.etree.ElementTree as E
root=Path(__file__).resolve().parents[1]
output=root.parent/'Placeable_LMGs_0.8.3.zip'
files=[p for folder in ['gamedata','fomod'] for p in (root/folder).rglob('*') if p.is_file()]
files += [root/'README_USER.md',root/'meta.ini']
assert len(list((root/'gamedata/meshes/plmg').glob('*.ogf')))==2, 'Supply the two private mounted models first'
for node in E.parse(root/'fomod/ModuleConfig.xml').getroot().find('requiredInstallFiles'):
    assert (root/node.get('source')).exists()
with zipfile.ZipFile(output,'w',compression=zipfile.ZIP_DEFLATED)as z:
    for p in sorted(files):z.write(p,p.relative_to(root).as_posix())
with zipfile.ZipFile(output)as z:
    assert z.testzip() is None
    assert set(z.namelist())=={p.relative_to(root).as_posix() for p in files}
    for name in z.namelist():
        assert name.startswith(('gamedata/','fomod/')) or name in ['README_USER.md','meta.ini']
        assert not name.endswith(('.log','.blend','.py','.lua','.pyc'))
    assert 'gamedata/scripts/plmg_api.script' not in z.namelist()
print('PASS end-user ZIP:',len(files),'entries; runtime, installer and player guide only')
