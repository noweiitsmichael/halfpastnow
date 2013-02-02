require 'pp'
class ActsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]

  layout "venues"

  def show
    @fullmode = !params[:fullmode].to_s.empty?
    @modeType = "act"

    @act = Act.find(params[:id])
    @pageTitle = @act.name + " | half past now."
    if(current_user)
      bookmark = Bookmark.where(:bookmarked_type => 'Act', :bookmarked_id => @act.id, :bookmark_list_id => current_user.main_bookmark_list.id).first
      @bookmarkId = bookmark.nil? ? nil : bookmark.id
    else
      @bookmarkId = nil
    end

    @occurrences  = []
    @recurrences = []
    @pictures = []
    @occs = @act.events.collect { |event| event.occurrences.select { |occ| occ.start >= DateTime.now }  }.flatten.sort_by { |occ| occ.start }
    @occs.each do |occ|
      # check if occurrence is instance of a recurrence
      if occ.recurrence_id.nil?
        @occurrences << occ
      else
        if @recurrences.index(occ.recurrence).nil?
          @recurrences << occ.recurrence
        end
      end
    end

    @act.pictures.each do |pic|
      @pictures << pic
    end

    respond_to do |format|
      if @fullmode
        format.html { render :layout => "fullmode" }
      else
        format.html { render :layout => "mode" }
      end
      format.json { render json: { :occurrences => @occurrences.to_json(:include => :event), :recurrences => @recurrences.to_json(:include => :event), 
                                   :act => @act.to_json, :pictures => @pictures.to_json } } 
    end
  end

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @acts = Act.includes(:events, :tags, :embeds).all.sort_by{ |act| act.name }

    render :layout => "admin"
  end


  def destroy
    @act = Act.find(params[:id])
    @act.destroy

    render json: {:act_id => @act.id }
  end

  def actCreate
    pp params
    authorize! :actCreate, @user, :message => 'Not authorized as an administrator.'  
    if (params[:act][:id].to_s.empty?)
      @act = Act.new()
    else
      @act = Act.find(params[:act][:id])
    end
    puts "act update"
    # puts params[:act]
    @act.updated_by = current_user.id
    @act.update_attributes!(params[:act])
    @act.completion = @act.completedness
    @act.save!
    puts "act embeds"
    # pp @act.embeds
    unless params[:pictures].nil? 
      params[:pictures].each do |pic|
          #puts pic
          #puts pic[1]["id"]
          addedPic = Picture.find(pic[1]["id"])
          addedPic.pictureable_id = @act.id
          addedPic.save!
      end
    end


    respond_to do |format|
      if @act.save
        format.html { redirect_to :action => :index, :notice => 'yay' }
        format.json { render json: { :name => @act.name, :text => @act.name, :id => @act.id, :tags => (@act.tags.collect { |t| t.id.to_s } * ","), :completedness => @act.completion} }
      else
        format.html { redirect_to :action => :index, :notice => 'boo' }
        format.json { render json: false }
      end
    end
  end

  def actFind
    if(params[:contains])
      # @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :name => "#{a.name}", :text => "#{a.name}", :id => a.id, :fb_picture => a.fb_picture, :tags => (a.tags.collect { |t| t.id.to_s } * ",") , :pictures => a.pictures } }
      @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :name => "#{a.name}", :text => "#{a.name}", :id => a.id, :fb_picture => a.fb_picture, :tags => (a.tags.collect { |t| t.id.to_s } * ",") , :pictures => a.pictures } }
    else
      @acts = []
    end

    render json: @acts
  end

  def eventActFind
    if(params[:contains])
      @acts = Act.where("name ilike ?", "%#{params[:contains]}%").collect {|a| { :label => "#{a.name}", :value => "#{a.name}", :tags => a.tags.collect { |t| t.id}, :id => a.id } }
    else
      @acts = []
    end

    render json: @acts
  end

  # 
  def test
    query = "SELECT bookmark_lists.id, occurrences.recurrence_id AS recurrence_id, recurrences.range_end AS range_end, occurrences.start AS start,occurrences.deleted AS deleted, 
        occurrences.id AS occurrence_id, tags.id AS tag_id FROM bookmark_lists
        INNER JOIN bookmarks ON bookmark_lists.id = bookmarks.bookmark_list_id
        INNER JOIN occurrences ON bookmarks.bookmarked_id = occurrences.id
        INNER JOIN events ON occurrences.event_id = events.id
                INNER JOIN events_tags ON events.id = events_tags.event_id
                INNER JOIN recurrences ON events.id = recurrences.event_id
                INNER JOIN tags ON events_tags.tag_id = tags.id
                WHERE bookmarks.bookmarked_type = 'Occurrence' AND bookmark_lists.featured IS TRUE"
        result = ActiveRecord::Base.connection.select_all(query)
      listIDs = result.collect { |e| e["id"] }.uniq
      tagIDs = result.collect { |e| e["tag_id"].to_i }.uniq
      #@parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| tagIDs.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
    puts result.uniq
    puts result.uniq.size
    legitSet = filter_all_legit(result)
    #puts "legit set"
    puts legitSet.size
    legittagIDs = []
    tagIDs.each { |tagID|
      set = legitSet.select{ |r| r["tag_id"] == tagID.to_s }.uniq
      puts "Set herer"
      set1 = set.collect { |e| {:id => e["id"], :tag_id => e["tag_id"]}  }
      puts set1
      if set1.size > set1.uniq.size
        puts "TagID"
        puts tagID
        legittagIDs << tagID
      end
    }
    puts legittagIDs
    @parentTags = Tag.all(:conditions => {:parent_tag_id => nil}).select{ |tag| legittagIDs.uniq.include?(tag.id) && tag.name != "Streams" && tag.name != "Tags" }
    puts @parentTags
    puts @parentTags.collect{ |p| p.name}
    tag_id = params[:id]
    if tag_id.to_s.empty?
      @featuredLists = BookmarkList.where(:featured=>true)
    else
      @list=[]
      @exclude=[]
      rs = result.select { |r| r["tag_id"] == tag_id.to_s }.uniq
      rs.uniq.each{ |r|
        id = r["occurrence_id"]
        lID = r["id"]
        recurrence_id = r["recurrence_id"]
        deleted = r["deleted"]
        start = r["start"]
        range_end = r["range_end"]
        # occ = Occurrence.find(id)
        if ( deleted.eql?"f" ) # !deleted
          if !recurrence_id.nil?
            @list << lID
          else
            if start.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
              @list << lID
            else
              @exclude << r 
            end

          end
          
        else 
          if !recurrence_id.nil?
            #rec =   Recurrence.select{ |r| r.id = recurrence_id}.first
            if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
              @list << lID
            else
              @exclude << r 
            end
          else
            @exclude << r 
          end


        end
      }
      @legit = rs - @exclude
      puts "Legit"
      puts @legit
      puts @list

      ls = []
      @list.each { |l|
        puts "List ID"
        puts l
        n = @legit.select{ |r| r["id"] == l.to_s }.uniq
        if n.count > 1
          puts l
          ls << l
        end
      }
      @featuredLists = BookmarkList.find(ls)
      puts @featuredLists
      # @featuredLists = BookmarkList.find(result.select { |r| r["tag_id"] == tag_id.to_s }.collect { |e| e["id"] }.uniq)
    end
  end

  def filter_all_legit(result)
    @list=[]
    @exclude=[]
    
    result.uniq.each{ |r|
      id = r["occurrence_id"]
      lID = r["id"]
      recurrence_id = r["recurrence_id"]
      deleted = r["deleted"]
      # occ = Occurrence.find(id)
      start = r["start"]
      range_end = r["range_end"]
      puts r
      if ( deleted.eql?"f" )
        if !recurrence_id.nil?
          puts " 1 "
          @list << lID
        else
          if start.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
            puts " 2 "
            @list << lID
          else
            puts " 3 "
            @exclude << r 
          end

        end
        
      else 
        if !recurrence_id.nil?
          puts " 4 "
          #rec = Recurrence.select{ |r| r.id = recurrence_id}.first
          if range_end.nil? || range_end.to_time >= Date.today.strftime('%a, %d %b %Y %H:%M:%S').to_time
            puts " 5 "
            @list << lID
          else
            puts " 6 "
            @exclude << r 
          end
        else
          puts " 7 "
          @exclude << r 
        end


      end
    }
    return @legit = result - @exclude 
  end
  # 


  def actsMode
    if(params[:id].to_s.empty?)
      @act = Act.new
    else
      @act = Act.find(params[:id])
    end
    @parentTags = Tag.includes(:childTags).all(:conditions => {:parent_tag_id => nil})

    render :layout => false
  end

end
