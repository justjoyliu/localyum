require 'spec_helper'

describe "signups/edit" do
  before(:each) do
    @signup = assign(:signup, stub_model(Signup,
      :hostevent_id => 1,
      :user_id => 1,
      :confirmation_host => false,
      :confirmation_guest => false,
      :confirmation_status => "MyString",
      :payment_status => "MyString",
      :payment_amt => "9.99"
    ))
  end

  it "renders the edit signup form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => signups_path(@signup), :method => "post" do
      assert_select "input#signup_hostevent_id", :name => "signup[hostevent_id]"
      assert_select "input#signup_user_id", :name => "signup[user_id]"
      assert_select "input#signup_confirmation_host", :name => "signup[confirmation_host]"
      assert_select "input#signup_confirmation_guest", :name => "signup[confirmation_guest]"
      assert_select "input#signup_confirmation_status", :name => "signup[confirmation_status]"
      assert_select "input#signup_payment_status", :name => "signup[payment_status]"
      assert_select "input#signup_payment_amt", :name => "signup[payment_amt]"
    end
  end
end
