extends Control


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
	var modulesRoot = AddPageIfDoesntExist(root, "modules", {"Name":"Modules", "Text":"This is the base modules page. Click on a module to find more."})
	for module in Castagne.modules:
		SetupDocumentationModule(modulesRoot, module)
	
	LoadPage(pages[defaultPage])

func SetupDocumentationCustomPages(root):
	var documentationFolders = Castagne.SplitStringToArray(Castagne.configData["Editor-DocumentationFolders"])
	
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
	while(fileName != ""):
		var filePath = rootDirectory.get_current_dir() + "/" + fileName
		if(rootDirectory.current_is_dir()):
			var subdir = Directory.new()
			if(subdir.open(filePath) == OK):
				var subdirPage = AddPage(pageRoot, fileName)
				SetupDocumentationCustomPagesParseFolder(subdirPage, subdir)
			else:
				print("[Castagne] Editor: Couldn't open directory " + filePath)
		elif(fileName.ends_with(".md")):
			var pageName = fileName.left(fileName.length()-3)
			var page = AddPage(pageRoot, pageName)
			var file = File.new()
			if(file.open(filePath, File.READ) == OK):
				var text = file.get_as_text()
				file.close()
				page["Text"] = text
			else:
				print("[Castagne] Editor: Couldn't open file " + filePath)
		fileName = rootDirectory.get_next()


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
		treeNode = tree.create_item(pageRoot["TreeNode"])
		path = pageRoot["Path"] + "/"+pageName
	else:
		treeNode = tree.create_item()
	
	var page = {
		"Name":pageName,
		"Path":path,
		"Text":"No contents",
		"TreeNode":treeNode,
	}
	Castagne.FuseDataOverwrite(page, pageData)
	
	treeNodesToPath[treeNode] = path
	treeNode.set_text(0, page["Name"])
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

func ExitDocumentation():
	hide()




func PageSelected():
	var treeNode = tree.get_selected()
	if(treeNode == null):
		return
	if(!treeNodesToPath.has(treeNode) or !pages.has(treeNodesToPath[treeNode])):
		print("[Castagne] Editor: Can't load page from tree node " + str(treeNode))
		return
	LoadPage(pages[treeNodesToPath[treeNode]])
