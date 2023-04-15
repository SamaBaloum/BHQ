function X_row=extract_selcted_features(Date,accelerometer,activity_recognition,battery,bluetooth,calls,gyroscope,...
 light,location,screen_state,wireless)
X_row=zeros(1,26);
%Date=D;
%Date=dates{1};
cur_date=Date;
%wireless=raw(idx_wireless,:);
%% call sensor
count_calls=zeros(1,length(Date));
duration_calls=count_calls;
cur_calls=calls(cellfun(@(x) strcmp(x, cur_date), calls(:,5)),:);
count_calls = size(cur_calls,1);
if count_calls ~=0
    cur_calls_table=cell2table(cur_calls);
    writetable(cur_calls_table,'cur_calls.csv') ;
    T1 = readtable('cur_calls.csv','TreatAsEmpty',{'.','NA','NaN',''});
    T2 = fillmissing(T1,'nearest');
    cur_calls=table2cell(T2);
duration_calls = sum(cellfun(@(x) (x), cur_calls(:,9)));
cur_calls(:,11)=cellfun(@num2str, cur_calls(:,11), 'UniformOutput', false);
incoming = cur_calls(cellfun(@(x) strcmp(x, '1'), cur_calls(:,11)),:);
outgoing = cur_calls(cellfun(@(x) strcmp(x, '2'), cur_calls(:,11)),:);
missed=cur_calls(cellfun(@(x) strcmp(x, '3'), cur_calls(:,11)),:);
reject_user=cur_calls(cellfun(@(x) strcmp(x,'5'), cur_calls(:,11)),:);
X_row(1)=count_calls; % numbers of calls in a day
X_row(2)= duration_calls; % duration of calls in a day
X_row(3)=(size(incoming,1)/size(cur_calls,1))*100; % incoming precentage
X_row(4)=(size(outgoing,1)/size(cur_calls,1))*100;% outgoing precentage
X_row(5)=(size(missed,1)/size(cur_calls,1))*100; % missed precentage
%X_row(6)=(size(reject_user,1)/size(cur_calls,1))*100; % reject user precentage
else 
    X_row(1)=0;
    X_row(2)=0;
    X_row(3)=0;
    X_row(4)=0;
    X_row(5)=0;
    %X_row(6)=0;
end
%% WIFI -Date=D;
count_wifi=zeros(1,length(Date));
wifi_strength=zeros(1,length(Date));
cur_wifi=wireless(cellfun(@(x) strcmp(x, cur_date), wireless(:,5)),:);
count_wifi = size(cur_wifi,1);
if count_wifi ~=0
    cur_wifi_table=cell2table(cur_wifi);
    writetable(cur_wifi_table,'cur_wifi.csv') ;
    T3 = readtable('cur_wifi.csv','TreatAsEmpty',{'.','NA','NaN'});
    T4 = fillmissing(T3,'nearest');
    cur_wifi=table2cell(T4);
    cur_wifi(:,9)=cellfun(@num2str, cur_wifi(:,9), 'UniformOutput', false);
    wifi_strength = mean(cellfun(@(x) abs(str2double(x)), cur_wifi(:,9)));
wifi_suuid=cellfun(@(x) strcmp(x, 'Not found'), cur_wifi(:,8));
X_row(6)=count_wifi; % numbers of use of wifi in a day
%X_row(8)=wifi_strength; % mean strength in a day
X_row(7)=(size(wifi_suuid(wifi_suuid==1))/size(wifi_suuid))*100; % 'Not found' precntage in a day
else 
    X_row(6)=0;
    %X_row(8)=NaN;
    X_row(7)=0;
end
%% Bluetooth -Date=D;
count_bluetooth=zeros(1,length(Date));
bluetooth_strength=zeros(1,length(Date));
cur_bluetooth=bluetooth(cellfun(@(x) strcmp(x, cur_date), bluetooth(:,5)),:);
count_bluetooth = size(cur_bluetooth,1);
if count_bluetooth ~=0
    cur_bluetooth_table=cell2table(cur_bluetooth);
    writetable(cur_bluetooth_table,'cur_bluetooth.csv') ;
    T5 = readtable('cur_bluetooth.csv','TreatAsEmpty',{'.','NA','NaN'});
    T6 = fillmissing(T5,'nearest');
    cur_bluetooth=table2cell(T6);
cur_bluetooth(:,9)=cellfun(@num2str, cur_bluetooth(:,9), 'UniformOutput', false);
bluetooth_strength = mean(cellfun(@(x) abs(str2double(x)), cur_bluetooth(:,9)));
bluetooth_suuid=cellfun(@(x) strcmp(x, 'Not found'), cur_bluetooth(:,8));
bluetooth_state=cellfun(@(x) strcmp(x, 'on'), cur_bluetooth(:,10));
X_row(8)=count_bluetooth; % numbers of use of bluetooth in a day
%X_row(11)=bluetooth_strength; % mean bluetooth strength in a day
X_row(9)=(size(bluetooth_suuid(bluetooth_suuid==1))/size(bluetooth_state))*100; % 'Not found' precntage in a day
X_row(10)=(size(bluetooth_state(bluetooth_state==1))/size(bluetooth_state))*100;% 'on' precntage in a day
else 
    X_row(8)=0;
    %X_row(11)=NaN;
    X_row(9)=0;
    X_row(10)=0;
