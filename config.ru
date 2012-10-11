# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

map '/lab04' do
	run GESTPRO::Application
end

