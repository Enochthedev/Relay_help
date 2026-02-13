# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/me
  def me
    render_success(
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
      message: 'User profile retrieved successfully'
    )
  end

  # POST /api/v1/workspaces/:id/switch
  def switch_workspace
    workspace = current_user.workspaces.find(params[:id])
    
    current_user.update!(workspace: workspace)
    
    # Refresh tokens to include new workspace context?
    # For now, just updating the context is enough as long as API calls
    # rely on current_user.workspace_id
    
    render_success(
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes],
      message: "Switched to workspace: #{workspace.name}"
    )
  rescue ActiveRecord::RecordNotFound
    render_error(message: 'Workspace not found or not a member', status: :not_found)
  end

  # GET /api/v1/admin/workspaces
  # Platform admin only
  def index_workspaces
    authorize_platform_admin!
    return if performed?

    workspaces = Workspace.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 20)
    
    render_success(
      data: WorkspaceSerializer.new(workspaces).serializable_hash[:data],
      meta: pagination_meta(workspaces),
      message: 'Workspaces retrieved successfully'
    )
  end

  private

  def authorize_platform_admin!
    unless current_user.platform_admin?
      render_error(message: 'Unauthorized access', status: :forbidden)
    end
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
