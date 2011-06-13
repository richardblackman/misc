
require 'find'
require 'ftools'

MERGE_LINE_REGEXP = /^(Module|Class|Form|UserControl)/

  module Find
    def match(*paths)
      matched = []
      find(*paths) { |path| matched << path if yield path }
      return matched
    end
    module_function :match
  end	

class File

  def File.versioned_filename(base, first_suffix='.0')
    suffix = nil
    filename = base
    while File.exists?(filename)
      suffix = (suffix ? suffix.succ : first_suffix)
      filename = base + suffix
    end
    return filename
  end

  def File.backup(filename, move=false)
    new_filename = nil
    if File.exists? filename
      new_filename = File. 
        versioned_filename(filename)
      File.send(move ? :move : :copy, filename, new_filename)
    end
    return new_filename
  end

end


class VBProject

  public 

  def self.merge(file_from, file_to)
    backup = File.backup(file_to, true)

    open(file_to, 'w') do |f|
      f << non_merger_lines_top(backup)
      f << merger_lines(file_from)
      f << non_merger_lines_bottom(backup)
    end
  end

  def self.find(*paths)
    Find.match(*paths) { |p| ext = p[-4...p.size]; ext && ext.downcase == ".vbp" } 
  end

  private 

  def self.merger_lines(file_name)
    out = ""

    open(file_name).each do |line|
      if line =~ MERGE_LINE_REGEXP
        out << line
      end
    end

    return out
  end

  def self.non_merger_lines_top(file_name)
    out = ""

    open(file_name).each do |line|
      break if line =~ MERGE_LINE_REGEXP

      out << line
    end

    return out
  end

  def self.non_merger_lines_bottom(file_name)
    out = ""

    start_output = false

    open(file_name).each do |line|
      if line =~ MERGE_LINE_REGEXP
        start_output = true
      elsif start_output
        out << line
      end
    end

    return out
  end
end
