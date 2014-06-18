#encoding: utf-8

if ENV['RACK_ENV']=='test'
  require 'coveralls'
  Coveralls.wear!
elsif ENV['RACK_ENV']=='development'
  require 'simplecov'
  SimpleCov.start
end

require "bundler"
require "logger"
require "yaml"
require 'fakeweb'
require "#{File.dirname(__FILE__)}/../lib/tweetlr"


Bundler.require :default, :development, :test

logger = Logger.new('/dev/null')
Tweetlr::LogAware.log = logger

TWEETLR_CONFIG_FILE = 'tweetlr.yml'

FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https?://coveralls.io/api/v1/jobs]
twitter_search_api_response = File.open("#{File.dirname(__FILE__)}/support/fixtures/twitter_search_api_response.json", 'rb') { |file| file.read }
FakeWeb.register_uri(:get, %r|https://api.twitter.com/1.1/search/tweets.json|, :response => twitter_search_api_response)
FakeWeb.register_uri(:post, "https://@api.twitter.com/oauth2/token", response: Net::HTTPCreated.new("Created.", "201", true))
def check_pic_url_extraction(service)
  image_url = Tweetlr::Processors::PhotoService.find_image_url @links[service]
  (image_url =~ Tweetlr::Processors::PhotoService::PIC_REGEXP).should be, "service #{service} not working, no picture extracted!"
end

def stub_oauth
  OAuth::AccessToken.any_instance.stub(:post).and_return(Net::HTTPCreated.new("Created.", "201", true))
end

def stub_tumblr
  Curl::Easy.any_instance.stub(:response_code).and_return 201
  Curl::Easy.any_instance.stub(:header_str).and_return %|HTTP/1.1 201 Created
Date: Sun, 13 Nov 2011 16:56:02 GMT
Server: Apache
P3P: CP="ALL ADM DEV PSAi COM OUR OTRo STP IND ONL"
Vary: Accept-Encoding
X-Tumblr-Usec: D=2600406
Content-Length: 11
Connection: close
Content-Type: text/plain; charset=utf-8

|
  Curl::Easy.any_instance.stub(:body_str).and_return %|12742797055|
  Curl::Easy.stub!(:http_post).and_return Curl::Easy.new
  stub_instagram
end

def stub_twimg
  Curl::Easy.any_instance.stub(:body_str).and_return %|<div class="js-tweet-details-fixer tweet-details-fixer">



        <div class="cards-media-container "><div data-card-url="//twitter.com/KSilbereisen/status/228035435237097472/photo/1/large" data-card-type="photo" class="cards-base cards-multimedia" data-element-context="platform_photo_card">
  <div class="media">
    
    <a class="twitter-timeline-link media-thumbnail" href="//twitter.com/KSilbereisen/status/228035435237097472/photo/1/large" data-url="https://pbs.twimg.com/media/AyolBSnCQAA0vdp.jpg:large" data-resolved-url-large="https://pbs.twimg.com/media/AyolBSnCQAA0vdp.jpg:large">
      <img src="https://pbs.twimg.com/media/AyolBSnCQAA0vdp.jpg" alt="Embedded image permalink" width="281" height="375">
    </a>
  </div>
  <div class="cards-content">
    <div class="byline">
      
    </div>
    
  </div>
  
</div>



</div>

  <div class="js-tweet-media-container "></div>

  <div class="js-machine-translated-tweet-container"></div>
  <div class="js-tweet-stats-container tweet-stats-container ">
  </div>
  <div class="client-and-actions">
    <span class="metadata">
      <span title="9:54 AM - 25 Jul 12">9:54 AM - 25 Jul 12</span>

      



      

          <span class="flag-container flag-cards">
  <button type="button" class="flaggable btn-link">
    Flag media
  </button>
  <span class="flagged hidden">
    Flagged
    <span>
      <a target="_blank" href="//support.twitter.com/articles/20069937">
        (learn more)
      </a>
    </span>
  </span>
</span>
          
          

    </span>
  </div>
</div>|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_twitter_pics
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"url": "http://pic.twitter.com/stubbedpic.jpg:large"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_instagram
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"provider_url": "http://instagram.com/", "title": "Curse you tweets. See what you have done to me?!!!", "url": "http://distillery.s3.amazonaws.com/media/2011/05/02/d25df62b9cec4a138967a3ad027d055b_7.jpg", "author_name": "loswhit", "height": 612, "width": 612, "version": "1.0", "author_url": "http://instagram.com/", "provider_name": "Instagram", "type": "photo"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

#instagram syntax but without a valid image link
def stub_no_image_link
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"url":"http://noimageurl"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_bad_request
  Curl::Easy.any_instance.stub(:body_str).and_return %|<html><title>400: Bad Request - Invalid URL format http://mopskopf</title><body>400: Bad Request - Invalid URL format http://mopskopf</body></html>|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_utf8_response
  Curl::Easy.any_instance.stub(:body_str).and_return %|√∫ƒ® are inhabitänts of utf-8 wonderländ.|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_yfrog
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"version":"1.0","provider_name":"yFrog","provider_url":"http:\/\/yfrog.com","thumbnail_url":"http:\/\/yfrog.com\/h4vlfp:small","width":1210,"height":894,"type":"image","url":"http:\/\/img616.yfrog.com\/img616\/16\/vlf.png"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_picplz
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"result":"ok","value":{"pics":[{"city":{"url":"/city/los-angeles-ca/","id":27,"name":"Los Angeles, CA"},"creator":{"username":"lakers","display_name":"Los Angeles Lakers","following_count":8,"follower_count":2364,"id":216541,"icon":{"url":"http://s1.ui1.picplzthumbs.com/usericons/c7/46/be/c746bee5eb6926e71f46176fddbd3fc16fc9b198_meds.jpg","width":75,"height":75}},"url":"/user/lakers/pic/6rlcc/","pic_files":{"640r":{"width":640,"img_url":"http://s1.i1.picplzthumbs.com/upload/img/7c/54/a0/7c54a0a10d3e97bef7ac570e14f461b1836e9168_wmeg.jpg","height":478},"100sh":{"width":100,"img_url":"http://s1.i1.picplzthumbs.com/upload/img/7c/54/a0/7c54a0a10d3e97bef7ac570e14f461b1836e9168_t200s.jpg","height":100},"320rh":{"width":320,"img_url":"http://s1.i1.picplzthumbs.com/upload/img/7c/54/a0/7c54a0a10d3e97bef7ac570e14f461b1836e9168_mmed.jpg","height":239}},"view_count":10873,"caption":"The playoff logo down on the floor.","comment_count":2,"like_count":24,"place":{"url":"/pics/staples-center-los-angeles-ca/","id":17357,"name":"STAPLES Center"},"date":1303059128,"id":1662796}]}}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_lockerz
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"BigImageUrl":"http:\/\/c0013763.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","CommentCount":1,"DetailsUrl":"http:\/\/api.plixi.com\/api\/tpapi.svc\/json\/photos\/100269159","GdAlias":"100269159","Id":100269159,"LargeImageUrl":"http:\/\/c0013763.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","LikedVotes":0,"Location":{"Latitude":0,"Longitude":0},"MediumImageUrl":"http:\/\/c0013764.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","Message":"Her name is Tofoi Al Nasr , she Reps the future of Qatar. @ the Doha Forum, technology is the new Revolution! ","MobileImageUrl":"http:\/\/c0013765.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","Name":"x2_5f9fc67","SmallImageUrl":"http:\/\/c0013766.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","ThumbnailUrl":"http:\/\/c0013767.cdn1.cloudfiles.rackspacecloud.com\/x2_5f9fc67","TinyAlias":"100269159","TwitterStatusId":67672440125394944,"UnLikedVotes":0,"UploadDate":1304969336,"UploadDateString":"2011-05-09T19:28:56Z","UserId":1067006,"Views":9319,"Vote":null}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

