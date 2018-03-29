class User < ActiveRecord::Base
  include RoleModel
  AVAILABLE_ROLES = [:admin, :seller]
  roles AVAILABLE_ROLES

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation,
    :remember_me, :role
  # attr_accessible :title, :body

  validates :email, :username, presence: true, uniqueness: true

  after_initialize :set_default_role

  def to_s
    self.username
  end

  def set_default_role
    self.role ||= :regular
  end

  def role
    self.roles.first.try(:to_sym)
  end

  def role=(role)
    self.roles = [role]
  end

  AVAILABLE_ROLES.each do |role_name|
    define_method("#{role_name}?".to_sym) do
      self.role == role_name
    end
  end
end
