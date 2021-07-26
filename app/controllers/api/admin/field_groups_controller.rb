# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::FieldGroupsController < Api::Admin::ApplicationController
  helper 'admin/fields'

  # GET /admin/field_groups/1
  # GET /admin/field_groups/1.xml                                        AJAX
  #----------------------------------------------------------------------------
  def show
    @field_group = FieldGroup.find_by(id: params[:id])
    render json: {data: @field_group.to_json, success: true}, status: 200
  end

  # POST /field_groups
  def index
    @field_group = FieldGroup.where(klass_name: params[:klass_name] )
    render json: @field_group.to_json(include: [:fields]), status: 200
  end


  def create
    @field_group = FieldGroup.create(field_group_params)
    if @field_group.save
      render json: {data: @field_group, success: true}, status: 200
    else
      render json: {msg: @field_group.errors, success: false}, status: 500
    end
  end

  # PUT /admin/field_groups/1
  # PUT /admin/field_groups/1.xml                                          AJAX
  #----------------------------------------------------------------------------
  def update
    @field_group = FieldGroup.find(params[:id])
    if @field_group.update(field_group_params)
      render json: {data: @field_group, success: true}, status: 200
    else
      render json: {msg: @field_group.errors, success: true}, status: 500
    end
  end

  # DELETE /admin/field_groups/1
  # DELETE /admin/field_groups/1.xml                                       AJAX
  #----------------------------------------------------------------------------
  def delete
    @field_group = FieldGroup.find(params[:id])
    if @field_group.destroy
      render json: {data: @field_group, success: true}, status: 200
    else
      render json: {msg: @field_group.errors, success: false}, status: 500
    end
  end

  # POST /admin/field_groups/sort
  #----------------------------------------------------------------------------
  def sort
    asset = params[:asset]
    field_group_ids = params["#{asset}_field_groups"]
    field_group_ids.each_with_index do |id, index|
      FieldGroup.where(id: id).update_all(position: index + 1)
    end
    render nothing: true
  end

  # GET /admin/field_groups/1/confirm                                      AJAX
  #----------------------------------------------------------------------------
  # def confirm
  #   @field_group = FieldGroup.find(params[:id])
  # end

  protected

  def field_group_params
    params.permit(
      :name,
      :label,
      :position,
      :hint,
      :tag_id,
      :klass_name
    )
  end
end
