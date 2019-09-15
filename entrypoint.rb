require 'yaml'

puts "ARGV is:"
puts ARGV
puts "Environment is:"
puts ENV
channel = ARGV[1] || 'releases'
event = ENV.fetch('GITHUB_EVENT_PATH')
puts "CHANNEL is #{channel}"
puts "EVENT is #{event}"


parsed = YAML.load(File.open(event))
puts "YAML IS:"
puts parsed

puts "Repository is '#{parsed.dig('repository', 'name')}"
commits = parsed.fetch('commits')
puts "Commits are:"

puts commits

puts
commits.each.with_index(1) do |commit, index|
  puts commit
  if commit.fetch('distinct') == 'false'
    puts "#{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
  else
    puts "THIS IS A MERGE: #{commit.fetch('message')}"
  end
end

puts 'Done'
