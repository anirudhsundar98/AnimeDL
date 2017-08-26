class Episode
  def initialize(episode_no, link)
    @number = episode_no
    @link = link
  end
  attr_reader :number

  def download
    unless @number
      puts link
      return -1
    end

    open("#{@link}") do |video|
      file = File.new("Episode #{@number}.mp4", 'w')
      puts "Writing"
      file.write(video.read)
      file.close
    end
  end
end