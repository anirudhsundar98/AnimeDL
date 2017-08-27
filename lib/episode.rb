require "open-uri"

class Episode
  def initialize(episode_no, link)
    @number = episode_no
    @link = link
  end
  attr_reader :number, :link

  def download_to(path = ".")
    # Limit Check
    unless @number
      puts @link
      return -1
    end

    open("#{@link}") do |video|
      file = File.new( File.join( path, "Episode #{@number}.mp4" ), 'w')
      puts "Writing"
      file.write(video.read)
      file.close
    end

    return 1
  end

  def details
    return "Episode #{@number}: #{@link}\n"
  end
end
