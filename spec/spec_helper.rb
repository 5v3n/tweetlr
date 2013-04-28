#encoding: utf-8
require "bundler"
require "logger"
require "yaml"
require "#{File.dirname(__FILE__)}/../lib/tweetlr"

Bundler.require :default, :development, :test

logger = Logger.new(STDOUT)
logger.level = Logger::FATAL
Tweetlr::LogAware.log = logger

def check_pic_url_extraction(service)
  image_url = Tweetlr::Processors::PhotoService.find_image_url @links[service]
  (image_url =~ Tweetlr::Processors::PhotoService::PIC_REGEXP).should be, "service #{service} not working, no picture extracted!"
end

def stub_oauth
  OAuth::AccessToken.any_instance.stub(:post).and_return(Net::HTTPCreated.new("Created.", "201", nil))
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

def stub_twitter
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"results":[{"from_user_id_str":"220650275","profile_image_url":"http://a2.twimg.com/profile_images/668619338/9729_148876458070_505518070_2628895_7160219_n_normal.jpg","created_at":"Sat, 16 Jul 2011 23:20:01 +0000","from_user":"LoMuma","id_str":"92372947855093760","metadata":{"result_type":"recent"},"to_user_id":null,"text":"Need to stop procrastinating! 5 quizzes and personal responses due tomorrow... #fail","id":92372947855093760,"from_user_id":220650275,"geo":null,"iso_language_code":"en","to_user_id_str":null,"source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"from_user_id_str":"129718556","profile_image_url":"http://a2.twimg.com/profile_images/1428268221/twitter_normal.png","created_at":"Sat, 16 Jul 2011 23:20:01 +0000","from_user":"priiislopes","id_str":"92372947846692865","metadata":{"result_type":"recent"},"to_user_id":null,"text":"Esse jogo do Flu foi uma vergonha. Se ele fez o melhor dele no brasileiro semana passada, hj fez o pior de todos os tempos. #Fail","id":92372947846692865,"from_user_id":129718556,"geo":null,"iso_language_code":"pt","to_user_id_str":null,"source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"from_user_id_str":"259930166","profile_image_url":"http://a3.twimg.com/profile_images/1425221519/foto_normal.jpg","created_at":"Sat, 16 Jul 2011 23:20:00 +0000","from_user":"YamiiG4","id_str":"92372943132303360","metadata":{"result_type":"recent"},"to_user_id":null,"text":"vaya que eran 2 minutos..#FAIL!","id":92372943132303360,"from_user_id":259930166,"geo":null,"iso_language_code":"es","to_user_id_str":null,"source":"&lt;a href=&quot;http://www.tweetdeck.com&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;"},{"from_user_id_str":"321557905","profile_image_url":"http://a0.twimg.com/profile_images/1445672626/profile_normal.png","created_at":"Sat, 16 Jul 2011 23:20:00 +0000","from_user":"JasWafer_FFOE","id_str":"92372941379088384","metadata":{"result_type":"recent"},"to_user_id":null,"text":"RT @eye_OFBEHOLDER: RT @JasWafer_FFOE #Oomf said that he'll NEVER eat pussy! O.o --#FAIL","id":92372941379088384,"from_user_id":321557905,"geo":null,"iso_language_code":"en","to_user_id_str":null,"source":"&lt;a href=&quot;http://twidroyd.com&quot; rel=&quot;nofollow&quot;&gt;Twidroyd for Android&lt;/a&gt;"},{"from_user_id_str":"279395613","profile_image_url":"http://a0.twimg.com/profile_images/1334871419/lnnsquare_normal.jpg","created_at":"Sat, 16 Jul 2011 23:19:59 +0000","from_user":"LanguageNewsNet","id_str":"92372940640890881","metadata":{"result_type":"recent"},"to_user_id":null,"text":"Questioning the Inca Paradox: Did the civilization behind Machu Picchu really fail to develop a written la... http://tinyurl.com/5sfos23","id":92372940640890881,"from_user_id":279395613,"geo":null,"iso_language_code":"en","to_user_id_str":null,"source":"&lt;a href=&quot;http://twitterfeed.com&quot; rel=&quot;nofollow&quot;&gt;twitterfeed&lt;/a&gt;"}],"max_id":92372947855093760,"since_id":0,"refresh_url":"?since_id=92372947855093760&q=+fail","next_page":"?page=2&max_id=92372947855093760&rpp=5&q=+fail","results_per_page":5,"page":1,"completed_in":0.022152,"since_id_str":"0","max_id_str":"92372947855093760","query":"+fail"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
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

def stub_foursquare
  Curl::Easy.any_instance.stub(:body_str).and_return %|{"provider_url": "http://foursquare.com", "description": "See where your friends are, learn about the places they frequent, and unlock rewards as you travel. 8555 Fletcher PkwyLa Mesa, CA 91942(619) 589-0071", "title": "Matt S. checked in at Banbu Sushi Bar And Grill", "url": "https://playfoursquare.s3.amazonaws.com/pix/PNIBDBIPP5G2XGROCZXVCOHABOZP4MICHZVPJWZXZWAN3SEQ.jpg", "author_name": "Matt S.", "height": 345, "width": 460, "thumbnail_url": "https://playfoursquare.s3.amazonaws.com/pix/PNIBDBIPP5G2XGROCZXVCOHABOZP4MICHZVPJWZXZWAN3SEQ.jpg", "thumbnail_width": 460, "version": "1.0", "provider_name": "Foursquare", "type": "photo", "thumbnail_height": 345, "author_url": "https://foursquare.com/mjstraus"}|
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
end

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
  Curl::Easy.any_instance.stub(:body_str).and_return %^<div id="container" class="wrap"><div class="checkinDetail"><div id="checkinDetailPage" class=""><div id="mapContainer" class="leaflet-container leaflet-fade-anim"><div class="leaflet-map-pane" style="left: 0px; top: 0px;"><div class="leaflet-tile-pane"><div class="leaflet-layer"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 542px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34580/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 542px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34580/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 798px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34581/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 286px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34579/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 542px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34580/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 798px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34581/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 798px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34581/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 286px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34579/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 286px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34579/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 542px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34580/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 542px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34580/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 30px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34578/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1054px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34582/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 30px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34578/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 286px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34579/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 798px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34581/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 30px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34578/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1054px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34582/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 798px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34581/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1054px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34582/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 286px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34579/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 30px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34578/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1054px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34582/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1054px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34582/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 30px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34578/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1310px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34583/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -226px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34577/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -226px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34577/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1310px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34583/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -226px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34577/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1310px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34583/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1310px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34583/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1310px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34583/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -226px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34577/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -226px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34577/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1566px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34584/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -482px; top: 65px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34576/21178.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1566px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34584/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -482px; top: 321px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34576/21179.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1566px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34584/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -482px; top: -191px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34576/21177.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -482px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34576/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: -482px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34576/21180.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1566px; top: -447px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34584/21176.png"><img class="leaflet-tile leaflet-tile-loaded" style="width: 256px; height: 256px; left: 1566px; top: 577px;" src="https://dnv9my2eseobd.cloudfront.net/v3/foursquare.map-0y1jh28j/16/34584/21180.png"></div></div><div class="leaflet-objects-pane"><div class="leaflet-shadow-pane  leaflet-zoom-hide"></div><div class="leaflet-overlay-pane"></div><div class="leaflet-marker-pane  leaflet-zoom-hide"><div class="leaflet-marker-icon mapMarker leaflet-zoom-hide" style="margin-left: -6px; margin-top: -6px; width: 12px; height: 12px; left: 1012px; top: 148px; z-index: 148;"><div class="bigBlueMapPin"><img alt="Café" src="https://foursquare.com/img/categories_v2/food/cafe_44.png"></div></div></div><div class="leaflet-popup-pane  leaflet-zoom-hide"></div></div></div><div class="leaflet-control-container"><div class="leaflet-top leaflet-left"><div class="leaflet-control-zoom leaflet-control"><a href="#" class="leaflet-control-zoom-in" title="Zoom in"></a><a href="#" class="leaflet-control-zoom-out" title="Zoom out"></a></div></div><div class="leaflet-top leaflet-right"></div><div class="leaflet-bottom leaflet-left"></div><div class="leaflet-bottom leaflet-right"><div class="leaflet-control-attribution leaflet-control"><a class="footerLink terms" href="/about#maps" target="_blank">Über unsere Karten</a></div></div></div></div><div class="venueHeader"><div class="venueDetailsContainer"><div class="venueDetails"><span class="venueName"><a href="https://foursquare.com/kopiba">kopiba</a><a href="https://foursquare.com/kopiba"><img src="https://ss1.4sqi.net/img/specials/check-in-f870bc36c0cc2a842fac06c35a6dccdf.png" class="tooltip" title="" alt="Check-in Special"></a></span><div><div class="venueScore tooltip score positive" title="">9.3</div><div class="venueAddress"><span class="local">Beim Grünen Jäger 24, Hamburg</span></div><div class="venueCats"><span>Café</span></div></div></div><div class="venueHistoryTopRight"><div class="saveButton saveToListAction inactive" title="Save to my to-do list!"><span class="buttonLeft"><img src="https://ss0.4sqi.net/img/lists/button_icon_saveribbon-9c5999c47028ca670954422ee53e7d96.png" height="16" width="16" data-retina-url="https://ss1.4sqi.net/img/lists/button_icon_saveribbon@2x-d809e5af932a66d1725c40dfddcc2855.png"></span><span class="buttonRight unsaved"><span class="label">Speichern</span></span></div></div><div class="venuePhotoContainer"><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/39861258_Ulcg4M_vZ0Gkfce9Y6Han4mDkR-83QTumS5wV2RLij8.jpg" photo-id="5084ff52e4b068d89dd5dbf9" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/39861258_Ulcg4M_vZ0Gkfce9Y6Han4mDkR-83QTumS5wV2RLij8.jpg"></span><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/x1mhxhrpvjgAtQHgJLtII38EKNOA46aA7fQ0KfzMB6g.jpg" photo-id="50181552e4b0a0721fc746a5" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/x1mhxhrpvjgAtQHgJLtII38EKNOA46aA7fQ0KfzMB6g.jpg"></span><span class="photoThumb link"><img src="https://irs2.4sqi.net/img/general/125x125/8352028_BmwTYQ1KnCk522ISUVo-e8Mgn5sz42u-DRu968m0MhQ.jpg" photo-id="50f6aa1ce4b07eb72279543e" width="125" height="125" alt="" data-retina-url="https://irs2.4sqi.net/img/general/250x250/8352028_BmwTYQ1KnCk522ISUVo-e8Mgn5sz42u-DRu968m0MhQ.jpg"></span><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/2653854_W_immUSqq2SjUyVC_2zuP84A-dOubiwBYla9CVZKO8s.jpg" photo-id="50ba05eae4b0e2256067a77d" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/2653854_W_immUSqq2SjUyVC_2zuP84A-dOubiwBYla9CVZKO8s.jpg"></span></div><span class="link returnToCheckin returnToCheckinAction">Return to check-in</span></div></div><div class="checkinWrapper"><div class="checkInHeader"><div class="leftCheckInHeader"><a href="https://foursquare.com/sven_kr" class="currentUser"><img src="https://irs1.4sqi.net/img/user/64x64/UWZCDYXIH51YAMWC.jpg" alt="Sven K." class="avatar " width="64" height="64" title="Sven K." data-retina-url="https://irs1.4sqi.net/img/user/128x128/UWZCDYXIH51YAMWC.jpg"></a><div class="detailsWrap"><h3><div class="iconButton likeButton"><div class="buttonLeft icon"><img src="https://ss1.4sqi.net/img/button_icon_heart-867354611744be6d0146ffca1b3bdad6.png" alt="Gefällt mir "></div><div class="buttonRight label">Gefällt mir </div></div><span class="userName"><a href="https://foursquare.com/sven_kr">Sven Kräuter</a></span> hat eingecheckt bei <a href="https://foursquare.com/v/kopiba/4b169255f964a52072ba23e3">kopiba</a></h3><div class="timeStamp">Hamburg, Germany  <span class="lightPipe">|</span>  Januar 10, 2012  via <a href="https://foursquare.com/download/#/iphone">foursquare for iPhone</a></div></div></div></div><div class="shout"><p>#coffeediary</p></div><div class="commentsContainer" style=""><div class="page commentsWrapper commentThread"><div class="comments"><div class="commentsList"><div id="4f0c4020e4b0261c93fd4ede" class="comment withPhoto"><a href="https://foursquare.com/sven_kr"><img src="https://irs1.4sqi.net/img/user/35x35/UWZCDYXIH51YAMWC.jpg" alt="Sven K." class="avatar " width="35" height="35" title="Sven K." data-retina-url="https://irs1.4sqi.net/img/user/70x70/UWZCDYXIH51YAMWC.jpg"></a><div class="contentWrap"><img class="featured" src="https://irs0.4sqi.net/img/general/680x680/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg" photo-id="4f0c4020e4b0261c93fd4ede" width="680" height="680" alt="" data-retina-url="https://irs0.4sqi.net/img/general/1360x1360/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg"></div></div></div></div><div class="addCommentForm" style=""><img src="https://irs2.4sqi.net/img/user/64x64/EEI0WTBYZ32OGRSV.png" alt="Makers And C." class="avatar " width="64" height="64" title="Makers And C." data-retina-url="https://irs2.4sqi.net/img/user/128x128/EEI0WTBYZ32OGRSV.png"><div class="prompt">Hey <strong>Makers And</strong>, hinterlasse einen Kommentar:</div><span class="commentCharCount"></span><span class="posting hidden"><img class="spinner" src="/img/spinner_14.gif"></span><div class="inputWrapper"><div class="inputBackground"><div class="mentions"><div class="mirror"></div></div><textarea placeholder="Kommentieren" class="commentTextInput"></textarea></div><div class="suggestions"></div></div><div class="commentErrors"></div><div class="checkinActionButtons"><input type="submit" tabindex="2" class="greenButton addComment" value="Kommentar hinzufügen"></div></div></div></div><div class="likesFacepileSection" style="display: none;"><div class="likesTitle"><strong>0 Leuten</strong> gefällt das. </div><div class="likesFacepile empty"></div></div><div class="eventsForCheckInContainer"><div id="events"><p class="eventsHeader"><strong>About this check-in</strong></p><div class="event"><img src="https://foursquare.com/img/points/defaultpointsicon2.png" alt=""><p>Jeder Check-in verbessert deine Empfehlungen</p></div></div></div><div class="venueDetailsContainer"><div class="venueDetails"><span class="venueName"><a href="https://foursquare.com/kopiba">kopiba</a><a href="https://foursquare.com/kopiba"><img src="https://ss1.4sqi.net/img/specials/check-in-f870bc36c0cc2a842fac06c35a6dccdf.png" class="tooltip" title="" alt="Check-in Special"></a></span><div><div class="venueScore tooltip score positive" title="">9.3</div><div class="venueAddress"><span class="local">Beim Grünen Jäger 24, Hamburg</span></div><div class="venueCats"><span>Café</span></div></div></div><div class="venueHistoryTopRight"><div class="saveButton saveToListAction inactive" title="Save to my to-do list!"><span class="buttonLeft"><img src="https://ss0.4sqi.net/img/lists/button_icon_saveribbon-9c5999c47028ca670954422ee53e7d96.png" height="16" width="16" data-retina-url="https://ss1.4sqi.net/img/lists/button_icon_saveribbon@2x-d809e5af932a66d1725c40dfddcc2855.png"></span><span class="buttonRight unsaved"><span class="label">Speichern</span></span></div></div><div class="venuePhotoContainer"><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/39861258_Ulcg4M_vZ0Gkfce9Y6Han4mDkR-83QTumS5wV2RLij8.jpg" photo-id="5084ff52e4b068d89dd5dbf9" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/39861258_Ulcg4M_vZ0Gkfce9Y6Han4mDkR-83QTumS5wV2RLij8.jpg"></span><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/x1mhxhrpvjgAtQHgJLtII38EKNOA46aA7fQ0KfzMB6g.jpg" photo-id="50181552e4b0a0721fc746a5" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/x1mhxhrpvjgAtQHgJLtII38EKNOA46aA7fQ0KfzMB6g.jpg"></span><span class="photoThumb link"><img src="https://irs2.4sqi.net/img/general/125x125/8352028_BmwTYQ1KnCk522ISUVo-e8Mgn5sz42u-DRu968m0MhQ.jpg" photo-id="50f6aa1ce4b07eb72279543e" width="125" height="125" alt="" data-retina-url="https://irs2.4sqi.net/img/general/250x250/8352028_BmwTYQ1KnCk522ISUVo-e8Mgn5sz42u-DRu968m0MhQ.jpg"></span><span class="photoThumb link"><img src="https://irs1.4sqi.net/img/general/125x125/2653854_W_immUSqq2SjUyVC_2zuP84A-dOubiwBYla9CVZKO8s.jpg" photo-id="50ba05eae4b0e2256067a77d" width="125" height="125" alt="" data-retina-url="https://irs1.4sqi.net/img/general/250x250/2653854_W_immUSqq2SjUyVC_2zuP84A-dOubiwBYla9CVZKO8s.jpg"></span></div></div><span class="currentLanguageWrapper">Switch Language: <span id="currentLanguage" class="link">Deutsch</span></span></div></div></div><script type="text/javascript">fourSq.currentPage = new fourSq.views.CheckinPage({el: $('#checkinDetailPage').get(0), checkin: {"id":"4f0c401ae4b020a8d96fb0b1","createdAt":1326202906,"type":"checkin","shout":"#coffeediary","timeZoneOffset":60,"user":{"id":"304170","firstName":"Sven","lastName":"Kräuter","gender":"male","relationship":"friend","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"}},"venue":{"id":"4b169255f964a52072ba23e3","name":"kopiba","contact":{"phone":"040343824","formattedPhone":"040 343824","twitter":"kopiba","facebook":"130271680341869"},"location":{"address":"Beim Grünen Jäger 24","lat":53.558831084738,"lng":9.963698387145996,"postalCode":"20357","city":"Hamburg","country":"Germany","cc":"DE"},"canonicalUrl":"https:\/\/foursquare.com\/v\/kopiba\/4b169255f964a52072ba23e3","categories":[{"id":"4bf58dd8d48988d16d941735","name":"Café","pluralName":"Cafés","shortName":"Café","icon":{"prefix":"https:\/\/foursquare.com\/img\/categories_v2\/food\/cafe_","mapPrefix":"https:\/\/foursquare.com\/img\/categories_map\/food\/cafe","suffix":".png"},"primary":true}],"verified":true,"stats":{"checkinsCount":5121,"usersCount":885,"tipCount":37},"url":"http:\/\/www.kopiba.de","urlSig":"nK15GTWcjDP4MzV9Co9r6ugWBE8=","specials":{"count":1},"venuePage":{"id":"35040828"}},"source":{"name":"foursquare for iPhone","url":"https:\/\/foursquare.com\/download\/#\/iphone"},"photos":{"count":1,"items":[{"id":"4f0c4020e4b0261c93fd4ede","createdAt":1326202912,"prefix":"https:\/\/irs0.4sqi.net\/img\/general\/","suffix":"\/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg","width":537,"height":720,"user":{"id":"304170","firstName":"Sven","lastName":"Kräuter","gender":"male","relationship":"friend","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"}},"visibility":"friends"}]},"posts":{"count":0,"textCount":0},"likes":{"count":0,"groups":[]},"like":false,"comments":{"count":0,"items":[]},"score":{"total":1,"scores":[{"icon":"https:\/\/foursquare.com\/img\/points\/defaultpointsicon2.png","message":"Jeder Check-in verbessert deine Empfehlungen","points":1}]},"canonicalUrl":"https:\/\/foursquare.com\/sven_kr\/checkin\/4f0c401ae4b020a8d96fb0b1"},currentUser: {"lists":{"groups":[{"type":"created","count":1,"items":[]}]},"capabilities":{"canHaveFollowers":false,"canManageOtherAccounts":false,"canReceiveBadges":true,"canHaveFriends":true,"canAddTips":true},"experiments":[{"experimentName":"allowSmartCheckinPings","groupId":0.0,"enrollmentDate":1351031330},{"experimentName":"frrsvb","groupId":0.0,"enrollmentDate":1364300941},{"experimentName":"frrsvb2","groupId":1.0,"enrollmentDate":1365149578},{"experimentName":"ecgh","groupId":1.0,"enrollmentDate":1365365780},{"experimentName":"ese0410","groupId":0.0,"enrollmentDate":1366312102},{"experimentName":"tprefeb28","groupId":1.0,"enrollmentDate":1366312102},{"experimentName":"edb0422","groupId":0.0,"enrollmentDate":1367063108},{"experimentName":"evt0422","groupId":4.0,"enrollmentDate":1367063108},{"experimentName":"eugpfb","groupId":1.0,"enrollmentDate":1367063116}],"location":{"lat":53.58333,"lng":10.0,"location":"Hamburg","countryCode":"DE"},"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/EEI0WTBYZ32OGRSV.png"},"contact":{"email":"info@makersand.co"},"locale":"en_US","bio":"","lastName":"Co.","firstName":"Makers And","relationship":"self","id":"20659271","hasMobileClientConsumer":false,"canonicalUrl":"https:\/\/foursquare.com\/user\/20659271","roles":[],"isManager":false,"homeCity":"Hamburg","gender":"female"},fullVenue: {"name":"kopiba","beenHere":{"count":1,"marked":true},"stats":{"checkinsCount":5121,"usersCount":885,"tipCount":37},"location":{"city":"Hamburg","lng":9.963698387145996,"country":"Germany","postalCode":"20357","address":"Beim Grünen Jäger 24","cc":"DE","distance":3632,"lat":53.558831084738},"url":"http:\/\/www.kopiba.de","urlSig":"nK15GTWcjDP4MzV9Co9r6ugWBE8=","description":"Best Coffee in Town - Own roasting facility! Familiy run café and bar. Free wifi, coffee brands St. Pauli Deathpresso and Early Byrd.","tags":["bar","café","cocktails","deathpresso","espresso","free wifi","hamburg","kopiba","schanze","self roasted coffee","st. pauli"],"venuePage":{"id":"35040828"},"permissions":{"flagVenue":true,"editVenue":false,"addTips":true,"editCategories":false,"viewFlags":false,"editHours":true,"flagTips":true,"viewEditHistory":false},"hereNow":{"count":0,"groups":[],"summary":"0 Leute hier"},"popular":{"isOpen":false,"status":"None listed","timeframes":[{"days":"Heute","includesToday":true,"open":[{"renderedTime":"10:00\u201319:00"}],"segments":[]},{"days":"Mo","open":[{"renderedTime":"09:00\u201314:00"},{"renderedTime":"16:00\u201320:00"}],"segments":[]},{"days":"Di","open":[{"renderedTime":"11:00\u201314:00"},{"renderedTime":"16:00\u201321:00"}],"segments":[]},{"days":"Mi","open":[{"renderedTime":"Mittag\u201314:00"},{"renderedTime":"16:00\u201321:00"}],"segments":[]},{"days":"Do","open":[{"renderedTime":"Mittag\u201315:00"},{"renderedTime":"17:00\u201321:00"}],"segments":[]},{"days":"Fr","open":[{"renderedTime":"09:00\u201314:00"},{"renderedTime":"18:00\u201323:00"}],"segments":[]},{"days":"Sa","open":[{"renderedTime":"11:00\u201318:00"},{"renderedTime":"20:00\u201323:00"}],"segments":[]}]},"contact":{"twitter":"kopiba","phone":"040343824","formattedPhone":"040 343824","facebook":"130271680341869"},"specials":{"count":1,"items":[{"provider":"foursquare","interaction":{"entryUrl":"https:\/\/foursquare.com\/device\/specials\/51791550e0e2f2d7a70d8280?venueId=4b169255f964a52072ba23e3"},"state":"in progress","description":"You'll unlock this special with every 1st check-in here.","icon":"check-in","page":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/QFKULDPU2Z3JNABT.png"},"contact":{"twitter":"kopiba","facebook":"130271680341869"},"bio":"","firstName":"kopiba","id":"35040828","canonicalUrl":"https:\/\/foursquare.com\/kopiba","type":"venuePage","homeCity":"Hamburg","venue":{"id":"4b169255f964a52072ba23e3"},"gender":"none"},"likes":{"count":1,"groups":[{"type":"others","count":1,"items":[{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/FI3TM1SI3K2IR2V2.jpg"},"lastName":"B.","firstName":"Florian","id":"11294478","canonicalUrl":"https:\/\/foursquare.com\/florianbuehler","gender":"male"}]}],"summary":"Florian B"},"id":"51791550e0e2f2d7a70d8280","progress":0,"message":"5% Rabatt für jeden Checkin! (Checkin auf dem Display zeigen)","redemption":"webview","title":"Check-in Special","type":"frequency","like":false}]},"shortUrl":"http:\/\/4sq.com\/9Ff6WJ","likes":{"count":47,"groups":[{"type":"others","count":47,"items":[]}],"summary":"47 Gefällt mir"},"hours":{"isOpen":true,"status":"Open until 02:00, reopens","timeframes":[{"days":"Mo\u2013Do","open":[{"renderedTime":"09:30\u201320:00"}],"segments":[{"label":"Breakfast a la carte","renderedTime":"09:30\u201314:00"},{"label":"Coffee & Cake Special","renderedTime":"14:00\u201320:00"}]},{"days":"Fr","open":[{"renderedTime":"09:30\u201302:00"}],"segments":[{"label":"Breakfast a la carte","renderedTime":"09:30\u201314:00"},{"label":"Cocktail Happy Hour","renderedTime":"19:00\u201322:00"}]},{"days":"Sa","open":[{"renderedTime":"10:00\u201302:00"}],"segments":[{"label":"Breakfast Buffet","renderedTime":"10:00\u201314:00"},{"label":"Cocktail Happy Hour","renderedTime":"19:00\u201322:00"}]},{"days":"So","includesToday":true,"open":[{"renderedTime":"10:00\u201320:00"}],"segments":[{"label":"Breakfast Buffet","renderedTime":"10:00\u201314:00"}]}]},"id":"4b169255f964a52072ba23e3","canonicalUrl":"https:\/\/foursquare.com\/kopiba","rating":9.29,"categories":[{"pluralName":"Cafés","name":"Café","icon":{"prefix":"https:\/\/foursquare.com\/img\/categories_v2\/food\/cafe_","mapPrefix":"https:\/\/foursquare.com\/img\/categories_map\/food\/cafe","suffix":".png"},"id":"4bf58dd8d48988d16d941735","shortName":"Café","primary":true},{"pluralName":"Frühstücksplätze","name":"Frühstücksplatz","icon":{"prefix":"https:\/\/foursquare.com\/img\/categories_v2\/food\/breakfast_","mapPrefix":"https:\/\/foursquare.com\/img\/categories_map\/food\/default","suffix":".png"},"id":"4bf58dd8d48988d143941735","shortName":"Frühstück \/ Brunch"},{"pluralName":"Bars ","name":"Bar","icon":{"prefix":"https:\/\/foursquare.com\/img\/categories_v2\/nightlife\/bar_","mapPrefix":"https:\/\/foursquare.com\/img\/categories_map\/nightlife\/bar","suffix":".png"},"id":"4bf58dd8d48988d116941735","shortName":"Bar"}],"createdAt":1259770453,"tips":{"count":37,"groups":[{"count":6,"items":[{"url":"","urlSig":"CQD3KKqxEwwqY7lJ5kNrlSJ1tn8=","text":"There is free Wifi. Just ask for the passphrase.","likes":{"count":17,"groups":[{"type":"others","count":17,"items":[]}],"summary":"17 Gefällt mir"},"id":"4c9665eff6c8ef3b952a82cf","canonicalUrl":"https:\/\/foursquare.com\/item\/4c9665eff6c8ef3b952a82cf","createdAt":1284924911,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"},"like":false},{"text":"Self roasted coffee beans - absolutely delicious espresso.","likes":{"count":16,"groups":[{"type":"others","count":16,"items":[]}],"summary":"16 Gefällt mir"},"id":"4b681b0270c603bbba5791b4","canonicalUrl":"https:\/\/foursquare.com\/item\/4b681b0270c603bbba5791b4","createdAt":1265113858,"todo":{"count":2},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"},"lastName":"Kräuter","firstName":"Sven","relationship":"friend","id":"304170","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","gender":"male"},"like":false},{"url":"http:\/\/www.kopiba.de","urlSig":"nK15GTWcjDP4MzV9Co9r6ugWBE8=","text":"Best coffee in Schanzenviertel","likes":{"count":15,"groups":[{"type":"others","count":15,"items":[]}],"summary":"15 Gefällt mir"},"id":"4c3db0460928b713d23695ef","canonicalUrl":"https:\/\/foursquare.com\/item\/4c3db0460928b713d23695ef","createdAt":1279111238,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/EDQTGEXLUIAKAWQG.png"},"firstName":"kopiba","relationship":"friend","id":"2085682","canonicalUrl":"https:\/\/foursquare.com\/user\/2085682","gender":"male"},"like":false},{"text":"Get a Deathpresso t-shirt or bag and flaunt your coffee stylez.","likes":{"count":9,"groups":[{"type":"others","count":9,"items":[{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/IKG0KJD245Z2EDC4.jpg"},"lastName":"K.","firstName":"Rouven","id":"2955841","canonicalUrl":"https:\/\/foursquare.com\/gestalterhuette","gender":"male"}]}],"summary":"9 Gefällt mir"},"id":"4ecceab4cc21561612614eb1","canonicalUrl":"https:\/\/foursquare.com\/item\/4ecceab4cc21561612614eb1","createdAt":1322052276,"todo":{"count":3},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"},"like":false},{"url":"","urlSig":"CQD3KKqxEwwqY7lJ5kNrlSJ1tn8=","text":"You can get everything with decaf Espresso. Yum!","likes":{"count":9,"groups":[{"type":"others","count":9,"items":[]}],"summary":"9 Gefällt mir"},"id":"4c96657ff6c8ef3b2d2882cf","canonicalUrl":"https:\/\/foursquare.com\/item\/4c96657ff6c8ef3b2d2882cf","createdAt":1284924799,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"},"like":false},{"text":"Decaf chocolate frappissimo, yum! Goes well with chocolate cake :)","likes":{"count":3,"groups":[{"type":"others","count":3,"items":[]}],"summary":"3 Gefällt mir"},"id":"4d4eb9854f67224b38a76550","canonicalUrl":"https:\/\/foursquare.com\/item\/4d4eb9854f67224b38a76550","createdAt":1297004933,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"},"like":false}],"type":"friends","name":"Tipps von Freunden"},{"count":31,"items":[{"url":"http:\/\/www.facebook.com\/pages\/kopiba-Kaffeerosterei-Bar\/130271680341869","urlSig":"juS1uGDDmuOmzgmdyDspbaoDXhI=","text":"Check them on Facebook!","likes":{"count":24,"groups":[{"type":"others","count":24,"items":[]}],"summary":"24 Gefällt mir"},"id":"4d0f776db3692d43f18535de","canonicalUrl":"https:\/\/foursquare.com\/item\/4d0f776db3692d43f18535de","createdAt":1292859245,"todo":{"count":4},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JH4NWSXXPOVJYA41.jpg"},"lastName":"W.","firstName":"Sven","id":"143490","canonicalUrl":"https:\/\/foursquare.com\/svenwiesner","gender":"male"},"like":false},{"text":"Seit März 2011: ec-Kartenzahlung möglich, bald Kreditkarte auch","likes":{"count":12,"groups":[{"type":"others","count":12,"items":[]}],"summary":"12 Gefällt mir"},"id":"4d7680ce3798a1cd7a0a33ca","canonicalUrl":"https:\/\/foursquare.com\/item\/4d7680ce3798a1cd7a0a33ca","createdAt":1299611854,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/F3WIPHXNSSPS415H.jpg"},"lastName":"M.","firstName":"Romy","id":"110666","canonicalUrl":"https:\/\/foursquare.com\/snoopsmaus","gender":"female"},"like":false},{"text":"Best coffee in town!","likes":{"count":9,"groups":[{"type":"others","count":9,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"}]}],"summary":"9 Gefällt mir"},"id":"4dcc0cc01f6ea1401d4d8ce9","canonicalUrl":"https:\/\/foursquare.com\/item\/4dcc0cc01f6ea1401d4d8ce9","createdAt":1305218240,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/44ZH22TR0E3EXMQG.jpg"},"lastName":"S.","firstName":"Frank","id":"135275","canonicalUrl":"https:\/\/foursquare.com\/franks","gender":"male"},"like":false},{"photo":{"source":{"name":"foursquare for Android","url":"https:\/\/foursquare.com\/download\/#\/android"},"prefix":"https:\/\/irs0.4sqi.net\/img\/general\/","suffix":"\/uH8uPFG_MPI4kAC9PvhgzFYpXlERyNgBRsQpmiv3A1c.jpg","height":720,"id":"50324471e4b01a9da00b361e","createdAt":1345471601,"width":406},"text":"Auf Wunsch gibt's \"Mipfel\". Minz-Apfel Granizado","likes":{"count":6,"groups":[{"type":"others","count":6,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"},{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/RX051IGZPR43V1IO.jpg"},"firstName":"Elo","id":"389736","canonicalUrl":"https:\/\/foursquare.com\/frauelo","gender":"female"},{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/1PBBQY3IKLHT4I5Z.jpg"},"firstName":"Malte","id":"12007792","canonicalUrl":"https:\/\/foursquare.com\/sanktpony","gender":"male"},{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/2XCZOYXBYWLMHA05.jpg"},"lastName":"M.","firstName":"Christina","id":"31482063","canonicalUrl":"https:\/\/foursquare.com\/user\/31482063","gender":"female"}]}],"summary":"6 Gefällt mir"},"id":"5032446fe4b07d6b3648da7e","canonicalUrl":"https:\/\/foursquare.com\/item\/5032446fe4b07d6b3648da7e","createdAt":1345471599,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"},"like":false},{"text":"Ab jetzt auch hausgemachte Pasta zum Lunch. Yummy!","likes":{"count":6,"groups":[{"type":"others","count":6,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"}]}],"summary":"6 Gefällt mir"},"id":"4e78a8277d8b90e4422a9cec","canonicalUrl":"https:\/\/foursquare.com\/item\/4e78a8277d8b90e4422a9cec","createdAt":1316530215,"todo":{"count":4},"user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/DHPLMBHTGZJNXFZC.jpg"},"lastName":"S.","firstName":"Friederike","id":"1643859","canonicalUrl":"https:\/\/foursquare.com\/miss_r_e","gender":"female"},"like":false},{"text":"Try 'judiths gaypefruit happy  peppermint party' !! Awesome cocktail !!!","likes":{"count":5,"groups":[{"type":"friends","count":1,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}]},{"type":"others","count":4,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"}]}],"summary":"5 Personen gefällt das - Matthias B"},"id":"4ec7d2c661af9e14301ede37","canonicalUrl":"https:\/\/foursquare.com\/item\/4ec7d2c661af9e14301ede37","createdAt":1321718470,"todo":{"count":3},"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"},"like":false},{"text":"Die Frische Minze ist super, wenn es mal kein Kaffee sein soll und es draussen kalt ist.","likes":{"count":4,"groups":[{"type":"friends","count":1,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}]},{"type":"others","count":3,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/JLREN2E14QNQX0S3.jpg"},"firstName":"MultaniFX","id":"174058","canonicalUrl":"https:\/\/foursquare.com\/multanifx","gender":"male"}]}],"summary":"4 Personen gefällt das - Matthias B"},"id":"504e1e07e4b03c3db278e273","canonicalUrl":"https:\/\/foursquare.com\/item\/504e1e07e4b03c3db278e273","createdAt":1347296775,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/F51FECN4M0K2TVFD.jpg"},"lastName":"W.","firstName":"Julian","id":"108955","canonicalUrl":"https:\/\/foursquare.com\/julianwki","gender":"male"},"like":false},{"text":"Hipstercafe für Internethipster. Aber trotzdem nett.","likes":{"count":4,"groups":[{"type":"others","count":4,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/IVXPACCGH1MGBFZZ.jpg"},"firstName":"JustMeHH","id":"24943698","canonicalUrl":"https:\/\/foursquare.com\/user\/24943698","gender":"female"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/BIEZ5QKYQMRZTUPZ.jpg"},"lastName":"S.","firstName":"Sarah","id":"17845224","canonicalUrl":"https:\/\/foursquare.com\/hunger24","gender":"none"}]}],"summary":"4 Gefällt mir"},"id":"4f9ec0bbe4b0d2bd64a71b1c","canonicalUrl":"https:\/\/foursquare.com\/item\/4f9ec0bbe4b0d2bd64a71b1c","createdAt":1335804091,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/WC5CFOWOKU5DD2JH.jpg"},"lastName":"B.","firstName":"Sebastian","id":"177100","canonicalUrl":"https:\/\/foursquare.com\/infinsternis","gender":"male"},"like":false},{"text":"an warmen tagen kühlt der eiskaffee bestens","likes":{"count":4,"groups":[{"type":"others","count":4,"items":[]}],"summary":"4 Gefällt mir"},"id":"4db56e7081543d71da578df0","canonicalUrl":"https:\/\/foursquare.com\/item\/4db56e7081543d71da578df0","createdAt":1303735920,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JPFVX32IWMALDZMJ.jpg"},"firstName":"maxi_b","id":"4339593","canonicalUrl":"https:\/\/foursquare.com\/maxi_b","gender":"female"},"like":false},{"text":"Gin Tonic (Bombays) mit Gurke!","likes":{"count":3,"groups":[{"type":"others","count":3,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/I2YOYM23VEYKI343.jpg"},"lastName":"v.","firstName":"Cordelia","id":"52732235","canonicalUrl":"https:\/\/foursquare.com\/user\/52732235","gender":"female"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/1IRKSZWMQ4POA123.jpg"},"lastName":"H.","firstName":"Robert","id":"41972106","canonicalUrl":"https:\/\/foursquare.com\/user\/41972106","gender":"male"},{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/NSHSVTSSUQXGHZZX.jpg"},"lastName":"B.","firstName":"Paul","id":"727880","canonicalUrl":"https:\/\/foursquare.com\/paulbaum","gender":"male"}]}],"summary":"3 Gefällt mir"},"id":"51311adde4b02c44577262c7","canonicalUrl":"https:\/\/foursquare.com\/item\/51311adde4b02c44577262c7","createdAt":1362172637,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/WMMEHEGOZZSXD4RW.jpg"},"firstName":"Christian","id":"4864425","canonicalUrl":"https:\/\/foursquare.com\/schwinaldo","gender":"male"},"like":false},{"text":"Try out the breakfast buffet on weekends","likes":{"count":3,"groups":[{"type":"others","count":3,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"}]}],"summary":"3 Gefällt mir"},"id":"4c3084507cc0c9b6556bed9a","canonicalUrl":"https:\/\/foursquare.com\/item\/4c3084507cc0c9b6556bed9a","createdAt":1278248016,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/G2EYM2UVCHKPY32C.jpg"},"lastName":"L.","firstName":"Benny","id":"512552","canonicalUrl":"https:\/\/foursquare.com\/laude","gender":"male"},"like":false},{"text":"Wi-Fi network: kopiba Guest. Password: deathpresso","likes":{"count":2,"groups":[{"type":"others","count":2,"items":[{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/KDXUMMMUXRLBAENH.png"},"firstName":"Ben","id":"5001785","canonicalUrl":"https:\/\/foursquare.com\/salzig","gender":"male"},{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UW2MQ3H1B04BRG4H.gif"},"firstName":"Felix","id":"1758999","canonicalUrl":"https:\/\/foursquare.com\/user\/1758999","gender":"male"}]}],"summary":"2 Gefällt mir"},"id":"4fffeecbe4b077c7a9e2e30f","canonicalUrl":"https:\/\/foursquare.com\/item\/4fffeecbe4b077c7a9e2e30f","createdAt":1342172875,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/XTQ4ABMQ2IFORB31.jpg"},"lastName":"P.","firstName":"Dmitry","id":"27670602","canonicalUrl":"https:\/\/foursquare.com\/user\/27670602","gender":"male"},"like":false},{"text":"try kopiba43. best coffeeshot!","likes":{"count":2,"groups":[{"type":"friends","count":1,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}]},{"type":"others","count":1,"items":[]}],"summary":"2 Personen gefällt das - Matthias B"},"id":"4ec2d974775b802d2003706b","canonicalUrl":"https:\/\/foursquare.com\/item\/4ec2d974775b802d2003706b","createdAt":1321392500,"todo":{"count":0},"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"},"like":false},{"text":"Try the lunch special - excellent starters included.","likes":{"count":2,"groups":[{"type":"others","count":2,"items":[]}],"summary":"2 Gefällt mir"},"id":"4e2983e945ddfe8f9dfcaa5a","canonicalUrl":"https:\/\/foursquare.com\/item\/4e2983e945ddfe8f9dfcaa5a","createdAt":1311343593,"todo":{"count":3},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/H5KBTARS2M1NEZ12.jpg"},"lastName":"M.","firstName":"Stefan","id":"3797193","canonicalUrl":"https:\/\/foursquare.com\/erfolgsspur","gender":"male"},"like":false}],"type":"others","name":"Tipps von anderen"}]},"mayor":{"count":25,"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/VWQUWDEMZDJHZORT.jpg"},"lastName":"L.","firstName":"Judith","id":"9823634","canonicalUrl":"https:\/\/foursquare.com\/juedithe","gender":"female"}},"friendVisits":{"count":18,"items":[{"visitedCount":1,"liked":false,"user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/EEI0WTBYZ32OGRSV.png"},"lastName":"Co.","firstName":"Makers And","relationship":"self","id":"20659271","canonicalUrl":"https:\/\/foursquare.com\/user\/20659271","gender":"female"}},{"visitedCount":490,"liked":true,"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}},{"visitedCount":174,"liked":true,"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"},"lastName":"Kräuter","firstName":"Sven","relationship":"friend","id":"304170","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","gender":"male"}},{"visitedCount":48,"liked":false,"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/LDIY5ZMG0OYWNU20.jpg"},"lastName":"HH","firstName":"Kuemmel","relationship":"friend","id":"851159","canonicalUrl":"https:\/\/foursquare.com\/kuemmel_hh","gender":"female"}},{"visitedCount":44,"liked":false,"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/ECGA3OT51JXXMP4Q.png"},"lastName":"Lüders","firstName":"Lasse","relationship":"friend","id":"108262","canonicalUrl":"https:\/\/foursquare.com\/lueti","gender":"male"}},{"visitedCount":36,"liked":false,"user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/MQXJOQTEE2V0NKVD.jpg"},"lastName":"Meyer","firstName":"Inken","relationship":"friend","id":"613731","canonicalUrl":"https:\/\/foursquare.com\/meyola","gender":"female"}},{"visitedCount":23,"liked":true,"user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/PHSBMWWE30LL5ODJ.jpg"},"lastName":"S.","firstName":"Rene","relationship":"friend","id":"497906","canonicalUrl":"https:\/\/foursquare.com\/renehamburg","gender":"male"}}],"summary":"Du und 17 Freunde seid hier gewesen"},"verified":true,"like":false,"listed":{"groups":[{"type":"friends","name":"Listen von Freunden","count":4,"items":[{"name":"Must-visit Cafés in Hamburg","updatedAt":1.316909702E9,"url":"https:\/\/foursquare.com\/look_now\/list\/mustvisit-caf%C3%A9s-in-hamburg","description":"","followers":{"count":14},"public":true,"id":"4e7e7286f9f43946e7b9c7a2","canonicalUrl":"https:\/\/foursquare.com\/look_now\/list\/mustvisit-caf%C3%A9s-in-hamburg","createdAt":1316909702,"listItems":{"count":8,"items":[{"id":"v4b169255f964a52072ba23e3","createdAt":1316909702}]},"type":"friends","collaborative":false,"user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/NGDP30ANSUKMPKEN.jpg"},"lastName":"W","firstName":"Nicole","relationship":"friend","id":"1275267","canonicalUrl":"https:\/\/foursquare.com\/look_now","gender":"female"},"editable":false},{"name":"Favorites on the Schanze","updatedAt":1.35610828E9,"url":"https:\/\/foursquare.com\/jormason\/list\/favorites-on-the-schanze","description":"the best places to eat, work, make party in the Schanzenviertel in Hamburg","followers":{"count":3},"public":true,"id":"4e91798edab46521c17639c8","canonicalUrl":"https:\/\/foursquare.com\/jormason\/list\/favorites-on-the-schanze","createdAt":1318156686,"listItems":{"count":14,"items":[{"id":"v4b169255f964a52072ba23e3","createdAt":1318156833}]},"type":"friends","collaborative":true,"user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/Z4UR55XHNYRGAYZR.jpg"},"lastName":"Ast","firstName":"Joern Hendrik","relationship":"friend","id":"251998","canonicalUrl":"https:\/\/foursquare.com\/jormason","gender":"male"},"editable":true},{"name":"Hamburg","updatedAt":1.366898607E9,"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/general\/","suffix":"\/CP6b6ue_nIDJwOBW6tK_UnF6CJw4DhxjtbnsNAUW-Dw.jpg","height":540,"id":"502bfbb4e4b01590f9bdec03","createdAt":1345059764,"width":720,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/HEZI5XFARZLHXBXP.jpg"},"lastName":"K.","firstName":"Hans-Joachim","id":"3044320","canonicalUrl":"https:\/\/foursquare.com\/werk2","gender":"male"}},"url":"https:\/\/foursquare.com\/sven_kr\/list\/hamburg","description":"","followers":{"count":2},"public":true,"id":"50c385e9e4b085c8e3d3d1d5","canonicalUrl":"https:\/\/foursquare.com\/sven_kr\/list\/hamburg","createdAt":1354991081,"listItems":{"count":28,"items":[{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/general\/","suffix":"\/304170_cr5zUdRg3xQmLREuAi8CZiakZSglIuFNUnUHxgsiSFk.jpg","height":537,"id":"50a9025ae4b0495d7f54b882","createdAt":1353253466,"width":720,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"},"lastName":"Kräuter","firstName":"Sven","relationship":"friend","id":"304170","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","gender":"male"}},"id":"v4b169255f964a52072ba23e3","createdAt":1354998644},{"id":"t4c3db0460928b713d23695ef","createdAt":1354998669,"tip":{"url":"http:\/\/www.kopiba.de","urlSig":"nK15GTWcjDP4MzV9Co9r6ugWBE8=","text":"Best coffee in Schanzenviertel","likes":{"count":15,"groups":[{"type":"others","count":15,"items":[]}],"summary":"15 Gefällt mir"},"id":"4c3db0460928b713d23695ef","canonicalUrl":"https:\/\/foursquare.com\/item\/4c3db0460928b713d23695ef","createdAt":1279111238,"todo":{"count":1},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/EDQTGEXLUIAKAWQG.png"},"firstName":"kopiba","relationship":"friend","id":"2085682","canonicalUrl":"https:\/\/foursquare.com\/user\/2085682","gender":"male"},"like":false}}]},"type":"friends","collaborative":false,"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"},"lastName":"Kräuter","firstName":"Sven","relationship":"friend","id":"304170","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","gender":"male"},"editable":false}]},{"type":"others","name":"Listen von anderen Leuten","count":60,"items":[{"name":"Alles in Hamburg","updatedAt":1.366700366E9,"url":"https:\/\/foursquare.com\/cps2006\/list\/alles-in-hamburg","description":"","followers":{"count":35},"public":true,"id":"4ed51a767ee5ddf314b432a3","canonicalUrl":"https:\/\/foursquare.com\/cps2006\/list\/alles-in-hamburg","createdAt":1322588790,"listItems":{"count":169,"items":[{"id":"v4b169255f964a52072ba23e3","createdAt":1325976392}]},"type":"others","collaborative":false,"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/IWU4GA15KEV2UO2P.jpg"},"lastName":"P.","firstName":"Christian","id":"7459702","canonicalUrl":"https:\/\/foursquare.com\/cps2006","gender":"male"},"editable":false},{"name":"StorefrontSticker #4sqCities: Hamburg","updatedAt":1.358793744E9,"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/general\/","suffix":"\/OjQiPvKPYkGp-aycH5F64gCsVv5bb7BkAlH7SRYVtHg.jpg","height":540,"id":"4f7d91dfe4b002615a2e00a1","createdAt":1333629407,"width":720,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/BY13RPWFYOAIZK4M.jpg"},"lastName":"S.","firstName":"Frauke","id":"21918659","canonicalUrl":"https:\/\/foursquare.com\/user\/21918659","gender":"female"}},"url":"https:\/\/foursquare.com\/storefrontstick\/list\/storefrontsticker-4sqcities-hamburg","description":"","followers":{"count":17},"public":true,"id":"501e9f57e4b0ccb681d26bfa","canonicalUrl":"https:\/\/foursquare.com\/storefrontstick\/list\/storefrontsticker-4sqcities-hamburg","createdAt":1344184151,"listItems":{"count":183,"items":[{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/WIImXmWHPJCkiV8SYC0joDk7NaoCmesnjIMGPGSmy88.jpg","height":612,"id":"501d9bb7e4b00e1d08fd13c6","createdAt":1344117687,"width":612,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}},"id":"t4b681b0270c603bbba5791b4","createdAt":1344632231,"tip":{"text":"Self roasted coffee beans - absolutely delicious espresso.","likes":{"count":16,"groups":[{"type":"others","count":16,"items":[]}],"summary":"16 Gefällt mir"},"id":"4b681b0270c603bbba5791b4","canonicalUrl":"https:\/\/foursquare.com\/item\/4b681b0270c603bbba5791b4","createdAt":1265113858,"todo":{"count":2},"user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/UWZCDYXIH51YAMWC.jpg"},"lastName":"Kräuter","firstName":"Sven","relationship":"friend","id":"304170","canonicalUrl":"https:\/\/foursquare.com\/sven_kr","gender":"male"},"like":false}}]},"type":"others","collaborative":false,"user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/DOKMQQTHVHINKWJW.png"},"firstName":"StorefrontSticker","id":"30390767","canonicalUrl":"https:\/\/foursquare.com\/storefrontstick","type":"page","gender":"none"},"editable":false}]}],"count":64},"timeZone":"Europe\/Berlin","photos":{"count":202,"groups":[{"type":"venue","name":"Venue-Fotos","count":202,"items":[{"source":{"name":"foursquare for iPhone","url":"https:\/\/foursquare.com\/download\/#\/iphone"},"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/39861258_Ulcg4M_vZ0Gkfce9Y6Han4mDkR-83QTumS5wV2RLij8.jpg","height":540,"id":"5084ff52e4b068d89dd5dbf9","createdAt":1350893394,"width":540,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs2.4sqi.net\/img\/user\/","suffix":"\/04N3V20HPMFOBJQI.jpg"},"lastName":"N.","firstName":"Mario","id":"39861258","canonicalUrl":"https:\/\/foursquare.com\/user\/39861258","gender":"male"}},{"source":{"name":"Instagram","url":"http:\/\/instagram.com"},"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/x1mhxhrpvjgAtQHgJLtII38EKNOA46aA7fQ0KfzMB6g.jpg","height":612,"id":"50181552e4b0a0721fc746a5","createdAt":1343755602,"width":612,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/JNYLLBOCW0WANBGU.jpg"},"lastName":"Bauer","firstName":"Matthias","relationship":"friend","id":"93567","canonicalUrl":"https:\/\/foursquare.com\/moeffju","gender":"male"}},{"source":{"name":"foursquare for iPhone","url":"https:\/\/foursquare.com\/download\/#\/iphone"},"prefix":"https:\/\/irs2.4sqi.net\/img\/general\/","suffix":"\/8352028_BmwTYQ1KnCk522ISUVo-e8Mgn5sz42u-DRu968m0MhQ.jpg","height":717,"id":"50f6aa1ce4b07eb72279543e","createdAt":1358342684,"width":959,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/RKCVDKVCPOIQVKRW.jpg"},"lastName":"K.","firstName":"Steffen","id":"8352028","canonicalUrl":"https:\/\/foursquare.com\/user\/8352028","gender":"male"}},{"source":{"name":"foursquare for Android","url":"https:\/\/foursquare.com\/download\/#\/android"},"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/2653854_W_immUSqq2SjUyVC_2zuP84A-dOubiwBYla9CVZKO8s.jpg","height":720,"id":"50ba05eae4b0e2256067a77d","createdAt":1354368490,"width":406,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/BMLTTVPHP3E1HCBH.jpg"},"firstName":"Christine","id":"2653854","canonicalUrl":"https:\/\/foursquare.com\/fake_empire","gender":"female"}},{"source":{"name":"foursquare for iPhone","url":"https:\/\/foursquare.com\/download\/#\/iphone"},"prefix":"https:\/\/irs2.4sqi.net\/img\/general\/","suffix":"\/39447563_prA36VaH6oDrZVfN7fAUvuP52nTv12oDYgpDgRoquAY.jpg","height":720,"id":"509677f0e4b0e34d638d1286","createdAt":1352038384,"width":537,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/BGDIUV0JLPU3WILA.jpg"},"lastName":"P.","firstName":"Mine","id":"39447563","canonicalUrl":"https:\/\/foursquare.com\/user\/39447563","gender":"female"}},{"source":{"name":"foursquare for Android","url":"https:\/\/foursquare.com\/download\/#\/android"},"prefix":"https:\/\/irs3.4sqi.net\/img\/general\/","suffix":"\/40529217_Ab39dfegSq-97DVrT6jIl_mOSTM2kfSPAgP5AA89N8k.jpg","height":720,"id":"509f71e3e4b0d60e8e3f8329","createdAt":1352626659,"width":720,"visibility":"public","user":{"photo":{"prefix":"https:\/\/irs3.4sqi.net\/img\/user\/","suffix":"\/44VAA3YZ3VNXLLXG.jpg"},"firstName":"Der josi","id":"40529217","canonicalUrl":"https:\/\/foursquare.com\/derjosihh","gender":"male"}}]}]}},canZoomMap: false, signature: 'eU7t9fpmByekJgPb8IOuchQ9ibw', cannotSeeCommentReason: '', cannotAddCommentReason: ''}).decorate();</script><div id="containerFooter"><div class="wideColumn"><ul class="notranslate"><li><a href="/about">Über</a></li><li><a href="http://blog.foursquare.com">Blog</a></li><li><a href="http://business.foursquare.com">Unternehmen</a></li><li><a href="/cities">Städte</a></li><li><a href="http://developer.foursquare.com">ENTWICKLER:</a></li><li><a href="http://foursquare.com/help">Hilfe</a></li><li><a href="/jobs/">Jobs</a></li><li><a href="/legal/privacy">Datenschutz (Updated)</a></li><li><a href="/legal/terms">AGB (Updated)</a></li><li><a href="http://store.foursquare.com">Store</a></li><li><span id="currentLanguage" class="link">Deutsch</span></li></ul></div><div class="narrowColumn">Foursquare © 2013 <img src="https://ss1.4sqi.net/img/icon-mini-crown-cdef5bfd4afc2ff3038c790ea2ae1e14.png" alt="" width="12" height="9"><span title="und Ithaka, Madison, Edinburgh &amp; London">Liebevoll in NYC &amp; SF hergestellt</span></div></div></div>
  ^
end

def stub_eyeem
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:header_str).and_return "HTTP/1.1 200 OK\r\nServer: nginx/1.0.5\r\nDate: Sun, 15 Apr 2012 09:16:58 GMT\r\nContent-Type: text/html; charset=utf-8\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\nX-Powered-By: PHP/5.3.6-13ubuntu3.6\r\nSet-Cookie: symfony=bv8mdicp6ucb8jr9qt0o0r7qk2; path=/\r\nExpires: Thu, 19 Nov 1981 08:52:00 GMT\r\nCache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\nPragma: no-cache\r\n\r\n"
  Curl::Easy.any_instance.stub(:body_str).and_return "<!DOCTYPE html>\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"shortcut icon\" href=\"/favicon.ico\" />\n<meta name=\"title\" content=\"EyeEm\" />\n<meta name=\"description\" content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It&#039;s free.\" />\n<title>EyeEm</title>\n<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"/css/eyeem.c.css?1334330223\" />\n  <meta content=\"EyeEm\" property=\"og:title\">\n<meta content=\"website\" property=\"og:type\">\n<meta content=\"EyeEm\" property=\"og:site_name\">\n<meta content=\"http://www.eyeem.com/p/326629\" property=\"og:url\">\n<meta content=\"http://www.eyeem.com/thumb/640/480/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\" property=\"og:image\">\n<meta content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It's free.\" property=\"og:description\">\n<meta content=\"138146182878222\" property=\"fb:app_id\">\n<script type=\"text/javascript\">\n\n  var _gaq = _gaq || [];\n  _gaq.push(['_setAccount', 'UA-12590370-2']);\n  _gaq.push(['_trackPageview']);\n\n  (function() {\n    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n  })();\n\n</script>\n</head>\n<body>\n\n<div id=\"fb-root\">\n  <!-- you must include this div for the JS SDK to load properly -->\n</div>\n<script>\n  window.fbAsyncInit = function() {\n    FB.init({\n      appId      : '138146182878222', // App ID\n      channelUrl : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File\n      status     : true, // check login status\n      cookie     : true, // enable cookies to allow the server to access the session\n      xfbml      : true  // parse XFBML\n    });\n\n    // Additional initialization code here\n  };\n\n  // Load the SDK Asynchronously\n  (function(d){\n     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];\n     if (d.getElementById(id)) {return;}\n     js = d.createElement('script'); js.id = id; js.async = true;\n     js.src = \"//connect.facebook.net/en_US/all.js\";\n     ref.parentNode.insertBefore(js, ref);\n   }(document));\n</script>\n  \n  \n\n\n  <div id=\"page\">\n        <div id=\"header\">\n      <div name=\"top\" class=\"top_bar\"><div class=\"top_bar-inner\">\n  <div class=\"padding-top\"></div>\n  <div class=\"top_bar_content\">\n    <div class=\"search_box\">\n    \t<form action=\"/search\" method=\"get\" enctype=\"application/x-www-form-urlencoded\">\n        <input type=\"text\" name=\"query\" class=\"search_form_query\" placeholder=\"Search\" id=\"query\" />  <!--   \t  <input class=\"search_form_submit\" type=\"image\" value=\"submit\" src=\"\"/> -->\n    \t  <input class=\"search_form_submit\" type=\"submit\" value=\"\" />\n    \t</form>\n    </div>\n    <div class=\"homelink\">\n    \t<a href=\"/\">\n        <img src=\"/images/layout/topbar_logo.png\">\n    \t</a>\n    </div>\n    \n    \n      \n    <div class=\"top_menus\">\n            <div class=\"top_menu user_menu\">\n  \t\t  <a class=\"user_login smooth_hover\" href=\"/login\">\n  \t\t\t\t<span class=\"\">Login</span>\n  \t\t  </a>\n      </div>\n      \n      \n      \n            <div class=\"top_menu about_menu\">\n  \t\t  <a class=\"top_menu_button about_box smooth_hover\" href=\"javascript:void(0)\">\n  \t\t\t\t<span class=\"about_name\">About</span>\n  \t\t    <img class=\"more_triangle\" src=\"/images/layout/topbar_triangle.png\">\n  \t\t  </a>\n  \t\t  <ul class=\"\">\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/whatiseyeem\"><span>What is EyeEm?</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/gettheapp\"><span>Download the App</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/contact\"><span>Contact and Press</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/team\"><span>Team & Jobs</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"http://blog.eyeem.com\" target=\"_blank\"><span>Blog</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/pages/service.html\"><span>Terms of service</span></a></li>\n  \t\t  </ul>\n      </div>  \n    </div>\n    \n  </div>\n</div></div>\n      <div class=\"top_bar_back\"></div>\n    </div> <!-- /#header -->\n    <div id=\"content\">\n      \n\n<div class=\"join_block\">\n  <div class=\"join_inner\">\n    <span class=\"join_description\">\n      <p>Take &amp; Discover photos</p>\n      <p>together with EyeEm!</p>\n    </span>\n    <div class=\"join_now\">\n      <div><a class=\"eyeem_button join_button\" href=\"/signup\">Join now!</a></div>\n      <div class=\"learn_more\"><a class=\"\" href=\"/whatiseyeem\">Learn more</a></div>\n    </div>\n  </div>\n</div>\n<div class=\"inner-content photo_inner_content\">\n  <div class=\"photo_indicator\"><img src=\"/images/layout/triangle_indicator.png\"></div>\n  <div class=\"viewports-wrapper\">\n    <div class=\"viewport active\" data-photo-id=\"326629\">\n        \n\n <div class=\"viewport-user\">\n  \t<a href=\"/u/8157\">\n  \t\t<img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  \t</a>\n  \t<span class=\"user_text\">\n    \t<a class=\"user_name\" href=\"/u/8157\">\n    \t\t<span><h2>Sven Kr\xC3\xA4uter</h2></span>\n    \t</a>\n    \t<div class=\"meta\">\n        <div class=\"viewport-age\">\n  \t     <span>4</span> days ago        </div>\n            \t</div>\n  \t</span>\n          </div>  \t\t\n  \t\t\n  \t\t\n    <div class=\"viewport-pic\">\n        <img src=\"http://www.eyeem.com/thumb/h/1024/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\">\n  </div>\n  \n  \n    <div class=\"viewport-albums\">\n        <div class=\"tags tags_arrow\">\n                  \n                  \n      <div class=\"album_tag_box hover_container\">\n        <a class=\"album_tag tag\" href=\"/a/168255\">#coffeediary</a>\n                  </div>                \t    \t\n    \t    </div>\n    <div class=\"places tags_arrow\">\n                \t    </div>\n  </div>\n    \n  \n\n  <div class=\"viewport-likes\">\n        <div class=\"likes_count count\">1 like</div>\n    <span class=\"user_thumbs\">\n                <a class=\"user_thumb hover_container\" href=\"/u/85456\">\n  <img class=\"user_face\" alt=\"filtercake-nophoto\" src=\"http://www.eyeem.com/thumb/sq/50/a5799d443153b9becad3a1e15d15c1ad79739f32.jpg\">\n            </a>\n              </span>\n  \t<span class=\"like_area\">\n      <div class=\"like_action action\">\n    \t    \t\t    \t\t\t<a class=\"photo_like eyeem_button like_button\" href=\"javascript:void(0)\">Like<img class=\"button_spinner\" src=\"/images/layout/spinner.gif\"></a>\n    \t\t    \t      </div>  \t\n      \t\n  \t</span>\n  </div>\n  \n  \n  <div class=\"viewport-comments\">\n  \t<div class=\"comments_count count\">1 comment</div>\n  \t  \t<div class=\"comment_box\">\n    <a class=\"user_face_link\" href=\"/u/8157\">\n    <img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  </a>\n  <span class=\"comment_display\">\n    <a class=\"user_name\" href=\"/u/8157\">\n      Sven Kr\xC3\xA4uter    </a>\n    <div class=\"comment_body\">\n      still using the bialetti until the spare parts for the espresso machine arrive. quite cozy actually.          </div>\n    <div class=\"comment_age\"><span>4</span> days ago</div>\n  </span>\n</div>\n  \t      </div>\n  \n  <div class=\"viewport-social\">\n    <div class=\"social\">\n      <div class=\"twitter-like\">\n        <script src=\"http://platform.twitter.com/widgets.js\" type=\"text/javascript\"></script>\n        <a href=\"http://twitter.com/share\" class=\"twitter-share-button\" data-url=\"http://www.eyeem.com/p/326629\">Tweet</a>\n      </div>\n      <div class=\"facebook-like\">\n        <div class=\"fb-like\" data-href=\"http://www.eyeem.com/p/326629\" data-send=\"false\" data-layout=\"button_count\" data-width=\"20\" data-show-faces=\"false\" data-font=\"verdana\"></div>\n      </div>\n    </div>\n  </div>\n\n    </div>\n  </div>\n</div>    </div> <!-- /#content -->\n  </div> <!-- /#page -->\n  \n  <script type=\"text/javascript\">\n    var app_url = 'http://www.eyeem.com/';\nvar signup_url = 'http://www.eyeem.com/signup';\nvar authenticated = false;\n  </script>\n\n  <script type=\"text/javascript\" src=\"/js/eyeem.c.js?1334330223\"></script>\n\n</body>\n</html>"
end


