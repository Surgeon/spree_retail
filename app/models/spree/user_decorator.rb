module Spree
  User.class_eval do

    after_create {|usr| usr.spree_send_created unless usr.retail_stamp.present? }
    after_update {|usr| usr.spree_send_updated unless usr.retail_stamp.present? }

    def spree_generate_customer
      user = {
          externalId: id,
          email: email,
      }
      if ship_address
        user[:firstName] = ship_address.firstname
        user[:lastName] = ship_address.lastname
        user[:address] = {text: ship_address.address1, index: ship_address.zipcode}
        user[:phones] = [ { number: ship_address.phone } ]
      end
      if ActiveRecord::Base.connection.column_exists?(:spree_users, :first_name)
        user[:firstName] = first_name unless user[:firstName].present?
        user[:lastName] = last_name unless user[:lastName].present?
        user[:phones] = [ { number: phone } ] if phone.present?
      end
      user
    end

    def spree_send_created
      unless RetailImport.check_user(id)
        ord = self.spree_generate_customer
        RETAIL.customers_create(ord).response
      end
    end

    def spree_send_updated
      if RetailImport.check_user(id)
        ord = self.spree_generate_customer
        RETAIL.customers_edit(ord).response
      end
    end

  end
end
