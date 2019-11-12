# frozen_string_literal: true
# Controller for managing Roles for Users
class UserRolesController < ApplicationController
  include Hydra::RoleManagement::UserRolesBehavior
end
