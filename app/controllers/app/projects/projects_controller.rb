class App::Projects::ProjectsController < App::AppController

  def index
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
      @projects =  @resource.projects
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @household = @user.home
      @context = @household
      @projects = @household.projects
    elsif params[:group_id]
      @group = Group.find(params[:group_id])
      @context = @group
      @projects = @group.projects
    else
      @projects = current_user.projects
      @projects += ::Projects::Project.where(:owner => current_user.businesses.to_a)
      @projects += ::Projects::Project.where(:owner => current_user.households.to_a)
      @projects += ::Projects::Project.where(:owner => current_user.groups.to_a)
    end
  end

  def show
  end

  def new
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @project = ::Projects::Project.new
  end

  def edit
  end

  def create
    if params[:resource_id]
      @resource = VanityUrl.find(params[:resource_id]).owner
      @context = @resource
    elsif params[:user_id]
      @user = User.find(params[:user_id])
      @resource = @user.home
      @context = @resource
    elsif params[:group_id]
      @resource = Group.find(params[:group_id])
      @context = @resource
    end
    @project = @resource.projects.new(project_params)
    @project.user = @resource.class.name == 'User' ? @resource : @resource.user
    if @project.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
  end

  def destroy
  end

  private

  def project_params
    params.require(:projects_project).permit(:name,:description)
  end
end
