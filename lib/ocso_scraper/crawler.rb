require 'httparty'
require 'uri'
require 'net/http'
require 'openssl'

module OcsoScraper
  class Crawler
    def self.perform
      warrants = []
      ('A'..'Z').each do |first_name_first_letter|
        ('A'..'Z').each do |last_name_first_letter|
          last_name_query = last_name_first_letter
          next_last_name_query = nil
          continue = true
          while continue
            results = request(first_name_first_letter, last_name_query)
            page_warrants = PageParser.perform(results).sort_by! { |warrant| warrant[:last_name] }
            warrants += page_warrants
            if next_last_name_query.present?
              last_name_query = next_last_name_query
              next_last_name_query = nil
            elsif page_warrants.count < page_limit
              continue = false
            else
              last_name_second_letter = page_warrants.last[:last_name].chars[1]
              last_name_query = "#{last_name_first_letter}#{last_name_second_letter}"
              next_last_name_query = "#{last_name_first_letter}[#{last_name_second_letter.succ}-z]"
            end
          end
        end
      end
      warrants
    end

    def self.page_limit
      300
    end

    def self.request(first_name_query, last_name_query)
      # if ENV['PROXY_HOST']
      #     HTTParty::Basement.http_proxy(
      #       ENV['PROXY_HOST'],
      #       ENV['PROXY_PORT'],
      #       ENV.fetch('PROXY_USER', nil),
      #       ENV.fetch('PROXY_PASS', nil)
      #     )
      # end

      header = {}
      header['Accept'] =
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
      header['Accept-Language'] = 'en-US,en;q=0.9'
      header['Cache-Control'] = 'max-age=0'
      header['Connection'] = 'keep-alive'
      header['Content-Type'] = 'application/x-www-form-urlencoded'
      # header["Cookie"] = 'ASPSESSIONIDAQSCCBTC=FHLDNKLAHOAHDCKHMDIHFNCA; visid_incap_2750025=RII72YP8SEWUlOfLX4K623irUmMAAAAAQUIPAAAAAACAVbiSlAhJFnG/Lw3pVGKi; nlbi_2750025=zXYlTha8x0O23zO8jxDpsAAAAAB7kvlmrEZMG6fODP8V0axW; ASPSESSIONIDCSRBACSD=MCPFIOBDCOKOHKBAOLJLABNP; ASPSESSIONIDCSQDACTC=ONKNGKODFKCJMGGFJALNPLDG; incap_ses_1438_2750025=2Sylc1VZTjHJMJctJc70Ey8HWGMAAAAAZlSehJ609ZmGvCvuHdiw+Q=='
      header['Origin'] = 'https://docs.oklahomacounty.org'
      header['Referer'] = 'https://docs.oklahomacounty.org/sheriff/warrantsearch/'
      header['Sec-Fetch-Dest'] = 'document'
      header['Sec-Fetch-Mode'] = 'navigate'
      header['Sec-Fetch-Site'] = 'same-origin'
      header['Sec-Fetch-User'] = '?1'
      header['Upgrade-Insecure-Requests'] = '1'
      header['User-Agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36'
      header['sec-ch-ua'] = '".Not/A)Brand";v="99", "Google Chrome";v="103", "Chromium";v="103"'
      header['sec-ch-ua-mobile'] = '?0'
      header['sec-ch-ua-platform'] = '"macOS"'

      puts "making request for #{first_name_query} and #{last_name_query}"

      HTTParty.post(
        'https://docs.oklahomacounty.org/sheriff/warrantsearch/warrantresults.asp',
        headers: header,
        body: "lname=#{first_name_query}&fname=#{last_name_query}"
      )
    end
  end
end
