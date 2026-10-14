"""Retarget already prepared private CtZ model bytes; no model assets embedded."""
from pathlib import Path
import struct,argparse

def chunks(data):
    result=[];i=0
    while i<len(data):
        if i+8>len(data):raise ValueError("Truncated chunk")
        tag,size=struct.unpack_from('<II',data,i);i+=8
        if i+size>len(data):raise ValueError("Truncated payload")
        result.append((tag,data[i:i+size]));i+=size
    return result

def pack(rows):return b''.join(struct.pack('<II',tag,len(data))+data for tag,data in rows)
def route(data,kind):
    top=chunks(data);lookup=dict(top)
    expected=('#include "models\\ctz\\mounted_'+kind+'_test.ltx"').encode()+b'\0'
    if lookup.get(17)!=expected:raise ValueError("Requires the prepared CtZ model")
    children=chunks(lookup[9])
    if len(children)!=3:raise ValueError("Requires three prepared meshes")
    tag,child=children[0];rows=chunks(child);material=dict(rows)[2].split(b'\0')
    if material[0]!=b'ctz\\mount_black':raise ValueError("Unexpected support texture")
    changed=b'plmg\\mount_black\0'+material[1]+b'\0'
    children[0]=(tag,pack([(k,changed if k==2 else v)for k,v in rows]))
    userdata=('#include "models\\plmg\\mounted_'+kind+'.ltx"').encode()+b'\0'
    result=pack([(k,pack(children) if k==9 else userdata if k==17 else v)for k,v in top])
    # Routing alone may change: all other top chunks and mesh chunks must match.
    final=dict(chunks(result))
    for k,v in top:
        if k not in (9,17):assert final[k]==v
    for i,((_,before),(_,after))in enumerate(zip(chunks(lookup[9]),chunks(final[9]))):
        for k,v in chunks(before):
            if i!=0 or k!=2:assert dict(chunks(after))[k]==v
    return result
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('input',type=Path);ap.add_argument('output',type=Path);ap.add_argument('--kind',choices=['pkm','mg42'],required=True);a=ap.parse_args();a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_bytes(route(a.input.read_bytes(),a.kind))
