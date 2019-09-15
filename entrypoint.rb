require 'yaml'

puts "ARGV is:"
puts ARGV
puts "Environment is:"
puts ENV.keys
channel = ARGV[1] || 'releases'
event = ENV.fetch('GITHUB_EVENT_PATH')
puts "CHANNEL is #{channel}"
puts "EVENT is #{event}"


parsed = YAML.load(File.open(event))
puts "YAML IS:"
puts parsed

puts "Repository is '#{parsed.dig('repository', 'name')}"
commits = parsed.fetch('commits')
commits.each.with_index(1) do |commit, index|
  puts "#{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end

puts 'Done'
