function [data_interp]=interpolate_nearest(lat,lon,data,latnew,lonnew)
%
% [data_interp]=interpolate_nearest(lat,lon,data,latnew,lonnew)
% PURPOSE
% Perform nearest neighbour interpolation
%
% INPUT
%  lon        - longitude for source grid/observations (must be vector --> lat(gridpoints))
%  lat        - latitude for source grid/observations (must be vector--> lon(gridpoints) )
%  data       - data to interpolate (must be array --> data(gridpoints,times) or data(gridpoints,levels,times))
%  lonnew     - longitude for the target grid (must be vector --> lonnew(new gridpoints))
%  latnew     - latitude for the target grid (must be vector --> lonnew(new gridpoints))
%
% OUTPUT
%  data_interp - interpolated data using nearest neighbour interpolation data_interp(new gridpoints,times))
%
% Author: Asgeir Sorteberg,
%         Bjerknes Centre for Climate Research, Univ. of Bergen, Norway  
%         email: asgeirs@gfi.uib.no
%
%
%         Dec  2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% check data
if size(lat,1)>1 && size(lat,2)>1
  disp('interpolate_nearest: ERROR: source grid/observations must be vector lat(gridpoints)')
  return
end
if size(data,1)~=length(lat)
  if size(data,3)==1
      data=data';
  else
      data=permute(data,[3 2 1]);
  end
  if size(data,1)~=length(lat)
    disp('interpolate_nearest: ERROR: data not same size as lat. and long.')
    return
  end
end

if max(lat)<max(latnew) || min(lat)>min(latnew) 
 disp('interpolate_nearest: WARNING: Latitude of original data do not cover all latitudes of the new grid ')
 disp(['max(lat), max(latnew) & min(lat), min(latnew) = ' num2str(max(lat)) ',' num2str(max(latnew)) ',' num2str(min(lat)) ',' num2str(min(latnew)) ])
end
if max(lon)<max(lonnew) || min(lon)>min(lonnew) 
 disp('interpolate_nearest: WARNING: Longitude of original data do not cover all longitudes of the new grid ')
 disp(['max(lon), max(lonnew) & min(lon), min(lonnew) = ' num2str(max(lon)) ',' num2str(max(lonnew)) ',' num2str(min(lon)) ',' num2str(min(lonnew)) ])
end

delta_lat=diff(lat);

delta_lat1=abs(min(delta_lat(find(abs(delta_lat)>0)))*2);
delta_lat2=abs(max(delta_lat(find(abs(delta_lat)>0)))*2);
if delta_lat2<delta_lat1
  delta_lat=delta_lat2;
else
  delta_lat=delta_lat1;
end

delta_lon=diff(lon);
delta_lon=abs(max(delta_lon(find(delta_lon>0)))*2); %change from min -> max...
 disp(['interpolate_nearest: delta_lat: ' num2str(delta_lat)  ' delta_lon: ' num2str(delta_lon)])

disp('interpolate_nearest: Do interpolation. May take some time ...')
if size(data,3)==1
  data_interp=ones(length(latnew),size(data,2))*NaN;
elseif size(data,4)==1
  data_interp=ones(length(latnew),size(data,2),size(data,3))*NaN;
end

% make distances between gradient grid and surface grid
earthellipsoid = almanac('earth','ellipsoid','m','sphere');
tic
for j=1:length(latnew) 
% find gradient gridpoint closest to surface gridpoint
  clear grid_distance
% to speed things up use only the closest points
  polygon_lat2=[latnew(j)+delta_lat,latnew(j)+delta_lat,latnew(j)-delta_lat,latnew(j)-delta_lat,latnew(j)+delta_lat];
  polygon_lon2=[lonnew(j)-delta_lon,lonnew(j)+delta_lon,lonnew(j)+delta_lon,lonnew(j)-delta_lon,lonnew(j)-delta_lon];
  inside=inpolygon(lon,lat,polygon_lon2,polygon_lat2);
  indx=find(inside==1);
  grid_distance=distance('rh',lat(indx),lon(indx),latnew(j),lonnew(j),earthellipsoid,'degrees');
 
% find minimum distance
  grid_min_distance=min(min(grid_distance));
% index to the gridpoint with minimum distance
  grid_min_distance_indx=find(grid_distance==grid_min_distance);
  grid_min_distance_index(j)=indx(grid_min_distance_indx(1));
% do nearest neighbour interpolation
  if size(data,3)==1
    data_interp(j,:)=data(grid_min_distance_index(j),:);  
  elseif size(data,4)==1
    data_interp(j,:,:)=data(grid_min_distance_index(j),:,:);  
  end
 if (j/1000==floor(j/1000))||j==1
        disp([num2str(floor(j/length(latnew)*100)),' % ',num2str(floor(toc*(length(latnew)/j-1)/60)),' min left']);
 end
end
