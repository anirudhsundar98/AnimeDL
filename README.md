# AnimeDL

<p align='center' style="width: 75%">
<img src='https://github.com/anirudhsundar98/AnimeDL/raw/master/fmab_anime_dl.jpg' alt='FMAB Stone'>
</p>

An app used to download anime episodes or get links to video sources of episodes without having to open your browser or go through annoying pop-up ads.

## Installation


Install the application with:

    $ gem install AnimeDL


<br>

To use this in a projext, add this line to your application's Gemfile:
```ruby
gem 'AnimeDL'
```

And then execute:

    $ bundle


## Usage

On running the command the program prompts the user for a search query and prints a list of search results.  
The user can then choose a particular anime.  Details for all episodes are scraped.  
To select particular episodes call the app with the '-e' option.


#### Links:
 To output links to a file, provide the path to a file as the last argument.  
 If argument is a directory, a new text file will be created in that directory.

#### Downloads: 
To download videos to particular directory, specify the directory as the last argument.  
If no directory is specified the videos are downloaded to ./anime_name/

### Examples:
    `$ anime_dl`                                        - (outputs link urls on the terminal)    
    `$ anime_dl -f rel/path/to/filename.txt`            - (outputs link urls to 'rel/path/to/filename.txt')  
    `$ anime_dl -o link -f rel/path/to/directory/`      - (outputs link urls to 'rel/path/to/directory/anime\_name.txt')  
    `$ anime_dl -o download`                            - (downloads videos to './anime\_name/')  
    `$ anime_dl -o download -f .`                       - (downloads videos to './')  
    `$ anime_dl -o d -f /abs/path/to/directory`         - (downloads videos to '/abs/path/to/directory/anime\_name/')  
    `$ anime_dl -o download -f /abs/path/to/directory/` - (downloads videos to '/abs/path/to/directory/anime\_name/')   

### Example App Usage:
```
$ anime_dl -q
    Enter Search Query: fullmetal alchemist b

    0. (Exit)
    1. Fullmetal Alchemist Brotherhood Dubbed | Hagane no Renkinjutsushi (2009) Dubbed
    2. Fullmetal Alchemist Brotherhood | Hagane no Renkinjutsushi (2009)
    3. (Enter new Search Query)

    Choice: 4

    (Empty response gets all episodes, '-1' exits)

    Total number of Episodes - 64  (1-64)
    Episodes: -1
```


### Specifying Episodes: 
When the '-a' option is not provided, the app asks for 'Episodes' after retrieving the user's anime choice.  
The user can provide induvidual space-seperated episodes.
The user can also provide multiple space-seperated ranges with each range having the format 'start-end'.  
Below are a few examples (assuming anime has more than 18 episodes).  
    `Episodes: 2 4 5` - Retrieves details for episodes 2, 4 and 5  
    `Episodes: 4-8` - Retrieves details for episodes 4 to 8  
    `Episodes: 8-l` - Retrieves details for episodes 8 to the last episode  
    `Episodes: 2 9-13 18-l` - Retrieves details for episodes 2, 9 to 13 and 18 to end 

### Other options
Run `$ anime_dl -h` for the list of all options. 

## Limitations
The page being scraped from, "animeheaven.eu", only allows a certain number of page views per day (>150, <300).
Once that limit is exceeded, you will have to change networks or try again in 24 hours.



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
