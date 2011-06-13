require 'rubygems'
require 'win32/changenotify'
include Win32

#
# Watch a directory for any changes to java source files and 
# run the compile command (makefile, or javac)
#

def run(command, input='')
    IO.popen(command, 'r+') do |io|
        io.puts input
        io.close_write
        return io.read
    end
end


dir = $1
command = $2 

cn = ChangeNotify.new(dir, true, ChangeNotify::LAST_WRITE)
    
cn.wait do |events|

    events.each  do |event|
        if event.file_name =~ /.java$/
            puts "executing " + command + "==========================="
            run command
            puts "fini..."
            puts ""
        end
    end
end
