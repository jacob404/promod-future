import datetime
from vmfparse import get_entities

### CONFIG ###
vmf_file = r'/path/to/file'
target_name = 'removeme'
item_properties = ['id']
### END CONFIG ###
 
out_file = '{0}-{1}.cfg'.format(
    vmf_file.split('\\')[-1].split('.')[0][:-2],
    datetime.datetime.utcnow().strftime('%Y%m%d-%H%M%S'))
 
print 'Reading in', vmf_file, '...'
print 'Searching for entities with names similar to', target_name, '...'

items = get_entities(vmf_file, target_name)

print 'Found', len(items), 'items.\n'
print 'Outputting', out_file
 
with open(out_file, 'w') as f:
    f.write('filter:\n')
    for item in items:
        f.write('{\n')
        for p in item_properties:
            if p in item:
                f.write('\t"hammer{0}" "{1}"\n'.format(p, item[p]))
        f.write('}\n')
 
print 'Finished.'