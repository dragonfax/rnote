
require 'nokogiri'
require 'yaml'
require 'evernote-thrift'


# converting between text formats and enml
#
# we have two types of conversion
#
# simple,
# single document conversion.
# which is enml <=> txt
#
# then our own additional wrappers we put on top of those 2 document types
# adding metadata to them.
# yaml_stream <=> notes attributes
# content is just considered an 'attribute' in the latter
#
# the yaml_stream is just a string
# the note attributes get its own class and thats where we stick the conversion routines.

class Evernote::EDAM::Type::Note
  
  NON_BREAKING_SPACE = "\xc2\xa0".force_encoding("UTF-8")
  
  ENML_PREAMBLE = <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;">
EOF

  # simple xhtml to txt converter
  # just tries to convert evernotes simple xhtml. 
  # the kind its own editors create. Which doesn't involve much nesting.
  class EnmlDocument < Nokogiri::XML::SAX::Document # Nokogiri SAX parser
    
    attr_accessor :_txt, :nested_div_count, :in_pre, :in_ul, :in_ol, :next_number

    def initialize
      @_txt = ''
      @in_pre = false
      @next_number = 1
      @in_ul = false
      @in_ol = false
      @nested_div_count = 0
      super
    end

    def in_div
      nested_div_count > 0
    end
    
    def characters string
      
      if ! self.in_div and ! self.in_pre and string == "\n"
        # ignore lone newlines that occur outside a div
      else
        self._txt << string
      end
    end
    
    def start_element name, attrs = []
      case name
        when 'en-todo'
          if Hash[attrs]['checked'] == 'true'
            self._txt << '[X] '
          else
            self._txt << '[ ] '
          end
        when 'div'
          self.nested_div_count += 1
        when 'pre'
          self.in_pre = true
        when 'ol'
          self.next_number = 1
          self.in_ol = true
        when 'ul'
          self.next_number = 1
          self.in_ul = true
        when 'li'
          if in_ol
            self._txt << next_number.to_s + '. '
            self.next_number += 1
          elsif in_ul
            self._txt << '* '
          end
        else
          # nothing
      end
    end
    
    def end_element name
      case name
        when 'div'
          raise "unmatched <div> tags" if self.nested_div_count <= 0
          self.nested_div_count -= 1
          # a newline for every div (whether its got a <br> in it or not)
          self._txt << "\n"
        when 'pre'
          self.in_pre = false
        when 'br'
          # ignore it, as its always in a div, and every div will be a newline anyways
        when 'ul'
          self.in_ul = false
        when 'ol'
          self.in_ol = false
        when 'li'
          # unnecessary, as we're in a div, so the other \n is kept
          # self._txt << "\n"
        else
          # nothing
      end
    end
    
    def txt
      # always remove the last newline. to match up with WYSIWYG interfaces.
      self._txt.chomp
    end
    
  end


  def self.enml_to_txt(enml)
    raise 'not given xml' if ! enml.start_with? '<?xml'

    sax_document = EnmlDocument.new
    parser = Nokogiri::XML::SAX::Parser.new(sax_document)
    parser.parse(enml)
    
    enml = sax_document.txt

    enml
  end
  
  def self.txt_to_enml(txt)
    raise 'given xml instead of txt' if txt.start_with? '<?xml'
    
    # TODO create a proper DOM, with proper xml entity escapes and tag structure
    
    # escape any entities
    txt = txt.gsub('<','&lt;')
    txt = txt.gsub('>','&gt;')
    
    # replace todo items 
    txt = txt.gsub('[ ] ','<en-todo/>')
    txt = txt.gsub('[X] ','<en-todo checked="true"/>')
    
    # every newline becomes a <div></div>
    # an empty line becomes a <div><br/></div>
    txt = txt.gsub('  ',NON_BREAKING_SPACE + ' ')
    
    lines = txt.split("\n",-1)
    lines = [''] if txt == ''
    raise if lines.length == 0
    
    # every pair of spaces must be swaped to a nbsp
    # don't have to use the identity though. the utf-8 char is fine
    
    xhtml = lines.map { |string|
      if string == ''
        "<div><br/></div>\n"
      else
        "<div>#{string}</div>\n"
      end
    }.join('')
      
    "#{Evernote::EDAM::Type::Note::ENML_PREAMBLE}#{xhtml}</en-note>\n"
  end
  
  def self.enml_to_format(format,enml)
    case format
      when 'enml'
        enml
      when 'txt'
        enml_to_txt(enml)
      else 
        raise
    end
  end
  
  def self.format_to_enml(format,formatted_content)
    case format
      when 'enml'
        formatted_content
      when 'txt'
        txt_to_enml(formatted_content)
      else
        raise
    end
  end
  
  def txt_content
    self.class.enml_to_format('txt',self.content)
  end
  
  def txt_content=(txt)
    self.content = self.class.format_to_enml('txt', txt)
  end
  
  # The yaml stream is what we give to the user to edit in their editor
  # 
  # Its just a string, but its composed of 2 parts. the note attributes and the note content.
  #
  # 1. a small yaml document with the note attributes as a hash.
  # 2. followed by the note content as txt
  def set_yaml_stream(format,yaml_stream)

    m = yaml_stream.match /^(---.+?---\n)(.*)$/m
    raise "failed to parse yaml stream\n#{yaml_stream}" unless m

    attributes_yaml = m[1]
    txt = m[2]

    enml = self.class.format_to_enml(format,txt)
    attributes_hash = YAML.load(attributes_yaml)
    
    # process tag names
    # allow for comma separated tag list
    tag_names = attributes_hash['tagNames']
    tag_names = tag_names.split(/\s*,\s*/) if tag_names.instance_of?(String)

    self.title = attributes_hash['title']
    self.tagNames = attributes_hash['tagNames']
    self.content = enml
  end
  
  def yaml_stream(format)
    YAML.dump({ 'title' => title, 'tagNames' => tagNames }) + "\n---\n" + self.class.enml_to_format(format,content)
  end
  
  def summarize
    self.txt_content.strip.gsub(/\s+/,' ')[0..100]
  end

end
