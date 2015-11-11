Db = require 'db'
Plugin = require 'plugin'

exports.onInstall = exports.onConfig = (config) !->
	Db.shared.set "wiki", config.wiki if config?

exports.client_save = (page, data) !->
	Plugin.assertAdmin() unless Db.shared.peek("wiki")
	Db.shared.set "p", page, data


