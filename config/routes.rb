DropSc::Application.routes.draw do
    devise_for :users

    match '/admin/' => "admin#index", :as => "admin"

    # root :to => "replays#popular", :time => "week"
    root :to => "home#index"

    match '/api/upload' => "api#upload", :via => :post
    match '/api/replay/:id' => 'api#replay'

    match '/about/'   => "static#about"
    match '/faq/'     => "static#faq"
    match '/twitter/' => "static#twitter"

    match '/tutorial/' => "static#tutorial"
    match '/pro/' => "static#pro"

    match '/users/make_pro/' => "users#make_pro", :as => "make_pro"

    resources :news_posts, :path => "/news" do
      resources :comments, :only => [:create, :destroy]
    end

    match '/users/:id/uploads' => "users#uploads", :as => "user_uploads"
    match '/users/update_settings' => "users#update_settings", :via => :post, :as => "update_settings"

    match '/popular/(:time)' => "replays#popular", :as => "popular"

    match '/stats/'   => "stats#stats"
    match '/profile/' => "users#profile"

    match '/inbox/'   => "notifications#index", :as => "inbox"

    resources :notifications, :only => [:index] do
      collection do
        get 'read_all'
      end
    end

    resources :events

    match '/players/:region/:bnet_id/:name' => "players#show_slug", :as => :show_player_slug

    resources :players, :only => [:index, :show] do
      get :autocomplete_player_name, :on => :collection
    end

    resources :packs do
      resources :comments, :only => [:create, :destroy]
      member do
        get 'd'
        post 'edit'
        post 'set_event'
      end
    end

    resources :replays, :path => "/" do
      member do
        get 'd'
        post 'set_event'
        get 'embed'
      end
      collection do
        get 'search'
        get 'popular'
        post 'upload'
        get 'pro'
      end
      resources :comments, :only => [:create, :destroy]
    end
end
