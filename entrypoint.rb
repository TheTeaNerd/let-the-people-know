require 'yaml'

puts ENV
channel = ARGV[1] || 'releases'
event = ENV.fetch('GITHUB_EVENT_PATH')
puts "EVENT is #{event}"
puts
puts

parsed = YAML.load(File.open(event))
puts "Repository is '#{parsed.dig('repository', 'name')}'"
commits = parsed.fetch('commits')
puts "Commits are:"
commits.select do |commit|
  commit.fetch('distinct') == false
end.each(with_index(1) do |commit, index|
  puts "#{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end
