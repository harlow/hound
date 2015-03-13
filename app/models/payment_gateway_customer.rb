class PaymentGatewayCustomer
  attr_reader :user

  def initialize(user, customer: nil)
    @user = user
    self.customer = customer
  end

  def email
    customer.email
  end

  def card_last4
    default_card.last4
  end

  def customer=(customer)
    @customer = customer
  end

  def customer
    @customer ||= begin
      if user.stripe_customer_id.present?
        Stripe::Customer.retrieve(user.stripe_customer_id)
      else
        NoRecord.new
      end
    end
  end

  def find_or_create_subscription(plan:, repo_id:)
    subscriptions.detect { |subscription| subscription.plan == plan } ||
      create_subscription(plan: plan, metadata: { repo_ids: [repo_id] },)
  end

  def subscriptions
    customer.subscriptions.map do |subscription|
      PaymentGatewaySubscription.new(subscription)
    end
  end

  def retrieve_subscription(stripe_subscription_id)
    PaymentGatewaySubscription.new(
      customer.subscriptions.retrieve(stripe_subscription_id)
    )
  end

  def update_card(card_token)
    customer.card = card_token
    customer.save
  end

  private

  def create_subscription(options)
    PaymentGatewaySubscription.new(
      customer.subscriptions.create(options),
      new_subscription: true,
    )
  end

  def default_card
    customer.cards.detect { |card| card.id == customer.default_card } ||
      BlankCard.new
  end

  class NoRecord
    def email
      ""
    end

    def cards
      []
    end

    def subscriptions
      NoSubscription.new
    end
  end

  class NoSubscription
    def retrieve(*_args)
      nil
    end
  end

  class BlankCard
    def last4
      ""
    end
  end
end
