module Api
  class UsersController < Api::ApiController
    before_action :auth_user

    def show; end

    def sign_in
        render json: {user_params}
    end
    def update
      current_user.update!(user_params)
      render :show
    end

    private

    def auth_user
      authorize current_user
    end

    def user_params
      params.require(:user).permit(:username, :first_name, :last_name, :email)
    end
  end
end