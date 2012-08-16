module FeedUsGrabberRoute #:nodoc:  i
	module Routing #:nodoc:  
		module MapperExtensions 
			def feedusgrabber
				@set.add_route("/FeedUsGrabber", {:controller => "feed_us_grabber", :action => "index"}) 				
			end  
		end  
	end 
end 

if ActionPack::VERSION::MAJOR >= 3
  # Commenting out for gem as generates -> uninitialized constant ActionDispatch::Routing::DeprecatedMapper (NameError)	
  #ActionDispatch::Routing::DeprecatedMapper.send :include, FeedUsGrabberRoute::Routing::MapperExtensions
  #ActionDispatch::Routing::DeprecatedMapper :include, FeedUsGrabberRoute::Routing::MapperExtensions
else
  ActionController::Routing::RouteSet::Mapper.send :include, FeedUsGrabberRoute::Routing::MapperExtensions
end




