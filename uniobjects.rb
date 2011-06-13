require 'java'
require 'pp'

$CLASSPATH << "C:\\IBM\\UniDK\\uojsdk\\lib\\asjava.zip"

include_class Java::asjava.uniobjects.UniSession

#
# Playing around with a Simple DSL for IBM UniVerse task automation
#

class UniSession
    def list_methods
        methods.sort.each { |x| pp x }
        nil
    end

    def connect(host, account, user, pass)
        set_host_name host
        set_account_path account
        set_user_name user
        set_password pass
        begin 
            connect
            exec "DATE.FORMAT ON"
        rescue Exception => e
            print "error occurred: #{e.message} : disconnecting"
            disconnect
        end

        self
    end

    def exec(command, output=true)
        command().command = command
        command().exec
        pp command
        pp_command_output command().response if output 
        self
    end

    def pp_command_output(command_output)
        command_output.split("\r\n").each { |line| puts line  }
    end

    def method_missing(id, *args)
        exec id.id2name.upcase + " " + args.join(' ').upcase 
    end
end

def uni_task(config, &block)
    session = UniSession.new
    session.connect config[:host], config[:account], config[:user], config[:pass]

    session.instance_eval &block #block.call(session)

    session.disconnect
end


