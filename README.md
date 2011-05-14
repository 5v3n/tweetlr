# tweetlr

tweetlr crawls twitter for a given term, extracts photos out of the collected tweets' short urls and posts the images to tumblr. 

## Installation

Use `gem install tweetlr` if you're using *rubygems* or add the line `gem 'tweetlr'` to your `Gemfile` if you're using *bundler*.

## Configuration

It's essential that you have a directory called `config` in the directory you are starting tweetlr in, which has to contain the configuration file `tweetlr.yml`:

```yaml
    results_per_page: 100
    result_type: recent
    search_term: <the term you want to search for>
    twitter_timestamp: 61847783463854082 # the timestamp you want to start searching at
    api_endpoint_twitter: 'http://search.twitter.com/search.json'
    api_endpoint_tumblr: 'http://www.tumblr.com'
    tumblr_username: <your tumblr username / e-mail address>
    tumblr_password: <your tumblr password>
    update_period: 300 #check for updates every 300 secs = 5 minutes
    shouts: 'says' # will be concatenated after the username, before the message: @mr_x <shouts>: awesome things on a photo!
    whitelist: #twitter accounts in that list will have their tweets published immediately. post from others will be saved as drafts
      - whitey_mc_whitelist
      - sven_kr
```

## Usage

Make sure you put the configuration file in it's proper place as mentioned above, then: 

start/stop tweetlr using `tweetlr start`/`tweetlr stop`. Run `tweetlr` without arguments for a list of options concerning the daemon's options. 

For further details on the configuration part, check out the [tweetlr_demo](http://github.com/5v3n/tweetlr_demo).

Enjoy!

