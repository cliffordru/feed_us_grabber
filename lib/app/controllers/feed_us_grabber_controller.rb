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
		args[:DebugOutput] = ""
		args[:Debug] = false
		unless params[:debug].nil?
			args[:Debug] = params[:debug] == "1"
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
		isPermittedToProceed = IsPermittedToProceed(args)
		
		renderText = ""
		if isPermittedToProceed == false
			renderText = "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
					<p style=\"font-family:arial;\"> IP " + @mClientIp + " is not authorized.  Modify the feed_us_grabber_controller @mClientWhiteList array if this IP should have access. "				
		else	
			if fetch == true 
				feedUsGrabber(args)
				renderText = "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\">Congratulations!  You have successfully refreshed your content.</p>
				<p style=\"font-family:arial;\"><a href=\"/\">Home</a></p> "
			else
				renderText = "<img src=\"http://feed.us/images/feedus_logo_people.png\"><br />
				<p style=\"font-family:arial;\"> Please specify cachecommand=clear&group=GROUPNAME or cachecommand=clearall or cachecommand=force_clear_all in the URL</p> "
			end
		end
		
		if args[:Debug] == true
			renderText << args[:DebugOutput]
			renderText << @mClientWhiteList.to_s	
		end
		
		render :text=> renderText
	end
	
	def IsPermittedToProceed(args)			
		isPermitted = false
		@mClientIp = request.remote_addr	
		
		if @mClientIp == "" || @mClientIp.nil?
			@mClientIp = request.env["HTTP_X_FORWARDED_FOR"]
		end
				
		isPermitted = IsClientIpInWhiteList(args)
		
		if isPermitted == false
			if @mClientHostNameWhileList.nil? == false
				# Try to resolve hostname from ip
				begin
					s = Socket.getaddrinfo(@mClientIp,nil)
					host = s[0][2]
					puts "Trace: host = #{host}"						
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
			isPermitted = IsClientIpInWhiteList(args)
			puts "Trace: Try to use fwd header = #{@mClientIp}"	
			puts "Trace: using fwd header isPermitted = #{isPermitted}"	
		end
		
		# Set the Debug flag - do not want to output Debug info if not permitted
		if isPermitted == false
			args[:Debug] = false
		end
		
		puts "Trace: mClientIp = #{@mClientIp}"		
		puts "Trace: returning is permitted true"
		args[:DebugOutput] << "Debug: mClientIp = #{@mClientIp}"

		return isPermitted
	end
	
	def IsClientIpInWhiteList(args)
		included = false		
		if @mClientWhiteList.nil? && @mClientHostNameWhileList.nil?
			included = true
		else	
			# User can specify additional IP's to add to whitelist				
			configuredClientWhiteList = FeedUsGrabber.new.getClientWhiteList
			unless configuredClientWhiteList.nil? || configuredClientWhiteList.empty?			
				@mClientWhiteList.push(configuredClientWhiteList)
			end

			if @mClientWhiteList.nil? == false && @mClientWhiteList.include?(@mClientIp) == true
				included = true
			end
		end
		return included
	end
end
