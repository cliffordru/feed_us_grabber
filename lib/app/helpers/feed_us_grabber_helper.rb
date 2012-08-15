module FeedUsGrabberHelper
	def feedUsGrabber(params)
    grabber = FeedUsGrabber.new
    
    unless params[:CacheCommand].nil?
      grabber.setCacheCommand(params[:CacheCommand])
    end
   unless params[:FeedUsCacheGroup].nil?
      grabber.setCacheGroup(params[:FeedUsCacheGroup])      
    end
    unless params[:FeedUsCacheFolder].nil?
      grabber.setCacheFolder(params[:FeedUsCacheFolder])
    else
      grabber.setCacheFolder(File.join(Rails.root.to_s,'tmp','CachedWebContent'));
    end
    unless params[:FeedUsCacheInterval].nil? && params[:FeedUsCacheIntervalLength].nil?
      grabber.setCacheIntervalUnit(params[:FeedUsCacheInterval])
      grabber.setCacheIntervalLength(params[:FeedUsCacheIntervalLength])
    end

    unless params[:FeedUsURL].nil?
      grabber.setDynURL(params[:FeedUsURL])
      if params[:includeFlag] == true
  			grabber.setIncludeFlag(true)
  		else
  			grabber.setIncludeFlag(false)
  		end
    end
    
    grabber.autoCacheToFile()
    grabber
	end
	
	def feedUsGrabberRender(grabber)
	    grabber.renderCacheFromFile.to_s.html_safe
	end
end
