angle_data = rad2deg(angle_data);
Final_speed_data = zeros(150,1);
Assemble_voting_table = zeros(150,100);
range_tilt_angle_data = zeros(150,100);
linear_estimation_speed = zeros(150,1);
min_value = zeros(150,3);
mink3_speed_data = zeros(150,3);
voting_table_linear = zeros(150,100);

range_angle_data = zeros(150,1);
range_distance_data = zeros(150,1);
filtered_speed_data = zeros(150,100);
voting_table_truezone = zeros(150,100);
voting_table_dbscan = zeros(150,100);

idx = zeros(150,100) - 2;
pred_speed = zeros(150,1);
std_arr = zeros(150,1);
tilt =0;
tilt1 = deg2rad(tilt);

for t=1:150
        if t==1 || t==2 || t==3
        %% true zone code %
        range_tilt_angle_data_index = find(  angle_data(t,1:detected_target_data(t))<=deg2rad(90)-2*tilt1);
        range_tilt_angle_data_index_size = size(range_tilt_angle_data_index);
        range_tilt_angle_data(t,1:length(range_tilt_angle_data_index)) = angle_data(t,range_tilt_angle_data_index);
        range_angle_data(t,:) = mean(abs(range_tilt_angle_data(1: range_tilt_angle_data_index_size(2)) + tilt1 ));
        index_ang = find(abs(angle_data(t,1:detected_target_data(t)) + tilt1)<=abs(range_angle_data(t)));
        [row,col]=size(index_ang);
        filtered_data_before(t,1:col) = magnitude_data(t,index_ang);
        standard_mag = mean(filtered_data_before(t,1:col))-std(filtered_data_before(t,1:col));
        index_mag=find(filtered_data_before(t,1:col)>=standard_mag);
        [row2,col2] = size(index_mag);  
        filtered_data_after(t,1:col2) = filtered_data_before(t,index_mag);
            A = [];
            for k=1:col2
                index_final = find(magnitude_data(t,:)==filtered_data_after(t,k));
                A = [A ,index_final];
            end
            for i = A 
                filtered_speed_data(t,i) = speed_data(t,i);
                voting_table_truezone(t,A) = 1;
            end
            
        %% DBSCAN %%
        n = detected_target_data(t)
        X = transpose(speed_data(t,1:n))
        idx(t,1:n) = dbscan(X,2,2)
        if(sum(idx(t,1:n))==-2*n)
             voting_table_dbscan(t,:) = 0
           
        end
        if(sum(idx(t,1:n)) == -1*n)
             voting_table_dbscan(t,:) = 0
            
        end

        if(std_arr(t,1) >= 5)
        label = transpose(idx(t,1:n));
        df_table = table(X,label);
        df_table.in_index = transpose(linspace(1,length(X),length(X)));
        toDelete = (df_table.label == -1);
        df_table(toDelete,:) = []
        T_mean = groupsummary(df_table,"label","mean");
        T_mean.mean_X = abs(T_mean.mean_X - v_0);
        minimum_cluster_speed = min(T_mean.mean_X);
        rows = (T_mean.mean_X == minimum_cluster_speed);
        min_label = T_mean(rows,:).label;
        minimum_indexing = (df_table.label == min_label);
        min_real_index = df_table(minimum_indexing,:).in_index;
        voting_table_dbscan(t,min_real_index) = 1
        end

        if(std_arr(t,1) <5)
        label = transpose(idx(t,1:n));
        df_table = table(X,label);
        df_table.in_index = transpose(linspace(1,length(X),length(X)));
        toDelete = (df_table.label == -1);
        df_table(toDelete,:) = []
        label_percent = categorical(df_table.label);
        label_percent = tabulate(label_percent)
        A = zeros( length(label_percent(:,1)) ,1)
        
            for i = 1:length(label_percent(:,1))
                A(i,1) = label_percent{i,3}
            end
         [M,I]=max(A)
         max_percent_label = I ;
         toMean = (df_table.label == max_percent_label);
         pred_speed_index = df_table.in_index(toMean);
         voting_table_dbscan(t,pred_speed_index) = 1;
        end
        
        %% Voting %%
        Assemble_voting_table(t,:) = voting_table_truezone(t,:) + voting_table_dbscan(t,:);
        Assemble_index = find(Assemble_voting_table(t,:)>=max(Assemble_voting_table(t,:)));
        Assemble_index_size = size(Assemble_index);
        Assemble_speed(t,1:Assemble_index_size(2)) = speed_data(t,Assemble_index);
        Final_speed_data(t) = mean(Assemble_speed(t,1:Assemble_index_size(2)));
    
        continue
        end
    
        
    %% linear_regression_estimation_code %%
    evaluate_distance = zeros(1,detected_target_data(t));
    t_3 = t-3;
    t_2 = t-2;
    t_1 = t-1;
    t_0 = t;
    v_3 = Final_speed_data(t_3);
    v_2 = Final_speed_data(t_2);
    v_1 = Final_speed_data(t_1);
    

    x = [t_3,t_2,t_1];
    y = [v_3,v_2,v_1];
    x = transpose(x);
    y = transpose(y);
    X = [ones(length(x),1) x];
    b = X\y;
    
    m = b(2);
    n = b(1) ;
    v_0 = m*t_0 + n ;
    
    
    %% DBSCAN_CLASS %%
    
    n = detected_target_data(t)
    X = transpose(speed_data(t,1:n))
    idx(t,1:n) = dbscan(X,1,2)
    std_arr(t,1) = std(speed_data(t,1:n));
    if(sum(idx(t,1:n))==-2*n)
         voting_table_dbscan(t,:) = 0
    end
    if(sum(idx(t,1:n)) == -1*n)
         voting_table_dbscan(t,:) = 0
    end
    if(std_arr(t,1) >= 5)
        label = transpose(idx(t,1:n));
        df_table = table(X,label);
        df_table.in_index = transpose(linspace(1,length(X),length(X)));
        toDelete = (df_table.label == -1);
        df_table(toDelete,:) = []
        T_mean = groupsummary(df_table,"label","mean");
        T_mean.mean_X = abs(T_mean.mean_X - v_0);
        minimum_cluster_speed = min(T_mean.mean_X);
        rows = (T_mean.mean_X == minimum_cluster_speed);
        min_label = T_mean(rows,:).label;
        minimum_indexing = (df_table.label == min_label);
        min_real_index = df_table(minimum_indexing,:).in_index;
        voting_table_dbscan(t,min_real_index) = 1
        
    end
    if(std_arr(t,1) < 5)
        label = transpose(idx(t,1:n));
        df_table = table(X,label);
        df_table.in_index = transpose(linspace(1,length(X),length(X)));
        toDelete = (df_table.label == -1);
        df_table(toDelete,:) = []
        label_percent = categorical(df_table.label);
        label_percent = tabulate(label_percent)
        A = zeros( length(label_percent(:,1)) ,1)
        for i = 1:length(label_percent(:,1))
            A(i,1) = label_percent{i,3}
        end
         [M,I]=max(A)
         max_percent_label = I ;
         toMean = (df_table.label == max_percent_label);
         pred_speed_index = df_table.in_index(toMean);
         voting_table_dbscan(t,pred_speed_index) = 1
      end


    %% Now we have to estimate y value %%
    evaluate_distance = abs(speed_data(t,1:detected_target_data(t)) - v_0) ;
    min_value = mink(evaluate_distance,3);
    A=[];
    for k = 1:3
        min_index = find(evaluate_distance==min_value(k));
        A=[A min_index];
        size_A = size(A);
    end
    %% here, we voting each value in mink3_speed_data %%
    voting_table_linear(t,A) = 1;

    evaluate_distance = abs(speed_data(t,1:detected_target_data(t)) - v_0) ;
    min_value = mink(evaluate_distance,1);
    A=[];
    for k = 1
        min_index = find(evaluate_distance==min_value(k));
        A=[A min_index];
        size_A = size(A);
    end

    voting_table_linear(t,A) = voting_table_linear(t,A) + 1;
     

     
    %% True_zone_code %%
    range_tilt_angle_data_index = find(  angle_data(t,1:detected_target_data(t))<=deg2rad(90)-2*tilt1);
    range_tilt_angle_data_index_size = size(range_tilt_angle_data_index);
    range_tilt_angle_data(t,1:length(range_tilt_angle_data_index)) = angle_data(t,range_tilt_angle_data_index);
    range_angle_data(t,:) = mean(abs(range_tilt_angle_data(1: range_tilt_angle_data_index_size(2)) + tilt1 ));
    index_ang = find(abs(angle_data(t,1:detected_target_data(t)) + tilt1)<=abs(range_angle_data(t)));
    [row,col]=size(index_ang);
    filtered_data_before(t,1:col) = magnitude_data(t,index_ang);
    standard_mag = mean(filtered_data_before(t,1:col))-std(filtered_data_before(t,1:col));
    index_mag=find(filtered_data_before(t,1:col)>=standard_mag);
    [row2,col2] = size(index_mag);  
    filtered_data_after(t,1:col2) = filtered_data_before(t,index_mag);
    B = [];
    for k=1:col2
        index_final = find(magnitude_data(t,:)==filtered_data_after(t,k));
        B = [B ,index_final];
    end
    for i = B 
        filtered_speed_data(t,i) = speed_data(t,i);
        voting_table_truezone(t,B) = 1;
    end 

    

    %% Assemble voting table %%
    Assemble_voting_table(t,:) = voting_table_truezone(t,:) + voting_table_dbscan(t,:)+voting_table_linear(t,:);
    max_voted =max(Assemble_voting_table(t,:));
    Assemble_index = find(Assemble_voting_table(t,:)>=max_voted);
    Assemble_index_size = size(Assemble_index);
    Assemble_speed(t,1:Assemble_index_size(2)) = speed_data(t,Assemble_index);
    Final_speed_data(t) = mean(Assemble_speed(t,1:Assemble_index_size(2)));
end