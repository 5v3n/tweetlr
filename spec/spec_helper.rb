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
  image_url = Tweetlr::Processors::PhotoService::send "image_url_#{service}".to_sym, @links[service]
  image_url.should =~ Tweetlr::Processors::PhotoService::PIC_REGEXP
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
  Curl::Easy.any_instance.stub(:body_str).and_return %|<div class="entities-media-container " style="min-height:580px">
                <div class="tweet-media">
          <div class="media-instance-container">
            <div class="twimg">
              <a target="_blank" href="http://twitter.com/KSilbereisen/status/228042798161596416/photo/1/large">
                <img src="https://p.twimg.com/Ayort3pCEAAHRrz.jpg">
              </a>
            </div>
            <span class="flag-container">
              <button type="button" class="flaggable btn-link">
                Flag this media
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
            <div class="media-attribution">
              <span>powered by</span> <img src="/phoenix/img/turkey-icon.png"> <a target="_blank" data-media-type="Twimg" class="media-attribution-link" href="http://photobucket.com/twitter">Photobucket</a>
            </div>
          </div>
        </div>    </div>|
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
  Curl::Easy.any_instance.stub(:body_str).and_return %^<?xml version="1.0" encoding="UTF-8"?>

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://opengraphprotocol.org/schema/" xmlns:lift="http://liftweb.net" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type" />
    <meta content="foursquare" name="description" />
    <meta content="foursquare" name="application-name" />

    <meta content="Start the foursquare App" name="msapplication-tooltip" />
    <meta content="/" name="msapplication-starturl" />
    <meta content="width=1024;height=768" name="msapplication-window" />
    <meta content="name=Recent Check-ins; action-uri=/; icon-uri=/favicon.ico" name="msapplication-task" />
    <meta content="name=Profile;action-uri=/user;icon-uri=/favicon.ico" name="msapplication-task" />
    <meta content="name=History;action-uri=/history;icon-uri=/favicon.ico" name="msapplication-task" />
    <meta content="name=Badges;action-uri=/badges;icon-uri=/favicon.ico" name="msapplication-task" />
    <meta content="name=Stats;action-uri=/stats;icon-uri=/favicon.ico" name="msapplication-task" />


    <title>foursquare :: Sven @ kopiba</title>
    <link href="https://static-s.foursquare.com/favicon-c62b82f6120e2c592a3e6f3476d66554.ico" type="image/x-icon" rel="icon" />
    <link href="https://static-s.foursquare.com/favicon-c62b82f6120e2c592a3e6f3476d66554.ico" type="image/x-icon" rel="shortcut icon" />
    <link href="https://static-s.foursquare.com/img/touch-icon-ipad-1d5a99e90171f6a0cc2f74920ec24021.png" sizes="72x72" rel="apple-touch-icon-precomposed" />
    <link href="https://playfoursquare.s3.amazonaws.com/press/logo/foursquare-logo.svg" type="image/svg" rel="logo" />
    <link href="https://static-s.foursquare.com/opensearch-6b463ddc6a73b41a3d4b1c705d814fcf.xml" title="foursquare" type="application/opensearchdescription+xml" rel="search" />

    <link href="https://static-s.foursquare.com/styles/reset-ba1d59b0e53d380b12b3e97a428b3314.css" type="text/css" rel="stylesheet" />
    <link href="https://static-s.foursquare.com/facebox/facebox-29383c5fc530ed391a05276abeb1959a.css" type="text/css" rel="stylesheet" />



      <link href="https://static-s.foursquare.com/styles/master-redesign-e811ecb709c2414dbd8bbb382f312aa1.css" type="text/css" rel="stylesheet" />





      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.min.js" type="text/javascript" id="jquery"></script>




  <script type="text/javascript">
    var _kmq = _kmq || [];
    function _kms(u){
      setTimeout(function(){
        var s = document.createElement('script'); var f = document.getElementsByTagName('script')[0]; s.type = 'text/javascript'; s.async = true;
        s.src = u; f.parentNode.insertBefore(s, f);
      }, 1);
    }
    // Use this for dev
    //_kms('//i.kissmetrics.com/i.js');_kms('//doug1izaerwt3.cloudfront.net/0c1574f4c7da92b07e34862fcc6c505d531a957c.1.js');
  </script>


    <script type="text/javascript">
      // Use this for production
      _kms('//i.kissmetrics.com/i.js');_kms('//doug1izaerwt3.cloudfront.net/033f1ff04dc072af9d77e05e3fe10ed9b6ea4fcf.1.js');
    </script>



    <script src="https://static-s.foursquare.com/scripts/build/en/chrome/root-d0d815376f0111b37b1b2f3786ff5314.js" type="text/javascript"></script>
    <script src="https://static-s.foursquare.com/scripts/build/en/foursquare/root-5c88202943112aa3305dcb2f9425a601.js" type="text/javascript"></script>













    <script type="text/javascript">
      (function() {
        window.fourSq = window.fourSq || {};
        window.fourSq.api = window.fourSq.api || {};
        window.fourSq.fb = window.fourSq.fb || {};
        window.fourSq.user = window.fourSq.user || {};
        window.fourSq.debugLevel = function() { return fourSq.debug.Level.OFF; };

        /**
         * Setup API domain and token
         */
        window.fourSq.api.config = {
          API_BASE: 'https://api.foursquare.com/',
          API_TOKEN: 'QEJ4AQPTMMNB413HGNZ5YDMJSHTOHZHMLZCAQCCLXIX41OMP',
          API_IFRAME: 'https://api.foursquare.com/xdreceiver.html',
          CLIENT_VERSION: '20111109'
        };

        /**
         * Useful values for current user.
         */
        window.fourSq.user.config = {
          USER_PROFILE: undefined,
          USER_LAT: 0,
          USER_LNG: 0,
          // Only used for display.
          SU6: false,
          LOCALE: 'en_US'
        };

        window.fourSq.fb.config = {
          APP_ID: 86734274142,
          SCOPE: 'offline_access,publish_stream,user_checkins,friends_checkins,user_location,user_birthday'
        };

        document.domain = 'foursquare.com';
      })();
    </script>



    <script type="text/javascript">
      $(function() {
        $('a[rel*=facebox]').facebox();
        $('.linkify').linkify();

        var search = $('#search input').placeholder();
        if ($.trim(search.val()) != '') {
          search.keydown();
        }
      })
    </script>




  <meta content="NOINDEX" name="ROBOTS" />


  <script src="https://maps.google.com/maps/api/js?sensor=false" type="text/javascript"></script>


  <script src="https://static-s.foursquare.com/scripts/build/en/foursquare/comments-be605309e291ccdcaa2c7d2645743741.js" type="text/javascript"></script>


  <script src="https://static-s.foursquare.com/scripts/build/en/foursquare/checkin-detail-page-2d377f73b6d6318b813cc6db39651fff.js" type="text/javascript"></script>


  <script type="text/javascript">
          $(function() {
            var options = {
              el: $('body')
            }

            options['lat'] = 53.558831084738;
            options['lng'] = 9.963698387145996;
            options['fuzzy'] = false;
            options['venue'] = {"id":"v4b169255f964a52072ba23e3","venue":{"id":"4b169255f964a52072ba23e3","name":"kopiba","contact":{"phone":"4940343824","formattedPhone":"040\/343824","twitter":"kopiba"},"location":{"address":"Beim Grünen Jäger 24","lat":53.558831084738,"lng":9.963698387145996,"postalCode":"20357","city":"Hamburg","country":"Germany"},"categories":[{"id":"4bf58dd8d48988d16d941735","name":"Café","pluralName":"Cafés","shortName":"Café","icon":{"prefix":"https:\/\/foursquare.com\/img\/categories\/food\/cafe_","sizes":[32,44,64,88,256],"name":".png"},"primary":true}],"verified":true,"stats":{"checkinsCount":2903,"usersCount":478,"tipCount":26}}};



            options['checkinId'] = '4f0c401ae4b020a8d96fb0b1';


            if(typeof FRIENDS_PHOTOS_JSON != 'undefined') {
              options = _.extend(options, {friendsPhotosJson: FRIENDS_PHOTOS_JSON});
            }

            if(typeof STREAM_PHOTOS_JSON != 'undefined') {
              options = _.extend(options, {streamPhotosJson: STREAM_PHOTOS_JSON});
            }

            new fourSq.views.CheckinDetailPage(options);
          });
        </script>


  </head>
  <body>



      <div id="wrapper">


  <div id="header">



      <div class="wrap loggedOut translate">
        <a id="logo" href="/">foursquare</a>
        <form id="search" method="get" action="/search">
          <input placeholder="Search people and places..." name="q" type="text" />
          <button>Search</button>
        </form>
        <div id="loginLink"><a href="/login">Log in</a></div>
        <div id="menu"><a href="/signup">Sign up</a></div>
      </div>

  </div>
  <div id="lift__noticesContainer__"></div>





    <div class="translate wrap" id="signupPrompt">
      <h3>foursquare helps you keep up with friends, discover what's nearby, save money &amp; unlock rewards</h3>
      <a class="greenButton biggerButton" href="/signup/?source=nav">Get Started Now</a>
      <iframe scrolling="no" allowTransparency="true" src="https://www.facebook.com/plugins/facepile.php?app_id=86734274142&amp;amp;width=600&amp;amp;max_rows=1" style="border:none; overflow:hidden; width:600px; height: 70px;" frameborder="0"></iframe>
    </div>

    <style type="text/css">
      #loginBeforeActionPopup {
        padding: 10px;
        width: 500px;
      }
        #loginBeforeActionPopup h2 {font-size: 21px;}
      #loginBeforeActionPopup #signupPopup {}
        #loginBeforeActionPopup #signupPopup p {
          float: left;
          line-height: 18px;
          margin: 15px 0;
          padding-top: 2px;
          width: 330px;
        }
        #loginBeforeActionPopup #signupPopup .newGreenButton {
          font-size: 18px;
          height: 40px;
          float: right;
          line-height: 40px;
          margin: 15px 0;
          text-transform: none;
          width: 140px;
        }
      #loginBeforeActionPopup #loginPopup {
        border-top: 1px solid #d9d9d9;
        padding-top: 10px;
      }
        #loginBeforeActionPopup #loginPopup .linkStyle {
          border: none;
          background: none;
          color: #2398c9;
          cursor: pointer;
          font: inherit;
          font-weight: bold;
          padding: 0;
          margin: 0;
        }
          #loginBeforeActionPopup #loginPopup .linkStyle:hover {text-decoration: underline;}
    </style>

    <div style="display:none;" class="translate" id="loginBeforeActionPopup">

      <h2 class="newh2">Join foursquare to <span id="loginActionLabel">do that</span></h2>
        <form method="POST" action="/signup/pre-signup">
          <input value="" type="hidden" name="actionKey" id="loginActionKey" />
          <input value="" type="hidden" name="source" id="loginSource" />
          <input value="" type="hidden" name="continue" id="loginContinue" />
          <div id="signupPopup">
            <p>Foursquare helps you meet up with friends and find<br />new places to experience in your neighborhood.</p>
            <input value="Get Started" name="signupSubmit" class="newGreenButton greenButton translate" type="submit" />
            <div style="clear: both;"></div>
          </div>
          <div id="loginPopup">
            <strong>Already a foursquare user?</strong> <input value="Log in" name="loginSubmit" class="linkStyle" type="submit" /> to continue.
          </div>
        </form>

    </div>





        <div class="wrap" id="container">









    <div class="twoColumns" id="checkinPage">
      <div class="wideColumn">


        <div id="userCheckin">
          <div id="userPic">
            <a href="/sven_kr"><img src="https://img-s.foursquare.com/userpix_thumbs/ZXPGHBJTWWSTMXN1.jpg" alt="Sven K." width="110" class="notranslate"  height="110" /></a>
          </div>
          <div id="userDetails">
            <h2><a href="/sven_kr">Sven K.</a> checked in to <a href="/v/kopiba/4b169255f964a52072ba23e3">kopiba</a> </h2>
            <p class="shout linkify">#coffeediary</p>

            <p class="date">
              8 hours ago  via <em><a href="https://foursquare.com/download/#/iphone">foursquare for iPhone</a></em>
            </p>












          </div>
        </div>


        <div>
          <script type="text/javascript">
  // <![CDATA[
  var STREAM_PHOTOS_JSON = "{\"count\":1,\"items\":[{\"id\":\"4f0c4020e4b0261c93fd4ede\",\"createdAt\":1326202912,\"url\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/pix\u005c/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg\",\"sizes\":{\"count\":4,\"items\":[{\"url\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/pix\u005c/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg\",\"width\":537,\"height\":720},{\"url\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/derived_pix\u005c/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE_300x300.jpg\",\"width\":300,\"height\":300},{\"url\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/derived_pix\u005c/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE_100x100.jpg\",\"width\":100,\"height\":100},{\"url\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/derived_pix\u005c/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE_36x36.jpg\",\"width\":36,\"height\":36}\u005d},\"user\":{\"id\":\"304170\",\"firstName\":\"Sven\",\"lastName\":\"K.\",\"photo\":\"https:\u005c/\u005c/img-s.foursquare.com\u005c/userpix_thumbs\u005c/ZXPGHBJTWWSTMXN1.jpg\",\"gender\":\"male\",\"homeCity\":\"Hamburg, Germany\"},\"visibility\":\"friends\"}\u005d}";
  // ]]>
  </script>
          <div id="comments">

                <div id="4f0c4020e4b0261c93fd4ede" class="comment withPhoto">
                  <div class="commentLeft">
                    <a href="/sven_kr"><img src="https://img-s.foursquare.com/userpix_thumbs/ZXPGHBJTWWSTMXN1.jpg" alt="Sven K." width="60" class="notranslate"  height="60" /></a>
                  </div>
                  <div class="commentPhoto">
                    <span title="Delete your image?" class="flagDelete">

                    </span>
                    <img src="https://img-s.foursquare.com/pix/NKFGXXX41TIQJA0P25ZYSUYKUUROQLLWGUXXSA5ABUQFDDYE.jpg" />
                  </div>
                </div>

          </div>








            <div class="translate" id="cantComment">
              Only <span class="notranslate">Sven's</span> friends can see comments and add their own.
            </div>


        </div>

      </div>

      <div class="narrowColumn">





        <div id="venueDetails" class="box">
          <div id="venueIcon">
            <img src="https://static-s.foursquare.com/img/categories/food/cafe-f0c1523ad255a6e9e65e27c2ca02576c.png" class="thumb" />
            <img src="https://static-s.foursquare.com/img/specials/check-in-f870bc36c0cc2a842fac06c35a6dccdf.png" class="specialImage" title="Check-in Special" />
          </div>
          <div class="vcard" id="venueName">
            <h5 class="fn org"><a href="/v/kopiba/4b169255f964a52072ba23e3">kopiba</a></h5>
            <p>Hamburg</p>
            <div class="hiddenAddress">
              <span class="adr"><span class="street-address">Beim Grünen Jäger 24</span><br /><span class="locality">Hamburg</span>, <span class="region"></span> <span class="postal-code">20357</span><br /><span class="tel">040/343824</span><br /></span>
            </div>
          </div>
          <div id="listControlHolder"></div>
          <div id="vmap"></div>

        </div>


        <div class="box">
          <div class="statsBlock translate">
            <div class="stat">
              <strong>Total<br />People</strong><br /><span class="notranslate">478</span>
            </div>
            <div class="stat">
              <strong>Total<br />Checkins</strong><br /><span class="notranslate">2903</span>
            </div>
            <div class="stat">
              <strong>Here<br />Now</strong><br /><span class="notranslate">1</span>
            </div>
          </div>
        </div>










      </div>
      <div style="clear: both;"></div>
    </div>

    <script type="text/javascript">
      $('.delete').tooltip();
      $('.flagDelete').tooltip();
    </script>



          <div id="containerFooter">
            <div class="wideColumn">
              <ul class="translate">
    <li><a href="https://foursquare.com/about">About</a></li>
    <li><a href="https://foursquare.com/apps">Apps</a></li>
    <li><a href="http://blog.foursquare.com">Blog</a></li>
    <li><a href="http://developers.foursquare.com">Developers</a></li>
    <li><a href="http://foursquare.com/help">Help</a></li>
    <li><a href="https://foursquare.com/jobs/">Jobs</a></li>
    <li><a href="https://foursquare.com/legal/privacy">Privacy</a></li>
    <li><a href="https://foursquare.com/legal/terms">Terms</a></li>
    <li><a href="http://store.foursquare.com">Store</a></li>
    <li>




    <script type="text/javascript">
      //<![CDATA[
      // IMPORTANT: This is what does the redirect to the correct domain
      fourSq.i18n.redirect();
      // ]]>
    </script>


    <script type="text/javascript">
      //<![CDATA[
      $(function() {
        $('#currentLanguage a').text(fourSq.i18n.currentLang());
      });
      // ]]>
    </script>

    <span id="currentLanguage">
      <a rel="facebox" href="#languagesContainer"></a>
    </span>

    <div style="display:none" class="translate" id="languagesContainer">
      Do none of the words on this site make sense to you? Select your
      favorite language below for greater clarity:
      <ul class="languages notranslate">
        <li><a onclick="fourSq.i18n.setLang('en'); return false;" href="#">English</a></li><li><a onclick="fourSq.i18n.setLang('it'); return false;" href="#">Italiano</a></li><li><a onclick="fourSq.i18n.setLang('de'); return false;" href="#">Deutsch</a></li><li><a onclick="fourSq.i18n.setLang('es'); return false;" href="#">Español</a></li><li><a onclick="fourSq.i18n.setLang('fr'); return false;" href="#">Français</a></li><li><a onclick="fourSq.i18n.setLang('ja'); return false;" href="#">日本語</a></li><li><a onclick="fourSq.i18n.setLang('th'); return false;" href="#">ภาษาไทย</a></li><li><a onclick="fourSq.i18n.setLang('ko'); return false;" href="#">한국어</a></li><li><a onclick="fourSq.i18n.setLang('ru'); return false;" href="#">Русский</a></li><li><a onclick="fourSq.i18n.setLang('pt'); return false;" href="#">Português</a></li><li><a onclick="fourSq.i18n.setLang('id'); return false;" href="#">Bahasa Indonesia</a></li>
      </ul>
    </div>
  </li>
  </ul>
            </div>
            <div class="narrowColumn translate">
              foursquare © 2011 <img src="https://static-s.foursquare.com/img/chrome/iconHeart-03e49accc507d9d99e7e4dfaa73868cb.png" height="9" width="11" alt="" /> Lovingly made in NYC &amp; SF
            </div>
          </div>
        </div>
      </div>

      <div id="footer">
        <div style="display: none;" class="wrap">
          <p class="right">Discover more brands in the <a href="/pages">page gallery</a>.</p>
          <p>Follow these brands to unlock badges and find interesting tips around your city!</p>


            <ul><li><a href="/vh1"><img src="https://static-s.foursquare.com/img/footer/vh1-bb870b187d4e4378457e4a8e7df33e28.png" height="50" /></a></li><li><a href="/luckymagazine"><img src="https://static-s.foursquare.com/img/footer/luckymagazine-81550ed80bb77ddf9fa7e09c94ef4ac3.png" height="50" /></a></li><li><a href="/askmen"><img src="https://static-s.foursquare.com/img/footer/askmen-32a19bae424cafba11d7131fbc763f6d.png" height="50" /></a></li><li><a href="/eater"><img src="https://static-s.foursquare.com/img/footer/eater-5a8d27da22828104e13b0a4a50a74db8.png" height="50" /></a></li><li><a href="/joinred"><img src="https://static-s.foursquare.com/img/footer/joinred-6b8edbfec8aeb5e256f7824ca757cb81.png" height="50" /></a></li><li><a href="/bbcamerica"><img src="https://static-s.foursquare.com/img/footer/bbcamerica-d777b112c51696700dbd348e1b1e6817.png" height="50" /></a></li></ul>

        </div>
      </div>

      <div id="overlayFrame">
    <div id="overlayPage">
      <div id="photoDetails">
        <div class="wrap">
          <img src="https://static-s.foursquare.com/img/gallery-next-4fe893b7a611387276ef45cd74632759.png" height="32" width="32" alt="" class="navControl" id="next" />
          <img src="https://static-s.foursquare.com/img/gallery-prev-6da401eecb2e8a276e2a89bea5ac3819.png" height="32" width="32" alt="" class="navControl" id="previous" />
          <img width="32" height="32" alt="" src="" id="userPic" />
          <h5 id="userName"><a href="#"></a></h5>
          <p id="date"></p>
        </div>
      </div>
      <div id="mainPhoto"></div>

      <div style="display:none" class="flagFrame unknown">
        <div class="flagForm translate">
          <h3>Flag this Photo</h3>
          <ul>
            <li><input id="spam_scam" value="spam_scam" type="radio" name="problem" /> <label for="spam_scam">Spam/Scam</label></li>
            <li><input id="nudity" value="nudity" type="radio" name="problem" /> <label for="nudity">Nudity</label></li>
            <li><input id="hate_violence" value="hate_violence" type="radio" name="problem" /> <label for="hate_violence">Hate/Violence</label></li>
            <li><input id="illegal" value="illegal" type="radio" name="problem" /> <label for="illegal">Illegal</label></li>
            <li><input id="unrelated" value="unrelated" type="radio" name="problem" /> <label for="unrelated">Unrelated</label></li>
          </ul>
          <p class="noProblemMessage">Please select a problem.</p>
          <p><input class="submitFlag greenButton" value="Submit Flag" name="submitFlag" type="button" name="problem" /></p>
        </div>
        <div class="flagStatus translate">
          <div class="status success">
            <h3>Flag this Photo</h3>
            <p>Your flag was submitted successfully.</p>
          </div>
          <div class="status failure">
            <h3>Flag this Photo</h3>
            <p>Your flag did not submit. Please try again later.</p>
          </div>
        </div>
      </div>
    </div>
  </div>



    <script src="https://ssl.google-analytics.com/ga.js" type="text/javascript"></script>



  <script type="text/javascript">
    try {
      var pageTracker = _gat._getTracker('UA-2322480-5');
      pageTracker._trackPageview();
      pageTracker._trackPageLoadTime();
      } catch(err) {
      }
  </script>
  <script type="text/javascript">var _sf_startpt=(new Date()).getTime()</script>
  <script type="text/javascript">
  var _sf_async_config={uid:11280,domain:'foursquare.com'};
  if (window.chartbeat_path) {
    _sf_async_config.path = chartbeat_path;
  }
  (function(){
    function loadChartbeat() {
      window._sf_endpt=(new Date()).getTime();
      var e = document.createElement('script');
      e.setAttribute('language', 'javascript');
      e.setAttribute('type', 'text/javascript');
      e.setAttribute('src',
         (('https:' == document.location.protocol) ? 'https://s3.amazonaws.com/' : 'http://') +
         'static.chartbeat.com/js/chartbeat.js');
      document.body.appendChild(e);
    }
    var oldonload = window.onload;
    window.onload = (typeof window.onload != 'function') ?
       loadChartbeat : function() { oldonload(); loadChartbeat(); };
  })();

  </script>






    <script src="/ajax_request/liftAjax.js" type="text/javascript"></script>


  </body>
  </html>  
  ^
