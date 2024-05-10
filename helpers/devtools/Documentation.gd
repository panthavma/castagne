# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends HBoxContainer

# Exports doc for the castagne website
func ExportDocumentation():
	var rootPath = "res://localcastagne/autodocs/"
	
	var modules = Castagne.GetLoadedModules()
	var logText = ""
	var nbModules = 0
	var nbCategories = 0
	var tags = ["Config", "Functions", "Variables", "Flags", "Battle Init Data"]
	var tagsKeys = ["Config", "Functions", "Variables", "Flags", "BattleInitData"]
	var stats = {}
	
	# TODO _moduleStateFlags
	
	for k in tagsKeys:
		stats[k] = 0
	stats["States"] = 0
	
	for mPath in modules:
		var m = modules[mPath]
		nbModules += 1
		
		var dirPath = rootPath+m.moduleDocumentation["docname"]
		var filepath = dirPath+"/ref.md"
		
		var page = "---\n"
		page += "title: "+m.moduleName+" Reference\n"
		page += "---\n"
		
		page += "# "+m.moduleName+" Reference\n\n"
		page += m.moduleDocumentation["Description"]+"\n\n"
		
		for category in m.moduleDocumentationCategories:
			var p = "\n"
			if(category != null):
				p += "### " +str(category)+"\n\n"
			nbCategories += 1
			
			var md = m.moduleDocumentationCategories[category]
			
			p += md["Description"] +"\n\n"
			
			for i in range(tags.size()):
				var tag = tags[i]
				var tagKey = tagsKeys[i]
				
				var list = md[tagKey]
				
				if(list.empty()):
					continue
				stats[tagKey] += list.size()
				
				p += "#### "+tag+"\n\n"
				
				p += "<table>\n"
				
				for e in list:
					var level = GetLevelOfElement(e)
					if(tagKey == "Config"):
						if(e.has("SubmenuName")):
							continue
						p += '<tr><th>'+e["Name"]+'</th><td colspan="2">'+str(e["Default"])+'</td><td>'+str(e["Flags"])+'</td><th>'+level+'</th></tr>'
						p += '<tr><td colspan="5">'+e["Description"]+'</td></tr>\n'
					elif(tagKey == "Functions"):
						var d = e["Documentation"]
						p += '<tr><th>'+d["Name"]+'</th><td>'+str(e["NbArgs"])+'</td><td>'+str(e["Flags"])+'</td><th>'+level+'</th></tr>'
						p += '<tr><td colspan="4">'+d["Description"]+'<ul>\n'
						var aID = 1
						for a in d["Arguments"]:
							p += '<li><strong>Arg '+str(aID)+':</strong> '+a+'</li>\n'
							aID += 1
							#p += '<tr><th></th></tr>\n'
						p += '</ul></td></tr>\n'
					elif(tagKey == "Variables"):
						p += '<tr><th>'+e["Name"]+'</th><td colspan="1">'+str(e["Default"])+'</td><td>'+str(e["Flags"])+'</td><th>'+level+'</th></tr>'
						p += '<tr><td colspan="4">'+e["Description"]+'</td></tr>\n'
					elif(tagKey == "Flags"):
						p += '<tr><th>'+e["Name"]+'</th><td colspan="2">'+e["Description"]+'</td></tr>\n'
					elif(tagKey == "BattleInitData"):
						p += '<tr><th>'+e["Name"]+'</th><td colspan="2">'+e["Description"]+'</td></tr>\n'
					else:
						p += str(e)+"\n\n"
				
				p += "</table>\n\n"
			
			page += p
		
		#if(m.baseCaspFilePath != null):
		#	page += "## Base.casp States\n"
		
		#page += "In progress!"
		
		# Write file
		var d = Directory.new()
		d.make_dir_recursive(dirPath)
		var f = File.new()
		f.open(filepath, File.WRITE)
		f.store_string(page)
		f.close()
	
	logText = str(nbModules)+" Modules ("+str(nbCategories)+" Categories), "+str(stats["Config"])+" Configs, "+str(stats["Functions"])+" Functions, "
	logText += str(stats["Variables"])+" Variables, "+str(stats["Flags"])+" Flags, "+str(stats["BattleInitData"])+" BID, "+str(stats["States"])+" States"
	
	$Label.set_text(logText)

func GetLevelOfElement(e):
	var levels = ["Expert", "Advanced", "Intermediate", "Basic"]
	for l in levels:
		if( ( e.has("Flags") and (l in e["Flags"]) ) or
			( e.has("Documentation") and e["Documentation"].has("Flags") and (l in e["Documentation"]["Flags"]) ) ):
			return l
	return ""
