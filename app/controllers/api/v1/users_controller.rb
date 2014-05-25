module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json

      before_action :set_user, only: [:show, :update, :destroy]
      before_action :require_admin, only: [:index]
      before_action :require_current, only: [:show, :update, :destroy, :reset_password, :send_reset_password]

      # GET /users
      # GET /users.json
      def index
        render json: User.all, status: :ok
      end

      # GET /users/1
      # GET /users/1.json
      def show
        render json: @user, status: :ok
      end

      # POST /users
      # POST /users.json
      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user, status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /users/1
      # PATCH/PUT /users/1.json
      def update
        if @user.update(user_params)
          render json: @user, status: :ok
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /users/1
      # DELETE /users/1.json
      def destroy
        render json: @user.destroy, status: :ok
      end

      def me
        user = authenticate_with_http_token { |token, options| User.find_by(api_key: token) }
        render json: user, status: :ok
      end

      def activate
        user = User.load_from_activation_token(params[:token])
        if user
          user.activate!
          render json: user, status: :ok
        else
          render json: {danger: "Invalid activation token."}, status: :not_found
        end
      end

      def resend_activation
        user = User.find_by(email: params[:email])
        if user
          SorceryMailer.activation_needed_email(user).deliver
          render json: user, status: :ok
        else
          render json: {danger: "Email doesn't correspond to any users."}, status: :not_found
        end
      end

      def send_reset_password
        user = User.find_by(email: params[:email])
        if user
          user.deliver_reset_password_instructions!
          render json: user, status: :ok
        else
          render json: {danger: "Email doesn't correspond to any users."}, status: :not_found
        end
      end

      def reset_password
        user = User.load_from_reset_password_token(params[:token])
        if user
          user.password = params[:password]
          user.password_confirmation = params[:password_confirmation]
          if user.save
            user.reset_password_attrs
            render json: user, status: :ok
          else
            render json: user.errors, status: :unprocessable_entity
          end
        else
          render json: {danger: "Invalid password reset token."}, status: :not_found
        end
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
