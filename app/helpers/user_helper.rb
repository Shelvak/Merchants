module UserHelper
  def show_user_roles_options(form)
    options = User.valid_roles.map { |r| [t("view.users.roles.#{r}"), r] }

    form.input :role, collection: options, as: :select, label: false,
      input_html: { class: nil }
  end
end
