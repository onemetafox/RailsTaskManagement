# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Entities::ContactsController < Api::EntitiesController
  # before_action :get_accounts, only: %i[new create edit update]

  # GET /contacts
  #----------------------------------------------------------------------------
  def index
    # @contacts = get_contacts(page: page_param, per_page: per_page_param)
    @contacts = get_contacts
    render json: {data: @contacts.to_json(include: [:tags]), success: true}, status: 200

    # respond_with @contacts do |format|
    #   format.xls { render layout: 'header' }
    #   format.csv { render csv: @contacts }
    # end
  end

  # GET /contacts/1
  # AJAX /contacts/1
  #----------------------------------------------------------------------------
  def show
    # @stage = Setting.unroll(:opportunity_stage)
    # @comment = Comment.new
    # @timeline = timeline(@contact)
    render json: {data: @contact.to_json(include: [:tasks, :opportunities]), success: true}, status: 200
    # respond_with(@contact)
  end

  # GET /contacts/new
  #----------------------------------------------------------------------------
  # def new
  #   @contact.attributes = { user: current_user, access: Setting.default_access, assigned_to: nil }
  #   @account = Account.new(user: current_user)

  #   if params[:related]
  #     model, id = params[:related].split('_')
  #     if related = model.classify.constantize.my(current_user).find_by_id(id)
  #       instance_variable_set("@#{model}", related)
  #     else
  #       respond_to_related_not_found(model) && return
  #     end
  #   end

  #   respond_with(@contact)
  # end

  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    # @account = @contact.account || Account.new(user: current_user)
    # @previous = Contact.my(current_user).find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i if params[:previous].to_s =~ /(\d+)\z/
    render json: {data: @contact.to_json(include: [:tags]), success: true}, status: 200

    # respond_with(@contact)
  end

  # POST /contacts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    if @contact.save_with_account_and_permissions(params.permit!)
      @contact.add_comment_by_user(@comment_body, current_user)
      # @contacts = get_contacts if called_from_index_page?
      render json: {data: @contact, success: true}, status: 200
    else
      @account = guess_related_account(params[:account][:id], request.referer, current_user) if params[:account]
      @opportunity = Opportunity.my(current_user).find(params[:opportunity]) unless params[:opportunity].blank?
      if @contact.save
        render json: {data: @contact, success: true}, status: 200
      else
        render json: {msg: @contact.errors.to_json, success: false}, status: 500
      end
    end
  end

  # PUT /contacts/1
  #----------------------------------------------------------------------------
  def update
      @account = @contact.account || Account.new(user: current_user) unless @contact.update_with_account_and_permissions(params.permit!)
  end

  # DELETE /contacts/1
  #----------------------------------------------------------------------------
  def delete
    @contact.destroy
    render json: {data: @contact.to_json, success: true}, status: 200


    # respond_with(@contact) do |format|
    #   format.html { respond_to_destroy(:html) }
    #   format.js   { respond_to_destroy(:ajax) }
    # end
  end

  # PUT /contacts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # POST /contacts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /contacts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /contacts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:contacts_per_page] = per_page_param if per_page_param

    # Sorting and naming only: set the same option for Leads if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:contacts_sort_by] = Contact.sort_by_map[params[:sort_by]]
      current_user.pref[:leads_sort_by] ||= Lead.sort_by_map[params[:sort_by]] if Lead.sort_by_fields.include?(params[:sort_by])
    end
    if params[:naming]
      current_user.pref[:contacts_naming] = params[:naming]
      current_user.pref[:leads_naming] ||= params[:naming]
    end

    @contacts = get_contacts(page: 1, per_page: per_page_param) # Start on the first page.
    set_options # Refresh options

    respond_with(@contacts) do |format|
      format.js { render :index }
    end
  end

  private

  #----------------------------------------------------------------------------
  # alias get_contacts get_list_of_records
  def get_contacts
    # self.current_page  = options[:page] if options[:page]
    self.current_query = params[:query] if params[:query]

    @search = klass.ransack(params[:q])
    @search.build_grouping unless @search.groupings.any?

    scope = Contact.text_search(params[:query])
    scope = scope.merge(@search.result)
    scope = scope.text_search(current_query)      if current_query.present?
    # scope = scope.paginate(page: current_page) if wants.html? || wants.js? || wants.xml?
    scope
  end

  #----------------------------------------------------------------------------
  def list_includes
    %i[account tags].freeze
  end

  #----------------------------------------------------------------------------
  def get_accounts
    @accounts = Account.my(current_user).order('name')
  end

  def set_options
    super
    @naming = (current_user.pref[:contacts_naming] || Contact.first_name_position) unless params[:cancel].true?
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?
        @contacts = get_contacts
        if @contacts.blank?
          @contacts = get_contacts(page: current_page - 1) if current_page > 1
          render(:index) && return
        end
      else
        self.current_page = 1
      end
      # At this point render destroy.js
    else
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @contact.full_name)
      redirect_to contacts_path
    end
  end
end
