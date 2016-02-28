class App::Finances::PaymentsController < App::AppController

  def index
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
    @ledger = ::Finances::Ledger.find(params[:receivable_id] ? params[:receivable_id] : params[:debt_id])
    @payment = ::Finances::Payment.new
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
    @ledger = ::Finances::Ledger.find(params[:receivable_id] ? params[:receivable_id] : params[:debt_id])

    unless params[:finances_payment][:wallet_id].blank?
      @wallet = ::Finances::Wallet.find(params[:finances_payment][:wallet_id])
    end

    if params[:receivable_id]
      params[:finances_payment][:value] = BigDecimal.new(params[:finances_payment][:value])
    elsif params[:debt_id]
      params[:finances_payment][:value] = - BigDecimal.new(params[:finances_payment][:value])
    end

    @payment = @ledger.payments.new(payment_params)
    @payment.currency = @ledger.currency

    if @wallet
      @payment.wallet_balance = @wallet.balance + @payment.value
    end
    @payment.ledger_balance = @ledger.value - @payment.value

    if @payment.save

      if @wallet
        set_adjustments(@payment.value,@wallet.balance)

        @wallet.update_attribute(:balance,@payment.wallet_balance)
        
        @wallet.owners.each do |ownership|
          ownership.update_balance_sheets(:value => @payment.value,:current_assets => @current_assets,:current_liabilities => @current_liabilities,:cash => @cash, :wallets => @payment.value,:item => @payment,:action => "create")
        end
      end

      @ledger.owners.each do |ownership|
        if @ledger.value > 0
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @payment.value,:current_assets => - @payment.value,:ledgers_receivable => - @payment.value,:item => @ledger,:action => 'update')
          else
            ownership.update_balance_sheets(:value => - @payment.value,:fixed_assets => - @payment.value,:ledgers_receivable => - @payment.value,:item => @ledger,:action => 'update')
          end
        else
          if @ledger.due_in_full_at < 1.year.from_now
            ownership.update_balance_sheets(:value => - @payment.value,:current_liabilities => @payment.value,:ledgers_debt => @payment.value,:item => @ledger,:action => 'update')
          else
            ownership.update_balance_sheets(:value => - @payment.value,:long_term_liabilities => @payment.value,:ledgers_debt => @payment.value,:item => @ledger,:action => 'update')
          end
        end
      end
      @ledger.update_attribute(:value,@payment.ledger_balance)

      flash[:notice] = "Payment registered!"
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def payment_params
    params.require(:finances_payment).permit(:wallet_id, :description, :value)
  end

  def set_adjustments(value,balance)
    if balance < 0 && value >= 0
      if balance.abs >= value
        @current_assets = 0
        @current_liabilities = - value
        @cash = 0
      elsif balance.abs < value
        @current_assets = balance + value
        @current_liabilities = balance
        @cash = balance + value
      end
    elsif balance > 0 && value <= 0
      if balance >= value.abs
        @current_assets = value
        @current_liabilities = 0
        @cash = value
      elsif balance < value.abs
        @current_assets = - balance
        @current_liabilities = - (balance + value)
        @cash = - balance
      end
    else
      if value > 0
        @current_assets = value
        @current_liabilities = 0
        @cash = value
      elsif value < 0
        @current_assets = 0
        @current_liabilities = - value
        @cash = 0
      end
    end
  end

end