#follow redirect lookups 

def stub_imgly
  curl = Curl::Easy.new
  Curl::Easy.any_instance.stub(:perform).and_return curl
  Curl::Easy.stub!(:http_get).and_return curl
  Curl::Easy.any_instance.stub(:header_str).and_return %|HTTP/1.1 302 Found
Content-Type: text/html; charset=utf-8
Connection: keep-alive
Status: 302
X-Powered-By: Phusion Passenger (mod_rails/mod_rack) 3.0.7
Location: http://s3.amazonaws.com/imgly_production/899582/full.jpg\r\nX-Runtime: 5
Content-Length: 122
Set-Cookie: _imgly_session=BAh7BjoPc2Vzc2lvbl9pZCIlZTk3ZDI2ZmNhNWJjNGVjOTVjNDdiNThjOWFkYjliNTY%3D--83345d9317715d664bcb5de63b0529488a17a351; domain=.img.ly; path=/; expires=Sun, 31-Jul-2011 00:59:06 GMT; HttpOnly
Cache-Control: no-cache
Server: nginx/1.0.0 + Phusion Passenger 3.0.7 (mod_rails/mod_rack)

|
  Curl::Easy.any_instance.stub(:body_str).and_return %|<div id="image-box">
<!-- / #the-image-container{ :'data-url' => @image.image.url(:large) } -->
<img alt="trending: laugenzopf camenbert.  #wirsounterwegs " crossorigin="" id="the-image" src="http://s3.amazonaws.com/imgly_production/899582/large.jpg">
<div id="tagging-cursor"></div>
<form accept-charset="UTF-8" action="/peopletaggings" class="new_peopletagging" id="tag-people-form" method="post">
<div style="margin:0;padding:0;display:inline">
<input name="utf8" type="hidden" value="✓"><input name="authenticity_token" type="hidden" value="780G4Ra4X2R0AyNc01w2XKQHmd0122ZoIt478wIYeOI=">
</div>|
end

