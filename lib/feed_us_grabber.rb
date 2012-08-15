# FeedUsGrabber
require 'feed_us_grabber/routing'
require File.join(File.dirname(__FILE__), 'app', 'models','feed_us_grabber')
require File.join(File.dirname(__FILE__), 'app', 'models','feed_us_grabber_logger')

%w{ controllers helpers }.each do |dir| 

	path = File.join(File.dirname(__FILE__), 'app', dir)  
	$LOAD_PATH << path  

	ActiveSupport::Dependencies.autoload_paths << path 
	ActiveSupport::Dependencies.autoload_once_paths.delete(path) 
end
