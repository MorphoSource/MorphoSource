# frozen_string_literal: true
json.tags @tags do |tag|
  next if tag.is_a? Integer
  json.text tag
  json.id tag
end
