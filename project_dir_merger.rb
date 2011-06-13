require 'project_merger'

#
# Searches a project hierarchy for any visual basic project files and merges from one to the other
# without overwriting any of the local systems dll references. Handy for merging between app versions
# and not destroying complex projects
#

if ARGV.length != 2 
	print "Usage: #{$0} <dir_from> <dir_to>"
	exit 0
end

dir_from = ARGV[0]
dir_to = ARGV[1]

VBProject.find(dir_to).each do |file|
	subpath = file[dir_to.size...file.size]

	if File.exists?(dir_from + subpath)
		puts "Merging " + dir_from + subpath + " to " + dir_to + subpath
		VBProject.merge(dir_from+subpath, dir_to+subpath)
	else
		puts dir_from+subpath + " does not exist"
	end

end
