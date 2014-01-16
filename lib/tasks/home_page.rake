namespace :home_page do
  desc "home page section one getting occurrence"
  task :section1 => :environment do
    Rails.logger.debug "home_page_section1"

    lat = 30.268093
    long = -97.742808
    zoom = 11

    params = {}
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom

    ids = Occurrence.find_with(params)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"

    @occurrences =  Occurrence.includes(:event => :tags).find(occurrence_ids, :order => order_by).take(5)
    @advertisement = Advertisement.where(:placement => ['home_page', 'home_search_pages'] ).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first

    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end
    html_str = view.render partial: 'events/home_page_section1', locals: {advertisement: @advertisement, occurrences: @occurrences}
    Rails.cache.write(:home_page_section1, html_str)
  end

  desc "home page section two austin occurrences"
  task :section2 => :environment do
    Rails.logger.debug "home_page_section2 austin occurrences"
    @austin_occurrences =  BookmarkList.find(2370).bookmarked_events_root.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }.take(5)

    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end
    html_str = view.render partial: 'events/home_page_section2', locals: {austin_occurrences: @austin_occurrences}
    Rails.cache.write(:home_page_section2, html_str)
  end

  desc "home page section three Happy Place"
  task :section3 => :environment do
    Rails.logger.debug "home_page_section3 Happy Place"

    lat = 30.268093
    long = -97.742808
    zoom = 11

    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:stream_id] = 19

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    #ads
    @advertisement = Advertisement.where(:adv_type => ["featured_venue", "featured_event", "featured_artist"]).where(:placement => ['search_results', 'home_search_pages']).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first

    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end
    html_str = view.render partial: 'events/home_page_section3', locals: {advertisement: @advertisement, occurrences: @occurrences}
    Rails.cache.write(:home_page_section3, html_str)
  end

  desc "home page section four Dance"
  task :section4 => :environment do
    Rails.logger.debug "home_page_section4"

    lat = 30.268093
    long = -97.742808
    zoom = 11

    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:included_tags] = "1"

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end
    html_str = view.render partial: 'events/home_page_section4', locals: {occurrences: @occurrences}
    Rails.cache.write(:home_page_section4, html_str)
  end

  desc "Free! Section 5"
  task :section5 => :environment do
    Rails.logger.debug "home_page_section5"

    lat = 30.268093
    long = -97.742808
    zoom = 11

    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:high_price] = 0

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end
    html_str = view.render partial: 'events/home_page_section5', locals: {occurrences: @occurrences}
    Rails.cache.write(:home_page_section5, html_str)
  end


  desc "Generate HTML for home page default sections"
  task :default_sections_html => :environment do
    ## for basic view setup
    app = Myapp::Application
    app.routes.default_url_options = {:host => 'www.halfpastnow.com'}
    controller = EventsController.new
    view = ActionView::Base.new(app.config.paths["app/views"].first, {}, controller)
    view.class_eval do
      include ApplicationHelper
      include app.routes.url_helpers
    end

    ## defaults params
    lat = 30.268093
    long = -97.742808
    zoom = 11

    Rails.logger.debug "home_page_section1"
    params = {}
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom

    ids = Occurrence.find_with(params)
    occurrence_ids = ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"

    @occurrences =  Occurrence.includes(:event => :tags).find(occurrence_ids, :order => order_by).take(5)
    @advertisement = Advertisement.where(:placement => ['home_page', 'home_search_pages'] ).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first

    html_str = view.render partial: 'events/home_page_section1', locals: {advertisement: @advertisement, occurrences: @occurrences}
    Rails.cache.write(:home_page_section1, html_str)

    Rails.logger.debug "home_page_section2 austin occurrences"
    @austin_occurrences =  BookmarkList.find(2370).bookmarked_events_root.select{ |o| o.start.strftime('%a, %d %b %Y %H:%M:%S').to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time }.sort_by { |o| o.start }.take(5)

    html_str = view.render partial: 'events/home_page_section2', locals: {austin_occurrences: @austin_occurrences}
    Rails.cache.write(:home_page_section2, html_str)

    Rails.logger.debug "home_page_section3 Happy Place"
    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:stream_id] = 19

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    #ads
    @advertisement = Advertisement.where(:adv_type => ["featured_venue", "featured_event", "featured_artist"]).where(:placement => ['search_results', 'home_search_pages']).where("start <= '#{Date.today}' AND advertisements.end >= '#{Date.today}'").order('weight ' 'desc').first

    html_str = view.render partial: 'events/home_page_section3', locals: {advertisement: @advertisement, occurrences: @occurrences}
    Rails.cache.write(:home_page_section3, html_str)

    Rails.logger.debug "home_page_section4"
    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:included_tags] = "1"

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    html_str = view.render partial: 'events/home_page_section4', locals: {occurrences: @occurrences}
    Rails.cache.write(:home_page_section4, html_str)

    Rails.logger.debug "home_page_section5"
    params = {}
    params[:start_date] = Date.today().to_s(:db)
    params[:end_date] = (Date.today()+14.days).to_s(:db)
    params[:lat_center] = lat
    params[:long_center] = long
    params[:zoom] = zoom
    params[:high_price] = 0

    @ids = Occurrence.find_with(params)
    @occurrence_ids = @ids.collect { |e| e["occurrence_id"] }.uniq
    order_by = "occurrences.start"
    @occurrences = Occurrence.includes(:event => :tags).where(id: @occurrence_ids).order(order_by).limit(5)

    html_str = view.render partial: 'events/home_page_section5', locals: {occurrences: @occurrences}
    Rails.cache.write(:home_page_section5, html_str)
  end
end
