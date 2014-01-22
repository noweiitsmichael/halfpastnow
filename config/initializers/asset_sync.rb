if defined?(AssetSync)
  AssetSync.configure do |config|
    config.fog_provider = 'AWS'
    config.aws_access_key_id = "AKIAJTZNTKSJQPAV3SLA"
    config.aws_secret_access_key = "LTRuhT705XVHFyVxeAMT7X10WgBDpYNaY7gugXjP"
    config.fog_directory = "hpn-production-assets"

    # Increase upload performance by configuring your region
    config.fog_region = "us-east-1"
    #
    # Don't delete files from the store
    # config.existing_remote_files = "keep"
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to
    # upload instead of searching the assets directory.
    config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    # config.fail_silently = true
  end
end