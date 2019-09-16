require 'yaml'


puts 'ENVIRONMENT:'
puts ENV
puts

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
  puts commit
  commit.fetch('distinct') == false
end.each.with_index(1) do |commit, index|
  puts "#{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end
puts
puts

commits.select do |commit|
  puts commit
  commit.fetch('distinct') == true
end.each.with_index(1) do |commit, index|
  puts "Merge #{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end
