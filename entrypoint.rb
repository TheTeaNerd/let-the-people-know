require 'yaml'


puts '------------------------'
puts 'ENVIRONMENT: '
puts( ENV.map{ |k,v| "#{k} => #{v}" }.sort )
puts '------------------------'
puts

channel = ENV.fetch('SLACK_CHANNEL')
puts 'Channel is #{channel}'
puts

webhook = ENV.fetch('SLACK_WEBHOOK')
puts 'Channel is #{webhook}'
puts

event = ENV.fetch('GITHUB_EVENT_PATH')
puts "EVENT is #{event}"
puts

parsed = YAML.load(File.open(event))
puts "Repository is '#{parsed.dig('repository', 'name')}'"
puts
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

puts
puts 'Done'
