require 'net/http'
require 'ruby-progressbar'

## TODO: Change Net::HTTP to OpenURI
module AnimeDL
  class Episode
    def initialize(episode_no, link)
      @number = episode_no
      @link = link
    end
    attr_reader :number, :link

    ##
    # Download video to path. Store in file_name
    # `file_name` generally of the form "Anime - Episode Number.mp4"
    # `status_print` is a callback to print progress or errors on the terminal
    ##
    def download(path, file_name, status_print)
      url_base = @link.split('/')[2]                    # Base Url
      url_path = '/'+@link.split('/')[3..-1].join('/')  # Path
      progress = {done: 0, total: 0}

      begin
        Net::HTTP.start(url_base) do |http|
          response = http.request_head(URI.escape(url_path))
          progress[:total] = response['content-length'].to_i
          file = File.new( File.join( path, "#{file_name}.tmp" ), 'w')

          begin
            http.get(URI.escape(url_path)) do |str|
              file.write(str)
              progress[:done] += str.length
              percentage_completion = (progress[:done].to_f / progress[:total].to_f) * 100
              content = "Episode #{@number} - #{percentage_completion.round(1)}%"
              status_print.call(content)
            end
          rescue Exception => e
            error_message = "Episode #{@number} download failed. #{e.message}"
            status_print.call(error_message)
            file.close
            File.delete(File.join( path, "#{file_name}.tmp" ))
            return
          end

          file.close
          File.rename(file, File.join( path, file_name ))
        end
      rescue => e # Net::OpenTimeout
        # FIX LATER
        status_print.call(e.message)
        return
      end

      content = "Episode #{@number} - 100% (complete)"
      status_print.call(content)
    end

    def details
      return "Episode #{@number}: #{@link}\n"
    end
  end
end