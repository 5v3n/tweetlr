require 'processors/http'
require 'nokogiri'
require 'log_aware'

module Processors
  #utilities for dealing with photo services
  module PhotoService
  
    LOCATION_START_INDICATOR = 'Location: '
    LOCATION_STOP_INDICATOR  = "\r\n"
    PIC_REGEXP = /(.*?)\.(jpg|jpeg|png|gif)/i 
  
    include LogAware
    
    def self.log
      LogAware.log #TODO why doesn't the include make the log method accessible?
    end
  
    def self.find_image_url(link, embedly_key=nil)
      url = nil
      if link && !(photo? link)
        url = image_url_instagram link if (link.index('instagr.am') || link.index('instagram.com'))
        url = image_url_picplz link if link.index 'picplz'
        url = image_url_twitpic link if link.index 'twitpic'
        url = image_url_yfrog link if link.index 'yfrog'
        url = image_url_imgly link if link.index 'img.ly'
        url = image_url_tco link, embedly_key if link.index 't.co'
        url = image_url_lockerz link if link.index 'lockerz.com'
        url = image_url_path link if link.index 'path.com'
        url = image_url_foursqaure link if link.index '4sq.com'
        url = image_url_embedly link, embedly_key if url.nil? #just try embed.ly for anything else. could do all image url processing w/ embedly, but there's probably some kind of rate limit invovled.
      elsif photo? link
        url = link
      end
      url
    end
  
    def self.photo?(link)
      link =~ PIC_REGEXP
    end
    #extract the image of a foursquare.com pic
    def self.image_url_foursqaure(link_url)
      service_url = link_url_redirect link_url #follow possible redirects
      link_url = service_url if service_url #if there's no redirect, service_url will be nil
      response = Processors::Http::http_get link_url
      image_url = parse_html_for '.commentPhoto img', Nokogiri::HTML.parse(response.body_str)
      return image_url
    end
    #extract the image of a path.com pic
    def self.image_url_path(link_url)
      service_url = link_url_redirect link_url #follow possible redirects
      link_url = service_url if service_url #if there's no redirect, service_url will be nil
      response = Processors::Http::http_get link_url
      image_url = parse_html_for 'img.photo-image', Nokogiri::HTML.parse(response.body_str)
      return image_url
    end
  
    #find the image's url via embed.ly
    def self.image_url_embedly(link_url, key)
      response = Processors::Http::http_get_json "http://api.embed.ly/1/oembed?key=#{key}&url=#{link_url}"
      log.debug "embedly call: http://api.embed.ly/1/oembed?key=#{key}&url=#{link_url}"
      if response && response['type'] == 'photo'
        image_url = response['url'] 
      end
      image_url
    end
    #find the image's url for a lockerz link
    def self.image_url_lockerz(link_url)
      response = Processors::Http::http_get_json "http://api.plixi.com/api/tpapi.svc/json/metadatafromurl?details=false&url=#{link_url}"
      response["BigImageUrl"] if response
    end
    #find the image's url for an twitter shortened link
    def self.image_url_tco(link_url, embedly_key = nil)
      service_url = link_url_redirect link_url
      find_image_url service_url, embedly_key
    end
    #find the image's url for an instagram link
    def self.image_url_instagram(link_url)
      link_url['instagram.com'] = 'instagr.am' if link_url.index 'instagram.com' #instagram's oembed does not work for .com links
      response = Processors::Http::http_get_json "http://api.instagram.com/oembed?url=#{link_url}"
      response['url'] if response
    end

    #find the image's url for a picplz short/longlink
    def self.image_url_picplz(link_url)
      id = extract_id link_url
      #try short url
      response = Processors::Http::http_get_json "http://picplz.com/api/v2/pic.json?shorturl_ids=#{id}"
      #if short url fails, try long url
      #response = HTTParty.get "http://picplz.com/api/v2/pic.json?longurl_ids=#{id}"
      #extract url
      if response && response['value'] && response['value']['pics'] && response['value']['pics'].first && response['value']['pics'].first['pic_files'] && response['value']['pics'].first['pic_files']['640r']
        response['value']['pics'].first['pic_files']['640r']['img_url'] 
      else
        nil
      end
    end
    #find the image's url for a twitpic link
    def self.image_url_twitpic(link_url)
      image_url_redirect link_url, "http://twitpic.com/show/full/"
    end
    #find the image'S url for a yfrog link
    def self.image_url_yfrog(link_url)
      response = Processors::Http::http_get_json("http://www.yfrog.com/api/oembed?url=#{link_url}")
      response['url'] if response
    end
    #find the image's url for a img.ly link
    def self.image_url_imgly(link_url)
      image_url_redirect link_url, "http://img.ly/show/full/", "\r\n"
    end
  
    # extract image url from services like twitpic & img.ly that do not offer oembed interfaces
    def self.image_url_redirect(link_url, service_endpoint, stop_indicator = LOCATION_STOP_INDICATOR)
      link_url_redirect "#{service_endpoint}#{extract_id link_url}", stop_indicator
    end
  
    def self.link_url_redirect(short_url, stop_indicator = LOCATION_STOP_INDICATOR)
      tries = 3
      begin
        resp = Curl::Easy.http_get(short_url) { |res| res.follow_location = true }
      rescue Curl::Err::CurlError => err
          log.error "Curl::Easy.http_get failed: #{err}"
          tries -= 1
          sleep 3
          if tries > 0
              retry
          else
             return nil
          end
      end
      if(resp && resp.header_str && resp.header_str.index(LOCATION_START_INDICATOR) && resp.header_str.index(stop_indicator))
        start = resp.header_str.index(LOCATION_START_INDICATOR) + LOCATION_START_INDICATOR.size
        stop  = resp.header_str.index(stop_indicator, start)
        resp.header_str[start...stop]
      else
        nil
      end
    end
  
    #extract the pic id from a given <code>link</code>
    def self.extract_id(link)
      link.split('/').last if link.split('/')
    end
    #parse html doc for element signature
    def self.parse_html_for(element_signature, html_doc)
      image_url= nil
      if html_doc
        photo_container_div = html_doc.css(element_signature)
        if photo_container_div && photo_container_div.first && photo_container_div.first.attributes["src"]
          image_url = photo_container_div.first.attributes["src"].value
        end
      end
      image_url
    end
  end
end