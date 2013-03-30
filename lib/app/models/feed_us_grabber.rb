# defining constants
CI_MINUTES  =  0
CI_HOURS    =  1
CI_DAYS     = 2
CI_FOREVER  = 3
ERROR_RESPONSE = "&nbsp;"
CACHE_COMMAND_FORCE = "force_clear_all"

require 'time'
require 'fileutils'


class FeedUsGrabber
  def initialize
    @mintCacheIntervalUnit = CI_FOREVER
    @mstrCacheFolder = File.join(Rails.root.to_s,'tmp','CachedWebContent')
    @mstrCacheFileExt = ".cache"
	@mstrCacheGroup = ""	
  end
  
  def setCacheGroup(param)
    @mstrCacheGroup = param
  end
  
  
  
  def setCacheFolder(param) 
		@mstrCacheFolder = param
  end
  
  
  
  def setCacheIntervalUnit(param) 
		@mintCacheIntervalUnit = param
  end
	
	
	
	def getCacheIntervalUnit
		@mintCacheIntervalUnit
	end
	
	def setCacheFileExt(strNewValue) 
    @mstrCacheFileExt = strNewValue
  end
	
	def setCacheCommand(strNewValue) 
	  @mstrCacheCommand = strNewValue
  end
  
  def getCacheCommand
		@mstrCacheCommand
	end
	
	def getCacheFolder
		@mstrCacheFolder
	end
	
	def setIncludeFlag(strNewValue) 
		@mblnInclude = $strNewValue
	end
	
  def getIncludeFlag
		@mblnInclude
	end
	
	def getCacheGroup
		@mstrCacheGroup
	end
	def getCachedFileName
	  @getCachedFileName
	end
	
	def setCacheIntervalLength(param) 
		@mintCacheIntervalLength = param
  end
	
	def getCacheIntervalLength
    @mintCacheIntervalLength
	end
	
	def setDynURL(param) 
			@mstrDynURL = param
			self.getCacheNames(param)
  end
  
  def getDynURL
			@mstrDynURL
	end
  
  def getCacheNames(sURL) 
    if (sURL =~ /\?/) > 0
      base = sURL.split('?')[0]
      params = sURL.split('?')[1]
    else
      base = sURL
      params = ''
    end
		#strip off the file extension	
		base = base.chomp(File.extname(base))
    base.sub!('http://','')
    base.gsub!(/[\?:\/\.]/,'_')
		@mstrScriptBaseName = base
    @mstrCacheFileQualifiers = self.getCacheFileQualifiers(params)
		@mstrCachedFileName =File.join( @mstrCacheFolder,
		                                @mstrCacheGroup,
		                                @mstrScriptBaseName + "_" + @mstrCacheFileQualifiers + @mstrCacheFileExt)
		@mstrCachedFileNameShort = @mstrScriptBaseName + "_" + @mstrCacheFileQualifiers + @mstrCacheFileExt
	end
	
	def getCacheFileQualifiers(strURLParams)		
		strResults = nil
		strSeparator = "_"
    strResults  = '_' + strURLParams.gsub(/[=&%\.\/:]+/,'_')
		strResults
	end
	
	def autoCacheToFile	
		puts "trace: start autoCacheToFile.  bIsPostBack = #{@bIsPostBack}"
		if @bIsPostBack
		  return
		end
		
		puts "trace: mstrCacheCommand = #{@mstrCacheCommand}"
		if @mstrCacheCommand.nil? || @mstrCacheCommand == ''
		  if (!self.cachedFileExists) or self.cacheFileIsExpired
		    self.createCacheFile
		  end
		else
		  if @mstrCacheCommand == "clear"
			if @mstrCacheGroup != ''
				self.clearCacheGroupFiles(@mstrCacheGroup)
			end
		  end
		  if @mstrCacheCommand == 'clearall' || @mstrCacheCommand == CACHE_COMMAND_FORCE
		    self.clearAllCachedFiles
		  end
		end
	end
	
	def cachedFileExists()
	  File.readable?(@mstrCachedFileName)
	end
	
	def cacheFileIsExpired()
		# Ruby 1.9.x Time.parse expects d/m/y
		strDate = File.mtime(@mstrCachedFileName).strftime('%d/%m/%Y %I:%M:%S %p')
		case @mintCacheIntervalUnit
	    when CI_MINUTES then strUnit = 'n'
	    when CI_HOURS then strUnit = 'h'
	    when CI_DAYS then strUnit = 'd'
      when CI_FOREVER then return false
		end
		
		if self.datediff(strUnit,strDate,Time.now().strftime('%d/%m/%Y %I:%M:%S %p')) > @mintCacheIntervalLength
		  return true
		else
		  return false
		end
	end
	
	def createCacheFile()
		strDynURL = @mstrDynURL					
		sFile = @mstrCachedFileName
		# Fetch the url
		begin
		  r = Net::HTTP.get_response(URI.parse(@mstrDynURL))
		rescue
		  logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
		  grabber_logger = FeedUsGrabberLogger.new(logfile)

		  grabber_logger.error("Unable to fetch URL #{@mstrDynURL}")
		  logfile.close
		  return;
		end

		if self.makeDirectory(File.join(@mstrCacheFolder,@mstrCacheGroup))
		  File.open(sFile,'w') do |file|
  		  file.write(r.body)  
  		end
  		return true
		end
		return false
  end
  
	def makeDirectory(dir, mode = 0755)
		if File.directory?(dir) || FileUtils.mkdir(dir)
		  return true
		end
		return false
	end
	
	def datediff(interval, datefrom, dateto, using_timestamps = false) 
		#$interval can be:
		#yyyy - Number of full years
		#q - Number of full quarters
		#m - Number of full months
		#y - Difference between day numbers
		#(eg 1st Jan 2004 is "1", the first day. 2nd Feb 2003 is "33". The datediff is "-32".)
		#d - Number of full days
		#w - Number of full weekdays
		#ww - Number of full weeks
		#h - Number of full hours
		#n - Number of full minutes
		#s - Number of full seconds (default)
		
		unless using_timestamps	
		  datefrom = Time.parse(datefrom).to_i
		  dateto = Time.parse(dateto).to_i
		end
		
		difference = dateto - datefrom  # Difference in seconds
	  if interval == 'd'
	    	datediff = (difference / 86400).floor
	  elsif interval == 'h'
	    datediff = (difference / 3600).floor
    elsif interval == 'n'
      datediff = (difference / 60).floor
    else
      datediff = difference
	  end
	  datediff
	end
	
	def renderCacheFromFile
		sFile = @mstrCachedFileName
		data = ''
		begin
		  File.open(sFile,'r') do |file|
		    while temp_data = file.gets
		      data = data + temp_data
		    end
      end
      data
    rescue
      logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
  		grabber_logger = FeedUsGrabberLogger.new(logfile)
		  grabber_logger.error("Unable to render/open #{@mstrCachedFileName}")
		  logfile.close
    end
	end
	
	
	def clearCacheGroupFiles(group)
	  if group == '.' || group == '..'
	    logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
  		grabber_logger = FeedUsGrabberLogger.new(logfile)
		  grabber_logger.warn("someone requested to delete . OR .. ")
		  logfile.close
	    return
	  end
	  logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
		grabber_logger = FeedUsGrabberLogger.new(logfile)
	  grabber_logger.info("Clearing cache at group  #{group} at path #{File.join(@mstrCacheFolder,group)}")
	  logfile.close
	  self.clearCacheFolder(File.join(@mstrCacheFolder,group))
  end
  
  def clearAllCachedFiles
	# For testing heroku logging	
	puts "Trace: Clearing all caches at path = #{@mstrCacheFolder}"
    logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
	grabber_logger = FeedUsGrabberLogger.new(logfile)
	grabber_logger.info("Clearing all caches at path #{@mstrCacheFolder}")
	logfile.close
    self.clearCacheFolder(@mstrCacheFolder);
	end
  
  def clearCacheFolder(folder)
	canConnect = canConnectToFeedUs()	
	
	if canConnect == true
		puts "Trace: clear cache folder can connect"
		FileUtils.rm_r Dir.glob("#{folder}/*")
	else
		logError("Unable to connect to Feed.Us. Cache will not be cleared. URL that was checked: #{@mstrDynURL}")
	end
  end
  
  def canConnectToFeedUs()	
	# Used for phone home check
	canConnect = false	
	
	if @mstrCacheCommand == CACHE_COMMAND_FORCE 
		canConnect = true
	else
		begin
			r = Net::HTTP.get_response(URI.parse(@mstrDynURL))
			if r.body.nil? == false && r.body != ERROR_RESPONSE
				canConnect = true
			end			
		rescue
		  logError("Unable to connect to Feed.Us.  Cache will not be cleared. URL #{@mstrDynURL}")	   
		end
	end
  	
    return canConnect; 
  end
  
  def logError(contents)
    logfile = File.open(File.join(Rails.root.to_s,'log','FeedUsGrabber.log'),'a');
    grabber_logger = FeedUsGrabberLogger.new(logfile)

    grabber_logger.error(contents)
    logfile.close	  
  end
			
end