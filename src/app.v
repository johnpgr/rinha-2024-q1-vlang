module main

import picohttpparser
import net.http
import x.json2
import db.pg
import strings

pub struct App {
pub:
	db pg.DB @[required]
}

pub struct Response {
pub mut:
	code    http.Status = .not_found
	headers map[string]string
	body    string
}

@[inline]
fn (app App) handler(req picohttpparser.Request) &Response {
	if req.path == '/admin/reset' && req.method == http.Method.post.str() {
		return app.handle_admin_reset()
	}

	mut path_parts := req.path.split('/')
	if path_parts.len == 0 {
		return Response.not_found()
	}
	path_parts.drop(1)

	if path_parts[0] != 'clientes' || path_parts.len < 2 {
		return Response.not_found()
	}

	curr_path := path_parts[2]
	cliente_id := path_parts[1].int()

	if cliente_id == 0 {
		return Response.not_found()
	}

	if curr_path == 'transacoes' {
		if req.method != http.Method.post.str() {
			return Response.not_found()
		}

		return app.handle_transacao(req.body, cliente_id)
	}

	if curr_path == 'extrato' {
		if req.method != http.Method.get.str() {
			return Response.not_found()
		}

		return app.handle_extrato(cliente_id)
	}

	return Response.not_found()
}

fn (app App) callback(_ voidptr, req picohttpparser.Request, mut res picohttpparser.Response) {
	response := app.handler(req)
	mut builder := strings.new_builder(20)
	defer {
		unsafe { builder.free() }
	}

	builder.write_string('HTTP/1.1 ')
	builder.write_string(int(response.code).str())
	builder.write_string(' ')
	builder.write_string(response.code.str())
	builder.write_string('\r\n')

	res.write_string(builder.str())

	for key, value in response.headers {
		res.header(key, value)
	}

	res.body(response.body)
	res.end()
}

@[inline]
fn Response.json[T](data T) &Response {
	mut buffer := []u8{cap: 200}

	defer {
		unsafe { buffer.free() }
	}

	// This make string encode faster
	encoder := json2.Encoder{
		escape_unicode: false
	}

	encoder.encode_value(data, mut buffer) or {
		dump(err)
		panic('erro no encode do json ${err}')
	}

	return &Response{
		code: .ok
		headers: {
			'Content-Type': 'application/json'
		}
		body: buffer.bytestr()
	}
}

@[inline]
fn Response.ok() &Response {
	return &Response{
		code: .ok
	}
}

@[inline]
fn Response.internal_error() &Response {
	return &Response{
		code: .internal_server_error
	}
}

@[inline]
fn Response.unprocessable() &Response {
	return &Response{
		code: .unprocessable_entity
	}
}

@[inline]
fn Response.bad_request() &Response {
	return &Response{
		code: .bad_request
	}
}

@[inline]
fn Response.not_found() &Response {
	return &Response{
		code: .not_found
	}
}
