if @upload.present? 
  json.id @upload.id
  json.name @upload.file.file.filename
  json.size @upload.file.file.size
end
