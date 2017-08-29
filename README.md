# AnimeDL

<p align='center' style="width: 75%">
<img src='https://github.com/anirudhsundar98/AnimeDL/raw/master/fmab_anime_dl.jpg' alt='FMAB Stone'>
</p>

An app used to download anime episodes or get links to video sources of episodes without having to open your browser or go through annoying pop-up ads.

## Installation

Install the application with:

    $ gem install AnimeDL

and run `anime-dl` on the command line.  

<br>

To use this in a projext, add this line to your application's Gemfile:
```ruby
gem 'AnimeDL'
```

And then execute:

    $ bundle

<br>
(If nokogiri fails to install on a MacOS, check out http://www.nokogiri.org/tutorials/installing_nokogiri.html#mac_os_x)  


## Usage

On running the command the program prompts the user for a search query and prints a list of search results.  
On choosing a particular anime, the user can then choose to get links or download videos and choose which episodes to scrape.


#### Links:
 To output links to a file, provide the path to a file with '--file'.  
 If argument is a directory, a new text file will be created in that directory.
 If '--file' is not provided, links are printed on the command line.

#### Downloads: 
 To download videos to particular directory, specify the directory with '--file'.  
 If no directory is specified the videos are downloaded to ./anime_name/

### Example Usage:
  (If user chooses to scrape LINKS)  

    `$ anime-dl`                          - (outputs link urls on the terminal)]  
    `$ anime-dl -f path/to/filename.txt`  - (outputs link urls to './path/to/filename.txt')]  
    `$ anime-dl -f path/to/directory/`    - (outputs link urls to './path/to/directory/anime_name.txt')]  

  (If user chooses to DOWNLOAD videos)  

    `$ anime-dl`                          - (downloads videos to './anime_name/')]  
    `$ anime-dl -f .`                     - (downloads videos to './')]  
    `$ anime-dl -f /path/to/directory`    - (downloads videos to '/path/to/directory/anime_name/')]  
    `$ anime-dl -f /path/to/directory/`   - (downloads videos to '/path/to/directory/anime_name/')]  


### Specifying Episodes: 
When the '-a' option is not provided, the app asks for 'Episodes' after retrieving the user's anime choice.  
The user can provide induvidual space-seperated episodes.
The user can also provide multiple space-seperated ranges with each range having the format 'start-end'.  
Below are a few examples (assuming anime below has more than 18 episodes).  
    `Episodes: 2 4 5` - Retrieves details for episodes 2, 4 and 5  
    `Episodes: 4-8` - Retrieves details for episodes 4 to 8  
    `Episodes: 8-l` - Retrieves details for episodes 8 to the last episode  
    `Episodes: 2 9-13 18-l` - Retrieves details for episodes 2, 9 to 13 and 18 to end 

### Other options
Run `$ anime-dl -h` for the list of all options. 

## Limitations
The page being scraped from, "animeheaven.eu", only allows a certain number of page views per day (>170, <350).
Once that limit is exceeded, you will have to change networks or try again the next day.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
