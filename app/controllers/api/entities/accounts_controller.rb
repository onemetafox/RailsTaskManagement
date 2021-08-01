# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Entities::AccountsController < Api::EntitiesController
  # before_action :get_data_for_sidebar, only: :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    # @accounts = get_accounts(page: page_param, per_page: per_page_param)
    @accounts = get_accouts
    render json: {data: @accounts.to_json(include: [:assignee, :tags]), success: true }, status: 200
  end

  # GET /accounts/1
  def show
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    @timeline = timeline(@account)
    render json: { data: @account.to_json(include: [:tasks, :contacts, :opportunities]), success: true }, status: 200
  end


  # POST /accounts
  def create
    @comment_body = params[:comment_body]
    if @account.save
      @account.add_comment_by_user(@comment_body, current_user)
      render json: { data: @account.to_json, success: true}, status: 200

    else
      render json: {msg: @account.errors.to_json, success: false}, status: 500
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    # respond_with(@account) do |_format|
    if @account.save
      @account.update(resource_params)
      @account.access = params[:account][:access] if params[:account][:access]
      render json: {data: @account.to_json, success: true}, status:200
    else
      render json: {msg: @account.errors.to_json, success: true}, status:500
    end
      # Must set access before user_ids, because user_ids= method depends on access value.
      
      # get_data_for_sidebar if @account.update(resource_params)
    # end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def delete
    if @account.destroy
      render json: {data: @account.to_json, success: true}, status: 200
    else
      render json: {msg: @account.errors.to_json, success: false}, status: 500
    end

    # respond_with(@account) do |format|
    #   format.html { respond_to_destroy(:html) }
    #   format.js   { respond_to_destroy(:ajax) }
    # end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:accounts_per_page] = per_page_param if per_page_param
    current_user.pref[:accounts_sort_by]  = Account.sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(page: 1, per_page: per_page_param)
    set_options # Refresh options

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:accounts_filter] = params[:category]
    @accounts = get_accounts(page: 1, per_page: per_page_param)

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  # GET /accounts/1/edit   
  def edit
    @account = Account.find(params[:id])
    render json: {data: @account.to_json(include: [:tags]), success: true}, status: 200
  end

  private

  #----------------------------------------------------------------------------
  # alias get_accounts get_list_of_records
  def get_accouts
    self.current_page  = params[:page] if params[:page]
    self.current_query = params[:query] if params[:query]

    @search = klass.ransack(params[:q])
    @search.build_grouping unless @search.groupings.any?

    scope = Account.text_search(params[:query])
    scope = scope.merge(@search.result)
    scope = scope.text_search(current_query)      if current_query.present?
    scope = scope.paginate(page: current_page)
    scope
  end

  #----------------------------------------------------------------------------
  def list_includes
    %i[pipeline_opportunities user tags].freeze
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.empty?
        @accounts = get_accounts(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
      # At this point render default destroy.js
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @account.name)
      redirect_to accounts_path
    end
  end


  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = HashWithIndifferentAccess[
                              Setting.account_category.map do |key|
                                [key, Account.my(current_user).where(category: key.to_s).count]
                              end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my(current_user).count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end
