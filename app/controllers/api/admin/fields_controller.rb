# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::FieldsController < Api::Admin::ApplicationController
  # before_action :setup_current_tab, only: [:index]
  # load_resource except: %i[create subform]

  # GET /fields/1
  # GET /fields/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show
    @field = Field.find_by(id: params[:id])
    render json: {data: @field.to_json, success: true}, status: 200
  end

  # POST /fields
  # POST /fields.xml                                                     AJAX
  #----------------------------------------------------------------------------
  def create
    as = field_params[:as]
    @field =
      # if as.match?(/pair/)
      #   CustomFieldPair.create_pair(params).first
      # elsif as.present?
      #   # klass = find_class(Field.lookup_class(as))
      #   klass = Field.lookup_class(as).safe_constantize
      #   klass.create(field_params)
      # else
        Field.new(field_params).tap(&:valid?)
      # end
    if @field.save
      render json: {data: @field, success: true}, status: 200
    else
      render json: {msg: @field.errors, success: false}, status: 500
    end
  end

  # PUT /fields/1
  # PUT /fields/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    if field_params[:as].match?(/pair/)
      @field = CustomFieldPair.update_pair(params).first
    else
      @field = Field.find(params[:id])
      @field.update(field_params)
    end
    render json: {data: @field, success: true}, status: 200
  end

  # DELETE /fields/1
  # DELETE /fields/1.xml                                        HTML and AJAX
  #----------------------------------------------------------------------------
  def delete
    @field = Field.find(params[:id])
    if @field.destroy
      render json: {data: @field, success: true}, status: 200
    else
      render json: {msg: @field.errors, success: false}, status: 500
    end
  end

  # POST /fields/sort
  #----------------------------------------------------------------------------
  def sort
    field_group_id = params[:field_group_id].to_i
    field_ids = params["fields_field_group_#{field_group_id}"] || []
    
    field_ids.each_with_index do |id, index|
      Field.where(id: id).update_all(position: index + 1, field_group_id: field_group_id)
    end
    render nothing: true
  end

  protected

  def field_params
    params.require(:field).permit!
  end
end
