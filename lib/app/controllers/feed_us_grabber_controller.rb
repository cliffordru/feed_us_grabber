include FeedUsGrabberHelper

# Constant already set in model
#CACHE_COMMAND_FORCE = "force_clear_all"

class FeedUsGrabberController < ActionController::Base
	def index
		def initialize
			# Client ip check. Can remove all ip's to turn off the check. 
			# ! IMPORTANT: TO DISABLE THIS CHECK SET BOTH ARRAYS TO nil 
			@mClientWhiteList = [ "75.126.108.226", "75.126.107.10", "127.0.0.1", "50.56.95.92" ]		
			@mClientHostNameWhileList = [ "app.feed.us", "request.feed.us", "feed.us", "classic.syndication.feed.us", "render.feed.us", "dev.feed.us", "stage.feed.us", "localhost"]  
			@mClientIp = ""			
		end

		@mArgs = {}
		
		# URL that will be checked for connectivity before clearing the cache (phone home)
		@mArgs[:FeedUsURL] = 'http://render.feed.us/grabberdefault.htm?phonehome=true'	 			
		@mArgs[:DebugOutput] = ""
		@mArgs[:Debug] = false
		@mDebugLogger = FeedUsGrabber.new

		unless params[:cachecommand].nil?
			@mArgs[:CacheCommand] = params[:cachecommand]
		end
		unless params[:group].nil?
			@mArgs[:FeedUsCacheGroup] = params[:group]
		end
		
		unless params[:debug].nil?
			@mArgs[:Debug] = params[:debug] == "1"
		end	  

		if @mArgs[:FeedUsCacheGroup]  && @mArgs[:CacheCommand].nil?
			@mArgs[:CacheCommand] = 'clear'
		end
    
		if @mArgs[:CacheCommand].nil?
		  @mArgs[:CacheCommand] = 'clearall'
		end
		
		if @mArgs[:CacheCommand] == 'clear' && @mArgs[:FeedUsCacheGroup]
		  fetch = true
		else
		  fetch = false
		end
		if @mArgs[:CacheCommand] == 'clearall' || @mArgs[:CacheCommand] == CACHE_COMMAND_FORCE
		  fetch = true
		end
		
		# Client ip check
		isPermitted = IsPermittedToProceed()
		
		renderText = ""
		if @mArgs[:Debug] == true && isPermitted
			renderText << @mArgs[:DebugOutput]					
		end

		if isPermitted
			if fetch == true 
				grabber = feedUsGrabber(@mArgs)
				renderText << grabber.getDebugOutput
				renderText << "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\">Congratulations!  You have successfully refreshed your content.</p>
				<p style=\"font-family:arial;\"><a href=\"/\">Home</a></p> "
			else
				renderText << "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\"> Please specify cachecommand=clear&group=GROUPNAME or cachecommand=clearall or cachecommand=force_clear_all in the URL</p> "
			end					
		else	
			renderText << "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
					<p style=\"font-family:arial;\"> IP " + @mClientIp + " is not authorized.  Modify the feed_us_grabber_controller @mClientWhiteList array if this IP should have access. "				
		end
					
		render :text=> renderText
	end
	
	def IsPermittedToProceed			
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
					AddToDebugOutput("Host is #{host}")										
					if @mClientHostNameWhileList.include?(host) == true
						isPermitted = true
					end
				rescue
					# Do Nothing
				end
			end
		end
		
		if isPermitted == false
			# Heroku fwd -> X-Forwarded-For, request.remote_addr would return proxy IP so now try fwd ip
			@mClientIp = request.env["HTTP_X_FORWARDED_FOR"]	
			if @mClientIp == "" || @mClientIp.nil?
				@mClientIp = request.env["X-Forwarded-For"]
			end			
			isPermitted = IsClientIpInWhiteList()
			AddToDebugOutput("Trying to use X-Forwarded-For #{@mClientIp}")			
		end
				
		AddToDebugOutput("Results of is permitted check = #{isPermitted.to_s} for IP #{@mClientIp}")

		isPermitted
	end
	
	def IsClientIpInWhiteList
		included = false			
		if @mClientWhiteList.nil? && @mClientHostNameWhileList.nil?
			included = true
		else	
			# User can specify additional IP's to add to whitelist				
			configuredClientWhiteList = FeedUsGrabber.new.getClientWhiteList
			unless configuredClientWhiteList.nil? || configuredClientWhiteList.empty?			
				@mClientWhiteList.push(configuredClientWhiteList)
			end

			AddToDebugOutput("Checking if IP #{@mClientIp} is in ClientWhiteList #{@mClientWhiteList.to_s}")	

			if @mClientWhiteList.nil? == false && @mClientWhiteList.include?(@mClientIp) == true
				included = true
			end
		end
		return included
	end

	def AddToDebugOutput(info)
		@mDebugLogger.addToDebugOutput(@mArgs[:DebugOutput], info)		
	end
end
