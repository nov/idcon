require 'restclient'
require 'json'
require 'active_support/all'

class Array
  def to_html
    <<-HTML
      <h2>History</h2>
      <div class="entry-content">
        <ul>
          #{collect(&:to_html).join}
          {% include events_static.html %}
        </ul>
      </div>

      <script>
        $(function () {
          $('.event').each(function (index, event) {
            var today = new Date();
            var date = new Date($(event).data('date'));
            if (today <= date) {
              $(event).addClass('future');
            } else {
              $(event).addClass('past');
            }
          });
        })
      </script>
    HTML
  end
end

class Event
  class << self
    def all
      JSON.parse(
        RestClient.get('http://api.doorkeeper.jp/groups/idcon/events?since=1970-01-01')
      ).collect do |event|
        new event.with_indifferent_access[:event]
      end.sort_by(&:starts_at).reverse
    end
  end

  attr_accessor :title, :hold_on, :starts_at, :venue_name, :public_url

  def initialize(attributes = {})
    self.title = attributes[:title]
    self.starts_at = Time.parse attributes[:starts_at]
    self.venue_name = attributes[:venue_name]
    self.public_url = attributes[:public_url]
    self.hold_on = self.starts_at.to_date
  end

  def to_html
    <<-HTML
      <li class="event" data-date="#{hold_on}">
        <div class="meta">
          <a href="#{public_url}">
            <span class="date"><time>#{hold_on}</time></span>
            <span class="location">#{venue_name}</span>
          </a>
        </div>
        <h3 class="title"><a href="#{public_url}">#{title}</a></h3>
      </li>
    HTML
  end
end