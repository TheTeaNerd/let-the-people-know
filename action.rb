# frozen_string_literal: true

require 'date'
require 'slack-notifier'
require 'yaml'

webhook = ENV.fetch('SLACK_WEBHOOK')
puts "Webhook is: '#{webhook}'"
event = ENV.fetch('GITHUB_EVENT_PATH')
puts "Event is: '#{event}'"

file = File.open(event)
puts "File is: '#{file}'"
parsed = YAML.safe_load(file)
puts "Parsed event is: '#{parsed}'"

puts 'Rejecting merge commits...'
commits = parsed.fetch('commits').reject do |commit|
  commit.fetch('message').start_with?('Merge pull request')
end
puts 'Done'
puts 'Rejecting Travis CI commits'
commits = commits.reject do |commit|
  commit.dig('author', 'name') == 'Travis CI'
end
puts 'Done'

if commits.empty?
  puts 'There are no commits!'
  return
end

puts 'Commits are:'
puts commits

repository_name = parsed.dig('repository', 'name')
                        .split('-')
                        .map(&:capitalize)
                        .join
repository_url = parsed.dig('repository', 'html_url')
announcement = <<~MARKUP
  *[#{repository_name}](#{repository_url}) has been updated!*

  _Changes_
MARKUP
commits.each do |commit|
  message_lines = commit.fetch('message')
                        .gsub(/\[no *ticket\]/i, '')
                        .gsub(/\[travis *skip\]/i, '')
                        .gsub(/\[ci *skip\]/i, '')
                        .lines
                        .map(&:strip)
  summary = message_lines.shift
  message_lines.shift # Discard the blank line between summary and details
  author = commit.dig('author', 'name')

  if ['dependabot-preview[bot]', 'dependabot[bot]'].include?(author)
    summary = message_lines.first.sub(/Bumps? /, ':hammer_and_wrench: Upgrades library ')
    announcement += "• #{summary} _(:robot_face: Dependabot)_\n"

    release_notes = message_lines.select { |line| line.match?('Release notes') }.first
    announcement += "> #{release_notes}\n" if release_notes

    change_log = message_lines.select { |line| line.match?('Changelog') }.first
    announcement += "> #{change_log}\n" if change_log
  else
    summary.gsub!(/#(\d+)/, "<#{repository_url}/issues/\\1|#\\1>")
    announcement += "• #{summary} _(#{author})_\n"
    message_lines.each { |line| announcement += "> #{line}\n" }
  end
end
announcement += "\n"

compare_url = parsed.fetch('compare')
announcement += "\n[Full changes](#{compare_url})"

puts 'Announcement for Slack:'
puts announcement
puts 'Sending to Slack'
notifier = Slack::Notifier.new(webhook)
notifier.ping announcement

puts
puts 'Done'
