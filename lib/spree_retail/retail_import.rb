class RetailImport
  require 'retailcrm'

  REGIONS = {26 => 1, 28 => 2, 35 => 3, 62 => 4, 84 => 5, 7 => 6, 52 => 7, 81 => 8, 4 => 9, 86 => 10, 72 => 11, 11 => 12,
         39 => 13, 80 => 14, 34 => 15, 41 => 16, 70 => 17, 16 => 18, 77 => 19, 22 => 20, 43 => 21, 24 => 22, 56 => 23,
         30 => 24, 60 => 25, 68 => 26, 75 => 27, 23 => 28, 53 => 29, 46 => 30, 69 => 31, 18 => 32, 38 => 33, 71 => 34,
         27 => 35, 10 => 36, 2 => 37, 25 => 38, 42 => 39, 17 => 40, 45 => 41, 5 => 42, 55 => 43, 15 => 44, 33 => 45,
         67 => 46, 12 => 47, 3 => 48, 19 => 49, 76 => 50, 78 => 51, 51 => 52, 44 => 53, 36 => 54, 59 => 55, 73 => 56,
         49 => 57, 61 => 58, 82 => 59, 32 => 60, 66 => 61, 64 => 62, 83 => 63, 48 => 64, 20 => 65, 14 => 66, 29 => 67,
         40 => 68, 9 => 69, 6 => 70, 74 => 71, 21 => 72, 57 => 73, 79 => 74, 31 => 75, 37 => 76, 13 => 77, 65 => 78,
         8 => 79, 58 => 80, 1 => 81, 47 => 82, 63 => 83, 85 => 84}
  REGIONS_WITH_NAME = { 'Адыгея Республика' => 1, 'Алтай Республика' => 2, 'Алтайский Край' => 3, 'Амурская область' => 4, 'Архангельская область' => 5,
                        'Астраханская область' => 6, 'Башкортостан Республика' => 7, 'Белгородская область' => 8, 'Брянская область' => 9, 'Бурятия Республика' => 10,
                        'Владимирская область' => 77, 'Волгоградская область' => 78, 'Вологодская область' => 76, 'Воронежская область' => 79, 'Дагестан Республика' => 15,
                        'Еврейская Автономная область' => 82, 'Забайкальский Край' => 83, 'Ивановская область' => 18, 'Ингушетия Республика' => 16, 'Иркутская область' => 17,
                        'Кабардино-Балкарская Республика' => 20, 'Калининградская область' => 24, 'Калмыкия Республика' => 30, 'Калужская область' => 31, 'Камчатский Край' => 19,
                        'Карачаево-Черкесская Республика' => 21, 'Карелия Республика' => 34, 'Кемеровская область' => 23, 'Кировская область' => 28, 'Коми Республика' => 32,
                        'Костромская область' => 33, 'Краснодарский Край' => 22, 'Красноярский Край' => 36, 'Крым Республика' => 84, 'Курганская область' => 25,
                        'Курская область' => 35, 'Ленинградская область' => 37, 'Липецкая область' => 38, 'Магаданская область' => 39, 'Марий Эл Республика' => 40,
                        'Мордовия Республика' => 41, 'Москва город' => 43, 'Московская область' => 42, 'Мурманская область' => 44, 'Ненецкий Автономный округ' => 45,
                        'Нижегородская область' => 47, 'Новгородская область' => 46, 'Новосибирская область' => 48, 'Омская область' => 49, 'Оренбургская область' => 50,
                        'Орловская область' => 51, 'Пензенская область' => 53, 'Пермский Край' => 52, 'Приморский Край' => 54, 'Псковская область' => 55, 'Ростовская область' => 56,
                        'Рязанская область' => 57, 'Самарская область' => 60, 'Санкт-Петербург город' => 64, 'Саратовская область' => 61, 'Сахалинская область' => 59,
                        'Саха (Якутия) Республика' => 58, 'Свердловская область' => 66, 'Северная Осетия-Алания Республика' => 62, 'Смоленская область' => 63,
                        'Ставропольский Край' => 65, 'Тамбовская область' => 68, 'Татарстан Республика' => 67, 'Тверская область' => 71, 'Томская область' => 69,
                        'Тульская область' => 70, 'Тыва Республика' => 72, 'Тюменская область' => 73, 'Удмуртская Республика' => 74, 'Ульяновская область' => 75,
                        'Хабаровский Край' => 26, 'Хакасия Республика' => 29, 'Ханты-Мансийский Автономный округ' => 27, 'Челябинская область' => 12, 'Чеченская Республика' => 11,
                        'Чувашская Республика' => 14, 'Чукотский Автономный округ' => 13, 'Ямало-Ненецкий Автономный округ' => 80, 'Ярославская область' => 81 }

  def self.create_customers
    customers = RETAIL.customers.response
    customers['customers'].each do |customer|
      create_customer(customer)
    end
  end

  def self.create_customer(customer)
    if customer && customer['email']
      user = Spree::User.where(email: customer['email']).first_or_create(password: SecureRandom.hex(10))
      address = user.bill_address || Spree::Address.new
      retail_address = customer['address'] ? [customer['address']['region'], customer['address']['city'], customer['address']['text']].compact.join(', ') : ''
      address.update(firstname: customer['firstName'] || 'Нет имени', lastname: customer['lastName'] || 'Нет фамилии', address1: retail_address || 'Нет адреса',
                     city: (customer['address'] && customer['address']['city']) || 'Нет города', country_id: (Spree::Country.first.id || 0),
                     zipcode: (customer['address'] && customer['address']['index']) || '000000')
      address.phone = customer['phones'].first ? customer['phones'].first['number'] : 'Нет телефона'
      address.state_id = REGIONS[customer['address']['regionId'].to_i]
      address.state_id = REGIONS_WITH_NAME[customer['address']['region']] || 1
      address.save
      user.bill_address_id = address.id# if address.new_record?
      user.ship_address_id = address.id
      if ActiveRecord::Base.connection.column_exists?(:spree_users, :first_name)
        user.first_name = customer['firstName']
      end
      if ActiveRecord::Base.connection.column_exists?(:spree_users, :last_name)
        user.last_name = customer['lastName']
      end
      user.retail_stamp = Time.now
      if user.save
        RETAIL.customers_fix_external_ids([{id: customer['id'], externalId: user.id}])
      end
      user
    else
      false
    end
  end

  def self.create_orders
    customers = RETAIL.orders.response
    customers['orders'].each do |order|
      create_or_update_order(order)
    end
  end

  def self.create_or_update_order(order)
    if order
      existing_order = Spree::Order.where(id: order['externalId']).first_or_initialize
      update_order(order, existing_order)
      # if existing_order
      # else
      #   create_order(order)
      # end
    end
  end

  def self.create_order(order)
    spree_order = Spree::Order.where(id: order['externalId']).first_or_initialize
    # order_exists = Spree::Order.find_by(number: order['number']) unless order_exists

    spree_order.assign_attributes(number: order['number'], item_total: order['summ'], total: order['totalSumm'], email: order['email'],
                    special_instructions: order['customerComment'].to_s + order['managerComment'].to_s, completed_at: order['createdAt'],
                    shipment_total: (order['delivery'] && order['delivery']['cost']), channel: 'RetailCRM', item_count: (order['items'] && order['items'].size))

    if order['customer'] && order['customer']['email']
      user = Spree::User.find_by(email: order['customer']['email']) || create_customer(order['customer'])
      spree_order.user = user
      spree_order.ship_address = user.ship_address
      spree_order.bill_address = user.bill_address
    end
    if Spree::User.admin.present?
      spree_order.created_by = Spree::User.admin.first
    end
    add_states_to_order(spree_order, order['status'], order['paymentStatus'])
    spree_order.retail_stamp = Time.now
    if spree_order.save
      RETAIL.orders_fix_external_ids([{id: order['id'], externalId: spree_order.id}])
    end
  end

  def self.update_order(order, existing_order)
    existing_order.retail_stamp = Time.now
    existing_order.number = order['number'] if order['number']
    # existing_order.item_total = order['summ'] if order['summ']
    # existing_order.total = order['totalSumm'] if order['totalSumm']
    existing_order.email = order['email'] if order['email']
    existing_order.comment = order['customerComment'].to_s + order['managerComment'].to_s if order['customerComment'] || order['managerComment']
    existing_order.shipment_total = order['delivery']['cost'] if order['delivery'] && order['delivery']['cost']
    existing_order.item_count = order['items'].size if order['items']
    existing_order.state = 'complete'

    sh_a = existing_order.ship_address
    sh_a = Spree::Address.new unless sh_a
    b_a = existing_order.bill_address
    b_a = Spree::Address.new unless b_a
    if order['customer'] && order['customer']['email']
      user = Spree::User.find_by(email: order['customer']['email']) || create_customer(order['customer'])
      existing_order.user = user
      if sh_a
        sh_a.firstname = order['firstName'] ? order['firstName'] : 'Нет имени'
        sh_a.lastname = order['lastName'] ? order['lastName'] : 'Нет фамилии'
        sh_a.phone = order['phone'] ? order['phone'] : 'Нет телефона'

      end
      if b_a
        b_a.firstname = order['firstName'] ? order['firstName'] : 'Нет имени'
        b_a.lastname = order['lastName'] ? order['lastName'] : 'Нет фамилии'
        b_a.phone = order['phone'] ? order['phone'] : 'Нет телефона'
      end
    end

    ln_ids = order['items'].map{|ln| ln['offer']['externalId']}
    existing_order.line_items.where.not(variant_id: ln_ids).each do |ln|
      ln.variant.stock_items.first && ln.variant.stock_items.first.update_attribute(:count_on_hand, ln.variant.stock_items.first.count_on_hand + ln.quantity)
    end
    existing_order.line_items.where.not(variant_id: ln_ids).destroy_all
    existing_order.inventory_units.where.not(variant_id: ln_ids).destroy_all
    if order['items']
      order['items'].each do |item|
        line_items = existing_order.line_items.where(variant_id: item['offer']['externalId'])
        line_items.each do |line_item|
          line_item.update_attribute(:quantity, item['quantity'])
        end
        if line_items.empty?
          ln = existing_order.line_items.new(currency: 'RUB')
          ln.variant_id = item['offer']['externalId'] if item['offer'] && item['offer']['externalId']
          ln.price = item['purchasePrice']
          ln.quantity = item['quantity']
          # existing_order.save
          ln.save
        end
      end
    end

    existing_payment = existing_order.payments.first_or_initialize
    existing_payment.retail_update = true
    existing_order.item_total = existing_order.line_items.map{|ln| ln.price * ln.quantity}.sum
    if order['paymentType']
      inverted_payments_methods = Spree::Config[:payment_method].invert
      payment_method_name = inverted_payments_methods[order['paymentType']]
      payment_method = Spree::PaymentMethod.find_by(name: payment_method_name)
      if payment_method
        existing_payment.payment_method = payment_method
      end
    end
    if order['paymentStatus']
      inverted_payment_states = Spree::Config.state_connection['payment'].invert
      existing_payment.state = inverted_payment_states[order['paymentStatus']]
    end

    if order['delivery']
      existing_delivery = existing_order.shipments.first_or_initialize
      existing_delivery.retail_update = true
      inverted_delivery_methods = Spree::Config[:delivery_method].invert
      if order['delivery']['code']
        delivery_method = inverted_delivery_methods[order['delivery']['code']]
        shipping_method = Spree::ShippingMethod.find_by(name: delivery_method)
        if shipping_method
          # existing_delivery.shipping_method = shipping_method
          shipping_rate = existing_delivery.shipping_rates.where(shipping_method_id: shipping_method.id).first_or_initialize
          shipping_rate.shipping_method = shipping_method
          shipping_rate.cost = order['delivery']['cost'] if order['delivery']['cost']
          shipping_rate.save
        end
      end
      existing_delivery.state = 'ready' unless existing_delivery.state
      existing_delivery.cost = order['delivery']['cost'] if order['delivery']['cost']
      existing_delivery.stock_location_id = 1
      existing_payment.amount = existing_delivery.cost + existing_order.line_items.map{|ln| ln.price * ln.quantity}.sum + existing_order.adjustments.pluck(:amount).sum
      existing_order.total = existing_payment.amount
      existing_order.save
      existing_order.inventory_units.destroy_all
      existing_order.line_items.each do |ln|
        ln.quantity.times do
          # existing_delivery.inventory_units.where(line_item_id: ln.id).first_or_create(variant_id: ln.variant_id, state: 'on_hand', order_id: existing_order.id)
          existing_delivery.inventory_units.create(line_item_id: ln.id, variant_id: ln.variant_id, state: 'on_hand', order_id: existing_order.id)
        end
      end
      existing_payment.save
      existing_delivery.save
      if order['delivery']['address']
        if order['delivery']['address']['city']
          sh_a.city = order['delivery']['address']['city']
          b_a.city = order['delivery']['address']['city']
        end
        sh_a.zipcode = order['delivery']['address']['index'] || '000000'
        b_a.zipcode = order['delivery']['address']['index'] || '000000'
        if order['delivery']['address']['text']
          text_address = order['delivery']['address']['text'].gsub('кв./офис', 'кв.')
          sh_a.address1 = text_address
          b_a.address1 = text_address
        end
        sh_a.country_id = 1
        b_a.country_id = 1
        if order['delivery']['address']
          sh_a.state_id = REGIONS[order['delivery']['address']['regionId'].to_i]
          sh_a.state_id = REGIONS_WITH_NAME[order['delivery']['address']['region']] || 1
          b_a.state_id = REGIONS[order['delivery']['address']['regionId'].to_i]
          b_a.state_id = REGIONS_WITH_NAME[order['delivery']['address']['region']] || 1
        end
      end
    end
    sh_a.save
    existing_order.ship_address = sh_a
    b_a.save
    existing_order.bill_address = b_a


    add_states_to_order(existing_order, order['status'], order['paymentStatus'])
    existing_order.retail_stamp = Time.now
    if existing_order.save
      RETAIL.orders_fix_external_ids([{id: order['id'], externalId: existing_order.id}])
    end
  end

  def self.add_states_to_order(spree_order, state, payment_state)
    if Spree::Config.state_connection['shipment']
      shipment_state = nil
      Spree::Config.state_connection['shipment'].each do |k, v|
        if v.include?(state)
          shipment_state = k
        end
      end
      if shipment_state
        spree_order.shipment_state = shipment_state || 'ready'
      else
        spree_order.shipment_state = spree_order.shipment_state || 'ready'
      end
      spree_order.completed_at = Time.now unless spree_order.completed_at
    end
    if Spree::Config.state_connection['payment']
      inverted_payment_states = Spree::Config.state_connection['payment'].invert
      spree_order.payment_state = inverted_payment_states[payment_state] || spree_order.payment_state || nil
    end
    # if Spree::Config[:state_connection]['shipment']
    #   inverted_states = Spree::Config[:state_connection]['order'] = Spree::Config.state_connection['shipment'].invert
    #   spree_order.shipment_state = inverted_states[state]
    # end
  end

  def self.update_states(options)
    if options[:payment_method]
      Spree::Config[:payment_method] = options[:payment_method]
    elsif options[:delivery_method]
      Spree::Config[:delivery_method] = options[:delivery_method]
    else
      options['shipment'].each{|k,v| v.delete('')}
      Spree::Config[:state_connection] = options
    end
  end

  def self.export_all_orders
    existing_orders = RETAIL.orders.response['orders'].map{|o| o['externalId']}
    Spree::Order.where.not(id: existing_orders).each do |order|
      order.spree_send_created
    end
  end

  def self.export_all_customers
    existing_customers = RETAIL.customers.response['customers'].map{|c| c['externalId']}
    Spree::User.where.not(id: existing_customers).each do |customer|
      customer.spree_send_created
    end
  end

  def self.check_order(id)
    begin
      RETAIL.orders_get(id, 'externalId').response['success']
    rescue
      false
    end
  end

  def self.check_user(id)
    begin
      RETAIL.customers_get(id, 'externalId').response['success']
    rescue
      false
    end
  end

end