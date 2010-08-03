# SIMPLE EXAMPLE OF USING PROTECTEDPLANET.NET API TO CHECK PROTECTION STATUS
# OF SPECIES LAT/LONG POINTS
# S.TOKUMINE & C.MILLS 2010
class MainController < ApplicationController
  def index
    base_url = "www.protectedplanet.net"
    @species    = []
     
    # CONNECT TO GOOGLE SPREADSHEETS
    session = GoogleSpreadsheet.login(GMAIL_USERNAME, GMAIL_PASSWORD)
    
    # GET WORKSHEET
    ws = session.spreadsheet_by_key(GOOGLE_SPREADSHEET_KEY).worksheets[0] 
        
    # READ DATA
    rows = ws.rows.dup
    
    # POP OFF HEADER ROW
    rows.shift
        
    # SORT DATA BY SPECIES NAME
    rows.sort! do |a,b|
      if a.first < b.first
        -1
      elsif a.first > b.first
        1
      else  
        0
      end  
    end  
        
    # INIT GMAPS
    GoogleStaticMapsHelper.size = '300x300'
    GoogleStaticMapsHelper.sensor = false
    @map = GoogleMap::Map.new :controls => [ :small, :type ],
                              :double_click_zoom => true,
                              :continuous_zoom => true,
                              :scroll_wheel_zoom => false
    
    # CHECK PROTECTION WITH PROTECTEDPLANET.NET API
    pa_overlap  = []
    rows.each_with_index do |row, i|
      if row[2] && row[3]
                
        # CREATE URL        
        url = "http://protectedplanet.net/api/site_atts_by_point/#{row[3]}/#{row[2]}"        
        Rails.logger.info "Retrieving data for #{url}"
        
        # CALL PROTECTEDPLANET API SERVICE AND PARSE RESPONSE
        pp = HTTParty.get(url).response.body
        pas = JSON.parse(pp)                
        pa_overlap << {:x => row[3], :y => row[2], :pas => pas}  
        
        # PACKAGE DATA
        if row == rows.last || rows[i+1].first != row.first         
          
          # COUNT TOTAL PROTECTED POINTS
          pp = pa_overlap.inject(0) {|sum, pnt| sum += 1 if !pnt[:pas].empty?; sum }
														
					# COLLECT UNIQUE PA LINKS																
					pa_links = pa_overlap.inject([]) { |a, pnt|
						pnt[:pas].each do |s| 
							a << {:slug => s['slug'], :url => "http://protectedplanet.net/sites/#{s['slug']}"} 							
						end
						a
					}.uniq
					
					# BUILD STATIC GOOGLE MAP
					map = GoogleStaticMapsHelper::Map.new :maptype => 'terrain'
					pa_overlap.each do |sp|
            color = sp[:pas].empty? ? "red" : "blue"
						map << GoogleStaticMapsHelper::Marker.new(:lng => sp[:x], 
 																										  :lat => sp[:y], 
																										  :color => color)
  					#BUILD STANDARD GOOGLE MAP					  				
  					@map.markers << GoogleMap::Marker.new(:map => @map,
                                                  :lat => sp[:y],
                                                  :lng => sp[:x], 
                                                  :icon => GoogleMap::SmallIcon.new(@map, color),
                                                  :marker_hover_text => row.first,
                                                  :html => infowindow(row.first, sp[:pas]))
          end                                                        					
					
					
          # PACKAGE FOR VIEW
          @species << {:name => row.first, 
                       :survey_points => pa_overlap, 
                       :protected_survey_point_count => pp,
                       :pa_links => pa_links,
                       :map => map.url}        
          pa_overlap = []
        end  
      end  
    end        
  end
  
  def to_pp_url slug
    "http://protectedplanet.net/sites/#{slug}"
  end  
  
  def to_pp_link slug
    "<a href='#{to_pp_url slug}'>#{slug.humanize}</a>"
  end
  
  def infowindow name, pas
    html = ""
    html << (pas.empty? ? "<h4>#{name} no protection</h4>" : "<h4>#{name} protected by</h4>")
    html << pas.map{|x| to_pp_link(x['slug'])}.join("<br> ")
    html
  end
end
