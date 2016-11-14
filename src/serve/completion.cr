module Serve
  module Completion
    def self.zsh : String
      <<-EOF
      #!/bin/zsh

      # if [[ -z $commands[serve] ]]; then
      #   echo 'serve is not installed, you should install it first'
      #   return -1
      # fi

      # Serve
      # version: #{Serve::VERSION}

      # Usage:
      # eval "$(serve --completion=zsh)"

      function _completion_serve() {
        local ret=1

        _arguments -C \\
          '(-H, --host)'{-H,--host=}'[Server host]:host: ' \\
          '(-p, --port)'{-p,--port=}'[Server port]:port: ' \\
          '(--no-color)--no-color[Turn off colored log]' \\
          '(--completion)--completion=[Print tab auto-completion for Serve]:shell:(#{Serve::SHELLS.join(" ")})' \\
          '(-v, --version)'{-v,--version}'[Show serve version]' \\
          '(-h, --help)'{-h,--help}'[Show this help]' \\
          '*:directory:_directories' && ret=0

        return ret
      }

      compdef _completion_serve serve
      EOF
    end
  end
end
