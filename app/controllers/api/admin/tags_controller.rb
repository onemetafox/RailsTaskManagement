# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::TagsController < Api::Admin::ApplicationController
 
  # GET /admin/tags
  # GET /admin/tags.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @tag = Tag.all.inspect
    render json: {data: @tag, success: true}, status: 200
  end

  # POST /admin/tags
  # POST /admin/tags.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: {data: @tag, success: true}, status: 200
    else
      render json: {msg: @tag.errors, success: false}, status: 500
    end
  end

  # PUT /admin/tags/1
  # PUT /admin/tags/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    @tag = Tag.find_by_id(params[:id])

    if @tag.update(tag_params)
      render json: {data: @tag, success: true}, status: 200
    else
      render json: {msg: @tag.errors, success: false}, status: 500
    end
  end
  
  def delete
    @tag = Tag.find_by_id(params[:id])
    if @tag.destroy
     render json: {data: @tag, success: true}, status: 200
    else
      render json: {msg: @tag.errors, success: false}, status: 500
    end
  end

  # GET /admin/tags/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  protected

  def tag_params
    params.permit(:name, :taggings_count)
  end
end
