import os, re, urllib2
config_files = []
scripts = []

for root, dirs, files in os.walk("."):
	for file in files:
		if '.cfg' in file and not re.search('maps', root):
			config_files.append(root+os.sep+file)
		elif '.sp' in file:
			scripts.append(root+os.sep+file)

for file in config_files:
	f = open(file, 'rb').read()
	body = f.split('\n\n', 1)[1]
	f = open(file, 'wb')
	f.write('''// ===================================================================================
// Pro Mod - A Competitive L4D2 Configuration Always Looking To Improve
// Developers: Jacob, Blade, CanadaRox, CircleSquared, darkid, Epilimic, Fig Newtons, High Cookie, Jahze, NF, Prodigysim, Sir, Stabby, Tabun, Vintik, Visor
// License CC-BY-SA 3.0 (http://creativecommons.org/licenses/by-sa/3.0/legalcode)
// Version 4.5
// http://github.com/jacob404/Pro-Mod-4.0
// ===================================================================================

''')
	f.write(body)
	f.close()

legal = '''/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
'''

for file in scripts:
	os.sleep(10)
	print file
	f = open(file, 'rb').read()
	if '*/' in f and 'AlliedModders' in f.split('*/', 1)[0]:
			f = legal + f.split('*/', 1)[1].strip() + '\n'
	else:
		f = legal + f
	m = re.search('url.*?=.*?"(.*?)"', f)
	if not m:
		f = re.sub('public Plugin:(.*?)\n}', 'public Plugin:\\1,\n    url = ""\n}', f, flags=(re.MULTILINE | re.DOTALL))
		f = re.sub(',,', ',', f) # I accidentally add an extra comma some times.
		m = re.search('url.*?=.*?"(.*?)"', f)
	try:
		urllib2.urlopen(m.group(1))
	except (ValueError, urllib2.HTTPError, urllib2.URLError) as e:
		print e
		try:
			urllib2.urlopen('http://'+m.group(1))
		except (ValueError, urllib2.HTTPError, urllib2.URLError) as e:
			print m.group(1), e
			f = re.sub('url\s*=\s*"(.*?)"', 'url = "https://github.com/jacob404/Pro-Mod-4.0/releases/latest"', f)

	g = open(file, 'wb')
	g.write(f)
	g.close()