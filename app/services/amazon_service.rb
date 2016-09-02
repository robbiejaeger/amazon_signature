class AmazonService

  def initialize
    @_conn = Faraday.new
  end

  def get_info(upcs)
    begin
      app_name = "amazon_signature"
      url = "http://webservices.amazon.com/onca/xml?AWSAccessKeyId=#{ENV['AMAZON_ACCESS_KEY_ID']}&AssociateTag=#{app_name}&ItemId=#{upcs}&IdType=UPC&SearchIndex=All&Operation=ItemLookup&ResponseGroup=Large&Service=AWSECommerceService&Timestamp="
      url << Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")

      signed_url = create_signature(url)
      response = connection.get do |req|
        req.url signed_url
      end

      result = parse(response)

    rescue StandardError
      puts "sleepytime"
      sleep(3)
    end
  end

  private

    def create_signature(url)
      AmazonSignatureService.new(ENV['AMAZON_SECRET_ACCESS_KEY'], url).sign
    end

    def connection
      @_conn
    end

    def parse(response)
      Crack::XML.parse(response.body)["ItemLookupResponse"]["Items"]["Item"] unless response.nil?
    end
end
