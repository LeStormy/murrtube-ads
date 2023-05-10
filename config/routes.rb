Rails.application.routes.draw do
  root to: 'application#advertise'

  get 'ads', to: 'ads#index'
  post 'set_code', controller: 'ads'
end
