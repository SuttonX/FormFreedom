#!/usr/bin/env python3
"""Package the complete repository as one directly installable addon folder."""
from pathlib import Path
import hashlib,re,zipfile
root=Path(__file__).resolve().parents[1]
toc=(root/'FormFreedom.toc').read_text()
version=re.search(r'^## Version: (.+)$',toc,re.M).group(1)
for line in toc.splitlines():
    if line.strip().endswith('.lua'): assert (root/line.strip()).is_file(),line
output=root/'dist';output.mkdir(exist_ok=True)
archive=output/('FormFreedom-'+version+'.zip')
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for path in sorted(root.rglob('*')):
        relative=path.relative_to(root)
        if path.is_file() and not any(p in relative.parts for p in ('dist','.git','__pycache__')):
            z.write(path,Path('FormFreedom')/relative)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert 'FormFreedom/FormFreedom.toc' in z.namelist()
    assert {n.split('/')[0] for n in z.namelist()}=={'FormFreedom'}
checksum=hashlib.sha256(archive.read_bytes()).hexdigest()
archive.with_suffix('.zip.sha256').write_text(checksum+'  '+archive.name+'\n')
print(archive);print('SHA256 '+checksum)
