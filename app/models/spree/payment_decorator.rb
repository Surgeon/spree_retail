module Spree
  Payment.class_eval do
    after_create :send_spree_order_update, unless: :retail_update
    after_update :send_spree_order_update, unless: :retail_update

    attr_accessor :retail_update

    def send_spree_order_update
      if order
        order.spree_send_updated
      end
    end
  end
end
