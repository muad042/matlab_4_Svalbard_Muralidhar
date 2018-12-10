function [simulation_start_year,simulation_end_year]=CORDEX_check_timeperiod(scenario,start_year,end_year)

% PURPOSE
% find start and end date for chosen simulation
%
% INPUT
% model - model name
% scenario - name of simulation
% 
%
% Author: Asgeir Sorteberg, 
%         Geophysical Institute, University of Bergen.
%         email: asgeir.sorteberg@gfi.uib.no
% 
%         Jul 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

if (strcmp(scenario,'RCP26') | strcmp(scenario,'RCP45') |  strcmp(scenario,'RCP60') | strcmp(scenario,'RCP85'))
    simulation_start_year=2006;simulation_end_year=2100;
elseif (strcmp(scenario,'evaluation'))
    simulation_start_year=1981;simulation_end_year=2010;
elseif (strcmp(scenario,'historical') )
    simulation_start_year=1971;simulation_end_year=2000;
% if (start_year<simulation_start_year | end_year>simulation_end_year)
%  disp([ 'CORDEX_check_timeperiod: ERROR: Data for ' scenario ' scenario only availabe from ' num2str(simulation_start_year) '-' num2str(simulation_end_year)]); 
%   return;
% end 
end

if (strcmp(scenario,'historical') | strcmp(scenario,'OBS'))
  simulation_start_year=1971;simulation_end_year=2010;
  if (start_year<simulation_start_year | end_year>simulation_end_year)
    disp([ 'CORDEX_check_timeperiod: ERROR: Data for ' scenario ' scenario only availabe from ' num2str(simulation_start_year) '-' num2str(simulation_end_year)]); 
    return;
  end 
end
  