end

def stub_eyeem
  Curl::Easy.any_instance.stub(:perform).and_return Curl::Easy.new
  Curl::Easy.any_instance.stub(:header_str).and_return "HTTP/1.1 200 OK\r\nServer: nginx/1.0.5\r\nDate: Sun, 15 Apr 2012 09:16:58 GMT\r\nContent-Type: text/html; charset=utf-8\r\nTransfer-Encoding: chunked\r\nConnection: keep-alive\r\nX-Powered-By: PHP/5.3.6-13ubuntu3.6\r\nSet-Cookie: symfony=bv8mdicp6ucb8jr9qt0o0r7qk2; path=/\r\nExpires: Thu, 19 Nov 1981 08:52:00 GMT\r\nCache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\nPragma: no-cache\r\n\r\n"
  Curl::Easy.any_instance.stub(:body_str).and_return "<!DOCTYPE html>\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"shortcut icon\" href=\"/favicon.ico\" />\n<meta name=\"title\" content=\"EyeEm\" />\n<meta name=\"description\" content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It&#039;s free.\" />\n<title>EyeEm</title>\n<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"/css/eyeem.c.css?1334330223\" />\n  <meta content=\"EyeEm\" property=\"og:title\">\n<meta content=\"website\" property=\"og:type\">\n<meta content=\"EyeEm\" property=\"og:site_name\">\n<meta content=\"http://www.eyeem.com/p/326629\" property=\"og:url\">\n<meta content=\"http://www.eyeem.com/thumb/640/480/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\" property=\"og:image\">\n<meta content=\"EyeEm is a photo-sharing and discovery app that connects people through the photos they take. Snap a photo and see where it takes you! It's free.\" property=\"og:description\">\n<meta content=\"138146182878222\" property=\"fb:app_id\">\n<script type=\"text/javascript\">\n\n  var _gaq = _gaq || [];\n  _gaq.push(['_setAccount', 'UA-12590370-2']);\n  _gaq.push(['_trackPageview']);\n\n  (function() {\n    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;\n    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';\n    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);\n  })();\n\n</script>\n</head>\n<body>\n\n<div id=\"fb-root\">\n  <!-- you must include this div for the JS SDK to load properly -->\n</div>\n<script>\n  window.fbAsyncInit = function() {\n    FB.init({\n      appId      : '138146182878222', // App ID\n      channelUrl : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File\n      status     : true, // check login status\n      cookie     : true, // enable cookies to allow the server to access the session\n      xfbml      : true  // parse XFBML\n    });\n\n    // Additional initialization code here\n  };\n\n  // Load the SDK Asynchronously\n  (function(d){\n     var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];\n     if (d.getElementById(id)) {return;}\n     js = d.createElement('script'); js.id = id; js.async = true;\n     js.src = \"//connect.facebook.net/en_US/all.js\";\n     ref.parentNode.insertBefore(js, ref);\n   }(document));\n</script>\n  \n  \n\n\n  <div id=\"page\">\n        <div id=\"header\">\n      <div name=\"top\" class=\"top_bar\"><div class=\"top_bar-inner\">\n  <div class=\"padding-top\"></div>\n  <div class=\"top_bar_content\">\n    <div class=\"search_box\">\n    \t<form action=\"/search\" method=\"get\" enctype=\"application/x-www-form-urlencoded\">\n        <input type=\"text\" name=\"query\" class=\"search_form_query\" placeholder=\"Search\" id=\"query\" />  <!--   \t  <input class=\"search_form_submit\" type=\"image\" value=\"submit\" src=\"\"/> -->\n    \t  <input class=\"search_form_submit\" type=\"submit\" value=\"\" />\n    \t</form>\n    </div>\n    <div class=\"homelink\">\n    \t<a href=\"/\">\n        <img src=\"/images/layout/topbar_logo.png\">\n    \t</a>\n    </div>\n    \n    \n      \n    <div class=\"top_menus\">\n            <div class=\"top_menu user_menu\">\n  \t\t  <a class=\"user_login smooth_hover\" href=\"/login\">\n  \t\t\t\t<span class=\"\">Login</span>\n  \t\t  </a>\n      </div>\n      \n      \n      \n            <div class=\"top_menu about_menu\">\n  \t\t  <a class=\"top_menu_button about_box smooth_hover\" href=\"javascript:void(0)\">\n  \t\t\t\t<span class=\"about_name\">About</span>\n  \t\t    <img class=\"more_triangle\" src=\"/images/layout/topbar_triangle.png\">\n  \t\t  </a>\n  \t\t  <ul class=\"\">\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/whatiseyeem\"><span>What is EyeEm?</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/gettheapp\"><span>Download the App</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/contact\"><span>Contact and Press</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/team\"><span>Team & Jobs</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"http://blog.eyeem.com\" target=\"_blank\"><span>Blog</span></a></li>\n      \t\t<li class=\"hidden\"><a class=\"smooth_hover\" href=\"/pages/service.html\"><span>Terms of service</span></a></li>\n  \t\t  </ul>\n      </div>  \n    </div>\n    \n  </div>\n</div></div>\n      <div class=\"top_bar_back\"></div>\n    </div> <!-- /#header -->\n    <div id=\"content\">\n      \n\n<div class=\"join_block\">\n  <div class=\"join_inner\">\n    <span class=\"join_description\">\n      <p>Take &amp; Discover photos</p>\n      <p>together with EyeEm!</p>\n    </span>\n    <div class=\"join_now\">\n      <div><a class=\"eyeem_button join_button\" href=\"/signup\">Join now!</a></div>\n      <div class=\"learn_more\"><a class=\"\" href=\"/whatiseyeem\">Learn more</a></div>\n    </div>\n  </div>\n</div>\n<div class=\"inner-content photo_inner_content\">\n  <div class=\"photo_indicator\"><img src=\"/images/layout/triangle_indicator.png\"></div>\n  <div class=\"viewports-wrapper\">\n    <div class=\"viewport active\" data-photo-id=\"326629\">\n        \n\n <div class=\"viewport-user\">\n  \t<a href=\"/u/8157\">\n  \t\t<img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  \t</a>\n  \t<span class=\"user_text\">\n    \t<a class=\"user_name\" href=\"/u/8157\">\n    \t\t<span><h2>Sven Kr\xC3\xA4uter</h2></span>\n    \t</a>\n    \t<div class=\"meta\">\n        <div class=\"viewport-age\">\n  \t     <span>4</span> days ago        </div>\n            \t</div>\n  \t</span>\n          </div>  \t\t\n  \t\t\n  \t\t\n    <div class=\"viewport-pic\">\n        <img src=\"http://www.eyeem.com/thumb/h/1024/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483\">\n  </div>\n  \n  \n    <div class=\"viewport-albums\">\n        <div class=\"tags tags_arrow\">\n                  \n                  \n      <div class=\"album_tag_box hover_container\">\n        <a class=\"album_tag tag\" href=\"/a/168255\">#coffeediary</a>\n                  </div>                \t    \t\n    \t    </div>\n    <div class=\"places tags_arrow\">\n                \t    </div>\n  </div>\n    \n  \n\n  <div class=\"viewport-likes\">\n        <div class=\"likes_count count\">1 like</div>\n    <span class=\"user_thumbs\">\n                <a class=\"user_thumb hover_container\" href=\"/u/85456\">\n  <img class=\"user_face\" alt=\"filtercake-nophoto\" src=\"http://www.eyeem.com/thumb/sq/50/a5799d443153b9becad3a1e15d15c1ad79739f32.jpg\">\n            </a>\n              </span>\n  \t<span class=\"like_area\">\n      <div class=\"like_action action\">\n    \t    \t\t    \t\t\t<a class=\"photo_like eyeem_button like_button\" href=\"javascript:void(0)\">Like<img class=\"button_spinner\" src=\"/images/layout/spinner.gif\"></a>\n    \t\t    \t      </div>  \t\n      \t\n  \t</span>\n  </div>\n  \n  \n  <div class=\"viewport-comments\">\n  \t<div class=\"comments_count count\">1 comment</div>\n  \t  \t<div class=\"comment_box\">\n    <a class=\"user_face_link\" href=\"/u/8157\">\n    <img class=\"user_face\" src=\"http://www.eyeem.com/thumb/sq/50/2033ff7cc732c4b8e1ee4375aa00b16d365b51c7.jpg\">\n  </a>\n  <span class=\"comment_display\">\n    <a class=\"user_name\" href=\"/u/8157\">\n      Sven Kr\xC3\xA4uter    </a>\n    <div class=\"comment_body\">\n      still using the bialetti until the spare parts for the espresso machine arrive. quite cozy actually.          </div>\n    <div class=\"comment_age\"><span>4</span> days ago</div>\n  </span>\n</div>\n  \t      </div>\n  \n  <div class=\"viewport-social\">\n    <div class=\"social\">\n      <div class=\"twitter-like\">\n        <script src=\"http://platform.twitter.com/widgets.js\" type=\"text/javascript\"></script>\n        <a href=\"http://twitter.com/share\" class=\"twitter-share-button\" data-url=\"http://www.eyeem.com/p/326629\">Tweet</a>\n      </div>\n      <div class=\"facebook-like\">\n        <div class=\"fb-like\" data-href=\"http://www.eyeem.com/p/326629\" data-send=\"false\" data-layout=\"button_count\" data-width=\"20\" data-show-faces=\"false\" data-font=\"verdana\"></div>\n      </div>\n    </div>\n  </div>\n\n    </div>\n  </div>\n</div>    </div> <!-- /#content -->\n  </div> <!-- /#page -->\n  \n  <script type=\"text/javascript\">\n    var app_url = 'http://www.eyeem.com/';\nvar signup_url = 'http://www.eyeem.com/signup';\nvar authenticated = false;\n  </script>\n\n  <script type=\"text/javascript\" src=\"/js/eyeem.c.js?1334330223\"></script>\n\n</body>\n</html>"
end


