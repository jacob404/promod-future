
def get_entities(vmf_file, target_name=None):
	'''
	Parses a .vmf file

	vmf_file - absolute file path to .vmf file to parse
	target_name - (optional) If specified, only entities with the
	    specified "targetname" value will be returned.  Otherwise, 
	    all parsable entities will be returned.

	Return type: list of dicts

	'''
	items = []
	depth = 0
	current_item = {}

	with open(vmf_file, 'r') as f:
	    for line in f.readlines():
	        line = line.strip()
	        if line.startswith('{'):
	            if depth == 0:
	                # We've just entered a new entity, intialize it
	                current_item = {}
	            # Note that we are within an entity
	            depth += 1
	            continue
	 
	        if line.startswith('}'):
	            depth -= 1
	            if depth == 0:
	                # We've just exited an entity, current_item should be filled
	                # so lets examine it.
	                if target_name and target_name in current_item.get('targetname', ''):
	                    print 'Found entity with targetname', current_item['targetname']
	                    items.append(current_item)
	            continue
	 
	        if depth == 1:
	            line_split = line.split('"')
	            try:
	                property_name = line_split[1]
	                property_value = line_split[3]
	            except IndexError:
	                # We aren't able to parse this line; probably not a line we care about.
	                continue
	 
	            current_item[property_name] = property_value

	return items