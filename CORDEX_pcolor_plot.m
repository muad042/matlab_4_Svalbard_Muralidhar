function CORDEX_pcolor_plot(lat,lon,data,proj,nw_corner,se_corner,cont,color_scheme,contour_type,add_zeroline,add_clines,mask,map_text,plot_unit,colorbar_location,prnt,output_name,language,seas,meanValue)

% PURPOSE
% plot longitude-latitude plots with given projection using pcolorm  
% lon             : longitude of data points  from -180 to 180 (vector)
% lat             : lattitude of data points  from -90 to 90 (vector)
% data            : data points to be plotted (vector)
% cont            : contour vectors
% proj            : Selected projection                   
%
% map_text     : Text to appear on the figure (title)
% add_clines      : Add extra contour lines on plot. U(for example at
%                    zero)
% color_scheme    : Selected colorscheme
%                     'RedBlue'
%                     'BlueRed'
%
% contour_type    : plot filled contours or pcolor
%                   'filled' using contourfm
%                   'pcolor' using pcolor
%
% mask             : mask out a region or not
%                   'ocean' masks out the ocean
%                   'no' : no masking
%
% colorbar_location: appends a colorbar in the specified location
%                    relative to the axes.  LOCATION may be any one of 
%                    the following strings:
%                'North'              inside plot box near top
%                'South'              inside bottom
%                'East'               inside right
%                'West'               inside left
%                'NorthOutside'       outside plot box near top
%                'SouthOutside'       outside bottom
%                'EastOutside'        outside right
%                'WestOutside'        outside left
% fnt             : Fontsize for text, integer number 
% fntname         : Fontname 
% prnt            : If prnt='eps' an eps file is made
%                   if prnt='pdf' a pdf file is made
%                   else the plot is only shown on screen (default)
%
% output_name : name of output file 
%
%
%  Author: Asgeir Sorteberg, 
%           Geophysical Institute, University of Bergen.   
% 
% Modified by Muralidhar Adakudlu, Jan 2018
% ( Line ## 200; to display the spatial mean on the plot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
fntname='Arial';

% area to plot
latmin=se_corner(2);
latmax=nw_corner(2);
lonmin=nw_corner(1);
lonmax=se_corner(1);

% fix size of the data
if size(lat,1)==1
    lat=lat';
end
if size(lon,1)==1
    lon=lon';
end
if size(data,1)==1
    data=data';
end

% make sure data is correctly sorted
data_plot=data;
lat_plot=lat;
lon_plot=lon;
sortdata=sortrows([lon_plot lat_plot data_plot],1);
lon_plot=sortdata(:,1);
lat_plot=sortdata(:,2);
data_plot=sortdata(:,3);

%% find Svalbard border
shape_no=2;
shape_file_land='/Data/gfi/share/ObsData/WORLD_SHAPEFILES/cntry00';
cntry_shape=shaperead(shape_file_land,'UseGeoCoords', false);
lon_cntry=cntry_shape(shape_no).X;
lat_cntry=cntry_shape(shape_no).Y;

% reshape
xdim=length(unique(lon));
ydim=length(unique(lat));
data_plot=reshape(data_plot,ydim,xdim);
lat_plot=reshape(lat_plot,ydim,xdim);
lon_plot=reshape(lon_plot,ydim,xdim);

lat_plot2=lat_plot;
lon_plot2=lon_plot;

%  lat and lon is in center values pcolor needs lower left corner so we fix this
if strcmp(contour_type,'pcolor')
    unique_lat=unique(lat_plot);
    delta_lat=abs(unique_lat(2)-unique_lat(1))/1;
    unique_lon=unique(lon_plot);
    delta_lon=abs(unique_lon(2)-unique_lon(1))/1;
    disp([ 'CORDEX_pcolor_plot: NOTE: Latitude and longitude changed from center to left corner value'])
    disp([ 'CORDEX_pcolor_plot:      Delta LAT: ' num2str(delta_lat)])
    disp([ 'CORDEX_pcolor_plot:      Delta LON: ' num2str(delta_lon)])
    lat_plot=lat_plot-delta_lat;
    lat_plot(find(lat_plot>90))=90;
    lat_plot(find(lat_plot<-90))=-90;
    lon_plot=lon_plot-delta_lon;
    lon_plot(find(lon_plot<-180))=-180;
    lon_plot(find(lon_plot>180))=180-360+delta_lon;
end

%%%%%%%% PLOTTING
% get coastline
load coast
% % cont=[-32.5:0.5:32.5];
% % color_scheme='GMT_drywet';
% make colorscale
cont_stp=(cont(2)-cont(1))/2;
clear cont_int
cont_int(1,:)=[cont(1)-abs(cont(1)-cont(2)) cont(1)];
for mm=2:length(cont)
  cont_int(mm,:)=[cont(mm-1) cont(mm)];
end
cont_int(mm+1,:)=[cont(end) (cont(end)+(cont(2)-cont(1)))];

% number of colors
ncol=size(cont_int,1)-1;

if strcmp(color_scheme,'RedBlue')
  my_colmap=lbmap(ncol,color_scheme);
elseif strcmp(color_scheme,'GMT_globe') || strcmp(color_scheme,'GMT_drywet') || strcmp(color_scheme,'GMT_polar');% || strcmp(color_scheme,'BlueDarkRed18')
  [cmap, lims, ticks, bfncol, ctable] =cptcmap(color_scheme, 'mapping', 'scaled','ncol',ncol);  
  my_colmap=cmap;
elseif strcmp(color_scheme,'BlueRed')  
  my_colmap=lbmap(ncol,'RedBlue');
  my_colmap=flipud(my_colmap);
elseif strcmp(color_scheme,'blue')
  my_colmap=lbmap(ncol,color_scheme);
else
  disp('CORDEX_pcolor_plot: ERROR: Colorscale not recognized')
  return
end

%%%%%%%%%%%%
figure(22);
clf
set(gca,'Color','w','Box','on','YColor',[0.99 0.99 0.99],'XColor',[0.99 0.99 0.99])
set(gca,'PlotBoxAspectRatio',[1 1 17000])

axesm(proj,'MapLatLimit',[latmin latmax],'MapLonLimit',[lonmin lonmax],'Frame','on','FEdgeColor',[1 1 1],'FLineWidth',0.01);
tightmap;

if strcmp(contour_type,'pcolor')
    h=pcolorm(lat_plot,lon_plot,data_plot);
elseif strcmp(contour_type,'filled')
    [c,h]=contourfm(lat_plot,lon_plot,data_plot,cont,'LineColor','none');
      
end

% set colormap
colormap(my_colmap);
caxis([cont(1)-cont_stp cont(end)+cont_stp]); 

% add selected contour lines
add_zeroline=[add_zeroline add_zeroline];
if length(add_clines)==1
    add_clines=[add_clines add_clines];
end

%[c,h]=contourm(lat_plot2,lon_plot2,data_plot,add_zeroline,'k-','Linewidth',2);
[c,h]=contourm(lat_plot2,lon_plot2,data_plot,add_clines,'w','Linewidth',1);

% % mask everything outside NORWAY
if strcmp(mask,'ocean')
   geoshow(fliplr(lat_cntry),fliplr(lon_cntry),'DisplayType','polygon','FaceColor','w')
elseif strcmp(mask,'land') % added by Muralidhar for sea ice maps
   geoshow(lat_cntry,lon_cntry,'DisplayType','polygon','FaceColor','w')
end

% coastline 
linem(lat_cntry,lon_cntry,'k')
% set the title
h=title([map_text]);
set(h,'FontSize',8,'Fontname',fntname);

% make colorbar 
x_color = [0 0 0]; %Color of x-axis
y_color = x_color; %Color of y-axis 
h=colorbar('XColor',x_color,'YColor',x_color); 
set(h,'FontSize',12,'Fontname',fntname); xlabel(h,plot_unit,'FontSize',14,'Fontname',fntname);
set(h,'Location',colorbar_location);
if strcmp(colorbar_location,'East') || strcmp(colorbar_location,'West') ||  strcmp(colorbar_location,'EastOutside') || strcmp(colorbar_location,'WestOutside')
    set(h,'YTick',cont(1:10:end))
else
     set(h,'XTick',cont(1:2:end))
end   
axis tight
text(-0.02,1.325,[seas ': ' num2str(sprintf('%.2f',meanValue))],'FontSize',9,'FontWeight','bold','Color','r','BackgroundColor','c')

if strcmp(language,'E')
   text(.055,.95,' Source: UNI', 'FontSize',12);
else
   text(.055,.95,' Kilde: UNI', 'FontSize',12);
end

if strcmp(prnt,'eps')
    eval(['print -depsc ' output_name '.eps'])
elseif strcmp(prnt,'png')
    eval(['print -dpng ' output_name '.png'])
elseif strcmp(prnt,'pdf')
    eval(['print -dpdf ' output_name '.pdf'])
end
%cd ..


