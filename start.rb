$LOAD_PATH << File.dirname(File.realpath(__FILE__))
require 'thread'
require 'proxy'
require 'sqlmap'
queue = Queue.new
threads = []
def main
    puts "This check sqlinject"
    puts "start"
end

trap 'INT' do
    threads.each(&:kill)
end

main()

threads << Thread.new do 
    proxy = Proxy.new(queue)
    proxy.start
end

5.times do
    threads << Thread.new do
        scan = SqlmapApi.new(queue).start
    end
    
end
threads.each(&:join)