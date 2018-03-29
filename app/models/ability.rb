class Ability
  include CanCan::Ability

  def initialize(user)
    user.roles.each do |role|
      send("#{role}_rules") if respond_to?("#{role}_rules")
    end
  end

  def admin_rules
    can :manage, :all
    can :assign_roles, User
    can :see_index_table, Box
    can :export, :report
  end

  def seller_rules
    can :manage, :all
    cannot :destroy, :all
    cannot :manage, User
    cannot :assign_roles, User
    cannot :see_index_table, Box
    cannot :export, :report

    cannot [:print, :show, :edit, :update], Bill do |bill|
      bill.created_at < 1.day.ago
    end
  end
end
