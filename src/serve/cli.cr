require "option_parser"

# Completions
module Serve
  class CLI
    def self.run(args)
      host = "0.0.0.0"
      port = 8000
      public_dir = "./"
      colors = true

      OptionParser.parse(args) do |parser|
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
          {% for name, index in Serve::SHELLS %}
            if val == {{name}}
              puts Serve::Completion.{{name.id}}
              exit
            end
          {% end %}

          raise "Unknown shell: #{val.downcase}. Available: #{Serve::SHELLS.join(", ")}"
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
  end
end
