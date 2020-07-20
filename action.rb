# frozen_string_literal: true

require 'date'
require 'slack-notifier'
require 'yaml'

webhook = ENV.fetch('SLACK_WEBHOOK')
event = ENV.fetch('GITHUB_EVENT_PATH')

parsed = YAML.safe_load(File.open(event))
commits = parsed.fetch('commits').reject do |commit|
  commit.fetch('message').start_with?('Merge pull request')
end
commits = commits.reject do |commit|
  commit.dig('author', 'name') == 'Travis CI'
end

return if commits.empty?

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

  if author == 'dependabot-preview[bot]'
    summary = message_lines.first.sub('Bumps ', 'Upgrades library ')
    announcement += "• #{summary} _(:robot_face: Dependabot)_\n"

    release_notes = message_lines.select { |line| line.match?('Release notes') }
    if release_notes
      announcement += "> #{release_notes}\n"
    end

    change_log = message_lines.select { |line| line.match?('Changelog') }
    if change_log
      announcement += "> #{change_log}\n"
    end
  else
    summary.gsub(/#(\d+)/, "[#\\1](#{repository_url}/issues/\\1)")
    announcement += "• #{summary} _(#{author})_\n"
    message_lines.each { |line| announcement += "> #{line}\n" }
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
