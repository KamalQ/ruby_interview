Rails.application.routes.draw do
  get 'patient_data/index'

  get "/patient_data", to: "patient_data#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
