class Snews
  
  def initialize
    # nothing for now
  end
  
  
  # report hotness back
  def self.howHot( amI )
    hotness = ""
    hotness = "spicy"     unless (amI/".c2").empty?
    hotness = "onfire"    unless (amI/".c3").empty?
    hotness = "volcanic"  unless (amI/".c4").empty?
    hotness
  end

  def self.checkHotness
    # check against Cachify
    if Cachify.is_fresh # fresh
      ret = Cachify.recent
    else # not fresh
      # TODO: load most recent state then fire load of new state (maybe via AJAX)
      ret = Snews.loadHotness
    end
    
    ret
  end

  def self.loadHotness
    tlist = Hpricot( open( "http://www.google.com/trends/hottrends" ) )
    hotlinks = (tlist/".hotColumn a")
    ret = "<div id='frag'><ol>"
    
    #     <ol>
    # <% for hot in @hot %>
    #   <li>
    #     <div class="tehot">
    #       <h1><%= hot[0] %></h1>
    #       <div class="desc"><%= hot[1] %></div>
    #     </div>
    #   </li>
    # <% end %>
    # </ol>
    
    # loop it out
    hotlinks.each do |l|
      href = l['href']
      name = l.inner_text
      # grab the page for the term
      linkDoc =   Hpricot( open( "http://www.google.com"+href ) )
      # grab the hot scale
      hotScale =  (linkDoc/".hotScale")
      # record the hotness as a string
      hotness =   self.howHot( hotScale )

      ret << "<li><div class='tehot'><h1><span class='name #{hotness}'><a href='http://www.google.com#{href}'>#{name}</a></span></h1><div class='desc'>" + (linkDoc/".gs-result").inner_html + "</div></div></li>"
    end
    
    ret << "</ol></div>"
    
    # Cachify.save_state( ret )
    
    ret
  end
  
  def self.get_snews
    Snews.checkHotness
  end
end