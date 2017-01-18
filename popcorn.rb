require 'open-uri'
require 'mechanize'
require 'ruby-progressbar'
require 'colorize'

$sep      = ('-'*60).colorize(:cyan)
leets     = [ 'T3N38R15', 'MakMan', 'Maini', 'Muhit' ] 

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
puts $sep

def get_links(url)
  begin
    mechanize = Mechanize.new
    html      = mechanize.get(url)
    links     = html.links.drop(7)
  rescue StandardError
    puts $sep
    abort("That show/season doesn't exist\n".colorize(:red) + $sep)
  end
  return links
end

print 'TV Show (eg; Castle) --> '.colorize(:red)
show  = gets.chomp
print 'Fetch/Download       --> '.colorize(:red)
dload = gets.chomp.downcase
url   = 'http://178.216.250.169/Series/'
links = get_links(url)
puts $sep

def dload(url, file, folder, show)
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
    File.open("#{show}/Season #{folder}/#{file}", "wb") do |f|
      while chunk = page.read(1024)
        f.write(chunk)
      end
    end
    puts "Episode [ #{file} ] has been downloaded!"
  end
end

links.each{|link|
  link = link.href
  if link.chomp('/').downcase == URI.escape(show.downcase)
    $found   = true
    seasons = get_links("#{url}#{link}")
    puts 'Season(s) Available ~'.colorize(:green)
    seasons.each.with_index(1) {|season, i|
      puts '['.colorize(:cyan) +  i.to_s.colorize(:green) + ']'.colorize(:cyan) + ' ~ ' + "Season #{season.to_s.delete("^0-9")}".colorize(:blue)
    }
    puts $sep
    print 'Season (eg; 1)       --> '.colorize(:red)
    wantedSeason = gets.chomp
    puts $sep
    episodes = get_links("#{url}#{link}/s#{wantedSeason}")
    episodes.each{|episode|
      epiSize = (((Mechanize.new.head("#{url}#{link}/s#{wantedSeason}/#{URI.unescape(episode.href)}")['content-length'].to_i/1024/1024) * 100) / 100).to_s
      puts URI.unescape(episode.href).colorize(:green) + ' ~ ' + (epiSize.to_s + 'MB').colorize(:green)
      if dload == 'download'
        Dir.mkdir(show) unless File.directory?(show)
        Dir.mkdir("#{show}/Season #{wantedSeason}") unless File.directory?("#{show}/Season #{wantedSeason}")
        dload("#{url}#{link}/s#{wantedSeason}/#{episode.href}", URI.unescape(episode.href), wantedSeason, show)
      end
  }
  puts $sep
  end
}

abort("[#{'!'.colorize(:red)}] ~ That show isn't available! :(\n" + $sep) unless $found
