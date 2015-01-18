class MavsController < ApplicationController
  before_filter :check_admin, :check_building_cookie
end