exports.client_save = (page, data) !->
	require('db').set ''+page, ''+data

