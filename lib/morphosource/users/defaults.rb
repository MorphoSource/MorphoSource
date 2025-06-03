module Morphosource
  module Users
    module Defaults

      # Settings used by morphosource.rake when creating default development user accounts
      ADMIN = {
        id: 1,
        academic_field: 'Evolutionary Anthropology',
        academic_institution_or_school: 'Duke University',
        academic_subfield: 'Information Architecture',
        active: true,
        address: '100 Main Street',
        affiliation: 'Admin Affiliation',
        city: 'Durham',
        country: 'US',
        demographics: ['University Staff'],
        department: 'Admin Department',
        display_name: 'AdminFirst AdminLast',
        email: 'admin@email.com',
        facebook_handle: 'admin',
        first_name: 'AdminFirst',
        guest: false,
        intent: ['Research'],
        last_name: 'AdminLast',
        middle_name: 'AdminMiddle',
        ms_id: '1',
        ms1_user: false,
        orcid: 'https://orcid.org/0000-0000-0000-0001',
        password: 'password',
        postal_code: '27708',
        profile_type: 'Faculty or Staff (University, Museum, and/or Library)',
        state: 'NC',
        telephone: '(888) 555-5555',
        terms_read: true,
        twitter_handle: '@Admin',
        website: 'www.admin.com'
      }

      CONTRIBUTOR = {
        id: 2,
        academic_field: 'Evolutionary Anthropology',
        academic_institution_or_school: 'Duke University',
        academic_subfield: 'Information Architecture',
        active: true,
        address: '100 Main Street',
        affiliation: 'Contributor Affiliation',
        city: 'Durham',
        country: 'US',
        demographics: ['University Staff'],
        department: 'Contributor Department',
        display_name: 'ContributorFirst ContributorLast',
        email: 'contributor@email.com',
        facebook_handle: 'contributor',
        first_name: 'ContributorFirst',
        guest: false,
        intent: ['Research'],
        last_name: 'ContributorLast',
        middle_name: 'ContributorMiddle',
        ms_id: '2',
        ms1_user: false,
        orcid: 'https://orcid.org/0000-0000-0000-0002',
        password: 'password',
        postal_code: '27708',
        profile_type: 'Faculty or Staff (University, Museum, and/or Library)',
        state: 'NC',
        telephone: '(888) 555-5555',
        terms_read: true,
        twitter_handle: '@Contributor',
        website: 'www.contributor.com'
      }

      REGISTERED = {
        id: 3,
        academic_field: 'Evolutionary Anthropology',
        academic_institution_or_school: 'Duke University',
        academic_subfield: 'Information Architecture',
        active: true,
        address: '100 Main Street',
        affiliation: 'Registered Affiliation',
        city: 'Durham',
        country: 'US',
        demographics: ['University Staff'],
        department: 'Registered Department',
        display_name: 'RegisteredFirst RegisteredLast',
        email: 'registered@email.com',
        facebook_handle: 'registered',
        first_name: 'RegisteredFirst',
        guest: false,
        intent: ['Research'],
        last_name: 'RegisteredLast',
        middle_name: 'RegisteredMiddle',
        ms_id: '3',
        ms1_user: false,
        orcid: 'https://orcid.org/0000-0000-0000-0003',
        password: 'password',
        postal_code: '27708',
        profile_type: 'Faculty or Staff (University, Museum, and/or Library)',
        state: 'NC',
        telephone: '(888) 555-5555',
        terms_read: true,
        twitter_handle: '@Registered',
        website: 'www.registered.com'
      }

      # Default user roles
      ROLES = ['admin', 'batch_submission_contributor', 'contributor', 'charge_api', 'globus_file_submitter', 'remote_file_submitter']
    end
  end
end