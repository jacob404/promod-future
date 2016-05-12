#!/usr/bin/env python2

from os import listdir, sep
from os.path import isdir
from platform import system as platform
from subprocess import Popen, PIPE
from sys import exit, argv

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

# Arguments:
# -quiet will suppress errors, just inform if error.
# Usage:
# build.py file1 (builds addons/sourcemod/scripting/file1)
# build.py (builds all files in addons/sourcemod/scripting)
quiet = False
sources = []
for arg in argv[1:]:
	if arg[0] == '-':
		if arg[1:] == 'quiet':
			quiet = True
	else:
		sources.append(arg)
if len(sources) == 0:
	sources = listdir('addons'+sep+'sourcemod'+sep+'scripting')
for source in sources:
	if isdir(source):
		continue
	elif source == '.DS_Store':
		continue
	if source[-3:] == '.sp':
		source = source[:-3]
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
		print '\tFatal error in file %s' % source
		if not quiet:
			for line in lines[3:-4]:
				print line
	elif 'Error' in lines[-2]:
		print '\tError in %s' % source
		if not quiet:
			for line in lines[3:-3]:
				print line
	elif len(lines) > 8:
		print '\tWarning in %s' % source
		if not quiet:
			for line in lines[3:-7]:
				print line

