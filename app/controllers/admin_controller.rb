class AdminController < ApplicationController
    layout 'admin' #every controller inherited from admincontroller will be authenticate before action and using admin layout
    before_action :authenticate_admin!
    def index
    end
end
