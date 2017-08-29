require 'net/http'
require 'ruby-progressbar'

class Episode
  def initialize(episode_no, link)
    @number = episode_no
    @link = link
  end
  attr_reader :number, :link

  def download_to(path = ".")
    url_base = @link.split('/')[2]
    url_path = '/'+@link.split('/')[3..-1].join('/')

    Net::HTTP.start(url_base) do |http|
      response = http.request_head(URI.escape(url_path))
      progress_bar = ProgressBar.create(:progress_mark => "\#", :length => 80, :total => response['content-length'].to_i)
      file = File.new( File.join( path, "Episode #{@number}.mp4" ), 'w')

      begin
        http.get(URI.escape(url_path)) do |str|
          file.write(str)

          begin
            progress_bar.progress += str.length
          rescue
            # Bypass InvalidProgressBar Error if raised
          end
        end
      rescue Exception
        # Handle SystemExit or Interrupt
        puts "Download incomplete. Deleting file."
        File.delete(File.join( path, "Episode #{@number}.mp4" ))
        raise
        exit
      end

      progress_bar.finish
    end

    puts "\n"
  end

  def details
    return "Episode #{@number}: #{@link}\n"
  end
end
