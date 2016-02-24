class App::Finances::LedgersController < App::AppController

  def index

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
    @ledger = ::Finances::Ledger.new
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
    params[:finances_ledger][:starting_value] = BigDecimal.new(params[:finances_ledger][:starting_value])
    @ledger = ::Finances::Ledger.new(ledger_params)
    @ledger.value = @ledger.starting_value
    if @ledger.save
      @ledger.owners.each do |ownership|
        if @ledger.value >= 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => @ledger.value,:current_assets => @ledger.value,:ledgers_receivable => @ledger.value,:item => @ledger,:action => 'create')
          else
            ownership.update_balance_sheets(:value => @ledger.value,:fixed_assets => @ledger.value,:ledgers_receivable => @ledger.value,:item => @ledger,:action => 'create')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => @ledger.value,:current_liabilities => - @ledger.value,:ledgers_debt => - @ledger.value,:item => @ledger,:action => 'create')
          else
            ownership.update_balance_sheets(:value => @ledger.value,:long_term_liabilities => - @ledger.value,:ledgers_debt => - @ledger.value,:item => @ledger,:action => 'create')
          end
        end
      end
      redirect_to root_path
    else
      render 'new'
    end
  end

  private

  def ledger_params
    params.require(:finances_ledger).permit(:name, :description, :starting_value, :currency, :"due_in_full_at(1i)", :"due_in_full_at(2i)", :"due_in_full_at(3i)", :owners_attributes => [:user_id,:global_owner,:equity])
  end

end