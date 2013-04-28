# tweetlr

<a href="http://travis-ci.org/#!/5v3n/tweetlr">![travis-ci](https://api.travis-ci.org/5v3n/tweetlr.png?branch=master)</a>

tweetlr crawls twitter for a given term, extracts photos out of the collected tweets' short urls and posts the images to tumblr. 

There is a new [tweetlr "as-a-service"](http://tweetlr.5v3n.com) where you can easily create an account without having to know or host anything.

## Supported image sharing services

tweetlr supports

- instagram
- twitter
  - photobucket
  - twimg
- foursquare
- path.com
- twitpic
- yfrog
- imgly
- eyeem.com
- t.co shortened links to pictures
- every photo service accessible via embed.ly (see [photo providers](http://embed.ly/providers))


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
tumblr_oauth_api_key: YOUR APPS TUMBLR API TOKEN
tumblr_oauth_api_secret: YOUR APPS TUMBLR API SECRET
tumblr_oauth_access_token_key: YOUR BLOGS OAUTH ACCESS TOKEN KEY
tumblr_oauth_access_token_secret: YOUR BLOGS OAUTH ACCESS TOKEN SECRE
tumblr_blog_hostname: YOUR BLOGS HOSTNAME #e.g. myblog.tumblr.com
embedly_key: '' #tweetlr uses http://embedly.com for link processing. a free plan containing an api key is available & recommended to use in order to ensure full support
update_period: 300 #check for updates every 300 secs = 5 minutes
shouts: 'says' # will be concatenated after the username, before the message: @mr_x says: awesome things on a photo!
loglevel: 1 # 0: debug, 1: info (default), 2: warn, 3: error, 5: fatal
whitelist: #twitter accounts in that list will have their tweets published immediately. post from others will be saved as drafts. blank list will publish all tweets immediately
  - whitey_mc_whitelist
  - sven_kr
```

## Usage

Make sure you put the configuration file in it's proper place as mentioned above, then: 

start/stop tweetlr using `tweetlr start`/`tweetlr stop`. Run `tweetlr` without arguments for a list of options concerning the daemon's options.

For a easy to modify working example, check out the [tweetlr_demo](http://github.com/5v3n/tweetlr_demo).

Enjoy!

