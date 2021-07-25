class Api::ApiController < ActionController::API
  # include Api::Concerns::ActAsApiRequest
  # include Pundit
  # include DeviseTokenAuth::Concerns::SetUserByToken

  # after_action :verify_authorized, except: :index
  # after_action :verify_policy_scoped, only: :index

  # before_action :authenticate_user!, except: :status
  # skip_after_action :verify_authorized, only: :status
 
  # ----------------- application controller part ---------------------

  include ActionController::Helpers
  before_action :configure_devise_parameters, if: :devise_controller?
  # before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_context
  before_action :clear_setting_cache
  before_action :cors_preflight_check
  # before_action { hook(:app_before_filter, self) }
  # after_action { hook(:app_after_filter, self) }
  after_action :cors_set_access_control_headers

  helper_method :called_from_index_page?, :called_from_landing_page?
  helper_method :klass

  respond_to :html, only: %i[index show auto_complete]
  respond_to :js
  respond_to :json, :xml, except: :edit
  respond_to :atom, :csv, :rss, :xls, only: :index

  rescue_from ActiveRecord::RecordNotFound, with: :respond_to_not_found
  rescue_from CanCan::AccessDenied,         with: :respond_to_access_denied

  include ERB::Util # to give us h and j methods

  #----------------------  application controller part  ---------------------


  


  rescue_from ActiveRecord::RecordNotFound,        with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid,         with: :render_record_invalid
  rescue_from ActionController::ParameterMissing,  with: :render_parameter_missing

  def status
    render json: {online: true}
  end

  private

  def render_not_found(exception)
    logger.info { exception } # for logging
    render json: { error: I18n.t('api.errors.not_found') }, status: :not_found
  end

  def render_record_invalid(exception)
    logger.info { exception } # for logging
    render json: { errors: exception.record.errors.as_json }, status: :bad_request
  end

  def render_parameter_missing(exception)
    logger.info { exception } # for logging
    render json: { error: I18n.t('api.errors.missing_param') }, status: :unprocessable_entity
  end
  # -----------------------  application controller part  --------------------
  def set_context
    Time.zone = ActiveSupport::TimeZone[session[:timezone_offset]] if session[:timezone_offset]
    if current_user.present? && (locale = current_user.preference[:locale]).present?
      I18n.locale = locale
    elsif Setting.locale.present?
      I18n.locale = Setting.locale
    end
  end
  def klass
    @klass ||= controller_name.classify.constantize
  end

  def current_query
    # @current_query = params[:query] || session[:"#{controller_name}_current_query"] || ''
    @current_query = params[:query] || ''
  end

  def current_query=(query)
    # if session[:"#{controller_name}_current_query"].to_s != query.to_s # nil.to_s == ""
    #   self.current_page = params[:page] # reset paging otherwise results might be hidden, defaults to 1 if nil
    # end
    # @current_query = session[:"#{controller_name}_current_query"] = query
    @current_query = query
  end
  def clear_setting_cache
    Setting.clear_cache!
  end

  def find_class(asset)
    Rails.application.eager_load! unless Rails.application.config.cache_classes
    classes = ActiveRecord::Base.descendants.map(&:name)
    puts "User".safe_constantize
    find = classes.find { |m| m == asset.classify }
    if find
      find.safe_constantize
    else
      raise "Unknown resource"
    end
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render plain: ''
    end
  end
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end
  # ----------------------  application controller part  -----------------------
end
