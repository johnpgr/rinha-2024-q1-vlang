module main

import x.json2
import db.pg
import vweb

struct App {
	vweb.Context
pub:
	clientes map[int]Cliente @[required]
pub mut:
	db        pg.DB
	db_handle vweb.DatabasePool[pg.DB] @[required]
}

fn (mut ctx App) json2[T](data T) vweb.Result {
	mut buffer := []u8{cap: 200}
	defer {
		unsafe { buffer.free() }
	}
	encoder := json2.Encoder{
		escape_unicode: false
	}
	encoder.encode_value(data, mut buffer) or { panic(err) }

	ctx.set_content_type('application/json')

	return ctx.text(buffer.bytestr())
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
