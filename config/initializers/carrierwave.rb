CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],       # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],       # required
    :region                 => 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['S3_BUCKET_NAME'] #'hpn_profile_pics'                    # required
  config.fog_host = "http://#{config.fog_directory}.s3.amazonaws.com"

end

## Alternative, using Carrierwave's built-in S3 adapter (which is based on fog???)
# CarrierWave.configure do |config|
#   config.root = Rails.root.join('tmp') # adding these...
#   config.cache_dir = 'carrierwave' # ...two lines

#   config.s3_access_key_id = ENV['AWS_ACCESS_KEY_ID']
#   config.s3_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
#   config.s3_bucket = ENV['S3_BUCKET_NAME']
# end