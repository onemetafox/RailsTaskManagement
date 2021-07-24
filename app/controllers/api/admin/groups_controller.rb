# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Api::Admin::GroupsController < Api::Admin::ApplicationController
  # before_action :setup_current_tab, only: %i[index show]

  # load_resource
  respond_to :json

  # POST /groups
  #----------------------------------------------------------------------------
  def create
    # render json: group_params
    render json: Group.create(group_params), status: 200
    # @group.attributes = group_params
    # @group = Group.create(group_params)

    # if @group.save
    #   render json: @group.to_json(include: [:users]), status: 200
    # else
    #   render json: {error: "Unable to create user"}, status: 500
    # end
    # rednder @group
  end

  # POST /groups
  def index
    @group = Group.all
    render json: @group.to_json(include: [:users]), status: 200
    # render json: {success: true, data: group}
  end

  # POST /groups/:id
  def show
    @group = Group.find_by(id: params[:id])
    render json: @group.to_json(include: [:users]), status: 200
  end

  # PUT /groups/1
  #----------------------------------------------------------------------------
  def update
    @group = Group.find(params[:id])
    @group.update(group_params)

    render json: @group, status: 200
  end

  # DELETE /groups/1
  #----------------------------------------------------------------------------
  def destroy
    @group = Group.find(params[:id])
    render json: @group.destroy
    # @group.destroy

    # render @group
  end

  protected

  def group_params
    # params.require(:group).permit(:name, user_ids: [])
    params.permit(:name, user_ids: [])

  end
end
