from os import listdir, sep
from os.path import isdir
from platform import system as platform
from subprocess import Popen, PIPE
from sys import exit
versions = listdir('build'+sep+'versions')
if len(versions) == 0:
	print 'Found no sourcemod versions!'
	exit(-1)
elif len(versions) > 1:
	print 'Select a sourcemod version to build against:'
	for i in range(len(versions)):
		print '('+str(i+1)+') '+(' ' if len(versions) > 10 and i < 9 else '')+versions[i]
	version = versions[int(raw_input('>'))-1]
else:
	version = versions[0]

for source in listdir('addons'+sep+'sourcemod'+sep+'scripting'):
	if isdir(source):
		continue
	elif source == '.DS_Store':
		continue
	source = source[:-3] # Remove .sp
	build = ['./build/versions/{version}/{system}/spcomp'.format(version=version, system=platform()),
		'addons/sourcemod/scripting/{source}.sp'.format(source=source),
		'-o=build/compiled/{source}.smx'.format(source=source),
		'-i=build/versions/{version}/include/'.format(version=version),
		'-i=build/other_includes/']
	if platform() == 'Windows':
		build[0] += '.exe' # spcomp -> spcomp.exe
		for i in range(len(build)):
			build[i] = build[i].replace('/', '\\')

	output = Popen(build, stdout=PIPE).stdout.read()
	lines = output.split('\n')
	if lines[-3] == 'Compilation aborted.':
		print '\nErrors for file {source}:'.format(source=source)
		for line in lines[3:-4]:
			print line
