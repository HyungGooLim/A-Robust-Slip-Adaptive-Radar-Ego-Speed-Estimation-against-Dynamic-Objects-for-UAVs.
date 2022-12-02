time_radar = linspace(1,150,150);
time_gps = linspace(1,150,150);
% speed_data = -1 * speed_data/cos(deg2rad(30));
% interp_GPS_Vel = transpose(interp1(time_gps,GPS_Vel,time_radar));
% smoothing start%
% yy1 = smooth(time_radar,pred_max_filter(:,1),0.1,'rlowess');


grid on;
plot(time_radar,GPS_Vel,'g');
hold on;
% plot(time_radar,up_range(:,1),'c');
% hold on;
% plot(time_radar,down_range(:,1),'c');
hold on;
plot(time_radar,Final_speed_data(:,1),'k');
hold on;
% plot(time_radar,yy1,'b');
scatter(time_radar,speed_data,'r');


ylim([-10,35]);
% RMSE_toal = sqrt(mean((GPS_Vel-Final_speed_data).^2));
RMSE_10_150 = sqrt(mean((GPS_Vel(10:150,:)-Final_speed_data(10:150,:)).^2));