end
%% Location -Date=D;
count_location=zeros(1,length(Date));
location_distance=zeros(1,length(Date));
cur_location=location(cellfun(@(x) strcmp(x, cur_date), location(:,5)),:);
count_location = size(cur_location,1);
if count_location ~=0
    cur_location_table=cell2table(cur_location);
    writetable(cur_location_table,'cur_location.csv') ;
    T7 = readtable('cur_location.csv','TreatAsEmpty',{'.','NA','NaN'});
    T8 = fillmissing(T7,'nearest');
    cur_location=table2cell(T8);
location_state=cellfun(@(x) strcmp(x, 'on'), cur_location(:,10));
%X_row(12)=count_location; % numbers of use of location in a day
X_row(11)=(size(location_state(location_state==1))/size(location_state))*100;% 'on' precntage in a day
else 
    %X_row(12)=0;
    X_row(11)=0;
end
%% Light -Date=D;
count_light=zeros(1,length(Date));
light_strength=zeros(1,length(Date));
cur_light=light(cellfun(@(x) strcmp(x, cur_date), light(:,5)),:);
count_light = size(cur_light,1);
if count_light ~=0
    cur_light_table=cell2table(cur_light);
    writetable(cur_light_table,'cur_light.csv') ;
    T9 = readtable('cur_light.csv','TreatAsEmpty',{'.','NA','NaN'});
    T10 = fillmissing(T9,'nearest');
    cur_light=table2cell(T10);
cur_light(:,9)=cellfun(@num2str, cur_light(:,9), 'UniformOutput', false);
light_level = mean(cellfun(@(x) str2double(x), cur_light(:,9)));
%X_row(14)=count_light; % numbers of use of light in a day
X_row(12)=light_level; % mean light strength in a day
else 
 % X_row(14)=0; 
  X_row(12)=0; 
end
%% Accelerometer -Date=D;'acelerometer'
count_accelerometer=zeros(1,length(Date));
cur_accelerometer=accelerometer(cellfun(@(x) strcmp(x, cur_date), accelerometer(:,5)),:);
count_accelerometer = size(cur_accelerometer,1);
if count_accelerometer ~=0
    cur_accelerometer_table=cell2table(cur_accelerometer);
    writetable(cur_accelerometer_table,'cur_accelerometer.csv') ;
    T11 = readtable('cur_accelerometer.csv','TreatAsEmpty',{'.','NA','NaN'});
    T12 = fillmissing(T11,'nearest');
    cur_accelerometer=table2cell(T12);
    cur_accelerometer(:,12)=cellfun(@num2str, cur_accelerometer(:,12), 'UniformOutput', false);
    cur_accelerometer(:,13)=cellfun(@num2str, cur_accelerometer(:,13), 'UniformOutput', false);
    cur_accelerometer(:,14)=cellfun(@num2str, cur_accelerometer(:,14), 'UniformOutput', false);
acc_x=cellfun(@(x) str2double(x), cur_accelerometer(:,12));
acc_y=cellfun(@(x) str2double(x), cur_accelerometer(:,13));
acc_z=cellfun(@(x) str2double(x), cur_accelerometer(:,14));
X_row(13)= mean(sqrt(acc_x.^2 +acc_y.^2+acc_z.^2));%accelerometer_energy
%X_row(17)=sum(acc_z); 
X_row(14)=std(acc_x)+std(acc_y)+std(acc_z); % standard deviation in 3 axises 
X_row(15)=mean(real(ifft(fft(acc_y))));
else
X_row(13)= 0;
%X_row(17)= 0;
X_row(14)= 0;
X_row(15)=0;
end
%% Gyroscope -Date=D;'acelerometer'
count_gyroscope=zeros(1,length(Date));
cur_gyroscope=gyroscope(cellfun(@(x) strcmp(x, cur_date), gyroscope(:,5)),:);
count_gyroscope = size(cur_gyroscope,1);
if count_gyroscope ~=0
    cur_gyroscope_table=cell2table(cur_gyroscope);
    writetable(cur_gyroscope_table,'cur_gyroscope.csv') ;
    T13 = readtable('cur_gyroscope.csv','TreatAsEmpty',{'.','NA','NaN'});
    T14 = fillmissing(T13,'nearest');
    cur_gyroscope=table2cell(T14);
    cur_gyroscope(:,12)=cellfun(@num2str, cur_gyroscope(:,12), 'UniformOutput', false);
    cur_gyroscope(:,13)=cellfun(@num2str, cur_gyroscope(:,13), 'UniformOutput', false);
    cur_gyroscope(:,14)=cellfun(@num2str, cur_gyroscope(:,14), 'UniformOutput', false);
