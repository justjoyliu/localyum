require 'spec_helper'

describe "signups/index" do
  before(:each) do
    assign(:signups, [
      stub_model(Signup,
        :hostevent_id => 1,
        :user_id => 2,
        :confirmation_host => false,
        :confirmation_guest => false,
        :confirmation_status => "Confirmation Status",
        :payment_status => "Payment Status",
        :payment_amt => "9.99"
      ),
      stub_model(Signup,
        :hostevent_id => 1,
        :user_id => 2,
        :confirmation_host => false,
        :confirmation_guest => false,
        :confirmation_status => "Confirmation Status",
        :payment_status => "Payment Status",
        :payment_amt => "9.99"
      )
    ])
  end

  it "renders a list of signups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Confirmation Status".to_s, :count => 2
    assert_select "tr>td", :text => "Payment Status".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
