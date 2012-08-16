# FeedUsGrabber
require 'feed_us_grabber/routing'
require File.join(File.dirname(__FILE__), 'app', 'models','feed_us_grabber')
require File.join(File.dirname(__FILE__), 'app', 'models','feed_us_grabber_logger')

# Added for gem
require File.join(File.dirname(__FILE__), 'app', 'helpers','feed_us_grabber_helper')
require File.join(File.dirname(__FILE__), 'app', 'controllers','feed_us_grabber_controller')

%w{ controllers helpers }.each do |dir| 

	path = File.join(File.dirname(__FILE__), 'app', dir)  
	$LOAD_PATH << path  

	# Commenting out for gem as generates error
	#ActiveSupport::Dependencies.autoload_paths << path
	#ActiveSupport::Dependencies.autoload_once_paths.delete(path) 	
end
