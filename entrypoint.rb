require 'yaml'


puts '------------------------'
puts 'ENVIRONMENT: '
puts( ENV.map{ |k,v| "#{k} => #{v}" }.sort )
puts '------------------------'
puts

channel = ENV.fetch('SLACK_CHANNEL')
puts "Channel is #{channel}"
puts

webhook = ENV.fetch('SLACK_WEBHOOK')
puts "Channel is #{webhook}"
puts

event = ENV.fetch('GITHUB_EVENT_PATH')
puts "EVENT is #{event}"
puts

parsed = YAML.load(File.open(event))
puts "Repository is '#{parsed.dig('repository', 'name')}'"
puts
commits = parsed.fetch('commits')
puts "Commits are:"
simple_commits, merge_commits = commits.partition do |commit|
  commit.fetch('distinct') == false
end

simple_commits.each.with_index(1) do |commit, index|
  puts "#{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end
puts
puts

merge_commits.each.with_index(1) do |commit, index|
  puts "Merge #{index}. #{commit.fetch('message')} (_#{commit.dig('author', 'name')}_)"
end


notifier = Slack::Notifier.new(webhook) do
  defaults channel: "##{channel}"
           username: "Let the people know"
end
notifier.ping "Hello default"

puts
puts 'Done'
