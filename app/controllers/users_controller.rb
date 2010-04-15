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
    data = []

    Mode.all.each do |mode|
      legend << mode.name
      colors_legend << rand(0xffffff).to_s(16)
      #data << @user.trips.find_all_by_mode_id(mode.id).map(&:distance)
    end

    miles = [0]
    @user.trips.all.each do |trip|
      miles << trip.distance
      days << trip.made_at
    end

    miles = miles.uniq.sort
    days = days.uniq.sort
    
    days.each do |time|
      new_trip = []
      Mode.all.each do |mode|
        trip = @user.trips.find(:first, :conditions => ["mode_id = ? AND made_at = ?", mode.id, time])
        trip = (trip != nil) ? trip.distance : 0
        #trip = trip.distance unless trip.nil?
        new_trip << trip
      end
      data << new_trip
    end
    
    data_graph = []
    data.each do |new_data|
      cont = 0
      new_data.each do |mile|
        if data_graph[cont].nil? 
          data_graph[cont] = [0]
        end
        posc = miles.index(mile)
       
        if posc!=0 && !posc.nil?
          data_graph[cont] << (posc * 100) / (miles.length - 1)
        end
      
        cont = cont + 1
      end
    end
   
    debugger

    @image = Gchart.line(
      :legend => legend,
      :bar_colors => colors_legend,
      #:data => [0, 50, 100],
      :data => data_graph,
      :axis_with_labels => 'x,y',
      :axis_labels => [days, miles],
      :max_value => 100
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


