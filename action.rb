# frozen_string_literal: true

require 'date'
require 'pry'
require 'slack-notifier'
require 'yaml'

def pretty_print(hash)
  Pry::ColorPrinter.pp(hash)
end

def parse_event
  event_path = ENV.fetch('GITHUB_EVENT_PATH')
  file = File.open(event_path)
  parsed_event = YAML.safe_load(file)
  puts 'GitHub event is:'
  pretty_print(parsed_event)
  parsed_event
end

def meaningful_commits(parsed_event)
  parsed_event.fetch('commits').reject do |commit|
    commit.fetch('message').start_with?('Merge pull request')
  end.reject do |commit|
    commit.dig('author', 'name') == 'Travis CI'
  end
end

def section(text)
  {
    type: :section,
    text: {
      type: :mrkdwn,
      text: text
    }
  }
end

webhook = ENV.fetch('SLACK_WEBHOOK')
if webhook.nil?
  warn 'Error: SLACK_WEBHOOK is not configured.'
  return
end

parsed_event = parse_event
commits = meaningful_commits(parsed_event)

if commits.empty?
  puts 'Nothing to do, there are no commits!'
  return
else
  puts 'Commits are:'
  pretty_print(commits)
end

pretty_date = DateTime.now.strftime('%A %B %d, %Y')
repository_name = parsed_event.dig('repository', 'name')
repository_url = parsed_event.dig('repository', 'html_url')
compare_url = parsed_event.fetch('compare')

header = "*A new version of <#{repository_url}|#{repository_name}> has been released!*\n<#{compare_url}|See commits :octocat:>"

changelog_intro = if commits.one?
                    'The only change is:'
                  else
                    "The #{commits.size} individual changes are:"
                  end

blocks = []
blocks << section(pretty_date)
blocks << section(header)
blocks << section(changelog_intro)

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
  change = nil

  if ['dependabot-preview[bot]', 'dependabot[bot]'].include?(author)
    summary = message_lines.first.sub(/Bumps? /, ':hammer_and_wrench: Upgrades library ')
    change = "#{summary} _(:robot_face: Dependabot)_\n"

    release_notes = message_lines.select { |line| line.match?('Release notes') }.first
    change += "> #{release_notes}\n" if release_notes

    change_log = message_lines.select { |line| line.match?('Changelog') }.first
    change += "> #{change_log}\n" if change_log
  else
    summary.gsub!(/#(\d+)/, "<#{repository_url}/issues/\\1|#\\1>")
    change = "#{summary} _(#{author})_\n"
    message_lines.each { |line| change += "> #{line}\n" }
  end
  blocks << section(change)
end

puts "\n\nBlocks:\n"
pretty_print(blocks)

puts 'Notifying Slack'
notifier = Slack::Notifier.new(webhook)

notifier.post(blocks: blocks)

puts 'Done'
