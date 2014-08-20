local_path=File.dirname(__FILE__)
require "#{local_path}/http"
require "#{local_path}/../log_aware"
require 'nokogiri'

module Tweetlr::Processors
  #utilities for dealing with photo services
  module PhotoService
  
    LOCATION_START_INDICATOR = 'Location: '
    LOCATION_STOP_INDICATOR  = "\r\n"
    PIC_REGEXP = /(.*?)\.(jpg|jpeg|png|gif)/i 
  
    include Tweetlr::LogAware
    
    def self.log
      Tweetlr::LogAware.log #TODO why doesn't the include make the log method accessible?
    end
  
    def self.find_image_url(link, embedly_key=nil)
      url = nil
      if link && !(photo? link)
        url = process_link link, embedly_key
      elsif photo? link
        url = link
      end
      url
    end
  
    def self.photo?(link)
      link =~ PIC_REGEXP
    end
    def self.image_url_twimg(link_url)
      retrieve_image_url_by_css link_url, '.media img'
    end
    #extract the image of an eyeem.com pic
    def self.image_url_eyeem(link_url)
      retrieve_image_url_by_css link_url, '.viewport-pic img'
    end
    #extract the image of a foursquare.com pic
    def self.image_url_foursqaure(link_url)
      link_url = follow_redirect(link_url)
      image_url = retrieve_image_url_by_css link_url, 'meta[property="og:image"]', 'content'
      image_url unless image_url.include? "foursquare.com/img/categories"
    end
    #extract the image of a path.com pic
    def self.image_url_path(link_url)
      retrieve_image_url_by_css link_url, 'img.photo-image'
    end
  
    #find the image's url via embed.ly
    def self.image_url_embedly(link_url, key)
      link_url = follow_redirect(link_url)
      log.debug "embedly call: http://api.embed.ly/1/oembed?key=#{key}&url=#{link_url}"
      response = Tweetlr::Processors::Http::http_get_json "http://api.embed.ly/1/oembed?key=#{key}&url=#{link_url}"
      if response && (response['type'] == 'photo' || response['type'] == 'image')
        image_url = response['url'] 
      end
      image_url
    end
    #find the image's url for an twitter shortened link
    def self.image_url_tco(link_url, embedly_key = nil)
      service_url = link_url_redirect link_url
      find_image_url service_url, embedly_key
    end
    #find the image's url for an instagram link
    def self.image_url_instagram(link_url)
      link_url['instagram.com'] = 'instagr.am' if link_url.index 'instagram.com' #instagram's oembed does not work for .com links
      response = Tweetlr::Processors::Http::http_get_json "http://api.instagram.com/oembed?url=#{link_url}"
      response['url'] if response
    end
    #find the image's url for a twitpic link
    def self.image_url_twitpic(link_url)
      image_url_redirect link_url, "http://twitpic.com/show/full/"
    end
    #find the image'S url for a yfrog link
    def self.image_url_yfrog(link_url)
      retrieve_image_url_by_css link_url, '#input-direct', 'value'
    end
    #find the image's url for a img.ly link
    def self.image_url_imgly(link_url, embedly_key)
      retrieve_image_url_by_css link_url, '#the-image'
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
        (tries > 0) ? retry : return
      end
      process_reponse_header resp, stop_indicator
    end
  
    #extract the pic id from a given <code>link</code>
    def self.extract_id(link)
      link.split('/').last if link.split('/')
    end
    #parse html doc for element signature
    def self.parse_html_for(element_signature, html_doc, identifier="src")
      image_url= nil
      if html_doc
        photo_container_div = html_doc.css(element_signature)
        if photo_container_div && photo_container_div.first && photo_container_div.first.attributes[identifier]
          image_url = photo_container_div.first.attributes[identifier].value
        end
      end
      image_url
    end
    def self.retrieve_image_url_by_css(link_url, css_path, selector='src')
      link_url = follow_redirect link_url
      response = Tweetlr::Processors::Http::http_get link_url
      image_url = parse_html_for css_path, Nokogiri::HTML.parse(response.body_str), selector
      return image_url
    end
private
    def self.process_link(link, embedly_key)
      url = nil
      log.info "embedly processing the link..."
      url = image_url_embedly link, embedly_key
      if url.nil? #fallback to self written image extractors
        log.info "embedly wasn't able to process the link, using self written extractors..."
        url = image_url_eyeem link if link.index 'eyeem.com'
        url = image_url_instagram link if (link.index('instagr.am') || link.index('instagram.com'))
        url = image_url_twitpic link if link.index 'twitpic'
        url = image_url_yfrog link if link.index 'yfrog'
        url = image_url_imgly link, embedly_key if link.index 'img.ly'
        url = image_url_tco link, embedly_key if link.index 't.co'
        url = image_url_twimg link if link.index 'twitter.com'
        url = image_url_path link if link.index 'path.com'
        url = image_url_foursqaure link if (link.index('4sq.com') || link.index('foursquare.com'))
      end
      url
    end
    def self.process_reponse_header(resp, stop_indicator)
      if(resp && resp.header_str && resp.header_str.index(LOCATION_START_INDICATOR) && resp.header_str.index(stop_indicator))
        start = resp.header_str.index(LOCATION_START_INDICATOR) + LOCATION_START_INDICATOR.size
        stop  = resp.header_str.index(stop_indicator, start)
        resp.header_str[start...stop]
      else
        nil
      end
    end
    def self.follow_redirect(link_url)
      service_url = link_url_redirect link_url #follow possible redirects
      link_url = service_url if service_url #if there's no redirect, service_url will be nil
      link_url
    end
  end
end