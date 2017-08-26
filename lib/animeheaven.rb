require "mechanize"
require "open-uri"

agent = Mechanize.new
agent.user_agent_alias = 'Windows Chrome'
# agent.log = Logger.new "mech.log"

print "Enter Search Query: "
search_query = gets.strip.split(" ").join("+")
puts "\n"
results_page = agent.get("http://animeheaven.eu/search.php?q=#{search_query}")
results = results_page.search(".iepsan")

for i in 0...results.length do
  print i+1, ". ", results[i].text
  puts
end
puts "\n"

puts "Enter your choice (Hit Enter(empty choice) to Exit)"
print "Choice? : "
choice = results[gets.strip.to_i - 1]
puts "Choice: " + choice.content + "\n\n"
anime_page = agent.get(choice.attributes['href'].value)

episode_links = anime_page.search(".infoepbox").search("a")
episode_links.each do |episode|
  episode_page = agent.get(episode.attributes['href'].value)

  if (episode_page.search(".c").search("b").length != 0)
    puts "Fuck"
    break
  end

  video_src = episode_page.search("script")[2].to_s[/src='http.*?'/][5...-1]
  puts video_src

  # DOWNLOAD
  # open("#{video_src}") do |video|
  #   file = File.new("Episode 1.mp4", 'w')
  #   puts "Writing"
  #   file.write(video.read)
  #   file.close
  # end
end

# link.click   -- gets next page
