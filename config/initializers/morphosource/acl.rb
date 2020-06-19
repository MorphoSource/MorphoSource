Hydra::ACL.class_eval do
  # adds Download access to MorphoSource
  property :Download # extends http://www.w3.org/ns/auth/acl#Access
end
