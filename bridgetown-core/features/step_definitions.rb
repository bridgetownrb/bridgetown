# frozen_string_literal: true

Before do
  FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
  FileUtils.mkdir_p(Paths.test_dir) unless Paths.test_dir.directory?
  Dir.chdir(Paths.test_dir)
  @timezone_before_scenario = ENV["TZ"]
end

#

After do
  FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
  Paths.output_file.delete if Paths.output_file.exist?
  Paths.status_file.delete if Paths.status_file.exist?
  Dir.chdir(Paths.test_dir.parent)
  ENV["TZ"] = @timezone_before_scenario
end

#

Given(%r!^I have a blank site in "(.*)"$!) do |path|
  unless File.exist?(path)
    then FileUtils.mkdir_p(path)
  end
end

#

Given(%r!^I do not have a "(.*)" directory$!) do |path|
  Paths.test_dir.join(path).directory?
end

#

Given(%r!^I have an? "(.*)" page(?: with (.*) "(.*)")? that contains "(.*)"$!) do |file, key, value, text|
  unless file.include?("srcsite")
    FileUtils.mkdir_p("src") unless File.exist?("src")
    File.write(File.join("src", file), <<~DATA)
      ---
      #{key || "layout"}: #{value || "none"}
      ---

      #{text}
    DATA
  else
    File.write(file, <<~DATA)
      ---
      #{key || "layout"}: #{value || "none"}
      ---

      #{text}
    DATA
  end
end

#

Given(%r!^I have an? "(.*)" file that contains "(.*)"$!) do |file, text|
  unless Paths.root_files.include?(file.split("/").first)
    FileUtils.mkdir_p("src") unless File.exist?("src")
    File.write(File.join("src", file), text)
  else
    File.write(file, text)
  end
end

#

Given(%r!^I have an? (.*) layout that contains "(.*)"$!) do |name, text|
  folder = "_layouts"

  destination_file = Pathname.new(File.join("src", folder, "#{name}.html"))
  FileUtils.mkdir_p(destination_file.parent) unless destination_file.parent.directory?
  File.write(destination_file, text)
end

#

Given(%r!^I have an? "(.*)" file with content:$!) do |file, text|
  unless Paths.root_files.include?(file.split("/").first)
    FileUtils.mkdir_p("src") unless File.exist?("src")
    File.write(File.join("src", file), text)
  else
    File.write(file, text)
  end
end

#

Given(%r!^I have an? "(.*)" page with content:$!) do |file, text|
  FileUtils.mkdir_p("src") unless File.exist?("src")
  File.write(File.join("src", file), <<~DATA)
    ---
    ---

    #{text}
  DATA
end

#

Given(%r!^I have an? (.*) directory$!) do |dir|
  unless Paths.root_files.include?(dir)
    dir_in_src = File.join("src", dir)
    unless File.directory?(dir_in_src)
      then FileUtils.mkdir_p(dir_in_src)
    end
  else
    FileUtils.mkdir_p(dir)
  end
end

#

Given(%r!^I have the following (page|post)s?(?: (in|under) "([^"]+)")?:$!) do |status, direction, folder, table|
  table.hashes.each do |input_hash|
    title = slug(input_hash["title"])
    ext = input_hash["type"] || "markdown"
    filename = "#{title}.#{ext}" if %w(page).include?(status)
    before, after = location(folder, direction)
    dest_folder = "_posts"  if status == "post"
    dest_folder = "" if status == "page"

    if status == "post"
      parsed_date = Time.xmlschema(input_hash["date"]) rescue Time.parse(input_hash["date"])
      input_hash["date"] = parsed_date
      filename = "#{parsed_date.strftime("%Y-%m-%d")}-#{title}.#{ext}"
    end

    path = File.join("src", before, dest_folder, after, filename)
    File.write(path, file_content_from_hash(input_hash))
  end
end

#

Given(%r!^I have the following posts? within the "(.*)" directory:$!) do |folder, table|
  table.hashes.each do |input_hash|
    title = slug(input_hash["title"])
    parsed_date = Time.xmlschema(input_hash["date"]) rescue Time.parse(input_hash["date"])

    filename = "#{parsed_date.strftime("%Y-%m-%d")}-#{title}.markdown"

    path = File.join("src", folder, "_posts", filename)
    File.write(path, file_content_from_hash(input_hash))
  end
end

#

Given(%r!^I have the following documents? under the (.*) collection:$!) do |folder, table|
  table.hashes.each do |input_hash|
    title = slug(input_hash["title"])
    filename = "#{title}.md"
    dest_folder = "_#{folder}"

    path = File.join("src", dest_folder, filename)
    File.write(path, file_content_from_hash(input_hash))
  end
end

#

Given(%r!^I have the following documents? under the "(.*)" collection within the "(.*)" directory:$!) do |label, dir, table|
  table.hashes.each do |input_hash|
    title = slug(input_hash["title"])
    path = File.join("src", dir, "_#{label}", "#{title}.md")
    File.write(path, file_content_from_hash(input_hash))
  end
end

#

Given(%r!^I have the following documents? nested inside "(.*)" directory under the "(.*)" collection within the "(.*)" directory:$!) do |subdir, label, dir, table|
  table.hashes.each do |input_hash|
    title = slug(input_hash["title"])
    path = File.join("src", dir, "_#{label}", subdir, "#{title}.md")
    File.write(path, file_content_from_hash(input_hash))
  end
