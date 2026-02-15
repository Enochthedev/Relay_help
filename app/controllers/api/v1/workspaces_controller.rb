module Api
  module V1
    class WorkspacesController < BaseController
      before_action :set_workspace, only: [:show, :update, :destroy]
      before_action :authorize_workspace_member!, only: [:show]
      before_action :authorize_workspace_admin!, only: [:update, :destroy]

      # GET /api/v1/workspaces
      def index
        workspaces = current_user.workspaces
        # Flatten the JSONAPI structure to match frontend expectations
        data = WorkspaceSerializer.new(workspaces).serializable_hash[:data].map { |resource| resource[:attributes] }
        render_success(data: data)
      end

      # POST /api/v1/workspaces
      def create
        # Use a transaction to create workspace and membership
        ActiveRecord::Base.transaction do
          workspace = Workspace.create!(workspace_params)
          
          # Add creator as owner
          WorkspaceMembership.create!(
            user: current_user,
            workspace: workspace,
            role: 'owner'
          )
          
          # Switch context to new workspace? Maybe optional.
          # current_user.update!(workspace: workspace)

          render_success(
            data: WorkspaceSerializer.new(workspace).serializable_hash[:data][:attributes],
            message: 'Workspace created successfully',
            status: :created
          )
        end
      rescue ActiveRecord::RecordInvalid => e
        render_error(message: e.message, status: :unprocessable_entity)
      end

      # GET /api/v1/workspaces/:id
      def show
        render_success(data: WorkspaceSerializer.new(@workspace).serializable_hash[:data][:attributes])
      end

      # PATCH/PUT /api/v1/workspaces/:id
      def update
        if @workspace.update(workspace_params)
          render_success(
            data: WorkspaceSerializer.new(@workspace).serializable_hash[:data][:attributes],
            message: 'Workspace updated successfully'
          )
        else
          render_error(message: @workspace.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/workspaces/:id
      def destroy
        @workspace.destroy
        render_success(message: 'Workspace deleted successfully')
      end

      # GET /api/v1/workspace
      # Returns the *current* workspace context of the user
      def show_current
        workspace = current_user.workspace
        return render_error(message: 'No current workspace context', status: :not_found) unless workspace

        render_success(data: WorkspaceSerializer.new(workspace).serializable_hash[:data][:attributes])
      end

      # PATCH /api/v1/workspace
      # Updates the *current* workspace context of the user
      def update_current
        workspace = current_user.workspace
        return render_error(message: 'No current workspace context', status: :not_found) unless workspace
        
        # Check permissions on current workspace
        unless current_user.workspace_admin?
          return render_error(message: 'Unauthorized access', status: :forbidden)
        end



        if workspace.update(workspace_params)
          render_success(
            data: WorkspaceSerializer.new(workspace).serializable_hash[:data][:attributes],
            message: 'Workspace updated successfully'
          )
        else
          render_error(message: workspace.errors.full_messages.join(', '), status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/workspace
      # Deletes the *current* workspace
      def destroy_current
        workspace = current_user.workspace
        return render_error(message: 'No current workspace context', status: :not_found) unless workspace

        # Check permissions - only owner can delete?
        membership = current_user.workspace_memberships.find_by(workspace: workspace)
        unless membership&.role == 'owner'
          return render_error(message: 'Only the owner can delete the workspace', status: :forbidden)
        end
        
        workspace.destroy
        render_success(message: 'Workspace deleted successfully')
      end

      private

      def set_workspace
        @workspace = Workspace.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error(message: 'Workspace not found', status: :not_found)
      end

      def authorize_workspace_member!
        unless current_user.workspaces.include?(@workspace)
          render_error(message: 'Unauthorized access', status: :forbidden)
        end
      end

      def authorize_workspace_admin!
        membership = current_user.workspace_memberships.find_by(workspace: @workspace)
        unless membership&.admin? || membership&.owner?
          render_error(message: 'Unauthorized access', status: :forbidden)
        end
      end

      def workspace_params
        # Allow updating slug and company_url if they exist, plus time_zone/language
        params.require(:workspace).permit(:name, :slug, :company_url, :time_zone, :language, :logo, :onboarding_complete, allowed_domains: [])
      end
    end
  end
end
