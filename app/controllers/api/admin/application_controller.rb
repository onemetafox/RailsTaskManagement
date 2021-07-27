# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::ApplicationController < Api::ApiController
  
  before_action :require_admin_user

  private

  def require_admin_user
    authenticate_user
    # unless current_user& current_user.admin?
    unless current_user
      render json: {success: false, msg: "You don't have admin role"}, status: 200
    end
  end
end
