require "./serve/*"
require "http"
require "colorize"
require "option_parser"

# Constants
private SERVER_NAME = "Serve"

private SHELLS = ["zsh"]

private COLORS = {
  :time         => :dark_gray,
  :method       => :green,
  :resource     => :cyan,
  :version      => :magenta,
  :status_code  => :blue,
  :elapsed_text => :yellow,
}

# Completions
# TODO: add dynamic generator based on parser
private def completion_zsh(): String
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
      '(--completion)--completion=[Print tab auto-completion for Serve]:shell:(#{SHELLS.join(" ")})' \\
      '(-v, --version)'{-v,--version}'[Show serve version]' \\
      '(-h, --help)'{-h,--help}'[Show this help]' \\
      '*:directory:_directories' && ret=0

    return ret
  }

  compdef _completion_serve serve
  EOF
end

module Serve
  def self.run(*, host = "0.0.0.0", port = 8000, public_dir = "./", colors = true)
    handler = Serve::StaticFileHandler.new(public_dir)
    logger = Serve::LogPrettyHandler.new(STDOUT, colors: colors)

    server = HTTP::Server.new(host, port, [logger, handler])
    public_dir = File.expand_path(public_dir)

    if colors
      host = host.colorize(:yellow)
      port = port.colorize(:yellow)
      public_dir = public_dir.colorize(:cyan)
    end

    puts "Serving #{public_dir} dir on #{host}:#{port}"

    server.listen
  end

  class StaticFileHandler < HTTP::StaticFileHandler
    def call(context)
      # Rewrite path
      if context.request.path.ends_with?("/")
        index_path = context.request.path + "index.html"
        index_realpath = @public_dir + index_path

        if File.exists?(index_realpath)
          context.response.status_code = 200
          context.request.path = index_path
        end
      end

      # Add server name
      context.response.headers["Server"] = SERVER_NAME

      super
    end
  end

  class LogPrettyHandler < HTTP::LogHandler
    def initialize(@io : IO = STDOUT, *, @colors = true)
    end

    def call(context)
      time = Time.now

      call_next(context)

      time_str = time.to_s

      elapsed = Time.now - time
      elapsed_text = elapsed_text(elapsed)

      # Headers
      # X-Response-Time
      millis = elapsed.total_milliseconds.to_s
      context.response.headers["X-Response-Time"] = millis + "ms"

      method = context.request.method
      resource = context.request.resource
      version = context.request.version
      status_code = context.response.status_code

      if @colors
        time_str = time_str.colorize(COLORS[:time])
        elapsed_text = elapsed_text.colorize(COLORS[:elapsed_text])

        method = method.colorize(COLORS[:method])
        resource = resource.colorize(COLORS[:resource])
        version = version.colorize(COLORS[:version])
        status_code = status_code.colorize(COLORS[:status_code])
      end

      # TODO: add ip addr
      # 127.0.0.1 - - [13/Nov/2016 12:24:51] "GET /src/ HTTP/1.1" 200 -

      @io.puts "[#{time_str}] #{method} #{resource} #{version} - #{status_code} (#{elapsed_text})"
    rescue e
      time = Time.now
      time_str = time.to_s

      method = context.request.method
      resource = context.request.resource
      version = context.request.version

      message = "Unhandled #exception"

      if @colors
        time_str = time_str.colorize(COLORS[:time])

        method = method.colorize(COLORS[:method])
        resource = resource.colorize(COLORS[:resource])
        version = version.colorize(COLORS[:version])

        message = message.colorize(:red)
      end

      @io.puts "[#{time_str}] #{method} #{resource} #{version} - #{message}:"
      e.inspect_with_backtrace(@io)
      raise e
    end
  end
end

# TODO: add checking like `__FILE__ == $0`
if true
  host = "0.0.0.0"
  port = 8000
  public_dir = "./"
  colors = true

  OptionParser.parse! do |parser|
    parser.banner = "Usage: serve [arguments] [public_dir]"
    parser.on("-H HOST", "--host=HOST", "Server host") do |val|
      host = val
    end
    parser.on("-p PORT", "--port=PORT", "Server port") do |val|
      port = val.to_i
    end
    parser.on("--no-color", "Turn off colored log") do
      colors = false
    end
    parser.on("--completion=SHELL", "Print tab auto-completion for Serve") do |val|
      {% for name, index in SHELLS %}
        if val == {{name}}
          puts completion_{{name.id}}
          exit
        end
      {% end %}

      raise "Unknown shell: #{val.downcase}. Available: #{SHELLS.join(", ")}"
    end
    parser.on("-v", "--version", "Show serve version") do
      puts Serve::VERSION
      exit
    end
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end

    parser.unknown_args do |before_dash, after_dash|
      if before_dash.size > 1
        puts "Invalid args: #{before_dash[1..before_dash.size].join(", ")}"
        puts parser
        exit 1
      end

      if before_dash.empty?
        next
      end

      public_dir = before_dash[0]
    end
  end

  Serve.run(host: host, port: port, public_dir: public_dir, colors: colors)
end
