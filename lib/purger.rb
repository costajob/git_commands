require 'fileutils'

module Purger
  extend self
  
  @published_paths = %w(public public-m)
  @sites = %w(ae at au be bg ca-en ca-fr ch cn cn-en cz de dk es fi fr hu ie int it jp kr nl no pl pt ro se si tr uk us)
  @dirs_count = 0
  
  def exec(projdir)
    confirm('Purge all the published contents') do
      print_spacer "Removing published contents...".bold.magenta
      Purger::purge_folders(projdir) do |site, path|
        puts "Removing #{site.upcase} folder (#{platform(path)})..."
      end
      print_spacer "Removed #{@dirs_count} published directories!".bold.yellow
    end
  end
  
  def purge_folders(projdir)
    @published_paths.each do |path|
      @sites.each do |site|
        if File.exists?((published_dir = File.join(projdir, path, site)))
          yield site, path
          FileUtils.rm_rf published_dir
          @dirs_count += 1
        end
      end
    end
  end
  
  def platform(path)
    path == 'public-m' ? 'Mobile' : 'Desktop'
  end
end