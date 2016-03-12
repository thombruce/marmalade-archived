class App::Projects::Finances::FinancesController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @project =  @resource.projects.find(params[:project_id])
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @project = @household.projects.find(params[:project_id])
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @project = @group.projects.find(params[:project_id])
    else
      @project = current_user.projects.find(params[:project_id])
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

end