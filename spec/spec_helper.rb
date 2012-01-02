#encoding: utf-8
require "bundler"
require "logger"
Bundler.require :default, :development, :test

logger = Logger.new(STDOUT)
logger.level = Logger::FATAL
LogAware.log = logger

def check_pic_url_extraction(service)
  image_url = Processors::PhotoService::send "image_url_#{service}".to_sym, @links[service]
  image_url.should =~ Processors::PhotoService::PIC_REGEXP
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


