require "httparty"

module OcsoScraper
class Crawler


def self.request
    if ENV['PROXY_HOST']
        HTTParty::Basement.http_proxy(
          ENV['PROXY_HOST'],
          ENV['PROXY_PORT'],
          ENV.fetch('PROXY_USER', nil),
          ENV.fetch('PROXY_PASS', nil)
        )
    end
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36'
    accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
url = "https://docs.oklahomacounty.org/sheriff/warrantsearch/" 
  
    html = HTTParty.post(url, headers: {'Content-Type' => 'text'} ,body:"lname=A&fname=S")
    byebug

end
end
end
