function [CORDEX_lat,CORDEX_lon,CORDEX_lat_grid,CORDEX_lon_grid,CORDEX_ser_time,CORDEX_time_calendar,CORDEX_data,CORDEX_data_longname,CORDEX_data_unit]...
   =CORDEX_read_time_area_slice_v2(CORDEX_var,CORDEX_directory,CORDEX_files,CORDEX_files_flag,start_year,end_year,polygon_lon,polygon_lat)

% PURPOSE
%  read CORDEX data for chosen region and for chosen period 
%
%
% INPUT
%
%    CORDEX_var Name of Parameter
%                prmsl: mean sea level pressure
%                etc. etc.
%
%    CORDEX_lev_var Name of vertical coordinate parameter
%                plev: pressure levels
%                etc. etc.
%
%    CORDEX_directory - directory to the original data
%
% CORDEX_files: name of files to be rad (array: CORDEX_files(no of files,length filenames)
%              Ex:  CORDEX_files=['ta_Amon_NorESM1-M_historical_r1i1p1_185001-194912.nc'; 'ta_Amon_NorESM1-M_historical_r1i1p1_195001-200512.nc']
%
% CORDEX_files_flag: flag if file is to be read or not (vector (CORDEX_files_flag(no of files)
%                    0: do not read the file
%                    1: read the file
%                   Example:  read both files: CORDEX_files_flag=[1 1];
%
% CORDEX_start_year - Start year
% CORDEX_end_year - End year
%                   Note: all data between start and end year will be
%                   selected
%        
% 
%
%  nw_corner - north-west corner vector [lon lat] for data to be chosen
%              NOTE: data with longitude 0 -> 360 will be changed to -180 -> 180
%              therefore nw_corner should be negative if it indicates west of 
%              Greenwich 
%  se_corner - south-east corner vector [lon lat] for data to be chosen 
%              NOTE: data with longitude 0 -> 360 will be changed to -180 -> 180
%              therefore nw_corner should be negative if it indicates west of
%              Greenwich 
%
% polygon defined by 5 points   [lon4 lat4] --> X-------------X [lon3 lat3]
%                                               |             |
%                                               |Returned data|
%                                               |             |
%                  [lon1 lat1]=[lon5 lat5] -->  X-------------X [lon2 lat2]
%
%
%  NOTE: Does not work over the dateline (for. ex 170 (E) to -170 (W) will not work.
%
%
% CORDEX_start_level - selected first vertical level to read 
%                     (number from 1 to max levels in the file)
%                     Ex: reana_levels=2 is the first second pressure level 
%                     from the ground.
%
% CORDEX_end_level - selected last vertical level to read 
%                  (number from 1 to max levels in the file)
% 
%
%
% OUTPUT
%
% CORDEX_lat and CORDEX_lon -  latitude and longitude data (as vector, eg, CORDEX_lat(gridpnts))
%
% CORDEX_levels -  selected vertical levels(as vector, eg, CORDEX_levels(no. levels))
% CORDEX_lev_longname -  original long name for data variable chosen (characters)
% CORDEX_lev_unit    -  original unit for data variable chosen (characters)
%
% CORDEX_ser_time    -  time in serial time  (in UTC) that can be used by 
%                     the matlab functions datestr,datevec and datenum
%                Note: for this time to be correct original data must follow 
%                      the gregorian calendar  (since this is the only 
%                      thing matlab  understands)
%
% CORDEX_time_calendar - calendar for time indication 
%
% CORDEX_data        -  original 6 hourly reanalysis data as matrix (as 3D 
%                     matrices, eg, CORDEX_data(times X ens. members X gridpnts)). 
%
% CORDEX_data_longname -  original long name for data variable chosen (characters)
% CORDEX_data_unit    -  original unit for data variable chosen (characters)
%
% Ex: read surface temperature data for for 1871-1872 for the region 60W-40E and 30-90N
% [CORDEX_lat,CORDEX_lon,CORDEX_ser_time,CORDEX_time_calendar,CORDEX_data,CORDEX_data_longname,CORDEX_data_unit]=CORDEX_read_time_area_slice('tas',CORDEX_directory,CORDEX_files,CORDEX_files_flag,1871,1872,[-60 90],[40  30])
%
% USES: CORDEX_time_fix.m
%
% MATLAB REQUIREMENTS
% Charles R. Denham's NetCDF Toolbox (http://crusty.er.usgs.gov/~cdenham/MexCDF/)
% CSIRO matlab/netCDF Interface (http://www.marine.csiro.au/sw/matlab-netcdf.html)
% 
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul. 2011
% modified for Euro-CORDEX by Stephanie Mayer
% Aug 2014
%
% Modified for Arctic CORDEX (Jan. 2018) - Muralidhar
% (Reason: The default version had a bug related to the rotation of the
% metadata towards the end of the script. This bug led to an inappropriate
% projection of the data while plotting.) 
% FIX: We don't need to rotate the metadata at all for the Arctic CORDEX data !
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Actual start of the function
[CORDEX_no_files,CORDEX_files]=CORDEX_filelist(CORDEX_directory);
[CORDEX_files_flag]=CORDEX_file_flag(CORDEX_directory,CORDEX_files,start_year,end_year);

no_files=size(CORDEX_files,1);

% files to read
count=0;
for i=1:no_files
    if CORDEX_files_flag(i)==1
        count=count+1;
        CORDEX_file(count,:)=CORDEX_files(i,:);
    end
end

if count==0
    disp('CORDEX_read_time_area_slice: ERROR No files found for selected period')
    disp('CORDEX_read_time_area_slice:       Existing files:')
    disp(CORDEX_files)

end

% loop over all files that should be read
no_files=size(CORDEX_file,1);

for i=1:no_files

% file to read
   CORDEX_ncfile=[CORDEX_directory deblank(CORDEX_file(i,:))];
   
   if i==1
% fix lat and lon     
     disp('CORDEX_read_time_area_slice: Reading latitude, longitude')
     CORDEX_lat=getnc(CORDEX_ncfile,'lat');
     CORDEX_lon=getnc(CORDEX_ncfile,'lon');
          
% Muralidhar - if the grid is rectangular, make a meshgrid 
     if ( (size(CORDEX_lon,1) == 1 && size(CORDEX_lat,1) == 1) || ...
          (size(CORDEX_lon,2) == 1 && size(CORDEX_lat,2) == 1) )   
     
          disp('The data is on a rectilinear grid. Formatting ...')
          model_grid = 'rectilinear';
          [xlon,xlat] = meshgrid(CORDEX_lon,CORDEX_lat);
          clear CORDEX_lon CORDEX_lat
          CORDEX_lon = xlon; CORDEX_lat = xlat;
     else
         model_grid = 'curvilinear';
     end
     
% find area inside the chosen polygon
     inside=inpolygon(CORDEX_lon,CORDEX_lat, polygon_lon, polygon_lat);
     [indx_area_I,indx_area_J]=find(inside);

     start_pnt_X=min(indx_area_J);
     start_pnt_X=start_pnt_X(1);
     end_pnt_X=max(indx_area_J);
     end_pnt_X=end_pnt_X(1);
     
     start_pnt_Y=min(indx_area_I);
     start_pnt_Y=start_pnt_Y(1);
     end_pnt_Y=max(indx_area_I);
     end_pnt_Y=end_pnt_Y(1);

     %% read lon/lat region
     if ( strcmp(model_grid,'rectilinear') )   
            
             clear xlon xlat
             xlon = CORDEX_lon(CORDEX_lon>=CORDEX_lon(start_pnt_Y,start_pnt_X) & CORDEX_lon <= CORDEX_lon(end_pnt_Y,end_pnt_X));
             if (CORDEX_lat(start_pnt_Y,start_pnt_X) > CORDEX_lat(end_pnt_Y,end_pnt_X))  % if the data starts from the north pole
                lat_dir ='np2sp'; 
                xlat = CORDEX_lat(CORDEX_lat<=CORDEX_lat(start_pnt_Y,start_pnt_X) & CORDEX_lat >= CORDEX_lat(end_pnt_Y,end_pnt_X));
             else
                lat_dir = 'sp2np'; 
                xlat = CORDEX_lat(CORDEX_lat>=CORDEX_lat(start_pnt_Y,start_pnt_X) & CORDEX_lat <= CORDEX_lat(end_pnt_Y,end_pnt_X)); 
             end   
             CORDEX_lon1 = unique(xlon);
             CORDEX_lat1 = unique(xlat);
     else        
            CORDEX_lon1=getnc(CORDEX_ncfile,'lon',[start_pnt_Y start_pnt_X],[end_pnt_Y end_pnt_X]);
            CORDEX_lat1=getnc(CORDEX_ncfile,'lat',[start_pnt_Y start_pnt_X],[end_pnt_Y end_pnt_X]);
     end
     
     disp(['CORDEX_read_time_area_slice: Parameter to read: ' CORDEX_var])
    
%    find longname
     [att_lname, att_names] = attnc(CORDEX_ncfile,CORDEX_var,'standard_name');
     if isempty(att_lname)
       CORDEX_data_longname= ' ';
     else  
       CORDEX_data_longname= att_lname; 
     end
     
% find units as text strings
     [att_val, att_names] = attnc(CORDEX_ncfile,CORDEX_var,'units');
     if isempty(att_val)
       CORDEX_data_unit= ' ';
     else  
       CORDEX_data_unit= att_val; 
     end
   end
   
% read time
   [gregorian_time,CORDEX_ser_time1]=timenc(CORDEX_ncfile,'time');
   
%    find calendar
     [att_lname, att_names] = attnc(CORDEX_ncfile,'time','calendar');
     if isempty(att_lname)
       CORDEX_time_calendar= ' ';
     else  
       CORDEX_time_calendar= att_lname; 
     end
     if i==1
         disp(['CORDEX_read_time_area_slice: NOTE: Calendar used: ' CORDEX_time_calendar])
     end
     
% read data
  if i==1
      disp(['CORDEX_read_time_area_slice: Reading the data may take some time ...'])
  end
    
     CORDEX_data1=getnc(CORDEX_ncfile,CORDEX_var,[-1 start_pnt_Y start_pnt_X],[-1 end_pnt_Y end_pnt_X]);
     
%     % check if there is one or several times on the file    
     if ndims(CORDEX_data1)==2
         CORDEX_data1=reshape(CORDEX_data1,1,size(CORDEX_data1,1)*size(CORDEX_data1,2));
     else
        CORDEX_data1=reshape(CORDEX_data1,size(CORDEX_data1,1),size(CORDEX_data1,2)*size(CORDEX_data1,3));
     end   
    
% put data for all days in one array
  if i==1
    CORDEX_data=CORDEX_data1; 
    CORDEX_ser_time=CORDEX_ser_time1';
  else
      endindx1=size(CORDEX_data,1);
      endindx2=size(CORDEX_data1,1);
      CORDEX_data(endindx1+1:endindx1+endindx2,:)=NaN;
      CORDEX_data(endindx1+1:end,:)=CORDEX_data1; 
      CORDEX_ser_time=[CORDEX_ser_time CORDEX_ser_time1'];
  end

   % clean up
   clear CORDEX_data1 CORDEX_ser_time1 
  
% end big loop over all years
end

% % as we have gone from lon being 0-360 to -180 to 180 we 
% % sort the data for easier plotting
disp('CORDEX_read_time_area_slice: Sorting the data ...')
if ( strcmp(model_grid,'rectilinear') )  
    [xx,yy] = meshgrid(CORDEX_lon1,CORDEX_lat1);
    [y_dim,x_dim]=size(xx);
else    
    [y_dim,x_dim]=size(CORDEX_lon1);
end    
t_dim=size(CORDEX_data,1);

% We want the dimension of the data before interpolation to test -
% Muralidhar
CORDEX_lat_grid = y_dim;
CORDEX_lon_grid = x_dim;

CORDEX_data=reshape(CORDEX_data,t_dim,y_dim,x_dim);
if ( strcmp(model_grid,'rectilinear') && strcmp(lat_dir,'np2sp') )  
   disp('We are on a rectilinear grid, arranged from np to sp. Flipping upside down.') 
   CORDEX_data = flip(CORDEX_data,2);
end   

%CORDEX_lon=CORDEX_lon1;
%CORDEX_lat=CORDEX_lat1;

%sort times since they may not be in correct order as we have not
%nessecarily read the file in correct order

[dummy,indx_sort]=sort(CORDEX_ser_time);
CORDEX_ser_time=CORDEX_ser_time(indx_sort);
CORDEX_data=CORDEX_data(indx_sort,:,:);

% ---------------------
% Fix dates if the model has a 360 day calendar
% ---------------------
% output frequency
frequency=CORDEX_ser_time(2)-CORDEX_ser_time(1);
if frequency<=1 
    if strcmp(deblank(lower(CORDEX_time_calendar)),'360_day') || ...
       strcmp(deblank(lower(CORDEX_time_calendar)),'360_days') || ...
       strcmp(deblank(lower(CORDEX_time_calendar)),'360 day') || ...
       strcmp(deblank(lower(CORDEX_time_calendar)),'360 days') 
    
       [CORDEX_ser_time_new]=CORDEX_time_fix(CORDEX_ser_time);
       CORDEX_ser_time=CORDEX_ser_time_new;
    end 
end

% remove duplicate times 
% For example in HADGEM-ES Dec 2099 in the rcp85 scenario 
% is in two different files ...
if length(unique(CORDEX_ser_time))~=length(CORDEX_ser_time)
    [dummy,indx1,dummy2]=unique(CORDEX_ser_time);
    [dummy,indx2]=setdiff(1:1:length(CORDEX_ser_time),indx1);
    disp('CORDEX_read_time_area_slice: WARNING: There are duplicate times')
    disp('CORDEX_read_time_area_slice:          Removing: ')
    disp(datestr(CORDEX_ser_time(indx2)))
    disp('CORDEX_read_time_area_slice:          which occure several times')
    CORDEX_ser_time=CORDEX_ser_time(indx1);
    t_dim=t_dim-length(indx2);
    CORDEX_data=CORDEX_data(indx1,:,:);
end

     
% Make sure data begins and ends at right dates
[yyyy,mm,dd,mi,ss]=datevec(CORDEX_ser_time);

indx=find(yyyy>=start_year & yyyy<=end_year);
CORDEX_ser_time=CORDEX_ser_time(indx);
CORDEX_data=CORDEX_data(indx,:,:);
disp(['latitude dims = ' num2str(size(CORDEX_lat1)) '; longitude dims = ' num2str(size(CORDEX_lon1))]) 

CORDEX_lat=reshape(CORDEX_lat1,[],1);
CORDEX_lon=reshape(CORDEX_lon1,[],1);      

disp('CORDEX_read_time_area_slice: Finished')

