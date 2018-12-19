module AnimeDL
  CONSTANTS = {
    detailed_user_prompts: {
      quiet: "(Note: Run app with '-q' or '--quiet' to suppress help messages)\n(Run anime-dl -h for more options)\n\n",
      scrape_option: "\nShould the app get links or download episodes? (Empty response will download episodes)\n",
      search: "\nNo Results Found. Please check your search query.\n",
      episodes: "\nEnter the desired episodes.\nYou can provide individual space-seperated episodes.\n" +
                "Or you can also provide multiple space-seperated ranges with each range having the format 'start-end'.\n" +
                "Examples (assuming anime below has more than 18 episodes):\n" +
                "    `Episodes: 2 4 5` - Retrieves details for episodes 2, 4 and 5\n" +
                "    `Episodes: 5 l` - Retrieves details for 5th and last episodes\n" +
                "    `Episodes: 4-7` - Retrieves details for episodes 4, 5, 6 and 7\n" +
                "    `Episodes: 8-l` - Retrieves details for episodes 8 to the last episode\n" +
                "    `Episodes: 2 9-11 18-l` - Retrieves details for episodes 2, 9, 10, 11 and 18 to the end\n" +
                "(Running app with '-a' or '--all' will automatically retrieve all episodes)\n" +
                "(Enter empty response to get all episodes or '-1' to exit)\n\n"
    },
    quiet_user_prompts: {
      quiet: nil,
      scrape_option: "\nLinks/Downloads?\n",
      search: "No Results Found.\n",
      episodes: "\nSelect Episodes. (Empty response gets all episodes, '-1' exits).\n"
    }
  }
end
