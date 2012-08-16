include FeedUsGrabberHelper

# Constant already set in model
#CACHE_COMMAND_FORCE = "force_clear_all"

class FeedUsGrabberController < ActionController::Base
	def index
	  def initialize
        # Client ip check. Can remove all ip's to turn off the check. 
		# ! IMPORTANT: TO DISABLE THIS CHECK SET BOTH ARRAYS TO nil 
	    @mClientWhiteList = [ "75.126.108.226", "75.126.107.10", "127.0.0.1" ]		
	    @mClientHostNameWhileList = [ "request.feed.us", "feed.us", "classic.syndication.feed.us", "render.feed.us", "dev.feed.us", "stage.feed.us", "localhost"]  
		@mClientIp
	  end
	
	  args = {}
	  
	  # URL that will be checked for connectivity before clearing the cache (phone home)
	  args[:FeedUsURL] = 'http://render.feed.us/grabberdefault.htm?phonehome=true'	 	
	  
	  unless params[:cachecommand].nil?
	    args[:CacheCommand] = params[:cachecommand]
	  end
	  unless params[:group].nil?
	    args[:FeedUsCacheGroup] = params[:group]
	  end
	  
	  if args[:FeedUsCacheGroup]  && args[:CacheCommand].nil?
	    args[:CacheCommand] = 'clear'
	  end
    
    if args[:CacheCommand].nil?
      args[:CacheCommand] = 'clearall'
    end
    
    if args[:CacheCommand] == 'clear' && args[:FeedUsCacheGroup]
      fetch = true
    else
      fetch = false
    end
    if args[:CacheCommand] == 'clearall' || args[:CacheCommand] == CACHE_COMMAND_FORCE
      fetch = true
    end
	
	# Client ip check
	isPermittedToProceed = IsPermittedToProceed()
	
	if isPermittedToProceed == false
		render :text=> "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\"> IP " + @mClientIp + " is not authorized.  Modify the feed_us_grabber_controller @mClientWhiteList array if this IP should have access."
	else	
		if fetch == true 
		  feedUsGrabber(args)
			  render :text => "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
			<p style=\"font-family:arial;\">Congratulations!  You have successfully refreshed your content.</p>
				<p style=\"font-family:arial;\"><a href=\"/\">Home</a></p>"
			else
			  render :text=> "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\"> Please specify cachecommand=clear&group=GROUPNAME or cachecommand=clearall or cachecommand=force_clear_all in the URL"
			end
		end
	end
	
	def IsPermittedToProceed()
		isPermitted = false
		@mClientIp = request.remote_addr	
		
		if @mClientIp == "" || @mClientIp.nil?
			@mClientIp = request.env["HTTP_X_FORWARDED_FOR"]
		end
				
		isPermitted = IsClientIpInWhiteList()
		
		if isPermitted == false
			if @mClientHostNameWhileList.nil? == false
				# Try to resolve hostname from ip
				begin
					s = Socket.getaddrinfo(@mClientIp,nil)
					host = s[0][2]				
					if @mClientHostNameWhileList.include?(host) == true
						isPermitted = true
					end
				rescue
					# Do Nothing
				end
			end
		end
		
		return isPermitted
	end
	
	def IsClientIpInWhiteList()
		included = false
		if @mClientWhiteList.nil? && @mClientHostNameWhileList.nil?
			included = true
		elsif @mClientWhiteList.nil? == false && @mClientWhiteList.include?(@mClientIp) == true
			included = true
		end
		return included
	end
end