def stub_twitpic
  curl = Curl::Easy.new
  Curl::Easy.any_instance.stub(:perform).and_return curl
  Curl::Easy.any_instance.stub(:header_str).and_return %|HTTP/1.1 302 Moved Temporarily
Server: nginx
Date: Sun, 17 Jul 2011 01:03:43 GMT
Content-Type: image/jpeg
Transfer-Encoding: chunked
Connection: keep-alive
X-Powered-By: PHP/5.3.5-1ubuntu7.2
Last-Modified: Sat, 16 Jul 2011 22:17:03 GMT
Etag: 0fe3c085839afa6e42ce28973192704a
Cache-Control: maxage=10000
Expires: Sun, 17 Jul 2011 03:50:23 GMT
Pragma: public
Location: http://s3.amazonaws.com/twitpic/photos/full/249034281.jpg?AWSAccessKeyId=AKIAJF3XCCKACR3QDMOA&Expires=1310865623&Signature=KNFdFAK%2Bu0u3maMaguUjsm2MbaM%3D\r\n
|
  #stub redirected call's response
  Curl::Easy.stub!(:http_get).and_return curl
  Curl::Easy.any_instance.stub(:body_str).and_return %|http://s3.amazonaws.com/twitpic/photos/full/249034281.jpg?AWSAccessKeyId=AKIAJF3XCCKACR3QDMOA&Expires=1310865623&Signature=KNFdFAK%2Bu0u3maMaguUjsm2MbaM%3D\r\n|
end

def stub_tco
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:header_str).and_return %|HTTP/1.1 301 Moved Permanently
Date: Sun, 17 Jul 2011 01:03:51 GMT
Server: hi
Location: http://yfrog.com/h0m3vpj
Cache-Control: private,max-age=300
Expires: Sun, 17 Jul 2011 01:08:51 GMT
Content-Length: 0
Connection: close
Content-Type: text/html; charset=UTF-8

|
  stub_yfrog
end

#embedly powered lookups

def stub_embedly
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"provider_url": "http://www.flickr.com/", "description": "Lady GaGa", "title": "Lady GaGa", "url": "http://farm6.static.flickr.com/5204/5319200155_c966f67dc3.jpg", "author_name": "mjcom18", "height": 468, "width": 307, "thumbnail_url": "http://farm6.static.flickr.com/5204/5319200155_c966f67dc3_t.jpg", "thumbnail_width": 66, "version": "1.0", "provider_name": "Flickr", "cache_age": 3600, "type": "photo", "thumbnail_height": 100, "author_url": "http://www.flickr.com/photos/57795463@N05/"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

def stub_embedly_no_photo
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"provider_url": "http://www.yelp.de/", "description": "Fotos von Kopiba \u2013 #coffeediary \u2013 Hamburg", "title": "#coffeediary Yelp", "url": "http://www.yelp.de/biz_photos/wB1uHl_VnEbn7tqigTZKTQ?pt=biz_photo&ref=twitter&select=py1D5XEyOHcOcg6GJD3SEQ", "thumbnail_width": 298, "thumbnail_url": "http://s3-media4.ak.yelpcdn.com/bphoto/py1D5XEyOHcOcg6GJD3SEQ/l.jpg", "version": "1.0", "provider_name": "Yelp", "type": "link", "thumbnail_height": 400}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

#path

def stub_path_redirected
  curl = Curl::Easy.new
  Curl::Easy.any_instance.stub(:perform).and_return curl
  Curl::Easy.any_instance.stub(:header_str).and_return %|HTTP/1.1 302 Moved Temporarily
  Date: Thu, 29 Dec 2011 20:30:22 GMT
  Connection: close
  Content-Length: 178
  Server: nginx
  Content-Type: text/html
  Location: https://path.com/p/KQd57\r\n
  |
  #stub redirected call's response
  stub_path
end

