# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control


var editor = null
var tree
var pages = {}
var treeNodesToPath = {}
var defaultPage = "/index"

func OpenDocumentation(pagePath = null):
	if(pagePath != null):
		if(pages.has(pagePath)):
			LoadPage(pages[pagePath])
		else:
			print("[Castagne] Editor: Documentation page " + str(pagePath) + " not found")
			LoadPage(pages[defaultPage])
	show()

func LoadPage(page):
	$Window/TopBar/PageName.set_text(page["Title"])
	$Window/PageContents.set_text(page["Text"])

func SetupDocumentation():
	tree = $Window/PageList
	tree.clear()
	var root = AddPage(null, "")
	tree.set_hide_root(true)
	
	
	SetupDocumentationCustomPages(root)
	
	AddPageIfDoesntExist(root, "index", {"Name":"Index","Text":"Welcome to the Castagne documentation !"})
	var modulesRoot = AddPageIfDoesntExist(root, "modules", {"Name":"Modules", "Text":"This is the base modules page. Click on a module to find more.", "Order":99990})
	var modulesUnloadedRoot = AddPageIfDoesntExist(root, "unloadedmodules", {"Name":"Unloaded Modules", "Text":"This is the base modules for the unloaded modules. Click on a module to find more.", "Order":89999})
	for modulePath in Castagne.modulesLoaded:
		var module = Castagne.modulesLoaded[modulePath]
		if(module in editor.configData.GetModules()):
			SetupDocumentationModule(modulesRoot, module)
		else:
			SetupDocumentationModule(modulesUnloadedRoot, module)
	
	SortPagesAndCreateTree()
	
	LoadPage(pages[defaultPage])

func SetupDocumentationCustomPages(root):
	var documentationFolders = Castagne.SplitStringToArray(editor.configData.Get("Editor-DocumentationFolders"))
	
	# :TODO:Panthavma:20220501:Manage overwrite ?
	for rootFolderPath in documentationFolders:
		var rootDirectory = Directory.new()
		if(rootDirectory.open(rootFolderPath) == OK):
			SetupDocumentationCustomPagesParseFolder(root, rootDirectory)
		else:
			print("[Castagne] Editor: Documentation folder " + str(rootFolderPath) + " doesn't exist.")

func SetupDocumentationCustomPagesParseFolder(pageRoot, rootDirectory):
	rootDirectory.list_dir_begin(true)
	var fileName = rootDirectory.get_next()
	var subdirectories = []
	while(fileName != ""):
		var filePath = rootDirectory.get_current_dir() + "/" + fileName
		if(rootDirectory.current_is_dir()):
			subdirectories += [fileName]
		elif(fileName.ends_with(".md")):
			var pageName = fileName.left(fileName.length()-3)
			var page = AddPage(pageRoot, pageName)
			var file = File.new()
			if(file.open(filePath, File.READ) == OK):
				var text = file.get_as_text()
				file.close()
				SetupPageFromText(page, text)
			else:
				print("[Castagne] Editor: Couldn't open file " + filePath)
		fileName = rootDirectory.get_next()
	
	for fn in subdirectories:
		fileName = fn
		var filePath = rootDirectory.get_current_dir() + "/" + fileName
		var subdir = Directory.new()
		if(subdir.open(filePath) == OK):
			var subdirPage = AddPageIfDoesntExist(pageRoot, fileName)
			SetupDocumentationCustomPagesParseFolder(subdirPage, subdir)
		else:
			print("[Castagne] Editor: Couldn't open directory " + filePath)


func SetupDocumentationModule(modulesRoot, module):
	var mainPage = AddPage(modulesRoot, module.moduleName)
	
	# Temporary documentation, just print everything
	var m = module
	var t = ""
	t += "# " + m.moduleName + "\n"
	t += m.moduleDocumentation["Description"] + "\n\n"
	for categoryName in m.moduleDocumentationCategories:
		var c = m.moduleDocumentationCategories[categoryName]
		var vars = c["Variables"]
		var funcs = c["Functions"]
		var flags = c["Flags"]
		if(vars.empty() and funcs.empty() and flags.empty()):
			continue
		t += "## " + categoryName + "\n"
		t += c["Description"] + "\n"
		
		
		if(!funcs.empty()):
			t += "\n### Functions\n"
			for f in funcs:
				t += "--- "+f["Name"] + ": ("
				var i = 0
				for a in f["Documentation"]["Arguments"]:
					t += ("" if i==0 else ", ") + str(a)
					i += 1
				t += ")\n"+f["Documentation"]["Description"] + "\n\n"
		
		if(!vars.empty()):
			t += "\n### Variables\n"
			for v in vars:
				t += v["Name"] + ": " + v["Description"] + "\n"
		if(!flags.empty()):
			t += "\n### Flags\n"
			for f in flags:
				t += f["Name"] + ": " + f["Description"] + "\n"
		
		t += "\n"
	mainPage["Text"] = t

