CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => 'AKIAJTZNTKSJQPAV3SLA',#ENV['AWS_ACCESS_KEY_ID'],       # required
    :aws_secret_access_key  => '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',#ENV['AWS_SECRET_ACCESS_KEY'],       # required
    :region                 => 'us-east-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = 'hpn_profile_pics'#ENV['S3_BUCKET_NAME'] #                    # required
  config.fog_host = "http://#{config.fog_directory}.s3.amazonaws.com"

  if ENV['RAILS_ENV'] != 'production'
      config.delete_tmp_file_after_storage = false
  end
end

## Alternative, using Carrierwave's built-in S3 adapter (which is based on fog???)
# CarrierWave.configure do |config|
#   config.root = Rails.root.join('tmp') # adding these...
#   config.cache_dir = 'carrierwave' # ...two lines

#   config.s3_access_key_id = ENV['AWS_ACCESS_KEY_ID']
#   config.s3_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
#   config.s3_bucket = ENV['S3_BUCKET_NAME']
# end