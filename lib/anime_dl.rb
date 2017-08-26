require "mechanize"
require "anime_dl/version"
require "episode"

module AnimeDL
  class AnimeHeaven
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Windows Chrome'
    end

    # Search
    def search(query)
      results_page = @agent.get("http://animeheaven.eu/search.php?q=#{query}")
      return results_page.search(".iepsan")
    end

    # Video Links
    def getLinks(option, print = false)
      # Episode page links retrieval
      anime_page = @agent.get(option.attributes['href'].value)
      episode_links = anime_page.search(".infoepbox").search("a")
      episodes = []

      episode_links.each do |link|
        episode_page = @agent.get(link.attributes['href'].value)

        # Limit Check
        if (episode_page.search(".c").search("b").length != 0)
          episodes << Episode.new(nil, limit_exceeded)
          puts limit_exceeded  if print
          break
        end

        # Video Link Retrieval
        # (Regex for safety)
        episode_no = episode_page.uri.to_s[/e=.+/][-1]
        video_src = episode_page.search("script")[2].to_s[/src='http.*?'/][5...-1]

        episode = Episode.new(episode_no, video_src)
        episodes << episode
        puts video_src  if print
      end

      return episodes
    end

    # Download
    def download(episodes, print = false)
      episodes = getLinks(argument)   if argument.class == Nokogiri::XML::Element

      episodes.each do |episode|
        puts "Downloading Episode #{episode.number}"
        episode.download
      end
    end


    # UTILITY
    def limit_exceeded
      return  "Unfortunately \"animeheaven.eu\" only allows a certain number of page views per day.\n" +
              "It seems you have exceeded that limit :(.\n" +
              "Please try again in 24 hours.\n"
    end
  end
end