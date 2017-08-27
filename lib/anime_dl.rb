require "mechanize"
require "anime_dl/anime_heaven"
require "episode"
# Methods to get links in 'anime_dl/#{anime_site}.rb'

module AnimeDL
  class AnimeHeaven
    def initialize
      @agent = Mechanize.new
      @agent.user_agent_alias = 'Windows Chrome'
      @anime_page = nil
    end

    # Search
    def search(query)
      results_page = @agent.get("http://animeheaven.eu/search.php?q=#{query}")
      return results_page.search(".iepsan")
    end

    # Returns the total number of episodes
    def getTotal(option = nil)
      @anime_page = @agent.get(option.attributes['href'].value)  unless (@anime_page)
      episodes = @anime_page.search(".infoepbox").search("a")

      first = episodes.last.search(".infoept2")[0].content.to_i
      last = episodes.first.search(".infoept2")[0].content.to_i
      return first, last
    end


    # UTILITY
    def limit_exceeded(quiet)
      return  "Unfortunately \"animeheaven.eu\" only allows a certain number of page views per day.\n" +
              "It seems you have exceeded that limit :(.\n" +
              "Please change networks or try again in 24 hours."   if (!quiet)

      return  "(Limit exceeded)"
    end

  end

  # Download
  def self.download(path, episodes)
    episodes.each do |episode|
      if ( File.exists?( File.join( path, "Episode #{episode.number}.mp4" )) )
        puts "Skipping Episode #{episode.number} (already exists)"
        next
      else 
        puts "Downloading Episode #{episode.number}"
      end

      status = episode.download_to(path)
      return  if status == -1
    end
  end

  # Episode Range Handler
  def self.range_handle(range, first, last)
    temp = []

    range.each do |arg|
      # Basic REGEX match
      unless (arg.match(/\A[0-9]+\Z|\A[0-9]+\-[0-9l]+\Z/))
        puts "'#{arg}' is an invalid input for 'Episodes'"
        next
      end

      if (arg.include?("-"))
        f, l = arg.split("-").collect(&:to_i)
        l = last  if (arg[-1] == "l")

        next  unless (f && l)
        next  if f > last
        l = last  if l > last

        (f..l).each do |n|
          temp << n  if ( (first..last).include? n )
        end

      else
        temp << arg.to_i  if ( (first..last).include? arg.to_i )

      end
    end

    return temp.uniq.sort
  end

end