def stub_path
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:body_str).and_return %^

  <div class="moments_photo moments_photo-landscape">
      <div class="photo-container">
          <img src="https://s3-us-west-1.amazonaws.com/images.path.com/photos2/f90fd831-43c3-48fd-84cb-5c3bae52957a/2x.jpg" width="480" height="358.5" class="moment-block photo-image" />
          <b class="photo-border" style="width: 478px; height: 356.5px;"></b>
      </div>
  </div>


          <div class="moment-block">




              <div class="moments_feedback">

      <div class="moment-description">

          <div class="moment-tags">

              <span class="moment-author">Sven Kräuter</span>



              <span class="moment-timestamp">1 hour ago</span>
          </div>

          <div class="feedback-actions">
              <div class="emotion-picker">
                  <div class="emotion-picker-box">
                      <ul class="emotion-icon-set">
                          <li class="emotion-icon happy">
                              <a href="#" class="emotion-icon-a" data-emotion-type="happy">Happy</a>
                          </li>
                          <li class="emotion-icon laugh">
                              <a href="#" class="emotion-icon-a" data-emotion-type="laugh">Laugh</a>
                          </li>
                          <li class="emotion-icon surprise">
                              <a href="#" class="emotion-icon-a" data-emotion-type="surprise">Surprise</a>
                          </li>
                          <li class="emotion-icon sad">
                              <a href="#" class="emotion-icon-a" data-emotion-type="sad">Sad</a>
                          </li>
                          <li class="emotion-icon love">
                              <a href="#" class="emotion-icon-a" data-emotion-type="love">Love</a>
                          </li>
                      </ul>
                  </div>
                  <a href="#" class="action action-emotion"><b class="None">Add Emotion</b></a>
              </div>

              <a href="#" class="action action-comment"><b>Add Comment</b></a>
          </div>
      </div>

      <div class="seen-it-container">
          <ul class="seen-it-set">

              <li class="user user-small seen-it  tooltip-target">

                  <img src="https://s3-us-west-1.amazonaws.com/images.path.com/profile_photos/4d973b511f60bf3eae6dc418a86e848653ad90ac/processed_80x80.jpg" class="user-photo" />
                  <div class="tooltip-block">
                      <div class="tooltip-container">
                          <b class="tooltip-text">Thies Arntzen</b>
                          <b class="tooltip-pointer"></b>
                      </div>
                  </div>

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it  tooltip-target">

                  <img src="https://s3-us-west-1.amazonaws.com/images.path.com/profile_photos/34255fba4020523f71a25b05b89d86f80d19850b/processed_80x80.jpg" class="user-photo" />
                  <div class="tooltip-block">
                      <div class="tooltip-container">
                          <b class="tooltip-text">Sven Kräuter</b>
                          <b class="tooltip-pointer"></b>
                      </div>
                  </div>

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="user user-small seen-it seen-it-blank tooltip-target">

                  <b class="user-border"></b>

              </li>

              <li class="clear"></li>
          </ul>

      </div>

      <ul class="comment-set">

          <li class="comment">
              <div class="user comment-user">
                  <img src="https://s3-us-west-1.amazonaws.com/images.path.com/profile_photos/34255fba4020523f71a25b05b89d86f80d19850b/processed_80x80.jpg" class="user-photo" />
                  <b class="user-border"></b>
              </div>
              <h4 class="comment-author">Sven Kräuter</h4>
              <div class="comment-body">#coffeediary usually not a big fan of industrial beans, I have to admit: the segafredo intermezzo is quite amazing</div>
              <h5 class="comment-timestamp">
                  <span class="comment-date"><time class="timestamp" datetime="2011-12-10T17:49:54Z">December 10, 2011 at 17:49</time></span>

                  <span class="comment-location">from Hamburg, Germany</span>

              </h5>


          </li>

      </ul>

      <div class="comment-box">

          <form action="/comments/create" method="POST" class="comment-form">
              <div class="comment-sizer">And a comment!</div>
              <input type="hidden" name="moment_id" value="4ee39bcf7c215078e9031249" />
              <textarea class="comment-field" name="body" rows="1" placeholder="Add a comment..."></textarea>
          </form>

          <div class="comment-blocker">
              <b>Login required</b>
          </div>

      </div>

  </div><!-- // moments_feedback -->
              <div class="timeline-arrow"></div>
          </div>

      </div>





      </div>







              <script src="/static/cache/javascripts/all.js?1323473167"></script>










      <script type="text/javascript" charset="utf-8">
          Ply.ui.register('shared', {
              view: document.body
          });

      Ply.ui.register('moments_show');

      </script>


  <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-9066780-2']);
      _gaq.push(['_trackPageview']);

      (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();
  </script>


  <script type="text/javascript">
      var _sf_async_config={uid:28481,domain:"path.com"};
      (function(){
          function loadChartbeat() {
              window._sf_endpt=(new Date()).getTime();
              var e = document.createElement('script');
              e.setAttribute('language', 'javascript');
              e.setAttribute('type', 'text/javascript');
              e.setAttribute('src', (("https:" == document.location.protocol) ? "https://a248.e.akamai.net/chartbeat.download.akamai.com/102508/" : "http://static.chartbeat.com/") + "js/chartbeat.js");
              document.body.appendChild(e);
          }
          var oldonload = window.onload;
          window.onload = (typeof window.onload != 'function') ? loadChartbeat : function() { oldonload(); loadChartbeat(); };
      })();
  </script>


  <script type="text/javascript">var mpq=[];mpq.push(["init","8317b3b4f5a2a5fdba3c5a4782c7289f"]);(function(){var b,a,e,d,c;b=document.createElement("script");b.type="text/javascript";b.async=true;b.src=(document.location.protocol==="https:"?"https:":"http:")+"//api.mixpanel.com/site_media/js/api/mixpanel.js";a=document.getElementsByTagName("script")[0];a.parentNode.insertBefore(b,a);e=function(f){return function(){mpq.push([f].concat(Array.prototype.slice.call(arguments,0)))}};d=["init","track","track_links","track_forms","register","register_once","identify","name_tag","set_config"];for(c=0;c<d.length;c++){mpq[d[c]]=e(d[c])}})();

  mpq.identify("687ad7fc-2360-11e1-8ff7-12313e006031");


  </script>


  <script src="https://cdn.optimizely.com/js/6548263.js"></script>
  </body>
  </html>^
end

def stub_foursquare
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:body_str).and_return %^<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:og=\"http://opengraphprotocol.org/schema/\" xmlns:fb=\"http://www.facebook.com/2008/fbml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /><meta name=\"application-name\" content=\"Foursquare\"/><meta name=\"msapplication-TileColor\" content=\"#0ca9c9\"/><meta name=\"msapplication-TileImage\" content=\"https://playfoursquare.s3.amazonaws.com/misc/foursquare-144-logo.png\"/><meta name=\"msapplication-tooltip\" content=\"Start the foursquare App\" /><meta name=\"msapplication-starturl\" content=\"/\" /><meta name=\"msapplication-window\" content=\"width=1024;height=768\" /><meta name=\"msapplication-task\" content=\"name=Recent Check-ins; action-uri=/; icon-uri=/favicon.ico\" /><meta name=\"msapplication-task\" content=\"name=Profile;action-uri=/user;icon-uri=/favicon.ico\" /><meta name=\"msapplication-task\" content=\"name=History;action-uri=/user/history;icon-uri=/favicon.ico\" /><meta name=\"msapplication-task\" content=\"name=Badges;action-uri=/user/badges;icon-uri=/favicon.ico\"  /><meta name=\"msapplication-task\" content=\"name=Stats;action-uri=/user/stats;icon-uri=/favicon.ico\"  /><link rel=\"icon\" href=\"/favicon.ico\" type=\"image/x-icon\"/><link rel=\"shortcut icon\" href=\"/favicon.ico\" type=\"image/x-icon\"/><link rel=\"apple-touch-icon-precomposed\" sizes=\"72x72\" href=\"/img/touch-icon-ipad.png\" /><link rel=\"apple-touch-icon-precomposed\" sizes=\"144x144\" href=\"/img/touch-icon-ipad-retina.png\" /><link rel=\"logo\" href=\"https://playfoursquare.s3.amazonaws.com/press/logo/foursquare-logo.svg\" type=\"image/svg\" /><link rel=\"search\" type=\"application/opensearchdescription+xml\" href=\"/opensearch.xml\" title=\"foursquare\" /><title>Sven @ kopiba</title><meta content=\"en\" http-equiv=\"Content-Language\" /><meta content=\"https://foursquare.com/sven_kr/checkin/4f0c401ae4b020a8d96fb0b1?ref=fb&amp;source=openGraph&amp;s=eU7t9fpmByekJgPb8IOuchQ9ibw\" property=\"og:url\" /><meta content=\"A check-in at kopiba\" property=\"og:title\" /><meta content=\"A check-in\" property=\"og:description\" /><meta content=\"playfoursquare:checkin\" property=\"og:type\" />

