HostSample::Application.routes.draw do
  root to: 'static_pages#home'
  
  # resources
    resources :sessions, only: [:new, :create, :destroy]
    resources :relationships, only: [:create, :destroy]
    resources :eventactivities, only: [:create, :destroy]
    resources :unsubscribes, only: [:new, :create, :destroy]
    resources :suggestion_inputs, only: [:new]
    
    # resources :cancellationpolicies
    # resources :charitypolicies
    
    # resources :hostevents do
    #   resources :eventphotos
    # end

  # static pages
    match '/help',    to: 'static_pages#help'
    match '/help#faq_2_1', to: 'static_pages#help', as: :faq_2_1
    match '/help#faq_2_2', to: 'static_pages#help', as: :faq_2_2
    match '/help#faq_2_9', to: 'static_pages#help', as: :faq_2_9
    match '/help#faq_2_3', to: 'static_pages#help', as: :faq_2_3
    match '/help#faq_2_5', to: 'static_pages#help', as: :faq_2_5
    match '/help#faq_2_6', to: 'static_pages#help', as: :faq_2_6
    match '/help#faq_2_7', to: 'static_pages#help', as: :faq_2_7
    
    # get "static_pages/help"
    match '/about',   to: 'static_pages#about'
    match '/terms',   to: 'static_pages#terms'
    match '/home',   to: 'static_pages#mobilehome'
    match '/cancellation_policy',   to: 'static_pages#cancellation_policy'
    match '/privacy_policy',   to: 'static_pages#privacy_policy'
    match '/email_ly', to: 'static_pages#email_ly', :via => :post
    # match '/#how_it_works', to: 'static_pages#home', as: :how_it_works
    match '/how_it_works', to: 'static_pages#how_it_works', as: :how_it_works
    match '/contact_ly', to: 'static_pages#about', as: :contact_us

  resources :addressusers, only: [:new, :create, :update]
    match '/my_address_book', to: 'addressusers#index'
    match '/delete_address/:id', to: 'addressusers#delete_address', :as => :delete_address

  resources :users, only: [:create]
    match '/member/:permalink/settings', to: 'users#edit', :as => :edit_user
    match "/member/:permalink", to: "users#show", :as => :user, via: :get
    match "/member/:permalink", to: "users#update", :as => :user, via: :put
    match "/member/:permalink", to: "users#destroy", :as => :user, via: :delete
    match '/hosts/:metroarea', to: 'users#hosts', :as => :hosts
    # Sign Up and log in
      match '/signup',  to: 'users#new'
      match '/signin',  to: 'sessions#new'
      match '/signout', to: 'sessions#destroy', via: :delete
      match '/auth/:provider/callback', to: 'sessions#create_fb'
      match '/auth/failure', to: redirect('/')

      match '/activate/:code' => "users#account_activate", :as => :account_activate, :via => :get
      match '/send_activation_link/:permalink' => 'users#activate_view', :as => :activate_view
      match '/resend_activation/:permalink' => 'users#resend_activation'
      match '/password_reset/:code' => 'users#password_reset', :as => :password_reset
      match '/request_password_reset' => 'users#request_password_reset'
      match '/email_password_reset' => 'users#email_password_reset'
      match '/update_password_reset/:permalink' => 'users#update_password_reset', :as => :update_password_reset
      match '/deactivate' => 'users#deactivate_account', :as => :deactivate_account
      match '/reactivate' => 'users#reactivate_account', :as => :reactivate_account
      # match '/close/:permalink' => 'users#close_account', :as => :close_account

    match '/my_events', to: 'users#show_myevents', :as => :show_myevents
    match '/my_past_events/:permalink', to: 'users#show_mypastevents', :as => :show_mypastevents
    match '/earnings',  to: 'users#show_myearnings', :as => :show_myearnings
    match '/create_bank_acct', to: 'users#create_bank_acct', :as => :create_bank_acct
    match '/favorite_chefs', to: 'users#following', :as => :following
    # match '/see_followers', to: 'users#followers', :as => :followers

  resources :menuitems, only: [:create]
    match '/my_recipebox', to: 'menuitems#index', as: :my_recipebox
    match '/my_events_recipes', to:'menuitems#my_events_recipes'
    match '/edit_recipe_from_event', to: 'menuitems#update_from_evt'
    match "/recipe/:permalink", to: "menuitems#show", :as => :menuitem, via: :get
    match "/recipe/:permalink", to: "menuitems#update", :as => :menuitem, via: :put
    match "/recipe/:permalink", to: "menuitems#destroy", :as => :menuitem, via: :delete
    match '/recipe/:permalink/edit', to: 'menuitems#edit', :as => :edit_menuitem
    match '/new_recipe', to: 'menuitems#new', :as => :new_menuitem

  resources :hostevents, only: [:create]
    match "/event/:permalink", to: "hostevents#show", :as => :hostevent, via: :get
    match "/event/:permalink", to: "hostevents#update", :as => :hostevent, via: :put
    match "/event/:permalink", to: "hostevents#destroy", :as => :hostevent, via: :delete
    match '/events/:metroarea', to: 'hostevents#index', :as => :events
    match '/new_event', to: 'hostevents#new', :as => :new_event
    match '/events/:permalink/open', to: 'hostevents#hostevent_open', :as => :hostevent_open
    match '/events/:permalink/cancel', to: 'hostevents#hostevent_cancel', :as => :hostevent_cancel
    match '/events/:permalink/edit_menu', to: 'hostevents#edit', :as => :edit_hostevent
    match '/events/:permalink/edit_basic', to: 'hostevents#edit_basic', :as => :edit_basic
    match '/events/:permalink/edit_details', to: 'hostevents#editstep2', :as => :step2
    match '/events/:permalink/removemenu/:menu', to: 'hostevents#disassociate_menuitem', :as => :removemenu
    match '/copy_event', to: 'hostevents#copy', :as => :copy_event
    match '/send_guestlist_to_host/:permalink', to: 'hostevents#send_guestlist_to_host', :as => :send_guestlist_to_host

    match '/events/:permalink/signup_requests', to: 'hostevents#signup_requests', :as => :signup_requests
    match '/events/:permalink/attended_guests', to: 'hostevents#hostevent_ratings', :as => :hostevent_ratings
    match '/host_rate_guest', to: 'signups#host_rate_guest'
    match '/invite_to_event', to: 'hostevents#send_invitation'

  # for event photos
    match '/event/:permalink/addphoto', to: 'eventphotos#new', :as => :addphoto_to_event
    match '/event/:permalink/addphoto_ie', to: 'eventphotos#new_dumb', :as => :addphoto_to_event_ie
    match '/event/:permalink/createphoto', to: 'eventphotos#create', :as => :create_photo, via: :post
    match '/event/:permalink/deletephoto/:id', to: 'eventphotos#destroy', :as => :delete_photo, via: :delete

  # for signups
    match '/event/:permalink/create_reservation', to: 'signups#create', :as => :create_signup, via: :post
    match "/event_reservation/:permalink", to: "signups#show", :as => :signup, via: :get
    match "/event_reservation/:permalink", to: "signups#update", :as => :signup, via: :post
    match '/pay_for_seat', to: 'signups#pay_for_seat', :as => :pay_for_seat
    match '/dispute_event', to: 'signups#dispute_event'
    # match '/stripeupdate', to: 'signups#stripeupdate'

  resources :recipereqs, only: [:create, :destroy, :edit, :update, :show, :index]
    match '/requested_evt_status_update/:permalink', to: 'recipereqs#update_status', :as => :update_status, via: :post
    match '/create_evt_from_request/:permalink', to: 'hostevents#new_evt_from_req', :as => :new_evt_from_req, via: :get
    match '/create_new_evt_from_request/:permalink', to: 'hostevents#create_evt_from_req', :as => :create_evt_from_req, via: :post
    match '/send_evt_proposal/:permalink', to: 'hostevents#propose_evt', :as => :propose_evt, :via => :post
    match '/chef_confirm_evt/:permalink', to: 'hostevents#chef_confirm_evt', :as => :chef_confirm_evt, :via => :post
    
  resources :messages, only: [:create, :destroy]
  resources :messagechains, only: [:create, :index]
    match "/message/:permalink", to: "messagechains#show", :as => :messagechain, via: :get
    # match '/events/:id/message_all', to: 'messages#message_all', :as => :message_all

  match '/send_customized_newsletter', to: 'users#send_customized_newsletter'
  match '/send_customized_newsletter_test', to: 'users#send_customized_newsletter_test'
  match '/send_reminders', to: 'users#send_reminders'

  # reporting
    match '/all_user_stats', to: 'users#all_user_stats'
    match '/update_evt_earnings', to: 'hostevents#calc_evt_earnings'

  mount StripeEvent::Engine => '/stripeupdate'
end