Plugin = require 'plugin'
Page = require 'page'

require('dom').css
	'.CodeMirror':
		border: 0
		background: 'none'
		height: 'auto'
	'.CodeMirror-scroll':
		height: 'auto'
		overflowX: 'auto'
		overflowY: 'hidden'
	'.cm-header-1': { fontSize: "150%" }
	'.cm-header-2': { fontSize: "130%" }
	'.cm-header-3': { fontSize: "120%" }
	'.cm-header-4': { fontSize: "110%" }
	'.cm-header-5': { fontSize: "100%" }
	'.cm-header-6': { fontSize: "90%" }
	'.cmStrong': { fontSize: "140%" }
	#'.cm-header': {}

exports.render = !->
	request = Plugin.request()
	page = require('page')
	db = require('db')

	curPage = (request 2) || 'default'
	edit = (request 3)=='edit'

	if edit
		data = (db.shared '#'+curPage)
		save = !->
			value = cm.getValue()
			Plugin.syncServer 'save', curPage, value, !->
				db.shared curPage, value # predict
			Page.navBack()
			
		Page.actions [[false, "Save", save, true]]
		Page.prev "Cancel"
		unless require('codemirror').isLoaded ['mode/markdown/markdown','addon/dialog/dialog','addon/search/search','addon/search/searchcursor']
			require('widgets').EmptyText 'Loading...'
			return

		cm = dbg.cm = require('codemirror').render
			indentWithTabs: true,
			lineWrapping: true
			mode: "markdown"
			value: data||"# Main heading\n\n## Sub heading\nSome info...\n\n## Another sub heading\nBla, bla, bla... with *emphasis* and **bold**.\n"
	else
		data = (db.shared curPage)
		edit = !->
			r = request()
			r[2] = curPage
			r[3] = 'edit'
			Page.nav r
		Page.actions [[false, "Edit", edit, true]]
		if data
			require('markdown').render data, getRequest: (url) ->
				r = request()
				r[2] = url.replace(/[^a-zA-Z0-9\-]/g, '_')
				r
		else
			require('widgets').EmptyText "Page does not exist yet. Tap 'edit' in the upper right corner."

