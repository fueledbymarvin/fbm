module Api
  module V1
    class SessionsController < ApplicationController
      respond_to :json

      before_action :require_authenticated, only: [:destroy]

      def create
        user = login(params[:email], params[:password])
        if user
          render json: user
        else
          user = User.where(email: params[:email]).first
          if !user.nil? and user.activation_state == 'pending'
            render json: { warning: "Please activate your account by confirming your email."}, status: :unauthorized
          else
            render json: { danger: "Incorrect email or password." }, status: :unauthorized
          end
        end
      end

      def destroy
        logout
        render json: { info: "Logged out!" }
      end
    end
  end
end
