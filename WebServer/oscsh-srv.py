#!/usr/bin/python2

"""
 A quick&dirty webserver, used to put captured screens in 
 a redis-database.
 
"""

import SimpleHTTPServer
import SocketServer
import logging
import redis
from redis.sentinel import Sentinel

import sys
import os

if len(sys.argv) > 2:
	PORT = int(sys.argv[2])
	I = sys.argv[1]
elif len(sys.argv) > 1:
	PORT = int(sys.argv[1])
	I = ""
else:
	PORT = 8000
	I = ""

class RedisHandler():
	def __init__(self, domain, service):
		# use dns srv records to find redis sentinels ip and port
		sentinelServer = []
		self.colabPrefix = 'COLABORATION'
		self.colabImagePrefix = 'img'
		self.colabIndexPrefix = 'idx'

		# for local testing use a local sentinel
		if domain == 'localhost':
			self.sentinel = Sentinel([('localhost', 26379)], socket_timeout=0.1)
		else:
			answers = dns.resolver.query('_redis-sentinel._tcp.' + domain, 'SRV')
			for rdata in answers:
				sentinelServer.append(( str(rdata.target), rdata.port ))
			self.sentinel = Sentinel(sentinelServer, socket_timeout=0.1)

		try:
			master = self.sentinel.discover_master(service)
		except redis.sentinel.MasterNotFoundError:
			print('Can\'t find a redis master node for service: ' + service)
			sys.exit(2)

		redispool = redis.ConnectionPool(host=master[0], port=master[1], db=0)
		self.redis = redis.Redis(connection_pool=redispool)

	def addFile(self, name, data):
		self.redis.setex(self.colabPrefix + ':' + self.colabImagePrefix + ':' + name, data, 60)
		self.redis.incr(self.colabPrefix + ':' + self.colabIndexPrefix + ':' + name)
		self.redis.expire(self.colabPrefix + ':' + self.colabIndexPrefix + ':' + name, 60)

	def getFile(self, name):
		data = self.redis.get(self.colabPrefix + ':' + self.colabImagePrefix + ':' + name)
		return data

	def getIdx(self, name):
		return str(self.redis.get(self.colabPrefix + ':' + self.colabIndexPrefix + ':' + name))

class ServerHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
	def do_GET(self):
		logging.warning(self.headers)
		if self.path.find(self.webPath + '/img/') != -1:
			filename = self.path[len(self.webPath + '/img/'):]
			data = self.redisHandler.getFile(filename)

			self.send_response(200)
			self.send_header("Content-type", "application/octet-stream")
			self.send_header("Content-Length", str(len(data)))
			self.end_headers()
			self.wfile.write(data)
		elif self.path.find(self.webPath + '/idx/') != -1:
			filename = self.path[len(self.webPath + '/idx/'):]
			idx = self.redisHandler.getIdx(filename)

			self.send_response(200)
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			self.wfile.write(idx)
		elif self.path.find(self.webPath + '/') != -1:
			SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

		else:
			self.send_response(404)
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			# change this - to be serious
			self.wfile.write('How let the dogs out...')
#		SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

	def do_POST(self):
		if self.path.find(self.webPath + '/') != -1:
			logging.warning(self.headers)

			length = int(self.headers['Content-Length'])
			post_data = self.rfile.read(length)
			logging.warning(str(len(post_data)))

			self.redisHandler.addFile(self.path[len(self.webPath + '/'):], post_data)
			self.send_response(200)
			self.end_headers()
		else:
			SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

if __name__ == "__main__":

	# TODO
	#  - configuration reader

	# you can use SRV-Records to find redis sentinels
	redis_domain = 'localhost'
	redis_service = 'mymaster'
	# local path for static content
	os.chdir('./htdocs/')
	# dynamic content url path
	web_path = '/colaboration'

	Handler = ServerHandler
	Handler.webPath = web_path
	Handler.redisHandler = RedisHandler(redis_domain, redis_service)
	httpd = SocketServer.TCPServer(("", PORT), Handler)

	print("Python http server version 0.1 (for testing purposes only)")
	print("Serving at: http://%(interface)s:%(port)s" % dict(interface=I or "localhost", port=PORT))
	httpd.serve_forever()
