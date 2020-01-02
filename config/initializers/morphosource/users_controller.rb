Hyrax::UsersController.class_eval do

  private

    def search(query)
      clause = query.blank? ? nil : "%" + query.downcase + "%"
      base = ::User.where(*base_query)
      base = base.where("email like lower(?) OR lower(display_name) like lower(?)", clause, clause) if clause.present?
      base.registered
          .where("#{Hydra.config.user_key_field} not in (?)",
                 [::User.batch_user_key, ::User.audit_user_key])
          .references(:trophies)
          .order(sort_value)
          .page(params[:page]).per(10)
    end
end
