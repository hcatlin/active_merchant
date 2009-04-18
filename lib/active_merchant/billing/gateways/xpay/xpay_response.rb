module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class XPayResponse
      def error?
        @xml.root.get_elements('Response/OperationResponse/Result').first.text == '0'
      end

      def success?
        @xml.root.get_elements('Response/OperationResponse/Result').first.text == '1'
      end
  
      def declined?
        @xml.root.get_elements('Response/OperationResponse/Result').first.text == '2'
      end
      
      def transaction_reference
        @params[:transaction_reference]
      end
      
      def auth_code
        @params[:auth_code]
      end
      
      def transaction_verifier
        @params[:transaction_verifier]
      end
      
      def initialize(xml_response)
        @xml = REXML::Document.new xml_response
      end
      
      def to_s
        if success?
          'The transaction was processed successfully.'
        elsif declined?
          'The transaction was declined by the card issuer.'
        else
          @xml.root.get_elements('Response/OperationResponse/Message').first.text
        end
      end
      
      def message
        self.to_s
      end
    end
  end
end