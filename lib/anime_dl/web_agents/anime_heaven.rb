##
# As of December 25th, this site has closed.
# As a result, the code here is obsolete.
# Most of the code here was written with the knowledge of the site closing.
# As a result a lot of previous coded still exists here in a commented format
##

require "mechanize"
require "watir"
require "anime_dl/episode"

module AnimeDL
  class AnimeHeaven
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Windows Chrome'
      @browser = Watir::Browser.new(
        :chrome,
        :headless => true,
        :options => {:prefs => {:password_manager_enable => false, :credentials_enable_service => false}},
        :switches => ["disable-infobars", "no-sandbox"]
      )
      @previous_search_results = []
      @current_anime_page = nil
    end

    # Setter for `@current_anime_page` instance variable
    def set_current_anime_page(choice_number)
      user_choice = @previous_search_results[choice_number - 1]
      @current_anime_page = @agent.get(user_choice.attributes['href'].value)

      return @previous_search_results[choice_number - 1].text
    end

    # Search
    def search(query)
      results_page = @agent.get("http://animeheaven.eu/search.php?q=#{query}")
      @previous_search_results = results_page.search(".iepcon").search(".cona")
      print_search_results(@previous_search_results)
      return @previous_search_results.map do |result|
        result.text
      end
    end

    # Returns the first and last episode numbers of the current anime page (@current_anime_page)
    def getEpisodeNumberLimits
      episodes = @current_anime_page.search(".infoepbox").search("a")

      # New Episodes have a different class
      begin
        first = episodes.last.search(".infoept2")[0].content.to_i
      rescue
        first = episodes.last.search(".infoept2r")[0].content.to_i
      end
      begin
        last = episodes.first.search(".infoept2")[0].content.to_i
      rescue
        last = episodes.first.search(".infoept2r")[0].content.to_i
      end

      return first, last
    end

    # Setup before fetching links
    def run_pre_fetch_setup
      puts "\nNOTE: AnimeHeaven (the site being scraped from) has a feature called 'Abuse Protection' " +
           "that prevents users from spamming requests to their site. " +
           "This means that you may have to wait up to 2 minutes between batches of 3 episodes before the app is allowed " +
           "to get links again. Please give the app at least 2 minutes to fetch links before closing it.\n\n"
    end

    # Return the required page links which contain the episode video, based on user input
    def getPageLinks(episode_choices)
      page_links = @current_anime_page.search(".infoepbox").search("a").reverse
      return page_links  if (episode_choices.empty?)

      first_episode, last_episode = getEpisodeNumberLimits
      episode_numbers = AnimeDL.handle_range(episode_choices, first_episode, last_episode)

      episode_links = []
      episode_numbers.each { |num| episode_links << page_links[num - first_episode] }

      return episode_links.map do |link|
        url_string = URI.escape(link.attributes['href'].value)

        # Checks to see if link href is relative or absolute
        if (url_string.match("^https?:\/\/(.*)$"))
          url_string
        else
          "#{@current_anime_page.uri.scheme}://#{@current_anime_page.uri.host}/#{url_string}"
        end
      end
    end

    # Get video links for the current anime page (@current_anime_page)
    def fetchVideoLinks(range = [], callback)
      episode_page_links = getPageLinks(range)
      # episodes = []

      # Output flag is based on whether the user wants links printed on the command line
      # unless (output)
      #   puts "Fetching Links..."
      #   progress_bar = ProgressBar.create(:progress_mark => "\*", :length => 80, :total => episode_page_links.length)
      # end

      episode_page_links.each do |link|
        # episode_page = @agent.get(link.attributes['href'].value)
        begin
          begin
            @browser.goto(link)
          rescue
            retry
          end

          episode_no = @browser.url[/e=.+/][2..-1]                       # (Regex for safety)
          video_src = @browser.video.wait_until(&:present?).source.src   # (wait_until for future safety in case video loaded with ajax)

          # Video did not load. `src` attribute is blank
          if (video_src == @browser.url)
            # puts "...\n"
            raise "Abuse protection"
            # Handle the errors below
            # You have triggered abuse protection. Wait 60 seconds before continuing.
            # Daily page view limit exceeded. You were limited for opening high amount of pages from your network. Limit will be lifted after 24 hours.
            # puts limit_exceeded(quiet)  if (output)
          end
        rescue RuntimeError => e
          if (e.message == "Abuse protection")
            sleep 3
            @browser.div.click
            sleep 3
            @browser.windows.last.close  until (@browser.windows.length == 1)
            sleep 70
          end

          retry
        end


        # Limit Check
        # if (episode_page.search(".c").search("b").length != 0)
        #   episodes << Episode.new(nil, limit_exceeded(quiet))
        #   break
        # end

        # Video Link Retrieval

        episode = AnimeDL::Episode.new(episode_no, video_src)
        callback.call(episode)

        # Progress Bar increment
        # progress_bar.progress += 1  unless (output)  rescue nil

        # puts episode.details  if (output)
      end

      # Progress bar finish
      # unless output
      #   progress_bar.finish
      #   puts "\n"
      # end

      # return episodes
    end

    def close
      @browser.div.click
      sleep 3
      @browser.close
    end


    # UTILITY
    # Print given array of Nokogiri Elements in a particular format
    def print_search_results(results)
      puts "0. (Exit)\n"
      for i in 0...results.length do
        print i+1, ". ", results[i].text
        puts
      end

      puts "#{results.length + 1}. (Enter new Search Query)\n"
      print @prompts[:search]   if (results.length == 0)
      puts "\n\n"
    end

    def limit_exceeded(quiet)
      return  "Unfortunately \"animeheaven.eu\" only allows a certain number of page views per day (>170, <350).\n" +
              "It seems you have exceeded that limit :(.\n" +
              "Please change networks or try again tomorrow."   if (!quiet)

      return  "(Limit exceeded)"
    end
  end
end
