# frozen_string_literal: true

require 'date'
require 'slack-notifier'
require 'yaml'

puts '------------------------'
puts 'ENVIRONMENT: '
puts(ENV.map { |k, v| "#{k} => #{v}" }.sort)
puts '------------------------'
puts

webhook = ENV.fetch('SLACK_WEBHOOK')
event = ENV.fetch('GITHUB_EVENT_PATH')

parsed = YAML.safe_load(File.open(event))
puts 'Event is:'
puts parsed
puts
puts

commits = parsed.fetch('commits')
                .reject do |commit|
                  commit.fetch('message').start_with?('Merge pull request')
                end.reject do |commit|
                  commit.dig('author', 'name') == 'Travis CI'
                end

return if commits.empty?

repository_name = parsed.dig('repository', 'name')
                        .split('-')
                        .map(&:capitalize)
                        .join
repository_url = parsed.dig('repository', 'html_url')
announcement = "*[#{repository_name}](#{repository_url}) has been updated!*\n\n_Changes_\n"
commits.each do |commit|
  message_lines = commit.fetch('message')
                        .gsub(/\[no *ticket\]/i, '')
                        .gsub(/\[travis *skip\]/i, '')
                        .gsub(/\[ci *skip\]/i, '')
                        .lines
                        .map(&:strip)
  summary = message_lines.shift
  message_lines.shift # Discard the blank line between summary and details

  announcement += "• #{summary} _(#{commit.dig('author', 'name')})_\n"

  next if message_lines.empty?

  message_lines.each do |line|
    announcement += "> #{line}\n"
  end
end
announcement += "\n"

compare_url = parsed.fetch('compare')
announcement += "\n[Full changes](#{compare_url})"

puts 'Sending to Slack'
puts announcement
notifier = Slack::Notifier.new(webhook)
notifier.ping announcement

puts
puts 'Done'
