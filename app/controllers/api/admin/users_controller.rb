# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::UsersController < Api::Admin::ApplicationController

  # GET /admin/users
  # GET /admin/users.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @users = get_users(page: params[:page])
    render json: @users.to_json(include: [:groups]), status: 200
  end

  # GET /admin/users/1
  def show
    @user = User.find_by_id(params[:id])
    render json: @user.to_json(include: [:groups]), status: 200
  end

  # POST /admin/users
  def create
    @user = User.new(user_params)

    @user.suspend_if_needs_approval
    if @user.save
      render json: @user, status: 200
    else
      render json: @user.errors, status: 500
    end
  end

  # POST /admin/users/1
  def update
    @user = User.find(params[:id])
    @user.attributes = user_params
    if @user.save
      render json: @user, status: 200
    else
      render json: @user.errors, status: 500
    end
  end

  # GET /admin/users/1/confirm                                             AJAX
  def confirm
    @user = User.find_by_id(params[:id])
    render json: @user, status: 200
  end

  # DELETE /admin/users/1
  def delete
    @user = User.find_by_id(params[:id])
    if @user.destroy
      render json: @user.destroy, status: 200
    else
      render json: @user.errors, status: 500
    end
  end

  # PUT /admin/users/1/suspend
  def suspend
    @user = User.find_by_id(params[:id])
    @user.update_attribute(:suspended_at, Time.now) 
    render json: @user, status: 200
  end

  # PUT /admin/users/1/reactivate
  def reactivate
    @user = User.find_by_id(params[:id])
    @user.update_attribute(:suspended_at, nil)
    render json: @user, status: 200
  end

  protected

  def user_params
    return {} unless params

    params[:password_confirmation] = nil if params[:password_confirmation].blank?
    params[:email].try(:strip!)
    params[:alt_email].try(:strip!)

    params.permit(
      :admin,
      :username,
      :email,
      :first_name,
      :last_name,
      :title,
      :company,
      :alt_email,
      :phone,
      :mobile,
      :aim,
      :yahoo,
      :google,
      :skype,
      :password,
      :password_confirmation,
      group_ids: [:id]
    )
  end

  private

  def get_users(options = {})
    self.current_page  = options[:page] if options[:page]
    self.current_query = params[:query] if params[:query]

    @search = klass.ransack(params[:q])
    @search.build_grouping unless @search.groupings.any?

    wants = request.format
    scope = User.by_id
    scope = scope.merge(@search.result)
    scope = scope.text_search(current_query)      if current_query.present?
    scope = scope.paginate(page: current_page) if wants.html? || wants.js? || wants.xml?
    scope
  end
end
