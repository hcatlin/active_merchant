module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class XpayGateway < Gateway
      cattr_accessor :site_reference, :certificate_path
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['GB']

      TRANSACTIONS = {
        :purchase => 'AUTH',
        :purchase_reversal => 'AUTHREVERSAL',
        :refund => 'REFUND',
        :refund_reversal => 'REFUNDREVERSAL',
        :settlement => 'SETTLEMENT'
      }
      
      CREDIT_CARDS = {
        :visa => "VISA",
        :master => "MASTERCARD",
        :delta => "DELTA",
        :solo => "SOLO",
        :switch => "MAESTRO",
        :maestro => "MAESTRO",
        :electron => "ELECTRON",
        :purchasing => "PURCHASING"
      }
      
      API_VERSION = '3.51'
      API_DATE_FORMAT = '%Y-%m-%d'
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :delta, :solo, :switch, :maestro, :electron, :purchasing]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.securetrading.com/'
      
      # The name of the gateway
      self.display_name = 'SecureTrading XPay'
      
      self.money_format = :cents
      self.default_currency = 'GBP'
      
      
      def initialize(options = {})
        #requires!(options, :login, :password)
        @options = options
        super
      end  

      def authorise(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)   
        add_customer_data(post, options)
        add_amount(post, money, options, 0)
        
        commit(TRANSACTIONS[:purchase], money, post)
      end
    
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)   
        add_customer_data(post, options)
        add_amount(post, money, options, 1)
             
        commit(TRANSACTIONS[:purchase], money, post)
      end                       
    
      private
      
      def add_amount(post, money, options, settlement_day=1)
        post[:Operation] = {
          :Amount           => amount(money),
          :Currency         => options[:currency] || currency(money),
          :SiteReference    => @@site_reference,
          :SettlementDay    => settlement_day
        }
      end
      
      def add_address(post, creditcard, options)
        post[:CustomerInfo] ||= {}
        post[:CustomerInfo][:Postal] = {
          :Name => {
            :FirstName      => creditcard.first_name,
            :LastName       => creditcard.last_name
          },
          :Company          => options[:billing_address][:company],
          :Street           => options[:billing_address][:address1],
          :City             => options[:billing_address][:city],
          :StateProv        => options[:billing_address][:state],
          :PostalCode       => options[:billing_address][:zip],
          :CountryCode      => options[:billing_address][:country]
        }
      end
      
      def add_customer_data(post, options)
        post[:CustomerInfo] ||= {}
        post[:CustomerInfo][:Telecom] = {
          :Phone            => options[:phone]
        }
        post[:CustomerInfo][:Online] = {
          :Email            => options[:email]
        }
      end

      def add_invoice(post, options)
        post[:Order] = {
          :OrderReference   => options[:order_id],
          :OrderInformation => options[:description]
        }
      end
      
      def add_creditcard(post, creditcard)
        post[:PaymentMethod] = {
          :CreditCard => {
            :Type           => creditcard.type.upcase,
            :Number         => creditcard.number,
            :ExpiryDate     => "#{'%02d' % creditcard.month}/#{'%02d' % creditcard.year.to_s.slice(2..-1)}"
          }
        }
        
        if [ CREDIT_CARDS[:SWITCH], CREDIT_CARDS[:SOLO] ].include?(creditcard.type)
          post[:PaymentMethod][:CreditCard][:Issue] = creditcard.verification_value
        else
          post[:PaymentMethod][:CreditCard][:SecurityCode] = creditcard.verification_value
        end
      end
      
      def parse(body)
      end
      
      def commit(action, money, parameters)
        puts post_data(action, parameters)
        puts socket_request "localhost", 5444, post_data(action, parameters)
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
        x = Builder::XmlMarkup.new :indent => 2
        
        x.RequestBlock('Version' => API_VERSION) do
          x.Request('Type' => action) do |request|
            parameters.each do |k, v|
              request << v.to_xml(:root => k.to_s, :skip_instruct => true, :indent => 2, :skip_types => true)
            end
          end
          x.Certificate File.read(@@certificate_path)
        end
      end
    end
  end
end

