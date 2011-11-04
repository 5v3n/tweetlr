#encoding: utf-8
require "bundler"
Bundler.require :default, :development, :test

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
