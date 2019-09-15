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
