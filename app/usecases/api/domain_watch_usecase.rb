require 'http'
require 'nokogiri'

class Api::DomainWatchUsecase < Api::Usecase
  class Input < Api::Usecase::Input
    attr_accessor :domainName

    def initialize(domainName:)
      @domainName = domainName
    end
  end

  class Output < Api::Usecase::Output
    attr_accessor :whois_data

    def initialize(whois_data:)
      @whois_data = whois_data
    end

    def as_json(options = {})
      { whois_data: whois_data }
    end
  end

  def initialize(input:)
    @input = input
  end

  def fetch
    api_key = ENV['WHOIS_API_KEY']
    begin
      response = HTTP.headers(accept: 'application/xml').get("https://www.whoisxmlapi.com/whoisserver/WhoisService", params: { apiKey: api_key, domainName: @input.domainName })

      if response.status.success?
        if response.content_type.mime_type == 'application/xml'
          xml_data = Nokogiri::XML(response.body.to_s)
          parsed_data = parse_xml(xml_data)
          Output.new(whois_data: parsed_data)
        else
          Output.new(whois_data: { error: 'Unsupported MIME type', mime_type: response.content_type.mime_type })
        end
      else
        Output.new(whois_data: { error: 'Failed to fetch WHOIS information', details: response.body.to_s })
      end
    rescue => e
      Output.new(whois_data: { error: 'Exception occurred', message: e.message })
    end
  end

  private

  def parse_xml(xml_data)
    {
      domain_name: xml_data.at_xpath('//domainName')&.text,
      registrar: xml_data.at_xpath('//registrarName')&.text,
      creation_date: xml_data.at_xpath('//createdDate')&.text,
      updated_date: xml_data.at_xpath('//updatedDate')&.text,
      expiration_date: xml_data.at_xpath('//expiresDate')&.text,
      status: xml_data.at_xpath('//status')&.text,
      registrant: {
        organization: xml_data.at_xpath('//registrant/organization')&.text,
        state: xml_data.at_xpath('//registrant/state')&.text,
        country: xml_data.at_xpath('//registrant/country')&.text,
        country_code: xml_data.at_xpath('//registrant/countryCode')&.text
      },
      administrative_contact: {
        organization: xml_data.at_xpath('//administrativeContact/organization')&.text,
        state: xml_data.at_xpath('//administrativeContact/state')&.text,
        country: xml_data.at_xpath('//administrativeContact/country')&.text,
        country_code: xml_data.at_xpath('//administrativeContact/countryCode')&.text
      },
      technical_contact: {
        organization: xml_data.at_xpath('//technicalContact/organization')&.text,
        state: xml_data.at_xpath('//technicalContact/state')&.text,
        country: xml_data.at_xpath('//technicalContact/country')&.text,
        country_code: xml_data.at_xpath('//technicalContact/countryCode')&.text
      },
      name_servers: xml_data.xpath('//nameServers/hostNames/hostName').map(&:text).reject(&:empty?)
    }
  end
end
