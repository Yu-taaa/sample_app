Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',   to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  # /users/:id（主キー）/followingや/users/:id（主キー）/followersといったURLになる
  # following_user_path(1)やfollowers_user_path(1)といった名前付きルートが使える
  # ただのネストの場合、外部キー（:関連モデル_id）を使うが、memberの場合、主キー（:id）になる
  # ネストだけでなく、memberも使う理由は、一覧表示は、usersテーブルと中間テーブルのやりとりだけで完結できるから
  # ネストだけだと別途リソースを考慮する必要があり、余計なファイル、記述で複雑になってしまうから
  # memberを使えば、動かすアクションは users#following / users#followers となり、シンプル
  # collectionだと、:id を含まないので、/users/followingや/users/followersとなり、
  # アプリケーションにあるすべてのfollowing、followersリストを表示してしまう
  resources :users do
    member do
      get :following, :followers
    end
  end
  # 本来、認証はすでにDBにあるデータを扱うため、PATCHリクエストとupdateアクションになるべき
  # editアクションである理由は、有効化リンクをメールでクリックした時にブラウザから発行されるのは、GETリクエストになるため
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end