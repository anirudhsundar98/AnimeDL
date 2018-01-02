module AnimeDL
  class AnimeHeaven

    # Return the required page links based on user input
    def getPageLinks(option, range)
      @anime_page = @agent.get(option.attributes['href'].value)  unless (@anime_page)
      page_links = @anime_page.search(".infoepbox").search("a").reverse
      return page_links  if range.empty?

      links_required = []
      first, last = getTotal(option)
      range = AnimeDL.range_handle(range, first, last)
      range.each { |num| links_required << page_links[num - first] }

      return links_required
    end

    # Video Links
    def getVideoLinks(option, range = [], quiet = false, output = false)
      episode_links = getPageLinks(option, range)
      episodes = []

      unless (output)
        puts "Fetching Links..."
        progress_bar = ProgressBar.create(:progress_mark => "\*", :length => 80, :total => episode_links.length)
      end

      episode_links.each do |link|
        episode_page = @agent.get(link.attributes['href'].value)

        # Limit Check
        if (episode_page.search(".c").search("b").length != 0)
          episodes << Episode.new(nil, limit_exceeded(quiet))
          puts limit_exceeded(quiet)  if (output)
          break
        end

        # Video Link Retrieval
        episode_no = episode_page.uri.to_s[/e=.+/][2..-1]    # (Regex for safety)
        video_src = parseURL(episode_page.search("script")[3])

        episode = Episode.new(episode_no, video_src)
        episodes << episode

        # Progress Bar increment
        progress_bar.progress += 1  unless (output)  rescue nil

        puts episode.details  if (output)
      end

      # Progress bar finish
      unless output
        progress_bar.finish
        puts "\n"
      end

      return episodes
    end

  end
end