require "anime_dl/constants"
require "anime_dl/web_agents/anime_heaven"
require "anime_dl/user"
require "anime_dl/episode"

# Contains Utility methods for the AnimeDL module
module AnimeDL

  # Episode Range Handler
  def self.handle_range(episode_choices, first_episode, last_episode)
    episode_numbers_list = []

    episode_choices.each do |arg|
      # Basic REGEX match
      unless (arg.match(/\A[0-9]+\Z|\A[0-9]+\-[0-9l]+\Z/))
        puts "'#{arg}' is an invalid input for 'Episodes'"
        next
      end

      # Use to remove possible duplicates, nonexistant episodes and invalid inputs
      if (arg.include?("-"))
        first_in_arg, last_in_arg = arg.split("-").collect(&:to_i)
        last_in_arg = last_episode  if (arg[-1] == "l")

        next  unless (first_in_arg && last_in_arg)
        next  if first_in_arg > last_episode
        last_in_arg = last_episode  if (last_in_arg > last_episode)

        (first_in_arg..last_in_arg).each do |n|
          episode_numbers_list << n  if ((first_episode..last_episode).include? n)
        end
      else
        episode_number = -1
        if (arg == "l")
          episode_number = last_episode
        else
          episode_number = arg.to_i
        end

        episode_numbers_list << episode_number  if ( (first_episode..last_episode).include? episode_number )
      end
    end

    return episode_numbers_list.uniq.sort
  end

end
