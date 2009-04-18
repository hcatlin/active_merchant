require File.dirname(__FILE__) + '/../../test_helper'

class RemoteXpayTest < Test::Unit::TestCase

  def setup
    @gateway = XpayGateway.new
    
    @gateway.site_reference = "testwoobius12861"
    @gateway.certificate_path = File.dirname(__FILE__) + '/../../testwoobius12861testcerts.pem'
    
    @amount = 100
    @credit_cards = {
      :visa         => credit_card('4111111111111111'),
      :mastercard   => credit_card('5111111111111118', :type => :master)
    }
    @declined_credit_cards = {
      :visa         => credit_card('4242424242424242'),
      :mastercard   => credit_card('5111111111111142', :type => :master)
    }
    
    @options = { 
      :order_id => '1',
      :billing_address => address,
      :description => 'Store Purchase',
      :currency => 'GBP'
    }
  end
  
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_cards[:visa], @options)
    assert_success response
    assert_equal 'REPLACE WITH SUCCESS MESSAGE', response.message
  end

  # def test_unsuccessful_purchase
  #   assert response = @gateway.purchase(@amount, @declined_card[:visa], @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end
  # 
  # def test_authorize_and_capture
  #   amount = @amount
  #   assert auth = @gateway.authorize(amount, @credit_card[:visa], @options)
  #   assert_success auth
  #   assert_equal 'Success', auth.message
  #   assert auth.authorization
  #   assert capture = @gateway.capture(amount, auth.authorization)
  #   assert_success capture
  # end
  # 
  # def test_failed_capture
  #   assert response = @gateway.capture(@amount, '')
  #   assert_failure response
  #   assert_equal 'REPLACE WITH GATEWAY FAILURE MESSAGE', response.message
  # end
  # 
  # def test_invalid_login
  #   gateway = XpayGateway.new(
  #               :login => '',
  #               :password => ''
  #             )
  #   assert response = gateway.purchase(@amount, @credit_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILURE MESSAGE', response.message
  # end
end
