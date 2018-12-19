#!/usr/bin/env ruby
require 'net/http'
require 'ruby-progressbar'
require 'open-uri'
require 'resolv-replace'

# def download_to(link, path = ".")
#   url_base = link.split('/')[2]                    # Animeheaven
#   url_path = '/'+link.split('/')[3..-1].join('/')  # Sub Url
#   file_name = link.split[-1]
#   puts url_base, url_path, file_name

#   Net::HTTP.start(url_base) do |http|
#     response = http.request_head(URI.escape(url_path))
#     puts response
#     # progress_bar = ProgressBar.create(:progress_mark => "\#", :length => 80, :total => response['content-length'].to_i)
#     file = File.new( File.join( path, "#{file_name}.tmp" ), 'w')

#     begin
#       http.get(URI.escape(url_path)) do |str|
#         file.write(str)
#         # progress_bar.progress += str.length  rescue nil
#       end
#     rescue Exception
#       # Handle SystemExit or Interrupt
#       puts "Download incomplete. Deleting file.\n\n"
#       file.close
#       File.delete(File.join( path, "#{file_name}.tmp" ))
#       raise
#       exit
#     end

#     # progress_bar.finish
#     file.close
#     File.rename(file, File.join( path, file_name ))
#   end

#   puts "\n"
#   puts `ls -l`
#   puts "\n"
# end

# download_to("https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")

# exit

pbar = nil
open("https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
  :content_length_proc => lambda {|t|
    if t && 0 < t
      puts "Creating"
      pbar = ProgressBar.create(:progress_mark => "\#", :length => 80, :total => t)
    end
  },
  :progress_proc => lambda {|s|
    pbar.progress = s  if pbar
  }
) do |f|
    puts "Done"
  puts f
end
