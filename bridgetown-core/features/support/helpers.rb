# frozen_string_literal: true

require "open3"
require "bridgetown-core"
require "bridgetown-paginate"

class Paths
  SOURCE_DIR = Pathname.new(File.expand_path("../..", __dir__))

  def self.test_dir
    source_dir.join("tmp", "bridgetown")
  end

  def self.theme_gem_dir
    source_dir.join("tmp", "bridgetown", "my-cool-theme")
  end

  def self.output_file
    test_dir.join("bridgetown_output.txt")
  end

  def self.status_file
    test_dir.join("bridgetown_status.txt")
  end

  def self.bridgetown_bin
    source_dir.join("bin", "bridgetown")
  end

  def self.source_dir
    SOURCE_DIR
  end

  def self.root_files
    [
      ".bridgetown-cache",
      ".bridgetown-cache/frontend-bundling",
      ".bridgetown-cache/frontend-bundling/manifest.json",
      "bridgetown.config.yml",
      "webpack.config.js",
      "esbuild.config.js",
      "plugins",
      "plugins/nested",
      "plugins/nested/subnested",
      "frontend",
    ]
  end
end

#

def file_content_from_hash(input_hash)
  matter_hash = input_hash.reject { |k, _v| k == "content" }
  matter = matter_hash.map { |k, v| "#{k}: #{v}\n" }.join
  matter.chomp!
  content = if input_hash["input"] && input_hash["filter"]
              "{{ #{input_hash["input"]} | #{input_hash["filter"]} }}"
            else
              input_hash["content"]
            end

  <<~YAML
    ---
    #{matter}
    ---

    #{content}
  YAML
end

#

def source_dir(*files)
  Paths.test_dir(*files)
end

#

def all_steps_to_path(path)
  source = source_dir
  dest = Pathname.new(path).expand_path
  paths = []

  dest.ascend do |f|
    break if f == source

    paths.unshift f.to_s
  end

  paths
end

#

def bridgetown_run_output
  Paths.output_file.read if Paths.output_file.file?
end

#

def bridgetown_run_status
  Paths.status_file.read if Paths.status_file.file?
end

#

def run_bundle(args)
  run_in_shell("bundle", *args.strip.split)
end

#

def run_rubygem(args)
  run_in_shell("gem", *args.strip.split)
end

#

def run_bridgetown(args)
  args = args.strip.split # Shellwords?
  process = run_in_shell("ruby", Paths.bridgetown_bin.to_s, *args, "--trace")
  process.exitstatus.zero?
end

#

def run_in_shell(*args)
  p, output = exec_command(*args)

  File.write(Paths.status_file, p.exitstatus)
  File.open(Paths.output_file, "wb") do |f|
    f.print "$ "
    f.puts args.join(" ")
    f.puts output
    f.puts "EXIT STATUS: #{p.exitstatus}"
  end

  p
end

def exec_command(*args)
  stdin, stdout, stderr, process = Open3.popen3(*args)
  out = stdout.read.strip
  err = stderr.read.strip

  [stdin, stdout, stderr].each(&:close)
  [process.value, out + err]
end

#

def slug(title = nil)
  if title
    title.downcase.gsub(%r![^\w]!, " ").strip.gsub(%r!\s+!, "-")
  else
    Time.now.strftime("%s%9N") # nanoseconds since the Epoch
  end
end

#

def location(folder, direction)
  if folder
    before = folder if direction == "in"
    after  = folder if direction == "under"
  end

  [before || ".",
   after || ".",]
end

#

def file_contents(path)
  Pathname.new(path).read
end

#

def seconds_agnostic_datetime(datetime = Time.now)
  date, time, zone = datetime.to_s.split
  time = seconds_agnostic_time(time)

  [
    Regexp.escape(date),
    "#{time}:\\d{2}",
    Regexp.escape(zone),
  ].join("\\ ")
end

#

def seconds_agnostic_time(time)
  time = time.strftime("%H:%M:%S") if time.is_a?(Time)
  hour, minutes, = time.split(":")
  "#{hour}:#{minutes}"
end

# Helper method for Windows
def dst_active?
  config = Bridgetown.configuration("quiet" => true)
  ENV["TZ"] = config["timezone"]
  dst = Time.now.isdst

  # reset variable to default state on Windows
  ENV["TZ"] = nil
  dst
end
