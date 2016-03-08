class App::Contacts::EmailsController < App::AppController

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
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @email = @contact.emails.new
  end

  def edit
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
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @email = @contact.emails.find(params[:id])
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
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @email = @contact.emails.new(email_params)
    if @email.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
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
    @contact = ::Contacts::Contact.find(params[:contact_id])
    @email = @contact.emails.find(params[:id])
    if @email.update_attributes(email_params)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def destroy
  end

  private

  def email_params
    params.require(:contact_details_email).permit(:address)
  end
end