class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.save do |result|
      if result
        flash[:notice] = "Registration successful."
        redirect_to root_url
      else
        render :action => 'new'
      end
    end
    @user.baseline = Baseline.create
  end

  def widget
    @user = current_user
    if @user
      render :layout => 'widget'
    else
      render :text => "&nbsp"
    end
  end
  
  def show
    @user = @current_user
    @trip = Trip.new
    
    legend = []
    colors_legend = []
    miles = []
    days = []

    Mode.all.each do |mode|
      legend << mode.name
      colors_legend << rand(0xffffff).to_s(16)
    end

    @user.trips.all.each do |trip|
      miles << trip.distance
      days << trip.made_at
    end

    @image = Gchart.line(
      :title => "Testing",
      :legend => legend,
      :bar_colors => colors_legend,
      :data => [[1, 5, 3, 6, 9, 7, 10], [3,5, 9, 10]],
      :axis_with_labels => 'x,y',
      :axis_labels => [days, miles]
    )
  end
 
  def edit
    @user = @current_user
  end
  
  def update
    @user = current_user
    @user.attributes = params[:user]
    @user.save do |result|
      if result
        flash[:notice] = "Successfully updated profile."
        redirect_to root_url
      else
        render :action => 'edit'
      end
    end
  end
end


