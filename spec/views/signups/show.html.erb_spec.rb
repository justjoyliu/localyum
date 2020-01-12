require 'spec_helper'

describe "signups/show" do
  before(:each) do
    @signup = assign(:signup, stub_model(Signup,
      :hostevent_id => 1,
      :user_id => 2,
      :confirmation_host => false,
      :confirmation_guest => false,
      :confirmation_status => "Confirmation Status",
      :payment_status => "Payment Status",
      :payment_amt => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/Confirmation Status/)
    rendered.should match(/Payment Status/)
    rendered.should match(/9.99/)
  end
end
