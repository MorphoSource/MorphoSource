module Morphosource
  module Users
    module Defaults

      # Settings used by morphosource.rake when creating default development user accounts
      ADMIN = {
        id: 1,
        email: "admin@email.com",
        password: 'password',
        guest: false,
        facebook_handle: 'admin',
        twitter_handle: '@Admin',
        display_name: 'AdminFirst AdminLast',
        address: '100 Main Street',
        department: 'Admin Department',
        website: 'www.admin.com',
        affiliation: 'Admin Affiliation',
        telephone: '(888) 555-5555',
        orcid: 'https://orcid.org/0000-0000-0000-0000',
        state: 'NC',
        country: 'USA',
        postal_code: '27278',
        terms_read: true,
        ms1_user: false,
        ms_id: "1"
      }

      CONTRIBUTOR = {
        id: 2,
        email: "contributor@email.com",
        password: 'password',
        guest: false,
        facebook_handle: 'contributor',
        twitter_handle: '@Contributor',
        display_name: 'ContributorFirst ContributorLast',
        address: '100 Main Street',
        department: 'Contributor Department',
        website: 'www.contributor.com',
        affiliation: 'Contributor Affiliation',
        telephone: '(888) 555-5555',
        orcid: 'https://orcid.org/0000-0000-0000-0000',
        state: 'NC',
        country: 'USA',
        postal_code: '27278',
        terms_read: true,
        ms1_user: false,
        ms_id: "2"
      }

      REGISTERED = {
        id: 3,
        email: "registered@email.com",
        password: 'password',
        guest: false,
        facebook_handle: 'registered',
        twitter_handle: '@Registered',
        display_name: 'RegisteredFirst RegisteredLast',
        address: '100 Main Street',
        department: 'Registered Department',
        website: 'www.registered.com',
        affiliation: 'Registered Affiliation',
        telephone: '(888) 555-5555',
        orcid: 'https://orcid.org/0000-0000-0000-0000',
        state: 'NC',
        country: 'USA',
        postal_code: '27278',
        terms_read: true,
        ms1_user: false,
        ms_id: "3"
      }
    end
  end
end