func AddPage(pageRoot, pageName, pageData = {}):
	var treeNode = null
	pageName = str(pageName)
	var path = pageName
	
	if(pageRoot != null):
		path = pageRoot["Path"] + "/"+pageName
	
	var page = {
		"Name":pageName,
		"Path":path,
		"Text":"No contents",
		"TreeNode":treeNode,
		"Order":1000,
		"Metadata":{},
		"Root": pageRoot,
		"Children":[],
	}
	Castagne.FuseDataOverwrite(page, pageData)
	
	if(pageRoot != null):
		pageRoot["Children"] += [page]
	if(!page.has("Title")):
		page["Title"] = page["Name"]
		
	pages[path] = page
	return page

func AddPageIfDoesntExist(pageRoot, pageName, pageData = {}):
	var path = str(pageName)
	if(pageRoot != null):
		path = pageRoot["Path"] + "/"+pageName
	if(pages.has(path)):
		return pages[path]
	return AddPage(pageRoot, pageName, pageData)

func SetupPageFromText(page, fulltext):
	var text = fulltext
	var metadata = {}
	if(fulltext.begins_with("---")):
		var endOfHeader = fulltext.find("---", 4)
		if(endOfHeader > 0):
			text = fulltext.right(endOfHeader + 4).strip_edges()
			var headerText = fulltext.left(endOfHeader)
			var lines = headerText.split("\n")
			for line in lines:
				var delim = line.find(":")
				if(delim < 1):
					continue
				metadata[line.left(delim).strip_edges()] = line.right(delim+1).strip_edges()
		
	
	var textFiltered = ""
	var nextComment = text.find("<!--")
	while nextComment >= 0:
		var endOfComment = text.find("-->", 3)
		if(endOfComment < 0):
			text = ""
			break
		
		textFiltered += text.left(nextComment)
		text = text.right(endOfComment+3)
		
		nextComment = text.find("<!--")
	
	textFiltered += text
	
	page["Text"] = textFiltered
	page["Metadata"] = metadata
	
	var valuesToElevate = ["Name", "Title", "Order"]
	for m in valuesToElevate:
		var mlower = m.to_lower()
		var mmeta = null
		
		if(metadata.has(m)):
			mmeta = m
		elif(metadata.has(mlower)):
			mmeta = mlower
		
		if(mmeta != null):
			var val = metadata[mmeta]
			if(val.is_valid_integer()):
				val = int(val)
			page[m] = val
			

func ExitDocumentation():
	hide()


func SortPagesAndCreateTree(pageRoot = null):
	var treeNode = null
	if(pageRoot == null):
		tree.clear()
		pageRoot = pages[""]
		treeNode = tree.create_item()
	else:
		treeNode = tree.create_item(pageRoot["Root"]["TreeNode"])
	
	pageRoot["TreeNode"] = treeNode
	treeNodesToPath[treeNode] = pageRoot["Path"]
	treeNode.set_text(0, pageRoot["Title"])
	
	var children = pageRoot["Children"]
	children.sort_custom(self, "_SortPagesComparator")
	
	for c in children:
		SortPagesAndCreateTree(c)

func _SortPagesComparator(a, b):
	if(a["Order"] != b["Order"]):
		return a["Order"] < b["Order"]
	return a["Name"] < b["Name"]


func PageSelected():
	var treeNode = tree.get_selected()
	if(treeNode == null):
		return
	if(!treeNodesToPath.has(treeNode) or !pages.has(treeNodesToPath[treeNode])):
		print("[Castagne] Editor: Can't load page from tree node " + str(treeNode))
		return
	LoadPage(pages[treeNodesToPath[treeNode]])
