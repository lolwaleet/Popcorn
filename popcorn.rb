require 'open-uri'
require 'mechanize'
require 'ruby-progressbar'
require 'colorize'

sep      = ('-'*60).colorize(:cyan)
leets    = [ 'T3N38R15', 'MakMan', 'Maini', 'Muhit' ] 

puts '  _____                                ___  
 |  __ \                              |__ \ 
 | |__) |__  _ __   ___ ___  _ __ _ __   ) |
 |  ___/ _ \| \'_ \ / __/ _ \| \'__| \'_ \ / / 
 | |  | (_) | |_) | (_| (_) | |  | | | |_|  
 |_|   \___/| .__/ \___\___/|_|  |_| |_(_) ~ by '.colorize(:yellow) + 'AnonGuy'.colorize(:magenta) + '
            | |                             
            |_|                            '.colorize(:yellow)
print 'Greets to ~ '.colorize(:green)
leets.each { |leet| (leet == leets.last ? (puts leet.colorize(:cyan)) : (print leet.colorize(:cyan) + ' -- ')) } # .. I know.
puts sep

print 'TV Show --> '.colorize(:red)
show    = gets.chomp
print 'Season  --> '.colorize(:red)
season  = gets.chomp

def get_links(url)
	mechanize = Mechanize.new
	html      = mechanize.get(url)
	links     = html.links.drop(7)
	return links
end
def dload(url, file, folder)
  # thanks user:923315[stackoverflow]
  pbar = nil
  open(url, "rb",
    :content_length_proc => lambda {|t|
     if t && 0 < t
       pbar = ProgressBar.create(title: file.to_s.colorize(:red), format:"Downloading [ %t ] ~ [%b%i] [%P%% ] [%E ]", total:t, progress_mark:'='.colorize(:green))
     end
    },
    :progress_proc => lambda {|s|
     pbar.progress = s if pbar
    }) do |page|
    File.open("Season #{folder}/#{file}", "wb") do |f|
      while chunk = page.read(1024)
        f.write(chunk)
      end
    end
    puts "Episode [ #{file} ] has been downloaded!"
  end
end

url   = (season == '' ? "http://178.216.250.169/Series/#{show}/" : "http://178.216.250.169/Series/#{show}/s#{season}/")
links = get_links(url)
puts sep

links.each{|link|
  if season == ''
    puts "Season #{link.to_s.delete("^0-9")}".colorize(:blue)
    episodes = get_links("#{url}#{link}")
    episodes.each{|epi|
      episodeSize = (((Mechanize.new.head("#{url}#{link}#{epi}")['content-length'].to_i/1024/1024) * 100) / 100)
      puts epi.to_s.colorize(:green) + ' ~ ' + (episodeSize.to_s + 'MB').colorize(:green)
    }
  else
    puts "Season #{season.to_s.delete("^0-9")}".colorize(:blue)
    episodeSize = (((Mechanize.new.head("#{url}#{link}")['content-length'].to_i/1024/1024) * 100) / 100)
    puts link.to_s.colorize(:green) + ' ~ ' + (episodeSize.to_s + 'MB').colorize(:green)
    Dir.mkdir("Season #{season}") unless File.directory?("Season #{season}")
    dload(URI::encode("#{url}#{link}"), link, season)
  end
}