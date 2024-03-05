module Hyrax
  module MediaHelper
    #
    # Return formatted HTML content showing an indented nested list of files in a directory structure,
    # given an array of either file name strings or directory hashes where hash keys are directory
    # names and hash values are arrays of either file name strings or sub-directory hashes.
    #
    # @param [Array<String, Hash>] Array of file names and directory hashes.
    #
    # @example Simple directory structure formatted as HTML
    # ["readme.txt", {"capsule"=>["capsule.obj", "capsule0.jpg", "capsule.mtl"]}, {"empty_dir"=>[]}]
    # => 
    # TBA
    #
    # @return HTML block tag
    #
    def format_nested_files(filename, files)
      content_tag(:ul) do
        content_tag(:li, class: "file-item") do
          concat "<i class='far fa-file-archive'></i>#{filename.to_s}".html_safe
          concat content_tag(:ul) { files.collect { |node| format_file(node) } }
        end
      end
    end

    #
    # Recursively format either file name string or a directory hash where hash key is directory name
    # and hash value is array of file name strings or sub-directory hashes into indented HTML.
    #
    # @param [String, Hash] File name string or directory hash.
    #
    # @return HTML block tag
    #
    def format_file(node)
      if node.is_a?(String)
        # Just a file reference, print with current indentation
        content_tag(:li, "<i class='far fa-file fa-fw'></i>#{node.to_s}".html_safe, class: "file-item")
      elsif node.is_a?(Hash)
        # Directory hash with directory name and contents, each contents array may be files or nested sub-dirs
        node.collect do |dir_name, dir_contents|
          concat content_tag(:li, class: "dir-item") { format_li_sublist(dir_name, dir_contents) }
        end
      else
        ""
      end
    end

    def format_li_sublist(label, contents)
      concat "<i class='far fa-folder fa-fw'></i>#{label}".html_safe
      concat content_tag(:ul) { contents.collect { |sub_node| concat(format_file(sub_node)) } }
    end
  end
end