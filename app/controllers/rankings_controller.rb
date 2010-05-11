class RankingsController < ApplicationController
  before_filter :require_ranking_enabled
  before_filter :setup_layout

  def index
    yesterday = Date.yesterday
    redirect_to polymorphic_url([current_tenant, :rankings], :action => :monthly, :year => yesterday.year, :month => yesterday.month)
  end

  # GET /ranking_data/:content_type/:year/:month
  def data
    if params[:content_type].blank?
      return head(:bad_request)
    end

    if params[:year].blank?
      @rankings = Ranking.total(current_tenant, params[:content_type])
      return render(:text => '', :status => :not_found) if @rankings.empty?
    else
      return render(:text => _('Invalid request.'), :status => :bad_request) if params[:month].blank?
      begin
        year, month = validate_time(params[:year], params[:month])
        @rankings = Ranking.monthly(current_tenant, params[:content_type], year, month)
        return render(:text => '', :status => :not_found) if @rankings.empty?
      rescue => e
        return render(:text => _('Invalid request.'), :status => :bad_request)
      end
    end
    render :layout => false
  end

  def all
    @dates = Ranking.extracted_dates(current_tenant)
  end

  def monthly
    yesterday = Date.yesterday
    year = params[:year].blank? ? yesterday.year : params[:year]
    month = params[:month].blank? ? yesterday.month : params[:month]
    begin
      year, month = validate_time(year, month)
      @year = year
      @month = month
      @dates = Ranking.extracted_dates(current_tenant)
    rescue => e
      flash.now[:error] = _('Invalid parameter(s) detected.')
      e.backtrace.each { |message| logger.error message }
      render :text => '', :status => :bad_request
    end
  end

  private
  def setup_layout
    @main_menu = @title = _('Rankings')

# 一旦、非表示にし、機能は残しておく
#    @tab_menu_source = [ {:label => _('Monthly Rankings'), :options => {:action => 'monthly'}} ]
  end

  def validate_time(year, month)
    time = Time.local(year, month)
    max_year = 2038
    min_year = 2000
    year = year.to_i
    raise ArgumentError, "year must be < #{max_year}." if year >= max_year
    raise ArgumentError, "year must be >= #{min_year}." if year < min_year
    [time.year, time.month]
  end
end
