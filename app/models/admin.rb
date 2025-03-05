class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #  devise will autogenerate methods and fill into ApplicationController : authenticate_admin! , admin_signed_in?, current_admin
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
