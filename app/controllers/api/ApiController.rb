class Api::ApiController < ActionController::API
 
  include ActionController::Helpers
  
  before_action :configure_devise_parameters, if: :devise_controller?
  # before_action :authenticate_user
  before_action :set_paper_trail_whodunnit
  before_action :cors_preflight_check
  
  after_action :cors_set_access_control_headers
  
  helper_method :klass
  
  respond_to :json

  rescue_from CanCan::AccessDenied,         with: :respond_to_access_denied
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
  # def current_user
  #   @current_user = session['dan@example.com']
  # end

  def authenticate_user
    if session['dan@example.com']
      @current_user = session['dan@example.com']
    else
      render json: {success: false, msg: "you should login"}, status: 200
    end

    # if request.headers['Authorization'].present?
    #   authenticate_or_request_with_http_token do |token|
    #     begin
    #       jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first

    #       @current_user_id = jwt_payload['id']
    #     rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
    #       head :unauthorized
    #     end
    #   end
    # end
  end
end
