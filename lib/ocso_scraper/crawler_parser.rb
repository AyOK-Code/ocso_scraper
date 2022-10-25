require 'nokogiri'
module OcsoScraper
     class CrawlerParser

        def self.parser(html)
            Nokogiri::HTML(html.body)
        end
     end
end