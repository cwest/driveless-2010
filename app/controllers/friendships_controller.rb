class FriendshipsController < ApplicationController

  before_filter :require_user

  def index
    users = params[:lb_co2].present? ? User.by_lb_co2 : User.by_green_miles
    users = params[:modes].present? ? users.by_mode(params[:modes]) : users
    @friends = users.in( current_user.friends.map{|u| u.id} ).paginate(:page => params[:page] || 1)
    @fans = users.in(Friendship.of(current_user).map{|f| f.user_id}).paginate(:page => params[:page] || 1)
  end

  def show
    @friends = User.find_by_name(params[:username]).friends.by_green_miles.paginate(:page => params[:page] || 1)
    @fans = User.find( Friendship.of( User.find_by_name(params[:username]) ).map{|f| f.user_id} ).paginate(:page => params[:page] || 1)
  end

  def destroy
    current_user.unfriendship_to(params[:id])
    redirect_to account_friends_url
  end

  def new
  end

  def create
    current_user.friendship_to(params[:friend_id])
    redirect_to account_friends_url
  end

end
