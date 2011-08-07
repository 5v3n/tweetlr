# tweetlr

tweetlr crawls twitter for a given term, extracts photos out of the collected tweets' short urls and posts the images to tumblr. 

<a href="http://travis-ci.org/#!/5v3n/tweetlr">![travis-ci](http://travis-ci.org/5v3n/tweetlr.png)</a>

## Supported image sharing services

tweetlr supports

- instagram
- picplz
- twitpic
- yfrog
- imgly
- lockerz / the service formerly known as plixi
- foursquare
- t.co shortened links to pictures
- every service accessible via embed.ly (see [photo providers](http://embed.ly/providers))

## Installation

Use `gem install tweetlr` if you're using *rubygems* or add the line `gem 'tweetlr'` to your `Gemfile` if you're using *bundler*.

## Configuration

It's essential that you have a directory called `config` in the directory you are starting tweetlr in, which has to contain the configuration file `tweetlr.yml`:

```yaml
results_per_page: 100
result_type: recent
search_term: 'cat+dog+unicorn' #find tweets containing any of these terms
start_at_tweet_id: 61847783463854082 # the tweet id to start searching at
api_endpoint_twitter: 'http://search.twitter.com/search.json'
api_endpoint_tumblr: 'http://www.tumblr.com'
tumblr_username: YOUR_TUMBLR_EMAIL
tumblr_password: YOUR_TUMBLR_PW
update_period: 300 #check for updates every 300 secs = 5 minutes
shouts: 'says' # will be concatenated after the username, before the message: @mr_x says: awesome things on a photo!
loglevel: 1 # 0: debug, 1: info (default), 2: warn, 3: error, 5: fatal
whitelist: #twitter accounts in that list will have their tweets published immediately. post from others will be saved as drafts
  - whitey_mc_whitelist
  - sven_kr
```

## Usage

Make sure you put the configuration file in it's proper place as mentioned above, then: 

start/stop tweetlr using `tweetlr start`/`tweetlr stop`. Run `tweetlr` without arguments for a list of options concerning the daemon's options. 

For a easy to modify working example, check out the [tweetlr_demo](http://github.com/5v3n/tweetlr_demo).

Enjoy!

