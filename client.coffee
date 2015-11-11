Db = require 'db'
Dom = require 'dom'
Form = require 'form'
Page = require 'page'
Plugin = require 'plugin'
Server = require 'server'
Ui = require 'ui'
{tr} = require 'i18n'

require('dom').css
	'.cm-header-1': fontSize: "150%"
	'.cm-header-2': fontSize: "130%"
	'.cm-header-3': fontSize: "120%"
	'.cm-header-4': fontSize: "110%"
	'.cm-header-5': fontSize: "100%"
	'.cm-header-6': fontSize: "90%"
	'.cmStrong': fontSize: "140%"
	'th':
		textAlign: 'left'
	'table':
		borderSpacing: '10px 4px'
	#'.cm-header': {}

example = """
	## Example text

	Bla, bla, bla... with *emphasis*, **bold**, [links](http://tinyurl.com/y8ufsnp), ~~mistakes~~, ```code```.

	This goes in a new paragraph.


	## Example table

	name | age
	-----|------
	Jack | 37
	Jan  | 22
	"""
	

exports.render = !->
	Dom.style _userSelect: 'text'

	allowEdit = Db.shared.get('wiki') || Plugin.userIsAdmin() || Plugin.ownerId() is Plugin.userId()
	log 'allowEdit', allowEdit

	curPage = Page.state.get(0) || 'default'
	edit = Page.state.get(1)=='edit'

	if edit and allowEdit
		data = Db.shared.peek("p",curPage)
		Form.setPageSubmit !->
			value = editor.value()
			Server.sync 'save', curPage, value, !->
				Db.shared.set "p", curPage, value # predict
			Page.back()
		,true

		editor = require('editor').render
			value: data||example
			mode: "markdown"

		Dom.onTap
			cb: !-> editor.focus()
			highlight: false
	else
		if allowEdit
			Page.setFooter
				label: tr("Edit page")
				action: !->
					if Plugin.agent().ios || Plugin.agent().android
						require('modal').confirm tr('Dragons ahead'), tr('The content editor can be wonky on mobile devices. It is recommended to open Happening (http://happening.im) on a laptop/desktop for this. Do you want to proceed anyway?'), !->
							Page.nav [curPage,'edit']
					else
						Page.nav [curPage,'edit']

			###
			Dom.img !->
				Dom.prop src: Plugin.resourceUri('icon-edit-48.png')
				Dom.style
					width: "32px"
					height: "32px"
					float: "right"
				Dom.onTap !->
					if Plugin.agent().ios || Plugin.agent().android
						require('modal').confirm 'Dragons ahead', 'The content editor can be wonky on mobile devices. It is recommended to open Happening (http://happening.im) on a laptop/desktop for this. Do you want to proceed anyway?', !->
							Page.nav [curPage,'edit']
					else
						Page.nav [curPage,'edit']
			###
		if data = Db.shared.get("p",curPage)
			require('markdown').render data, getRequest: (url) ->
				url.replace(/[^a-zA-Z0-9\-]/g, '_')
		else if allowEdit
			Ui.emptyText "No such page yet. Tap 'edit page' below to create it."
		else
			Ui.emptyText "No such page (yet)!"

exports.renderSettings = !->
	Form.sep()
	Form.check
		text: "All members can edit"
		name: 'wiki'
		value: if Db.shared then Db.shared.func('wiki')
	Form.sep()

