require 'webrick'
require 'webrick/httpproxy'
require 'addressable/uri'
require 'securerandom'
require 'lib/common'

=begin
 web代理类
 提供一个http代理服务
 过滤http请求
=end

class Proxy
	#构造函数
	def initialize(queue)
		@proxy_port = '8080'
		@save_path = 'E:\\sqliscan\\res\\'
		@filter_extname = load_filter
		@proxy = init_proxy
		@listened_host = 'ALL'
		@filter_status = [/4\d{2}/,/5\d{2}/]
		@queue = queue
	end

	#读取过滤的配置文件
	def load_filter
		filters = File.read('filter.ini').split("\n")
	end

	#定义handler ，创建新的代理对象
	def init_proxy
		handler = proc do |req, res|
			filter(req, res)
		end
		proxy = WEBrick::HTTPProxyServer.new(
								:Port => @proxy_port,
								:ProxyContentHandler => handler,
								:AccessLog => [],
								:Logger => WEBrick::Log.new('./proxy.log', WEBrick::Log::INFO)
								)
	end


	#http请求包的过滤
	def filter(req, res)
		uri = Addressable::URI.parse(req.request_uri)
		print_info("#{req.request_uri}")
		return if @listened_host !='ALL' && !(@listened_host.include? uri.host)
		@filter_extname.each do |extname|
			return if extname.eql? (uri.extname.downcase)
		end
		@filter_status.each do |status|
			return if res.status.to_s =~ status
		end
		save_file = File.join(@save_path,SecureRandom.hex(10))
		File.write(save_file, req)
		print_notice("This request Saveing to #{save_file}")
		@queue << save_file
	end

	def start
		msg1 = "Proxy will start listen on #{@proxy_port}"
		msg2 = "The request will save in #{@save_path}"
		print_info(msg1)
		print_info(msg2)
		@proxy.start
	end

	def stop
		@proxy.shutdown
	end

end



