desc "Keep heroku reachoutt awake"
task :call_reachoutt => :environment do
  uri = URI.parse("http://www.reachoutt.com/")
  Net::HTTP.get(uri)
end
