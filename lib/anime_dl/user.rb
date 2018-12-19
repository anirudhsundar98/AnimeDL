require "fileutils"
require "anime_dl/constants"

module AnimeDL
  class User
    def initialize(options)
      @options = options
      @prompts = (options[:quiet]) ? AnimeDL::CONSTANTS[:quiet_user_prompts] : AnimeDL::CONSTANTS[:detailed_user_prompts]
      @anime_choice = nil
    end

    def initialize_download_variables
      # A hash mapping a episode number to another hash containing an episode object and a cursor position
      @episode_hash = {}

      # A queue of episode numbers to be downloaded
      @episode_queue = []

      # Threads
      @number_of_active_threads = 0
      @max_active_threads = 3

      @download_state = "idle"
      @no_of_episodes_handled = 0

      # Wait messages
      @wait_message_options = {
        busy: "Waiting for current episodes to finish downloading...",
        idle: "Waiting for more episodes..."
      }
      @current_wait_message_id = :idle

      # Cursor Position Related
      @cursor_position = 1
      @latest_episode_position = 0
    end

    attr_reader :prompts, :download_state

    # Setter for `@anime_choice`
    def set_anime_choice(choice)
      @anime_choice = choice
    end

    # Set idle wait_message_option.
    def set_idle_wait_message_option(idle_message)
      @wait_message_options[:idle] = idle_message
      print_wait_message
    end


    ## USER INPUT METHODS
    # Get user search query
    def get_search_query
      print "Enter Search Query: "
      return gets.strip.split(" ").join("+")
    end

    # Gets a number input corresponding to the results list
    def get_anime_choice(results_length)
      while true
        print "Choice: "
        input = gets.strip
        redo  unless (input_valid?(input.to_i, 0..(results_length + 1)) == 1)
        break
      end

      return input
    end

    # Get scrape option (links/downloads)
    def get_scrape_option
      puts @prompts[:scrape_option]
      while true
        print "Option (l/d): "
        @options[:scrape_option] = gets.strip
        redo  unless ( input_valid?(@options[:scrape_option], ['l', 'd', ""]) == 1 )

        break
      end

      @options[:scrape_option] = "d"  if (@options[:scrape_option] == "")
      initialize_download_variables  if (@options[:scrape_option] == "d")

      return @options[:scrape_option]
    end

    # Get the episode numbers and ranges that the user desires
    def get_episode_choices(first_episode, last_episode)
      puts "\n"
      print @prompts[:episodes]
      puts "\n"

      puts "Total number of Episodes - #{last_episode - first_episode + 1}  (#{first_episode}-#{last_episode})"
      print "Episodes: "
      return gets.strip
    end


    ## EPISODE HANDLING METHODS
    # Pre fetch setup method
    def run_pre_fetch_setup
      status = create_required_resources
      return -1  if (status == -1)

      if (@options[:scrape_option] == "d")
        puts "Starting Downloads"
        return
      end

      # If scrape option is 'links' and a file path is given
      if (@options[:file_path])
        puts "Writing To File"

        # Hyphens printed above and below anime name for aesthetic appeal
        hyphens = "---------------------------------------------------"
        if (@anime_choice.length + 5  >  hyphens.length)
          hyphens = "#{"-" * @anime_choice.length}-----"
        end

        # Write anime name to file
        File.open(@options[:file_path], "a+") do |file|
          file.write(hyphens + "\n")
          file.write(@anime_choice + "\n")
          file.write(hyphens + "\n")
        end
      end

      return 1
    end

    # Handle incoming episode
    def handle_episode(episode)
      if (@options[:scrape_option] == "l")
        get_episode_link(episode)
      else
        # Store episode details and call handle_download method
        @episode_queue << episode.number
        @latest_episode_position += 1
        @episode_hash[episode.number] = { episode: episode, position: @latest_episode_position }
        handle_episode_download
      end
    end

    # Handle episode if user wants links
    def get_episode_link(episode)
      if (@options[:file_path])
        # Write to file
        File.open( @options[:file_path], "a+" ) do |file|
          file.write(episode.details)
        end
      else
        puts episode.details
      end
    end

    # Handle episode if user wants to download files
    def handle_episode_download
      # Return if all threads are busy
      if (@number_of_active_threads >= @max_active_threads)
        @current_wait_message_id = :busy
        print_wait_message
        return
      end

      while true
        # Return if there are no episodes to be downloaded
        if (@episode_queue.length == 0)
          @download_state = "idle"  if (@number_of_active_threads == 0)
          @current_wait_message_id = :idle
          print_wait_message
          return
        end

        @download_state = "active"  if (@download_state == "idle")
        episode_number = @episode_queue.shift  # Get an episode from the queue
        advance_cursor_position

        # Skip episode if it already exists
        if (File.exists?( File.join(@options[:file_path], "#{@anime_choice} - Episode #{episode_number}.mp4") ))
          content = "\033[3m(Skipping Episode #{episode_number} - file already exists)\033[0m"
          update_episode_status(@episode_hash[episode_number][:position], content)

          # Done handling episode
          @episode_hash.delete(episode_number)
          redo  # Get another episode in queue
        end

        break  # Go to download
      end

      @number_of_active_threads += 1
      download_episode(episode_number)
    end

    ##
    # Reposition cursor and add space for new episode's status
    # Check the block comment above `User#upddate_episode_status`
    ##
    def advance_cursor_position
      print "\033[K\n"
      print_wait_message
      @cursor_position += 1
      @no_of_episodes_handled += 1
    end

    def print_wait_message
      wait_message = @wait_message_options[@current_wait_message_id]
      clear = "\033[K"
      content =  "\033[3m#{wait_message}\033[0m"
      inline_reset = "\033[#{wait_message.length}D"
      print "#{clear}#{content}#{inline_reset}"
    end

    # Download episode in a new thread
    def download_episode(episode_number)
      Thread.new do
        required_episode = @episode_hash[episode_number][:episode]
        
        # Callback to update progress/status on terminal
        update_callback = lambda do |content|
          episode_position = @episode_hash[episode_number][:position]

          # Shift episode forward if it is lagging
          if (@cursor_position - episode_position > @max_active_threads * 2)
            @episode_hash[episode_number][:position] = @cursor_position
            shift_content_message = "\033[3m(Episode #{episode_number} shifted down)\033[0m"
            update_episode_status(episode_position, shift_content_message)
            advance_cursor_position
            return
          end

          update_episode_status(episode_position, content)
        end

        # Download episode
        file_name = "#{@anime_choice} - Episode #{episode_number}.mp4" 
        required_episode.download(@options[:file_path], file_name, update_callback)

        # Download complete
        @number_of_active_threads -= 1
        @episode_hash.delete(episode_number)
        handle_episode_download
      end
    end

    ##
    # Current Design for cursor positioning:
    #   Cursor is placed at the lowest line, below the most recent episode.
    #   When an episode needs to be updated, the cursor shifts upward to that episode,
    #   updates the progress and moves back down to its original position.
    #   When a new episode starts downloading, the cursor shift down one line
    ##
    # Shifts the cursor to the episode position, updates content and shifts back to neutral postion.
    def update_episode_status(episode_position, content)
      shift_amount = @cursor_position - episode_position
      shift_string = "\033[#{shift_amount.abs}"
      inline_reset = "\033[#{content.length}D"
      erase_to_eol = "\033[K"

      if (shift_amount > 0)
        print "#{shift_string}A#{erase_to_eol}#{content}#{shift_string}B#{inline_reset}"
      end
    end

    # Cleanup only if user wanted links printed to a file
    def run_post_fetch_cleanup
      return  unless (@options[:scrape_option] == "l" && @options[:file_path] != nil)

      File.open( @options[:file_path], "a+" ) do |file|
        file.write("\n\n")
      end
    end


    ## RESOURCE CREATION RELATED
    # Used to create new directories and/or files if required
    def create_required_resources
      begin
        # Note - `create_for_links` will never intentionally fail.
        #        Only `create_for_downloads` will fail and return -1
        #        when the path given is not a valid directory.
        return (@options[:scrape_option] == "l") ? create_resources_for_links : create_resources_for_downloads
      rescue => error
        puts "\nDirectory creation failed."
        puts error
        return -1
      end

      return 1
    end

    # Creation when scrape_option `links` is selected
    def create_resources_for_links
      # Return if File option is not provided
      return 1  if (@options[:file_path] == nil)

      # Return if argument is a file that exists
      if ( File.exists?(@options[:file_path]) && File.file?(@options[:file_path]))
        return 1
      end

      # Provided option is a directory
      if ( @options[:file_path][-1] == "/" || File.directory?(@options[:file_path]) )
        # Create directory if it doesn't exist
        create_directory(@options[:file_path])

        # Update file path with new text file name
        file_name = "Anime Episode Links.txt"
        @options[:file_path] = File.join(@options[:file_path], file_name)

        # Create the file if it doesn't exist
        create_file(@options[:file_path], file_name)
        return 1
      end
 
      # Provided option is a file that needs to be created.
      parent_directory, file_name = File.split(@options[:file_path])
      create_directory(parent_directory)
      create_file(@options[:file_path], file_name)
    end

    # Creation when scrape_option `downloads` is selected
    def create_resources_for_downloads
      puts "\n"

      # If file argument is not provided create "./#{@anime_choice}"
      if (@options[:file_path] == nil)
        abs_file_path = File.join(Dir.pwd, @anime_choice)
        create_directory(abs_file_path)

        # Set file path
        @options[:file_path] = abs_file_path
        return 1
      end

      # Argument must be a directory and not a file
      if ( File.file?(@options[:file_path]) )
        puts "ERROR: Argument provided to `--file` is not a directory"
        puts "For the option 'download', argument to `--file` must be a directory"
        return -1
      end

      # Create directory if it doesn't exist
      create_directory(@options[:file_path])
      return 1  # Creation Success
    end

    # Utility functions for creating resources
    def create_directory(directory_path)
      return  if (File.exists?(directory_path))

      puts "Creating directory '#{directory_path}'"
      FileUtils.mkdir_p(directory_path)
    end

    def create_file(file_path, file_name)
      return  if (File.exists?(file_path))

      parent_directory = File.split(file_path)[0]
      puts "Creating file '#{file_name}' in directory '#{parent_directory}'"
      File.new(file_path, "a+").close
    end


    ## OTHER UTILITY
    # Check if given input is valid
    def input_valid?(input, options)
      return 1  if (options.include? input)
      puts "Invalid input.\n\n"
    end
  end
end