end

#

Given(%r!^I have a configuration file with "(.*)" set to "(.*)"$!) do |key, value|
  config = \
    if source_dir.join("bridgetown.config.yml").exist?
      SafeYAML.load_file(source_dir.join("bridgetown.config.yml"))
    else
      {}
    end
  config[key] = YAML.load(value)
  Bridgetown.set_timezone(value) if key == "timezone"
  File.write("bridgetown.config.yml", YAML.dump(config))
end

#

Given(%r!^I have a configuration file with:$!) do |table|
  table.hashes.each do |row|
    step %(I have a configuration file with "#{row["key"]}" set to "#{row["value"]}")
  end
end

#

Given(%r!^I have a configuration file with "([^\"]*)" set to:$!) do |key, table|
  File.open("bridgetown.config.yml", "w") do |f|
    f.write("#{key}:\n")
    table.hashes.each do |row|
      f.write("- #{row["value"]}\n")
    end
  end
end

#

Given(%r!^I have fixture collections(?: in "(.*)" directory)?$!) do |directory|
  collections_dir = File.join(source_dir, "src", directory.to_s)
  FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_methods"), collections_dir
  FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_thanksgiving"), collections_dir
  FileUtils.cp_r Paths.source_dir.join("test", "source", "src", "_tutorials"), collections_dir
end

#

Given(%r!^I wait (\d+) second(s?)$!) do |time, _|
  sleep(time.to_f)
end

#

When(%r!^I run bridgetown(.*)$!) do |args|
  run_bridgetown(args)
  if args.include?("--verbose") || ENV["DEBUG"]
    warn "\n#{bridgetown_run_output}\n"
  end
end

#

When(%r!^I run bundle(.*)$!) do |args|
  run_bundle(args)
  if args.include?("--verbose") || ENV["DEBUG"]
    warn "\n#{bridgetown_run_output}\n"
  end
end

#

When(%r!^I run gem(.*)$!) do |args|
  run_rubygem(args)
  if args.include?("--verbose") || ENV["DEBUG"]
    warn "\n#{bridgetown_run_output}\n"
  end
end

#

When(%r!^I run git add .$!) do
  run_in_shell("git", "add", ".", "--verbose")
end

#

When(%r!^I change "(.*)" to contain "(.*)"$!) do |file, text|
  File.open(file, "a") do |f|
    f.write(text)
  end
end

#

When(%r!^I delete the file "(.*)"$!) do |file|
  unless Paths.root_files.include?(file)
    File.delete(File.join("src", file))
  else
    File.delete(file)
  end
end

#

Then(%r!^the (.*) directory should +(not )?exist$!) do |dir, negative|
  if negative.nil?
    expect(Pathname.new(dir)).to exist
  else
    expect(Pathname.new(dir)).to_not exist
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)"$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    expect(file_contents(file)).to match regexp
  else
    expect(file_contents(file)).not_to match regexp
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)" if on Windows$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    if Bridgetown::Utils::Platforms.really_windows?
      expect(file_contents(file)).to match regexp
    else
      expect(file_contents(file)).not_to match regexp
    end
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)" unless Windows$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    if Bridgetown::Utils::Platforms.really_windows?
      expect(file_contents(file)).not_to match regexp
    else
      expect(file_contents(file)).to match regexp
    end
  end
end

#

Then(%r!^I should see date "(.*)" in "(.*)" unless Windows$!) do |text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text)
  if Bridgetown::Utils::Platforms.really_windows? && !dst_active?
    expect(file_contents(file)).not_to match regexp
  else
    expect(file_contents(file)).to match regexp
  end
end

#

Then(%r!^I should see date "(.*)" in "(.*)" if on Windows$!) do |text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text)
  if Bridgetown::Utils::Platforms.really_windows? && !dst_active?
    expect(file_contents(file)).to match regexp
  else
    expect(file_contents(file)).not_to match regexp
  end
end

#

Then(%r!^I should see exactly "(.*)" in "(.*)"$!) do |text, file|
  step %(the "#{file}" file should exist)
  expect(file_contents(file).strip).to eq text
end

#

Then(%r!^I should see escaped "(.*)" in "(.*)"$!) do |text, file|
  step %(I should see "#{Regexp.escape(text)}" in "#{file}")
end

#

Then(%r!^the "(.*)" file should +(not )?exist$!) do |file, negative|
  if negative.nil?
    expect(Pathname.new(file)).to exist
  else
    expect(Pathname.new(file)).to_not exist
  end
end

#

Then(%r!^I should see today's time in "(.*)"$!) do |file|
  step %(I should see "#{seconds_agnostic_time(Time.now)}" in "#{file}")
end

#

Then(%r!^I should see today's date in "(.*)"$!) do |file|
  step %(I should see "#{Date.today}" in "#{file}")
end

#

Then(%r!^I should (not )?see "(.*)" in the build output$!) do |negative, text|
  if negative.nil? || negative.empty?
    expect(bridgetown_run_output).to match Regexp.new(text)
  else
    expect(bridgetown_run_output).not_to match Regexp.new(text)
  end
end

#

Then(%r!^I should get a zero exit(?:\-| )status$!) do
  step %(I should see "EXIT STATUS: 0" in the build output)
end

#

Then(%r!^I should get a non-zero exit(?:\-| )status$!) do
  step %(I should not see "EXIT STATUS: 0" in the build output)
end
