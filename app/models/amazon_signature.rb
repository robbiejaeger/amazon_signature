class AmazonSignature

  def initialize(secret, url)
    @_secret = secret
    @_url = url
  end

  def sign
    host_and_path, params = url.split("?")
    canonical = formated_params(params)
    signature = create_signature(canonical)
    "#{host_and_path}?#{canonical}&Signature=#{signature}"
  end

  private

  def formated_params(params)
    params = params.gsub(",","%2C").gsub(":","%3A")
    params.split("&").sort.join("&")
  end

  def create_signature(canonical)
    data      = ['GET', 'webservices.amazon.com', '/onca/xml', canonical].join("\n")
    sha256    = OpenSSL::Digest::SHA256.new
    sig       = OpenSSL::HMAC.digest(sha256, secret, data)
    signature = Base64.encode64(sig).strip
    signature = signature.gsub("+", "%2B").gsub("=", "%3D")
  end

  def secret
    @_secret
  end

  def url
    @_url
  end
end
