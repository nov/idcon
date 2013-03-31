require 'restclient'
require 'json'
require 'active_support/all'

class Array
  def to_html
    <<-HTML
      <h2>Recent Events</h2>
      <div class="entry-content">
        <ul>
          #{collect(&:to_html).join}
        </ul>
      </div>
    HTML
  end
end

class Event
  class << self
    def all
      JSON.parse(
        RestClient.get('http://api.doorkeeper.jp/groups/idcon/events')
      ).collect do |event|
        new event.with_indifferent_access[:event]
      end
    end
  end

  attr_accessor :title, :hold_on, :starts_at, :venue, :public_url

  def initialize(attributes = {})
    self.title = attributes[:title]
    self.starts_at = Time.parse attributes[:starts_at]
    self.venue = attributes[:venue]
    self.public_url = attributes[:public_url]
    self.hold_on = self.starts_at.to_date
  end

  def to_html
    <<-HTML
      <li>
        <div class="meta">
          <a href="#{public_url}">
            <span class="date"><time>#{hold_on}</time></span>
            <span class="location">#{venue}</span>
          </a>
        </div>
        <h3 class="title"><a href="#{public_url}">#{title}</a></h3>
      </li>
    HTML
  end
end