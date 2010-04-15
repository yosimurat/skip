class BookmarksController < ApplicationController
  include AccessibleBookmarkComment
  layout :select_layout

  def index
    search_params = params[:search] || {}
    search_params[:bookmark_comments_count_gt] = 0
    search_params[:publicated] = true
    search_params[:order_sort_type] ||= 'date_desc'
    search_params[:bookmark_type] ||= 'all'
    @search = current_tenant.bookmarks.tagged(params[:tag_words], params[:tag_select]).search(search_params)
    @bookmarks = @search.paginate(:include => :bookmark_comments, :page => params[:page], :per_page => 25)

    respond_to do |format|
      format.html do
        @tags = BookmarkComment.get_popular_tag_words(current_tenant)
        if @bookmarks.empty?
          flash.now[:notice] = _('No matching data found.')
        end
        render
      end
    end
  end

  def new
    if params[:bookmark]
      if bookmark = current_tenant.bookmarks.find_by_url(Bookmark.unescaped_url(params[:bookmark][:url]))
        respond_to do |format|
          format.html do
            if @bookmarklet
              redirect_to edit_polymorphic_url([current_tenant, bookmark])
            else
              redirect_to polymorphic_url([current_tenant, bookmark], :action => :edit_without_bookmarklet)
            end
          end
        end
      else
        @bookmark = current_tenant.bookmarks.build(params[:bookmark])
        @bookmark.title = SkipUtil.toutf8_without_ascii_encoding(@bookmark.title)
        @title = _('Bookmark Comment')
        respond_to do |format|
          format.html { render :new }
        end
      end
    end
  rescue Bookmark::InvalidMultiByteURIError => e
    flash[:error] = _('URL format invalid.')
    render :new_url
  end

  def new_with_bookmarklet
    params[:bookmarklet] = true
    new_without_bookmarklet
  end
  alias_method_chain :new, :bookmarklet

  def create
    @bookmark = current_tenant.bookmarks.build(params[:bookmark])
    @bookmark.url = Bookmark.unescaped_url(params[:bookmark][:escaped_url])
    required_full_accessible_bookmark_comment(@bookmark.bookmark_comments.last) do
      @bookmark.save!
      respond_to do |format|
        format.html do
          if params[:bookmarklet]
            render :text => "<script type='text/javascript'>location.href='#{@bookmark.url}';</script>"
          else
            flash[:notice] = _('Bookmark was successfully created.')
            redirect_to [current_tenant, :bookmarks]
          end
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => ex
    respond_to do |format|
      format.html { render :new }
    end
  rescue Bookmark::InvalidMultiByteURIError => e
    respond_to do |format|
      flash.now[:error] = _('URL format invalid.')
      format.html { render :new }
    end
  end

  def edit
    @bookmark = current_tenant.bookmarks.find(params[:id])
    @bookmark.title = SkipUtil.toutf8_without_ascii_encoding(@bookmark.title)
    @title = _('Bookmark Comment')
    respond_to do |format|
      format.html { render :new }
    end
  end

  def edit_with_bookmarklet
    params[:bookmarklet] = true
    edit_without_bookmarklet
  end
  alias_method_chain :edit, :bookmarklet

  def update
    @bookmark = current_tenant.bookmarks.find(params[:id])
    @bookmark.attributes = params[:bookmark]
    @bookmark.url = Bookmark.unescaped_url(params[:bookmark][:escaped_url])
    required_full_accessible_bookmark_comment(@bookmark.bookmark_comments.last) do
      @bookmark.save!
      respond_to do |format|
        format.html do
          if params[:bookmarklet]
            render :text => "<script type='text/javascript'>location.href='#{@bookmark.url}';</script>"
          else
            flash[:notice] = _('Bookmark was successfully updated.')
            redirect_to [current_tenant, :bookmarks]
          end
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => ex
    respond_to do |format|
      format.html { render :new }
    end
  rescue Bookmark::InvalidMultiByteURIError => e
    respond_to do |format|
      flash.now[:error] = _('URL format invalid.')
      format.html { render :new }
    end
  end

  def show
    @bookmark = current_tenant.bookmarks.find(params[:id], :include => :bookmark_comments)
    @main_menu = _('Bookmarks')
    @tags = BookmarkComment.get_tagcloud_tags @bookmark.url
    respond_to do |format|
      format.html
    end
  end

  def load_title
    render :text => Bookmark.get_title_from_url(Bookmark.unescaped_url(params[:url]))
  rescue Bookmark::InvalidMultiByteURIError => e
    render :text => _('URL format invalid.'), :status => :bad_request
  end

  private
  def select_layout
    params[:bookmarklet] ? 'subwindow' : 'layout'
  end
end
