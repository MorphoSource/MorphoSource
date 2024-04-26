desc 'Build the package and setup a release'
task :release do
  sh "helm package ."
  sh "helm repo index . --url https://samvera-labs.github.io/fcrepo-charts"
  sh "git add *.tgz index.yaml"
  puts "Package built and indexed. Don't forget to commit, push and have a great day!"
end
