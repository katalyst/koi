# Only loads the debugger if tmp/debug.txt is present
# To connect to the remote debugger use
# rdebug -c in your terminal after using 'rtd'
#
# aliases for your bashrc/zshrc to make life easier
# alias rt='touch tmp/restart.txt'
# alias rtd='touch tmp/debug.txt; rt'

debug_indicator = Rails.root + 'tmp/debug.txt'

if debug_indicator.exist?
  debug_indicator.delete
  require 'ruby-debug'
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
  Debugger.settings[:reload_source_on_change] = true
  Debugger.wait_connection = true
  Debugger.start_remote
end
