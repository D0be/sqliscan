require 'rest-client'
require 'json'

class SqlmapApi
	attr_accessor :taskid

	def initialize(queue)
		@apiaddr = '127.0.0.1:8775'
		@taskid = nil
		@queue = queue
	end

	def new_task
		begin                                                         
			r = RestClient.get("#{@apiaddr}/task/new")
			content = JSON.load(r.body)
			@taskid = content['taskid']
		rescue
			@taskid = nil
		end
	end

	def target_set(target)
		option = {'requestFile'=>target}
		begin
			r = RestClient.post("#{@apiaddr}/option/#{@taskid}/set", option.to_json, content_type: :json)
			content = JSON.load(r.body)
			content["success"] ? true : false
		rescue
			false
		end
	end

	def scan_status
		begin
			r = RestClient.get("#{@apiaddr}/scan/#{@taskid}/status")
			content = JSON.load(r.body)
			content["success"] ? content["status"] : false
		rescue
			false
		end
	end

	def scan_start
		data = {}
		begin
			r = RestClient.post("#{@apiaddr}/scan/#{@taskid}/start", data.to_json, content_type: :json)
			content = JSON.load(r.body)
			content["success"] ? true : false
		rescue
			false
		end
	end
	
	def scan_result
		begin
			r = RestClient.get("#{@apiaddr}/scan/#{@taskid}/data")
			content = JSON.load(r.body)
			content["success"] ? content["data"] : false
		rescue
			false
		end
	end
	
	def delete_task
		begin
			r = RestClient.get("#{@apiaddr}/task/#{@taskid}/delete")
			content = JSON.load(r.body)
			content["success"] ? true : false
		rescue
			false
		end
		
	end
	
	def termination
		loop do
			break if scan_status.eql? 'terminated'
			print_notice("Task:#{@taskid} scan not terminated,please wait...")
			sleep(5)
		end
		return true
	end
	
	def vulnerable?
		scan_result.empty? ? false : true
	end
	
	def delete_file(target)
		File.delete target
	end

	def start
		loop do
			if @queue.empty?
				sleep(3)
				next
			end
			target = @queue.pop
			unless new_task
				print_error("Get taskid error!")
				@queue << target
				sleep(3)
				next
			end
			unless target_set(target)
				print_error("Target set error!")
				@queue << target
				delete_task
				sleep(3)
				next
			end
			unless scan_start
				print_error("Start task #{@taskid} error!")
				@queue << target
				delete_task
				sleep(3)
				next
			end
			print_info("Start scan #{target} at id: #{@taskid}")
		    termination
			if vulnerable?
				print_success("#{target} have sqlinject")
			else
				print_notice("#{target} is not a sqlinject vul")
				delete_file target
			end
		end
		
	end

end