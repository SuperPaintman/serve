require "http"
require "colorize"

require "./serve/version"
require "./serve/cli"
require "./serve/completion"

module Serve
  SERVER_NAME = "Serve"

  SHELLS = ["zsh"]

  COLORS = {
    :time         => :dark_gray,
    :method       => :green,
    :resource     => :cyan,
    :version      => :magenta,
    :status_code  => :blue,
    :elapsed_text => :yellow,
  }

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
      context.response.headers["Server"] = Serve::SERVER_NAME

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
        time_str = time_str.colorize(Serve::COLORS[:time])
        elapsed_text = elapsed_text.colorize(Serve::COLORS[:elapsed_text])

        method = method.colorize(Serve::COLORS[:method])
        resource = resource.colorize(Serve::COLORS[:resource])
        version = version.colorize(Serve::COLORS[:version])
        status_code = status_code.colorize(Serve::COLORS[:status_code])
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
        time_str = time_str.colorize(Serve::COLORS[:time])

        method = method.colorize(Serve::COLORS[:method])
        resource = resource.colorize(Serve::COLORS[:resource])
        version = version.colorize(Serve::COLORS[:version])

        message = message.colorize(:red)
      end

      @io.puts "[#{time_str}] #{method} #{resource} #{version} - #{message}:"
      e.inspect_with_backtrace(@io)
      raise e
    end
  end
end
