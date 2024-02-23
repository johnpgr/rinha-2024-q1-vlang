module main

import x.json2
import db.pg
import vweb

struct App {
	vweb.Context
pub mut:
	db        pg.DB
	db_handle vweb.DatabasePool[pg.DB] @[required]
}

fn (mut ctx App) json2[T](data T) vweb.Result {
	ctx.set_content_type('application/json')
	return ctx.text(json2.encode(data))
}

fn (mut ctx App) unprocessable() vweb.Result {
	ctx.set_status(422, '')
	return ctx.text('')
}

fn (mut ctx App) internal_error() vweb.Result {
	ctx.set_status(500, '')
	return ctx.text('')
}

fn (mut ctx App) bad_request() vweb.Result {
	ctx.set_status(400, '')
	return ctx.text('')
}
