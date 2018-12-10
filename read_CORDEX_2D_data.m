function [CORDEX_lat,CORDEX_lon,CORDEX_lat_grid,CORDEX_lon_grid,CORDEX_ser_time,CORDEX_time_calendar,CORDEX_time_check_flag,CORDEX_data,CORDEX_data_longname,CORDEX_data_unit,CORDEX_start_year,CORDEX_end_year]...
          =read_CORDEX_2D_data(CORDEX_directory,scenario,CORDEX_var,frequency,GCMs,start_year,end_year,polygon_lon,polygon_lat)
%                                                                                                                                                                                                    
% PURPOSE
% 
% read CORDEX data from chosen scenario and model and make 
% gridpoint means over chosen timeperiod 
%
% INPUT
%
% CORDEX_var: Any CORDEX data variable name
%            The list is here: http://cmip-pcmdi.llnl.gov/CORDEX/data_description.html
%            Examples
%                 tas: 2m temperature
%                  pr: Precipitation
%                           
% scenario

%           historical      
%           rcp45  
%           rcp85 
%           rcp26  
%
% model_run: ensemble member identifier 
%            Example: r1i1p1 etc.
%            
%
%  frequency  - Frequency of outpout
%               day: daily
%
%  start_year - Start year for data that should be read (must be between 1958 and 2002) 
%  end_year   - End year for data that should be read (must be between 1958 and 2002)   
%
% nw_corner - north-west corner vector [lon lat] for data to be chosen
%             NOTE: data with longitude 0 -> 360 will be changed to -180 -> 180
%             therefore nw_corner should be negative if it indicates west of
%             Greenwich
% se_corner - south-east corner vector [lon lat] for data to be chosen
%             NOTE: data withlongitude 0 -> 360 will be changed to -180 -> 180
%             therefore nw_corner should be negative if it indicates west of
%             Greenwich
% polygon defined by 5 points   [lon4 lat4] --> X-------------X [lon3 lat3]
%                                               |             |
%                                               |Returned data|
%                                               |             |
%                  [lon1 lat1]=[lon5 lat5] -->  X-------------X [lon2 lat2]
%
%
% OUTPUT:
% CORDEX_lat
% CORDEX_lon
% CORDEX_ser_time
% CORDEX_time_calendar
% CORDEX_time_check_flag
% CORDEX_data
% CORDEX_data_longname
% CORDEX_data_unit
% CORDEX_start_year
% CORDEX_end_year
%
% EXAMPLES pick daily DMI tas from the third ensenmble member
% of the historical period 1951 to 1955
%
% USE
%     CORDEX_check_timeperiod.m CORDEX_filelist.m CORDEX_file_flag.m 
%     CORDEX_read_time_area_slice.m
%
% MATLAB REQUIREMENTS
% Charles R. Denham's NetCDF Toolbox (http://crusty.er.usgs.gov/~cdenham/MexCDF/)
% CSIRO matlab/netCDF Interface (http://www.marine.csiro.au/sw/matlab-netcdf.html)
% 
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
% modified for Euro-CORDEX by Stephanie Mayer
% Aug 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% disp([ 'read_CORDEX_2D_data:  GCM: ' GCM(1,:)])

% ---------------------
% check of selected years are inside possible range
% ---------------------
[simulation_start_year,simulation_end_year]=CORDEX_check_timeperiod(scenario,start_year,end_year);

% ---------------------
% get list of files for chosen model, simulation etc
% ---------------------
[CORDEX_no_files,CORDEX_files]=CORDEX_filelist(CORDEX_directory);

if CORDEX_no_files==0
    disp('read_CORDEX_2D_data:  No data found')
    CORDEX_lat=NaN;
    CORDEX_lon=NaN;
    CORDEX_ser_time=NaN;
    CORDEX_data=NaN;
    CORDEX_data_longname='';
    CORDEX_data_unit='';
    return
end

% ---------------------
% check which files are needed to have data for the chosen years
% ---------------------
[CORDEX_files_flag]=CORDEX_file_flag(CORDEX_directory,CORDEX_files,start_year,end_year);

if sum(CORDEX_files_flag)==0
    disp('read_CORDEX_2D_data:  No data found')
    CORDEX_lat=NaN;
    CORDEX_lon=NaN;
    CORDEX_ser_time=NaN;
    CORDEX_data=NaN;
    CORDEX_data_longname='';
    CORDEX_data_unit='';
    return
end

% ---------------------
% Read the data for chosen times and region
% ---------------------
[CORDEX_lat,CORDEX_lon,CORDEX_lat_grid,CORDEX_lon_grid,CORDEX_ser_time,CORDEX_time_calendar,CORDEX_data,CORDEX_data_longname,CORDEX_data_unit]...
    =CORDEX_read_time_area_slice(CORDEX_var,CORDEX_directory,CORDEX_files,CORDEX_files_flag,start_year,end_year,polygon_lon,polygon_lat);

% ---------------------
% Check that you have data for the whole period requested
% ---------------------
[CORDEX_time_check_flag]=CORDEX_time_check(CORDEX_ser_time,CORDEX_time_calendar,start_year,end_year,frequency);

% start and end year
    CORDEX_start_year=str2double(datestr(CORDEX_ser_time(1),10));
    CORDEX_end_year=str2double(datestr(CORDEX_ser_time(end),10));
% added by Steffi....    
    CORDEX_data=reshape(CORDEX_data,length(CORDEX_ser_time),1,[]);
    CORDEX_data=squeeze(CORDEX_data);
    
%%%%%%%%%%%%%%%%%%%%%%%    
    disp('read_CORDEX_2D_data:  Finished')
    disp(' ')
    disp(' ')
    