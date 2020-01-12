require 'spec_helper'

describe "Static pages" do

  #telling RSpec that page is the subject of the tests
  subject { page }

  describe "Home page" do

    #replaces visit root_path in the beginning of every do ... end
    #visit the root path before each example
    before { visit root_path }

    #R1 it "should have the content 'Sample App' " do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      #get static_pages_index_path
      #response.status.should be(200)
      # visit '/static_pages/home'
      # page.should have_content('Sample App')
    #end

    #R2 it "should have the h1 'Sample App'" do
      #visit root_path
      #page.should have_selector('h1', text: 'Sample App')
    #end

    #R3 it { should have_selector('h1', text: 'Sample App') }
    #it { should have_selector 'title',
    #                    text: "Ruby on Rails Tutorial Sample App" }
    #have_selector method checks for an HTML element (the “selector”) 
    #with the given content. In this instance, the title tag is "..."

    #R4 after including full_title function in spec/support/utilities.rb
    it { should have_selector('h1',    text: 'Sample App') }
    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector 'title', text: '| Home' }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end
  
  describe "Help page" do
    before { visit help_path }

    it { should have_selector('h1',    text: 'Help') }
    it { should have_selector('title', text: full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }

    it { should have_selector('h1',    text: 'About') }
    it { should have_selector('title', text: full_title('About Us')) }
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1',    text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end
end
