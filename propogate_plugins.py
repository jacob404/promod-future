import os
import re

# Get list of new plugins
plugins = {}
for root, dirs, files in os.walk('currentbuild/Update/addons/sourcemod/plugins'):
	for file in files:
		if file[-4:] == '.smx':
			plugins[file] = {}
# Get list of new plugins' cvars
for root, dirs, files in os.walk('addons/sourcemod/scripting/'):
	for file in files:
		if file[:-1]+'mx' in plugins.keys():
			f = open(root+'/'+file, 'rb').read()
			for match in re.findall('CreateConVar\("(.*?)", "(.*?)", "(.*?)"(, .*?|)(, true, .*?|)(, true, .*?|)\);', f):
				name, default, desc, flags, min, max = match
				plugins[file[:-1]+'mx'][name] = (default, desc, flags, min, max)
# Get data from cfg files (we will be overwriting them)
variable_files = {}
plugins_files = {}
loaded_plugins = set()
for root, dirs, files in os.walk('currentbuild/Update/cfg/cfgogl'):
	for file in files:
		config = root.split('/')[-1]
		path = root+'/'+file
		f = open(path, 'rb').read()
		if file[-4:] == '.cfg' and file[:7] != 'confogl': # promod.cfg, retro.cfg, etc
			variable_files[config] = {'path':path}
			header = ''
			header_done = False
			footer = ''
			plugin = None
			buffer = ''
			for line in f.split('\n'):
				if line[:4] == '// [' and line[-1:] == ']':
					plugin = line[4:-1]
					header_done = True
					footer = ''
				elif line.strip() == '':
					if plugin:
						variable_files[config][plugin] = buffer
						buffer = ''
						loaded_plugins.add(plugin)
					plugin = None
					footer += '\n'
				elif plugin:
					buffer += line+'\n'
				elif not header_done:
					header += line + '\n'
				else:
					footer += line + '\n'
			variable_files[config]['header'] = header
			variable_files[config]['footer'] = footer
		elif file == 'confogl_plugins.cfg':
			plugins_files[config] = []
			header = ''
			header_done = False
			main_done = False
			footer = ''
			for line in f.split('\n'):
				if line == '// Pro Mod Plugins':
					header_done = True
				elif not header_done:
					header += line + '\n'
				elif line.strip() == '':
					main_done = True
					footer += '\n'
				elif line[:25] == 'sm plugins load optional/':
					plugin = line[25:].split('.')[0]+'.smx'
					loaded_plugins.add(plugin)
					if not main_done:
						plugins_files[config].append(plugin)
					else:
						footer += line + '\n'
				else:
					footer += line + '\n'
			plugins_files[config] = [header, footer] + plugins_files[config]
# Go through each cvar, and ensure that it's set according to taste:
## If a cvar is present in all files, ignore it.
## If a cvar is present in some files, assume the user knows what they're doing and ignore it.
## If a cvar is present in no files, add it:
### Option 1. Globally add the cvar with the same setting to every file.
### Option 2. Select per-file what to set the cvar.
for plugin in plugins.keys():
	if plugin in loaded_plugins:
		continue
	print '\tPlugin:', plugin
	global_load = raw_input('Would you like to load this plugin globally? ')
	if not global_load or global_load[0] == 'y':
		for config in plugins_files:
			plugins_files[config].append(plugin)
			variable_files[config][plugin] = {}
	elif global_load == 'non1v1':
		for config in plugins_files:
			if '1v1' in config or config == 'deadman':
				continue
			plugins_files[config].append(plugin)
			variable_files[config][plugin] = {}
	else:
		for config in sorted(plugins_files.keys()):
			load = raw_input('Load this plugin in '+config+'? ')
			if (not load or load[0] == 'y'):
				plugins_files[config].append(plugin)
				variable_files[config][plugin] = {}
	for cvar in plugins[plugin].keys():
		default, desc, flags, min, max = plugins[plugin][cvar]
		print '''\tFound cvar {name}:\nDefault value: {default}\nDescription: {desc}\nRange: {min} <-> {max}\nFlags: {flags}'''.format(name=cvar, default=default, desc=desc, min=min[8:] if min else 'None', max=max[8:] if max else 'None', flags=flags[2:] if flags else 'None')
		global_set = raw_input('Would you like to set this variable globally? ')
		if (not global_set or global_set[0] == 'y'):
			value = raw_input('What should this variable be set to? ')
			for config in variable_files:
				if plugin in plugins_files[config]:
					variable_files[config][plugin][cvar] = value
		else:
			for config in sorted(variable_files.keys()):
				print plugin_files[config]
				if plugin not in plugins_files[config]:
					continue
				value = raw_input('Setting for config '+config+'? ')
				variable_files[config][plugin][cvar] = value
# Done with settings, now write to files.
for config in sorted(plugins_files.keys()):
	f = open('currentbuild/Update/cfg/cfgogl/'+config+'/confogl_plugins.cfg', 'wb')
	header = plugins_files[config].pop(0)
	footer = plugins_files[config].pop(0)
	f.write(header)
	f.write('// Pro Mod Plugins\n')
	for plugin in sorted(plugins_files[config]):
		if plugin == '':
			continue
		f.write('sm plugins load optional/'+plugin+'\n')
	f.write(footer)
	f.close()

for config in sorted(variable_files.keys()):
	path = variable_files[config]['path']
	del variable_files[config]['path']
	f = open(path, 'wb')
	header = variable_files[config]['header']
	del variable_files[config]['header']
	footer = variable_files[config]['footer']
	del variable_files[config]['footer']
	f.write(header)
	for plugin in sorted(variable_files[config].keys()):
		f.write('\n// ['+plugin+']')
		if plugin in loaded_plugins:
			f.write('\n'+variable_files[config][plugin])
		else:
			for cvar in sorted(variable_files[config][plugin].keys()):
				f.write('\nconfogl_addcvar '+cvar+' '+variable_files[config][plugin][cvar])
			f.write('\n')
	f.write(footer)
	f.close()
