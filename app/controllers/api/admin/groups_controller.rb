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
    @group.attributes = group_params
    @group.save

    rednder @group
  end

  def lists
    render json: $group
    # render json: {success: true, data: group}
  end

  # PUT /groups/1
  #----------------------------------------------------------------------------
  def update
    @group.update(group_params)

    render @group
  end

  # DELETE /groups/1
  #----------------------------------------------------------------------------
  def destroy
    @group.destroy

    render @group
  end

  protected

  def group_params
    params.require(:group).permit(:name, user_ids: [])
  end

  # def setup_current_tab
  #   set_current_tab('admin/groups')
  # end
end
