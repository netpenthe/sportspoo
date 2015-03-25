atom_feed :language => 'en-US' do |feed|
  feed.title "sportomate feed"
  feed.updated #{Time.now}

  @events.each do |item|

    feed.entry( item, :url => "") do |entry|
      entry.url "http://sportomate.com"
      entry.title "#{item.league} - #{item.display_name} starts in about 1 hour"

      # the strftime is needed to work with Google Reader.
      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 

      entry.author do |author|
        author.name "sportomate.com"
      end
    end
  end

end