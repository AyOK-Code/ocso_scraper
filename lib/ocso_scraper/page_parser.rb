require 'nokogiri'
module OcsoScraper
  class PageParser
    def self.perform(html)
      parsed_html = Nokogiri::HTML(html.body)

      data = parsed_html.css('td font').children

      warrants = []

      data.each_slice(6) do |last_el, first_el, middle_el, dob_el, details_el, offenses_el|
        details = details_el.text.split('   ')
        warrant = {
          last_name: last_el.text,
          first_name: first_el.text,
          middle_name: middle_el.text,
          birth_date: parse_date(dob_el.text),
          case_number: strip_nbsp(details[0].sub('CASE_NUMBER: ','')),
          bond_amount: Monetize.parse(strip_nbsp(details[1].sub('Bond Amount: ',''))).to_f.round(2),
          issued: parse_date(strip_nbsp(details[2].sub('Issued: ',''))),
          counts: strip_nbsp(offenses_el.text)
        }
        warrants << warrant
      end
      warrants
    end

    def self.parse_date(date)
      Date.strptime(date, '%m/%d/%Y')
    rescue
      nil
    end

    def self.strip_nbsp(string)
      string.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
    end
  end
end