<meta content=\"https://irs0.4sqi.net/img/general/600x600/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg\" property=\"og:image\" />

<meta content=\"2012-01-10T13:41:46.000Z\" property=\"playfoursquare:date\" /><meta content=\"https://foursquare.com/v/kopiba/4b169255f964a52072ba23e3\" property=\"playfoursquare:place\" /><meta content=\"Foursquare\" property=\"og:site_name\" /><meta content=\"86734274142\" property=\"fb:app_id\" /><meta content=\"@foursquare\" name=\"twitter:site\" /><meta content=\"photo\" name=\"twitter:card\" /><meta content=\"Foursquare\" name=\"twitter:app:name:iphone\" /><meta content=\"Foursquare\" name=\"twitter:app:name:ipad\" /><meta content=\"Foursquare\" name=\"twitter:app:name:googleplay\" /><meta content=\"foursquare://checkins/4f0c401ae4b020a8d96fb0b1?s=eU7t9fpmByekJgPb8IOuchQ9ibw\" name=\"twitter:app:url:iphone\" /><meta content=\"foursquare://checkins/4f0c401ae4b020a8d96fb0b1?s=eU7t9fpmByekJgPb8IOuchQ9ibw\" name=\"twitter:app:url:ipad\" />
^
end

def stub_foursquare_no_photo
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:body_str).and_return %^<!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:og="http://opengraphprotocol.org/schema/" xmlns:fb="http://www.facebook.com/2008/fbml"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><meta name="application-name" content="Foursquare"/><meta name="msapplication-TileColor" content="#0ca9c9"/><meta name="msapplication-TileImage" content="https://playfoursquare.s3.amazonaws.com/misc/foursquare-144-logo.png"/><meta name="msapplication-tooltip" content="Start the foursquare App" /><meta name="msapplication-starturl" content="/" /><meta name="msapplication-window" content="width=1024;height=768" /><meta name="msapplication-task" content="name=Recent Check-ins; action-uri=/; icon-uri=/favicon.ico" /><meta name="msapplication-task" content="name=Profile;action-uri=/user;icon-uri=/favicon.ico" /><meta name="msapplication-task" content="name=History;action-uri=/user/history;icon-uri=/favicon.ico" /><meta name="msapplication-task" content="name=Badges;action-uri=/user/badges;icon-uri=/favicon.ico"  /><meta name="msapplication-task" content="name=Stats;action-uri=/user/stats;icon-uri=/favicon.ico"  /><link rel="icon" href="/favicon.ico" type="image/x-icon"/><link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/><link rel="apple-touch-icon-precomposed" sizes="72x72" href="/img/touch-icon-ipad.png" /><link rel="apple-touch-icon-precomposed" sizes="144x144" href="/img/touch-icon-ipad-retina.png" /><link rel="logo" href="https://playfoursquare.s3.amazonaws.com/press/logo/foursquare-logo.svg" type="image/svg" /><link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="foursquare" /><title>Sven @ Le Lion</title><meta content="de" http-equiv="Content-Language" /><meta content="https://foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?ref=fb&amp;source=openGraph&amp;s=9aAHdtIEpzZ-t1yziwX8ASs_81c" property="og:url" /><meta content="Ein Check-in bei Le Lion" property="og:title" /><meta content="Ein Check-in" property="og:description" /><meta content="playfoursquare:checkin" property="og:type" /><meta content="https://foursquare.com/img/categories_map/nightlife/cocktails.png" property="og:image" /><meta content="2013-04-30T22:19:22.000Z" property="playfoursquare:date" /><meta content="https://foursquare.com/v/le-lion/4b0f0baaf964a520895e23e3" property="playfoursquare:place" /><meta content="Foursquare" property="og:site_name" /><meta content="86734274142" property="fb:app_id" /><meta content="@foursquare" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="Foursquare" name="twitter:app:name:iphone" /><meta content="Foursquare" name="twitter:app:name:ipad" /><meta content="Foursquare" name="twitter:app:name:googleplay" /><meta content="foursquare://checkins/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c" name="twitter:app:url:iphone" /><meta content="foursquare://checkins/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c" name="twitter:app:url:ipad" /><meta content="foursquare://checkins/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c" name="twitter:app:url:googleplay" /><meta content="306934924" name="twitter:app:id:iphone" /><meta content="306934924" name="twitter:app:id:ipad" /><meta content="com.joelapenna.foursquared" name="twitter:app:id:googleplay" /><link href="https://ss1.4sqi.net/styles/third_party/hfjfonts-5a7f8781ee1be1bb12433f1d74f0948c.css" type="text/css" rel="stylesheet"/><link href="https://ss1.4sqi.net/styles/master-d343426b4dbbd81a7e427d6f8c032b5a.css" type="text/css" rel="stylesheet"/><link href="https://ss0.4sqi.net/styles/standalone-pages/checkin-detail-1aabc265046d80b7c1e392c47dd3f8c9.css" type="text/css" rel="stylesheet"/><link rel="alternate" href="https://it.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="it"/><link rel="alternate" href="https://de.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="de"/><link rel="alternate" href="https://es.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="es"/><link rel="alternate" href="https://fr.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="fr"/><link rel="alternate" href="https://ja.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="ja"/><link rel="alternate" href="https://th.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="th"/><link rel="alternate" href="https://ko.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="ko"/><link rel="alternate" href="https://ru.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="ru"/><link rel="alternate" href="https://pt.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="pt"/><link rel="alternate" href="https://id.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="id"/><link rel="alternate" href="https://tr.foursquare.com/sven_kr/checkin/5180436ae4b098ea8af76e3a?s=9aAHdtIEpzZ-t1yziwX8ASs_81c&amp;ref=tw" hreflang="tr"/>^
end

