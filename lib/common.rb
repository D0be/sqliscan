require 'lib/color'


def print_info(msg)
	puts "[+] #{Time.now} #{msg}".blue
end

def print_notice(msg)
	puts "[+] #{Time.now} #{msg}".yellow
end

def print_error(msg)
	puts "[+] #{Time.now} #{msg}".red
end

def print_success(msg)
	puts "[+] #{Time.now} #{msg}".green
end
