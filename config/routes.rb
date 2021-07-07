Rails.application.routes.draw do
  root 'exports#new'
  
  resources :exports

end
