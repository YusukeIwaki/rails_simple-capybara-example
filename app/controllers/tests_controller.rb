class TestsController < ApplicationController
  # GET /tests/:id
  def show
    @user = User.find(params[:id])
  end
end