def stub_eyeem
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:header_str).and_return "HTTP/1.1 200 OK\r\nServer: nginx/1.0.5\r\nDate: Sun, 15 Apr 2012 09:16:58 GMT\r\nContent-Type: text/html; charset=utf-8\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\nX-Powered-By: PHP/5.3.6-13ubuntu3.6\r\nSet-Cookie: symfony=bv8mdicp6ucb8jr9qt0o0r7qk2; path=/\r\nExpires: Thu, 19 Nov 1981 08:52:00 GMT\r\nCache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\nPragma: no-cache\r\n\r\n"
  Curl::Easy.any_instance.stub(:body_str).and_return "<!DOCTYPE html>\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"shortcut icon\" href=\"/favicon.ico\" />\n<meta name=\"title\" content=\"EyeEm\" />\n<meta name=\"description\" content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It&#039;s free.\" />\n<title>EyeEm</title>\n<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"/css/eyeem.c.css?1334330223\" />\n  <meta content=\"EyeEm\" property=\"og:title\">\n<meta content=\"website\" property=\"og:type\">\n<meta content=\"EyeEm\" property=\"og:site_name\">\n<meta content=\"http://www.eyeem.com/p/326629\" property=\"og:url\">\n<meta content=\"http://www.eyeem.com/thumb/640/480/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\" property=\"og:image\">\n<meta content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It's free.\" property=\"og:description\">\n<meta content=\"138146182878222\" property=\"fb:app_id\">\n<script type=\"text/javascript\">\n\n  var _gaq = _gaq || [];\n  _gaq.push(['_setAccount', 'UA-12590370-2']);\n  _gaq.push(['_trackPageview']);\n\n  (function() {\n    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n  })();\n\n</script>\n</head>\n<body>\n\n<div id=\"fb-root\">\n  <!-- you must include this div for the JS SDK to load properly -->\n</div>\n<script>\n  window.fbAsyncInit = function() {\n    FB.init({\n      appId      : '138146182878222', // App ID\n      channelUrl : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File\n      status     : true, // check login status\n      cookie     : true, // enable cookies to allow the server to access the session\n      xfbml      : true  // parse XFBML\n    });\n\n    // Additional initialization code here\n  };\n\n  // Load the SDK Asynchronously\n  (function(d){\n     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];\n     if (d.getElementById(id)) {return;}\n     js = d.createElement('script'); js.id = id; js.async = true;\n     js.src = \"//connect.facebook.net/en_US/all.js\";\n     ref.parentNode.insertBefore(js, ref);\n   }(document));\n</script>\n  \n  \n\n\n  <div id=\"page\">\n        <div id=\"header\">\n      <div name=\"top\" class=\"top_bar\"><div class=\"top_bar-inner\">\n  <div class=\"padding-top\"></div>\n  <div class=\"top_bar_content\">\n    <div class=\"search_box\">\n    \t<form action=\"/search\" method=\"get\" enctype=\"application/x-www-form-urlencoded\">\n        <input type=\"text\" name=\"query\" class=\"search_form_query\" placeholder=\"Search\" id=\"query\" />  <!--   \t  <input class=\"search_form_submit\" type=\"image\" value=\"submit\" src=\"\"/> -->\n    \t  <input class=\"search_form_submit\" type=\"submit\" value=\"\" />\n    \t</form>\n    </div>\n    <div class=\"homelink\">\n    \t<a href=\"/\">\n        <img src=\"/images/layout/topbar_logo.png\">\n    \t</a>\n    </div>\n    \n    \n      \n    <div class=\"top_menus\">\n            <div class=\"top_menu user_menu\">\n  \t\t  <a class=\"user_login smooth_hover\" href=\"/login\">\n  \t\t\t\t<span class=\"\">Login</span>\n  \t\t  </a>\n      </div>\n      \n      \n      \n            <div class=\"top_menu about_menu\">\n  \t\t  <a class=\"top_menu_button about_box smooth_hover\" href=\"javascript:void(0)\">\n  \t\t\t\t<span class=\"about_name\">About</span>\n  \t\t    <img class=\"more_triangle\" src=\"/images/layout/topbar_triangle.png\">\n  \t\t  </a>\n  \t\t  <ul class=\"\">\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/whatiseyeem\"><span>What is EyeEm?</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/gettheapp\"><span>Download the App</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/contact\"><span>Contact and Press</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/team\"><span>Team & Jobs</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"http://blog.eyeem.com\" target=\"_blank\"><span>Blog</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/pages/service.html\"><span>Terms of service</span></a></li>\n  \t\t  </ul>\n      </div>  \n    </div>\n    \n  </div>\n</div></div>\n      <div class=\"top_bar_back\"></div>\n    </div> <!-- /#header -->\n    <div id=\"content\">\n      \n\n<div class=\"join_block\">\n  <div class=\"join_inner\">\n    <span class=\"join_description\">\n      <p>Take &amp; Discover photos</p>\n      <p>together with EyeEm!</p>\n    </span>\n    <div class=\"join_now\">\n      <div><a class=\"eyeem_button join_button\" href=\"/signup\">Join now!</a></div>\n      <div class=\"learn_more\"><a class=\"\" href=\"/whatiseyeem\">Learn more</a></div>\n    </div>\n  </div>\n</div>\n<div class=\"inner-content photo_inner_content\">\n  <div class=\"photo_indicator\"><img src=\"/images/layout/triangle_indicator.png\"></div>\n  <div class=\"viewports-wrapper\">\n    <div class=\"viewport active\" data-photo-id=\"326629\">\n        \n\n <div class=\"viewport-user\">\n  \t<a href=\"/u/8157\">\n  \t\t<img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  \t</a>\n  \t<span class=\"user_text\">\n    \t<a class=\"user_name\" href=\"/u/8157\">\n    \t\t<span><h2>Sven Kr\xC3\xA4uter</h2></span>\n    \t</a>\n    \t<div class=\"meta\">\n        <div class=\"viewport-age\">\n  \t     <span>4</span> days ago        </div>\n            \t</div>\n  \t</span>\n          </div>  \t\t\n  \t\t\n  \t\t\n    <div class=\"viewport-pic\">\n        <img src=\"http://www.eyeem.com/thumb/h/1024/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\">\n  </div>\n  \n  \n    <div class=\"viewport-albums\">\n        <div class=\"tags tags_arrow\">\n                  \n                  \n      <div class=\"album_tag_box hover_container\">\n        <a class=\"album_tag tag\" href=\"/a/168255\">#coffeediary</a>\n                  </div>                \t    \t\n    \t    </div>\n    <div class=\"places tags_arrow\">\n                \t    </div>\n  </div>\n    \n  \n\n  <div class=\"viewport-likes\">\n        <div class=\"likes_count count\">1 like</div>\n    <span class=\"user_thumbs\">\n                <a class=\"user_thumb hover_container\" href=\"/u/85456\">\n  <img class=\"user_face\" alt=\"filtercake-nophoto\" src=\"http://www.eyeem.com/thumb/sq/50/a5799d443153b9becad3a1e15d15c1ad79739f32.jpg\">\n            </a>\n              </span>\n  \t<span class=\"like_area\">\n      <div class=\"like_action action\">\n    \t    \t\t    \t\t\t<a class=\"photo_like eyeem_button like_button\" href=\"javascript:void(0)\">Like<img class=\"button_spinner\" src=\"/images/layout/spinner.gif\"></a>\n    \t\t    \t      </div>  \t\n      \t\n  \t</span>\n  </div>\n  \n  \n  <div class=\"viewport-comments\">\n  \t<div class=\"comments_count count\">1 comment</div>\n  \t  \t<div class=\"comment_box\">\n    <a class=\"user_face_link\" href=\"/u/8157\">\n    <img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  </a>\n  <span class=\"comment_display\">\n    <a class=\"user_name\" href=\"/u/8157\">\n      Sven Kr\xC3\xA4uter    </a>\n    <div class=\"comment_body\">\n      still using the bialetti until the spare parts for the espresso machine arrive. quite cozy actually.          </div>\n    <div class=\"comment_age\"><span>4</span> days ago</div>\n  </span>\n</div>\n  \t      </div>\n  \n  <div class=\"viewport-social\">\n    <div class=\"social\">\n      <div class=\"twitter-like\">\n        <script src=\"http://platform.twitter.com/widgets.js\" type=\"text/javascript\"></script>\n        <a href=\"http://twitter.com/share\" class=\"twitter-share-button\" data-url=\"http://www.eyeem.com/p/326629\">Tweet</a>\n      </div>\n      <div class=\"facebook-like\">\n        <div class=\"fb-like\" data-href=\"http://www.eyeem.com/p/326629\" data-send=\"false\" data-layout=\"button_count\" data-width=\"20\" data-show-faces=\"false\" data-font=\"verdana\"></div>\n      </div>\n    </div>\n  </div>\n\n    </div>\n  </div>\n</div>    </div> <!-- /#content -->\n  </div> <!-- /#page -->\n  \n  <script type=\"text/javascript\">\n    var app_url = 'http://www.eyeem.com/';\nvar signup_url = 'http://www.eyeem.com/signup';\nvar authenticated = false;\n  </script>\n\n  <script type=\"text/javascript\" src=\"/js/eyeem.c.js?1334330223\"></script>\n\n</body>\n</html>"
end

