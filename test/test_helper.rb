require 'test/unit'

class String
  
  # useful for indenting heredocs in tests
  def unindent
    smallest_indent = scan(/^[ \t]*(?=\S)/).min # should be nil
    indent_size = smallest_indent ? smallest_indent.size : 0
    gsub(/^[ \t]{#{indent_size}}/, '')
  end
  
  def replace_nbsp
    gsub(Evernote::EDAM::Type::Note::NON_BREAKING_SPACE,' ')
  end
  
end


