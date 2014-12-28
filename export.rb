require 'rubygems'
require 'bundler/setup'

require 'optparse'

$LOAD_PATH << './lib'
require 'tsr_scraper'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: export.rb [options]"

  opts.on("-u", "--username [USERNAME]", "TSR username") do |username|
    options[:username] = username
  end

  opts.on("-p", "--password [PASSWORD]", "TSR password") do |password|
    options[:password] = password
  end

  opts.on("-s", "--start-date [DATE]", "Start date to export from") do |start_date|
    options[:start_date] = start_date
  end
end.parse!

scraper = TSRScraper.new(options[:username], options[:password], options[:start_date])
scraper.log_in
scraper.export_all