gyro_x=cellfun(@(x) str2double(x), cur_gyroscope(:,12));
gyro_y=cellfun(@(x) str2double(x), cur_gyroscope(:,13));
gyro_z=cellfun(@(x) str2double(x), cur_gyroscope(:,14));
X_row(16)= mean(sqrt(gyro_x.^2 +gyro_y.^2+gyro_z.^2));%Gyroscope_energy
X_row(17)=median(gyro_y); 
X_row(18)=mean(gyro_x)+mean(gyro_y)+mean(gyro_z); 
X_row(19)=mean(real(ifft(fft(gyro_z))));
else
    X_row(16)=0;
    X_row(17)=0;
    X_row(18)=0;
    X_row(19)=0;
end
%% Battery 
count_battery=zeros(1,length(Date));
battery_level=zeros(1,length(Date));
cur_battery=battery(cellfun(@(x) strcmp(x, cur_date), battery(:,5)),:);
count_battery = size(cur_battery,1);
if count_battery ~=0
    cur_battery_table=cell2table(cur_battery);
    writetable(cur_battery_table,'cur_battery.csv') ;
    T15 = readtable('cur_battery.csv','TreatAsEmpty',{'.','NA','NaN'});
    T16 = fillmissing(T15,'nearest');
    cur_battery=table2cell(T16);
    cur_battery(:,9)=cellfun(@num2str, cur_battery(:,9), 'UniformOutput', false); 
battery_level = mean(cellfun(@(x) str2double(x), cur_battery(:,9)));
battery_state=cellfun(@(x) strcmp(x, 'on'), cur_battery(:,10));
%X_row(24)=count_battery; % numbers of use of battery in a day
X_row(20)=battery_level; % mean level in a day
X_row(21)=(size(battery_state(battery_state==1))/size(battery_state))*100;% 'on' precntage in a day
else 
    %X_row(24)=NaN; 
    X_row(20)=NaN; 
    X_row(21)=NaN;
end
%% screen state -Date=D;
count_screen_state=zeros(1,length(Date));
cur_screen_state=screen_state(cellfun(@(x) strcmp(x, cur_date), screen_state(:,5)),:);
count_screen_state = size(cur_screen_state,1);
if count_screen_state ~=0
    cur_screen_state_table=cell2table(cur_screen_state);
    writetable(cur_screen_state_table,'cur_screen_state.csv') ;
    T17 = readtable('cur_screen_state.csv','TreatAsEmpty',{'.','NA','NaN'});
    T18 = fillmissing(T17,'nearest');
    cur_screen_state=table2cell(T18);
screen_state_state=cellfun(@(x) strcmp(x, 'on'), cur_screen_state(:,9));
X_row(22)=count_screen_state; % numbers of use of screen_state in a day
X_row(23)=(size(screen_state_state(screen_state_state==1))/size(screen_state_state))*100;% 'on' precntage in a day
else
    X_row(22)=NaN;
    X_row(23)=NaN;
end
%% activity_recognition
count_activity_recognition=zeros(1,length(Date));
cur_activity_recognition=activity_recognition(cellfun(@(x) strcmp(x, cur_date), activity_recognition(:,5)),:);
count_activity_recognition = size(cur_activity_recognition,1);
if count_activity_recognition ~=0
    cur_activity_recognition_table=cell2table(cur_activity_recognition);
    writetable(cur_activity_recognition_table,'cur_activity_recognition.csv') ;
    T19 = readtable('cur_activity_recognition.csv','TreatAsEmpty',{'.','NA','NaN'});
    T20 = fillmissing(T19,'nearest');
    cur_activity_recognition=table2cell(T20);
cur_activity_recognition(:,10)=cellfun(@num2str, cur_activity_recognition(:,10), 'UniformOutput', false); 
activity_recognition_status = mean(cellfun(@(x) str2double(x), cur_activity_recognition(:,10)));
STILL = cur_activity_recognition(cellfun(@(x) strcmp(x, 'STILL'), cur_activity_recognition(:,11)),:);
TILTING = cur_activity_recognition(cellfun(@(x) strcmp(x, 'TILTING'), cur_activity_recognition(:,11)),:);
IN_VEHICLE=cur_activity_recognition(cellfun(@(x) strcmp(x, 'IN_VEHICLE'), cur_activity_recognition(:,11)),:);
ON_FOOT=cur_activity_recognition(cellfun(@(x) strcmp(x, 'ON_FOOT'), cur_activity_recognition(:,11)),:);
%X_row(29)=count_activity_recognition; % numbers of activity in a day
%X_row(30)=activity_recognition_status; % mean Activity in a day
%X_row(31)=size(STILL,1)/size(cur_activity_recognition,1);% Still precentage
X_row(24)=size(TILTING,1)/size(cur_activity_recognition,1);%Tilting precentage
X_row(25)=size(IN_VEHICLE,1)/size(cur_activity_recognition,1); %In Vehicle precentage
X_row(26)=size(ON_FOOT,1)/size(cur_activity_recognition,1);%ON_FOOT precentage
else
    %X_row(29)=0;
    %X_row(30)=0;
    %X_row(31)=0;
    X_row(24)=0;
    X_row(25)=0;
    X_row(26)=0;
end
end
