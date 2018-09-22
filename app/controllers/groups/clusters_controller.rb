# frozen_string_literal: true

module Groups
  class ClustersController < Groups::ApplicationController
    before_action :authorize_read_cluster!
    before_action :user_cluster, only: [:new]
    before_action :authorize_create_cluster!, only: [:new]

    def index
      @clusters = []
    end

    def new
    end

    def create_user
      @user_cluster = ::Clusters::GroupCreateService
        .new(group, current_user,  create_user_cluster_params)
        .execute

      if @user_cluster.persisted?
        redirect_to group_cluster_path(group, @user_cluster)
      else
        render :new, locals: { active_tab: 'user' }
      end
    end

    private

    def user_cluster
      @user_cluster = ::Clusters::Cluster.new.tap do |cluster|
        cluster.build_platform_kubernetes
      end
    end

    def create_user_cluster_params
      params.require(:cluster).permit(
        :enabled,
        :name,
        :environment_scope,
        platform_kubernetes_attributes: [
          :namespace,
          :api_url,
          :token,
          :ca_cert,
          :authorization_type
        ]).merge(
          provider_type: :user,
          platform_type: :kubernetes
        )
    end

    def authorize_read_cluster!
      unless can?(current_user, :read_cluster, group)
        access_denied!
      end
    end

    def authorize_create_cluster!
      unless can?(current_user, :create_cluster, group)
        access_denied!
      end
    end
  end
end
