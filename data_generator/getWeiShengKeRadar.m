function [frmData,carSignals] = getWeiShengKeRadar(raw_data)
%处理为升科角雷达数据---解放车

[m1,~] = size(raw_data.ObstacleStatus__NumberOfObstacles);
frmData = repmat(obstacle_const.FrameData,m1,1);
% 摄像头不同目标之间时间对齐
 cnt = zeros(32,1);
 num_max = max(raw_data.ObstacleStatus__NumberOfObstacles(:,2));
    for j = 1:num_max
        obj_ID = strcat('Obstacle',num2str(j-1),"DataA__Obstacle_ID");
         [k1,~] = size(raw_data.(obj_ID));
       if k1 == m1
          continue
       else
        obj_ID = strcat('Obstacle',num2str(j-1),"DataA__Obstacle_ID");
        obj_y = strcat('Obstacle',num2str(j-1),"DataA__ObstaclePositionY");
        obj_x = strcat('Obstacle',num2str(j-1),"DataA__ObstaclePositonX");
        obj_cls = strcat('Obstacle',num2str(j-1),"DataA__ObstacleType");
        vleo_x = strcat('Obstacle',num2str(j-1),"DataA__ObstacleRelativeVelocityX");
        obj_width = strcat('Obstacle',num2str(j-1),"DataB__ObstacleWidth");
        obj_y_arel = strcat('Obstacle',num2str(j-1),"DataC__ObstacleAccelX");
        obj_of_lane = strcat('Obstacle',num2str(j-1),"DataB__ObstacleLane");
        ID = zeros(m1,2);
        y = zeros(m1,2);
        x = zeros(m1,2);
        cls = zeros(m1,2);
        vx = zeros(m1,2);
        width = zeros(m1,2);
        ay = zeros(m1,2);
        ObstacleLane = zeros(m1,2);
        for k = 1:m1-1
            [n,~]=find(raw_data.ObstacleStatus__NumberOfObstacles(:,2)<=j-1);
            for k1=1:length(n)
                if k==n(k1)
                   cnt(j)=cnt(j)+1;
                    ID(k,1) = 0;         ID(k,2) = 0;
                    y(k,1) =  0;         y(k,2) =  0;
                    x(k,1) =  0;         x(k,2) =  0;
                    cls(k,1) =  0;       cls(k,2) =  0;
                    vx(k,1) =  0;        vx(k,2) =  0;
                    width(k,1) =  0;        width(k,2) =  0;
                    ay(k,1) =  0;        ay(k,2) =  0;
                    ObstacleLane(k,1) =  0;   ObstacleLane(k,2) =  0;
                   break
                elseif k-cnt(j)<=length(raw_data.(obj_ID)(:,2))
                    ID(k,2) = raw_data.(obj_ID)(k-cnt(j),2);
                    ID(k,1) = raw_data.(obj_ID)(k-cnt(j),1);
                    y(k,2) =  raw_data.(obj_y)(k-cnt(j),2);
                    y(k,1) =  raw_data.(obj_y)(k-cnt(j),1);
                    x(k,2) =  raw_data.(obj_x)(k-cnt(j),2);
                    x(k,1) =  raw_data.(obj_x)(k-cnt(j),1);
                    cls(k,2) =  raw_data.(obj_cls)(k-cnt(j),2);
                    cls(k,1) =  raw_data.(obj_cls)(k-cnt(j),1);
                    vx(k,2) =  raw_data.(vleo_x)(k-cnt(j),2);
                    vx(k,1) =  raw_data.(vleo_x)(k-cnt(j),1);
                    width(k,2) =  raw_data.(obj_width)(k-cnt(j),2);
                    width(k,1) =  raw_data.(obj_width)(k-cnt(j),1);
                    ay(k,2) =  raw_data.(obj_y_arel)(k-cnt(j),2);
                    ay(k,1) =  raw_data.(obj_y_arel)(k-cnt(j),1);
                    ObstacleLane(k,2) =  raw_data.(obj_of_lane)(k-cnt(j),2);
                    ObstacleLane(k,1) =  raw_data.(obj_of_lane)(k-cnt(j),1);
                end
            end
        end
        raw_data.(obj_ID) = ID;
        raw_data.(obj_y) = y;
        raw_data.(obj_x)  = x;
        raw_data.(obj_cls)  = cls;
        raw_data.(vleo_x) = vx;
        raw_data.(obj_width) = width;
        raw_data.(obj_y_arel) = ay;
        raw_data.(obj_of_lane) = ObstacleLane;
       end
   end

for i = 1:m1-1
%     n1 = numel(CameraData(i).measures);
    % 存摄像头数据
    CameraDataSinlge  = frmData(i).CameraFrame.CameraObjectList;    % Camera的结构体形式
    CameraDataSinlge1  = frmData(i).CameraFrame.LaneList; 
%     CameraDataSinlge_process  = CameraData(i).measures;             % 采集数据
    for ii = 1:num_max
         obj_ID = strcat('Obstacle',num2str(ii-1),"DataA__Obstacle_ID");
       if uint8(raw_data.(obj_ID)(i,2))==0
          continue
       end
        obj_y = strcat('Obstacle',num2str(ii-1),"DataA__ObstaclePositionY");
        obj_x = strcat('Obstacle',num2str(ii-1),"DataA__ObstaclePositonX");
        obj_cls = strcat('Obstacle',num2str(ii-1),"DataA__ObstacleType");
        vleo_x = strcat('Obstacle',num2str(ii-1),"DataA__ObstacleRelativeVelocityX");
        obj_width = strcat('Obstacle',num2str(ii-1),"DataB__ObstacleWidth");
        obj_y_arel = strcat('Obstacle',num2str(ii-1),"DataC__ObstacleAccelX");
        obj_of_lane = strcat('Obstacle',num2str(ii-1),"DataB__ObstacleLane");
        CameraDataSinlge(ii).time_ns = uint64(raw_data.(obj_ID)(i,1)*1000);
        CameraDataSinlge(ii).ID = uint8(raw_data.(obj_ID)(i,2));
        CameraDataSinlge(ii).x = double(-raw_data.(obj_y)(i,2));
        CameraDataSinlge(ii).y = double(raw_data.(obj_x)(i,2));

            if raw_data.(obj_cls)(i,2)==1
               CameraDataSinlge(ii).cls = obstacle_cls.radarReflection; 
            elseif raw_data.(obj_cls)(i,2)==2
               CameraDataSinlge(ii).cls = obstacle_cls.pedestrian;
            elseif raw_data.(obj_cls)(i,2)==3
               CameraDataSinlge(ii).cls = obstacle_cls.bicycle; 
            elseif raw_data.(obj_cls)(i,2)==4
               CameraDataSinlge(ii).cls = obstacle_cls.bus; 
            elseif raw_data.(obj_cls)(i,2)==5
               CameraDataSinlge(ii).cls = obstacle_cls.car;
            elseif raw_data.(obj_cls)(i,2)==6
               CameraDataSinlge(ii).cls = obstacle_cls.truck;
            elseif raw_data.(obj_cls)(i,2)==7
               CameraDataSinlge(ii).cls = obstacle_cls.generalObject; 
            elseif raw_data.(obj_cls)(i,2)==8
               CameraDataSinlge(ii).cls = obstacle_cls.animal;
            elseif raw_data.(obj_cls)(i,2)==9
               CameraDataSinlge(ii).cls = obstacle_cls.tinyCar; 
            elseif raw_data.(obj_cls)(i,2)==10
               CameraDataSinlge(ii).cls = obstacle_cls.uncertainVehicle;
            elseif raw_data.(obj_cls)(i,2)==11
               CameraDataSinlge(ii).cls = obstacle_cls.tricycle;
            elseif raw_data.(obj_cls)(i,2)==12
               CameraDataSinlge(ii).cls = obstacle_cls.leftGuard; 
            elseif raw_data.(obj_cls)(i,2)==13
               CameraDataSinlge(ii).cls = obstacle_cls.rightGuard;
            elseif raw_data.(obj_cls)(i,2)==15
               CameraDataSinlge(ii).cls = obstacle_cls.invalid;
            else
               CameraDataSinlge(ii).cls = obstacle_cls.unknown; 
            end

            CameraDataSinlge(ii).velo_y = double(raw_data.(vleo_x)(i,2));
            CameraDataSinlge(ii).obj_width = double(raw_data.(obj_width)(i,2));
            CameraDataSinlge(ii).obj_y_arel = double(raw_data.(obj_y_arel)(i,2));

%             CameraDataSinlge(i).obj_lane = raw_data.ObstacleB_Length(i,2);
            if raw_data.(obj_of_lane)(i,2)==0
               CameraDataSinlge(ii).obj_lane = obj_lane.undefined;
            elseif raw_data.(obj_of_lane)(i,2)==1
               CameraDataSinlge(ii).obj_lane = obj_lane.sameLane;
            elseif raw_data.(obj_of_lane)(i,2)==2
               CameraDataSinlge(ii).obj_lane = obj_lane.leftLane;
            elseif raw_data.(obj_of_lane)(i,2)==3
               CameraDataSinlge(ii).obj_lane = obj_lane.rightLane;
            end
            CameraDataSinlge(ii).det_src = det_src.front;
            CameraDataSinlge(ii).flag = uint8(1);
    end
   
    frmData(i).CameraFrame.CameraObjectList = CameraDataSinlge;
    frmData(i).CameraFrame.time_ns = uint64(raw_data.ObstacleStatus__NumberOfObstacles(i,1)*1000);
%     存车道线信息
            CameraDataSinlge1(1).lane_locaiotn = lane_index.l_line;
            if raw_data.LKA_LeftLaneA__LaneQuality(i,2) == 0 || raw_data.LKA_LeftLaneA__LaneQuality(i,2) == 1
                CameraDataSinlge1(1).quality = lane_quality.low_quality;
            elseif raw_data.LKA_LeftLaneA__LaneQuality(i,2) == 2 || raw_data.LKA_LeftLaneA__LaneQuality(i,2) == 3
                CameraDataSinlge1(1).quality = lane_quality.high_quality;
            end
            if raw_data.LKA_LeftLaneA__LaneType(i,2) == 0
                CameraDataSinlge1(1).lane_type = lane_cls.singleDash;
            elseif raw_data.LKA_LeftLaneA__LaneType(i,2) == 1
                CameraDataSinlge1(1).lane_type = lane_cls.singleSolid;
            elseif raw_data.LKA_LeftLaneA__LaneType(i,2) == 2
                CameraDataSinlge1(1).lane_type = lane_cls.lDashrSolid;
            end
            CameraDataSinlge1(1).width_marking = double(raw_data.LKA_LeftLaneA__WidthLeftMarking(i,2));
            CameraDataSinlge1(1).C0 = double(raw_data.LKA_LeftLaneA__PositionParameter_C0(i,2));
            CameraDataSinlge1(1).C1 = double(raw_data.LKA_LeftLaneB__HeadingAngleParameter(i,2));
            CameraDataSinlge1(1).C2 = double(raw_data.LKA_LeftLaneA__CurvatureParameter_C2(i,2));
            CameraDataSinlge1(1).view_range = double(raw_data.LKA_LeftLaneB__ViewRange(i,2));
            CameraDataSinlge1(1).view_range_valid = uint8(raw_data.LKA_LeftLaneB__ViewRangeAvailability(i,2));
            CameraDataSinlge1(1).flag = uint8(1);

            CameraDataSinlge1(2).lane_locaiotn = lane_index.r_line;
            if raw_data.LKA_RightLaneA__LaneQuality(i,2) == 0 || raw_data.LKA_RightLaneA__LaneQuality(i,2) == 1
                CameraDataSinlge1(2).quality = lane_quality.low_quality;
            elseif raw_data.LKA_RightLaneA__LaneQuality(i,2) == 2 || raw_data.LKA_RightLaneA__LaneQuality(i,2) == 3
                CameraDataSinlge1(2).quality = lane_quality.high_quality;
            end
            if raw_data.LKA_RightLaneA__LaneType(i,2) == 0
                CameraDataSinlge1(2).lane_type = lane_cls.singleDash;
            elseif raw_data.LKA_RightLaneA__LaneType(i,2) == 1
                CameraDataSinlge1(2).lane_type = lane_cls.singleSolid;
            elseif raw_data.LKA_RightLaneA__LaneType(i,2) == 2
                CameraDataSinlge1(2).lane_type = lane_cls.lDashrSolid;
            end
            CameraDataSinlge1(2).width_marking = double(raw_data.LKA_RightLaneA__WidthLeftMarking(i,2));
            CameraDataSinlge1(2).C0 = double(raw_data.LKA_RightLaneA__PositionParameter_C0(i,2));
            CameraDataSinlge1(2).C1 = double(raw_data.LKA_RightLaneB__HeadingAngleParameter(i,2));
            CameraDataSinlge1(2).C2 = double(raw_data.LKA_RightLaneA__CurvatureParameter_C2(i,2));
            CameraDataSinlge1(2).view_range = double(raw_data.LKA_RightLaneB__ViewRange(i,2));
            CameraDataSinlge1(2).view_range_valid = uint8(raw_data.LKA_RightLaneB__ViewRangeAvailability(i,2));
            CameraDataSinlge1(2).flag = uint8(1);
         
    frmData(i).CameraFrame.LaneList = CameraDataSinlge1;
end

    
%存雷达数据
[n2,~]= size(raw_data.AK_Status_0__AK_Num_Far);
[n1,~]= size(raw_data.AK_General_1__Object_ID);
[n3,~]= size(raw_data.AK_General_2__Object_ID);
% RadarDataSinlge_process  = RadarData(i).frame; % 采集数据
cnt_j2=1;
cnt_num_obj=0;
%找第一帧有效雷达信息位置
for i_effective = 1:n1
     if abs(raw_data.AK_Status_0__AK_Num_Far(1,1)-raw_data.AK_General_1__Object_ID(i_effective,1))<0.002
        break
     end
end
% i_effective = 1;
%对于雷达两帧报文相差一帧的情况，对齐雷达的两帧报文
 if n1<n3 && raw_data.AK_General_1__Object_ID(1,2)~=raw_data.AK_General_2__Object_ID(1,2)
    raw_data.AK_General_2__Object_ID = raw_data.AK_General_2__Object_ID(2:end,:);
    raw_data.AK_General_2__Object_Ax = raw_data.AK_General_2__Object_Ax(2:end,:);
    raw_data.AK_General_2__Object_Ay = raw_data.AK_General_2__Object_Ay(2:end,:);
    raw_data.AK_General_2__Object_Confidence = raw_data.AK_General_2__Object_Confidence(2:end,:);
    raw_data.AK_General_2__Object_Vx = raw_data.AK_General_2__Object_Vx(2:end,:);
    raw_data.AK_General_2__Object_Vy = raw_data.AK_General_2__Object_Vy(2:end,:);
 elseif n1>n3 && raw_data.AK_General_1__Object_ID(1,2)~=raw_data.AK_General_2__Object_ID(1,2)
    raw_data.AK_General_1__Object_ID = raw_data.AK_General_1__Object_ID(2:end,:);
    raw_data.AK_General_1__Absolute_rest = raw_data.AK_General_1__Absolute_rest(2:end,:);
    raw_data.AK_General_1__MoveType = raw_data.AK_General_1__MoveType(2:end,:);
    raw_data.AK_General_1__Object_Azimuth = raw_data.AK_General_1__Object_Azimuth(2:end,:);
    raw_data.AK_General_1__Object_SNR = raw_data.AK_General_1__Object_SNR(2:end,:);
    raw_data.AK_General_1__Object_Speed = raw_data.AK_General_1__Object_Speed(2:end,:);
    raw_data.AK_General_1__Object_TrackStatus = raw_data.AK_General_1__Object_TrackStatus(2:end,:);
    raw_data.AK_General_1__Object_WarningStatus = raw_data.AK_General_1__Object_WarningStatus(2:end,:);
    raw_data.AK_General_1__Objective_Class = raw_data.AK_General_1__Objective_Class(2:end,:);
 end

 for j1 = 1:n2-1
    num_far = raw_data.AK_Status_0__AK_Num_Far(j1,2);
    num_near = raw_data.AK_Status_0__AK_Num_Near(j1,2);
    num_total = num_far+num_near;
 
     for j2 = cnt_j2:m1-1
                RadarDataSinlge  = frmData(j2).RadarFrame.RadarObjectList;    % 定义的结构体形式
        if abs(raw_data.AK_Status_0__AK_Num_Far(j1,1)-raw_data.ObstacleStatus__NumberOfObstacles(j2,1))<0.03
                cnt_j2 = j2+1;
          for jj = 1:num_total
                RadarDataSinlge(jj).time_ns = uint64(raw_data.AK_General_1__Object_ID(cnt_num_obj+jj+i_effective-1,1)*1000);
                RadarDataSinlge(jj).ID = uint16(raw_data.AK_General_1__Object_ID(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).obj_range = double(raw_data.AK_General_1__Object_Range(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).moveType = double(raw_data.AK_General_1__MoveType(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).obj_speed = double(raw_data.AK_General_1__Object_Speed(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).obj_azimuth = double(raw_data.AK_General_1__Object_Azimuth(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).velo_x = double(raw_data.AK_General_2__Object_Vx(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).velo_y = double(raw_data.AK_General_2__Object_Vy(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).obj_trackStatus = double(raw_data.AK_General_1__Object_TrackStatus(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).obj_warningStaus = double(raw_data.AK_General_1__Object_WarningStatus(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).ax = double(raw_data.AK_General_2__Object_Ax(cnt_num_obj+jj+i_effective-1,2));
                RadarDataSinlge(jj).ay = double(raw_data.AK_General_2__Object_Ay(cnt_num_obj+jj+i_effective-1,2));

%                 RadarDataSinlge(jj).cls = raw_data.Objective_Class(cnt+jj,2);
                if raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==1
                    RadarDataSinlge(jj).cls = obstacle_cls.radarReflection;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==2
                    RadarDataSinlge(jj).cls = obstacle_cls.pedestrian;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==3
                    RadarDataSinlge(jj).cls = obstacle_cls.bicycle;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==4
                    RadarDataSinlge(jj).cls = obstacle_cls.bus;  
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==5
                    RadarDataSinlge(jj).cls = obstacle_cls.car;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==6
                    RadarDataSinlge(jj).cls = obstacle_cls.truck;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==7
                    RadarDataSinlge(jj).cls = obstacle_cls.generalObject; 
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==8
                    RadarDataSinlge(jj).cls = obstacle_cls.animal;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==9
                    RadarDataSinlge(jj).cls = obstacle_cls.tinyCar;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==10
                    RadarDataSinlge(jj).cls = obstacle_cls.uncertainVehicle;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==11
                    RadarDataSinlge(jj).cls = obstacle_cls.tricycle; 
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==12
                    RadarDataSinlge(jj).cls = obstacle_cls.leftGuard;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==13
                    RadarDataSinlge(jj).cls = obstacle_cls.rightGuard;
                elseif raw_data.AK_General_1__Objective_Class(cnt_num_obj+jj+i_effective-1,2)==15
                    RadarDataSinlge(jj).cls = obstacle_cls.invalid;
                else
                    RadarDataSinlge(jj).cls = obstacle_cls.unknown;
                end
        
                    RadarDataSinlge(jj).SNR = double(raw_data.AK_General_1__Object_SNR(cnt_num_obj+jj+i_effective-1,2));
                    RadarDataSinlge(jj).det_src = det_src.front;
                    RadarDataSinlge(jj).flag = uint8(1);
          end
%         cnt = cnt+num_total;
        frmData(j2).RadarFrame.RadarObjectList = RadarDataSinlge;
        frmData(j2).RadarFrame.time_ns = uint64(raw_data.AK_Status_0__AK_Num_Far(j1,1)*1000);
        break
        end
     end
   cnt_num_obj=cnt_num_obj+num_total;
 end

 %存整车信息carSignals

    [k1,~] = size(raw_data.Vehcle_Speed_st__Veh_Spd_Veh_speed);
    [k2,~] = size(raw_data.Vehcle_Speed_st__Veh_Spd_yaw_rate);
    [k3,~] = size(raw_data.VDC2__VDC2_SteerWheelAngle);
    VehSpeed = zeros(m1,2);
    YawRate = zeros(m1,2);
    SWAngle = zeros(m1,2);
    carSignals = zeros(m1,2);
        m_speed = 1;
        m_yaw = 1;
        m_SWAngle = 1;
        for k = 1:m1-1
            for kk = m_speed:k1
                if abs(raw_data.Vehcle_Speed_st__Veh_Spd_Veh_speed(kk,1)-raw_data.ObstacleStatus__NumberOfObstacles(k,1))<0.06
                    VehSpeed(k,2) = raw_data.Vehcle_Speed_st__Veh_Spd_Veh_speed(kk,2);
                    VehSpeed(k,1) = raw_data.Vehcle_Speed_st__Veh_Spd_Veh_speed(kk,1);
                    m_speed = kk;
                    break
                end
            end
           for kk = m_yaw:k2
                if abs(raw_data.Vehcle_Speed_st__Veh_Spd_yaw_rate(kk,1)-raw_data.ObstacleStatus__NumberOfObstacles(k,1))<0.06
                    YawRate(k,2) =  raw_data.Vehcle_Speed_st__Veh_Spd_yaw_rate(kk,2);
                    YawRate(k,1) =  raw_data.Vehcle_Speed_st__Veh_Spd_yaw_rate(kk,1);
                    m_yaw = kk;
                    break
                end
           end
           for kk = m_SWAngle:k3
                if abs(raw_data.VDC2__VDC2_SteerWheelAngle(kk,1)-raw_data.ObstacleStatus__NumberOfObstacles(k,1))<0.06
                    SWAngle(k,2) =  raw_data.VDC2__VDC2_SteerWheelAngle(kk,2);
                    SWAngle(k,1) =  raw_data.VDC2__VDC2_SteerWheelAngle(kk,1);
                    m_SWAngle = kk;
                    break
                end
            end
        end
        carSignals(:,1) = VehSpeed(:,2);
        carSignals(:,2) = YawRate(:,2);
        carSignals(:,3) = SWAngle(:,2);


% 角雷达不同目标之间时间对齐
[mRL,~] = size(raw_data.RadarInfo01__NoTar);
[mRR,~] = size(raw_data.RadarInfo03__NoTar);
[mFL,~] = size(raw_data.RadarInfo05__NoTar);
[mFR,~] = size(raw_data.RadarInfo07__NoTar);
%  cnt = zeros(128,1);
 num_max_RL = max(raw_data.RadarInfo01__NoTar(:,2)); %左后
 num_max_RR = max(raw_data.RadarInfo03__NoTar(:,2)); %右后
 num_max_FL = max(raw_data.RadarInfo05__NoTar(:,2)); %左前
 num_max_FR = max(raw_data.RadarInfo07__NoTar(:,2)); %右前
 %左后雷达
    for j = 1:num_max_RL
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_cls = strcat('ExTarget',num2str(j,'%03d'),"__Tar_Category");
         [k1,~] = size(raw_data.(obj_ID));
         [size_cls,~] = size(raw_data.(obj_cls));
       if k1 == mRL && size_cls== mRL
          continue
       else
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_y = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_Y");
        obj_x = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_X");
        vleo_x = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_X");
        vleo_y = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_Y");
        obj_x_arel = strcat('Target',num2str(j,'%03d'),"__Tar_Accel_X");
        obj_move_type = strcat('Target',num2str(j,'%03d'),"__Tar_DynSta");
        ObjExistProp = strcat('ExTarget',num2str(j,'%03d'),"__Tar_ConfidenceLevel");
        ID = zeros(mRL,2);
        y = zeros(mRL,2);
        x = zeros(mRL,2);
        cls = zeros(mRL,2);
        vx = zeros(mRL,2);
        vy = zeros(mRL,2);
        ax = zeros(mRL,2);
        MoveType = zeros(mRL,2);
        exist_prop = zeros(mRL,2);
        for k = 1:mRL-1
            for kk=1:k1
                 if abs(raw_data.RadarInfo01__NoTar(k,1)-raw_data.(obj_ID)(kk,1))<0.008
                    ID(k,2) = raw_data.(obj_ID)(kk,2);
                    ID(k,1) = raw_data.(obj_ID)(kk,1);
                    y(k,2) =  raw_data.(obj_y)(kk,2);
                    y(k,1) =  raw_data.(obj_y)(kk,1);
                    x(k,2) =  raw_data.(obj_x)(kk,2);
                    x(k,1) =  raw_data.(obj_x)(kk,1);
                    if size_cls>=kk
                    cls(k,2) =  raw_data.(obj_cls)(kk,2);
                    cls(k,1) =  raw_data.(obj_cls)(kk,1);
                    exist_prop(k,2) =  raw_data.(ObjExistProp)(kk,2);
                    exist_prop(k,1) =  raw_data.(ObjExistProp)(kk,1);
                    end
                    vx(k,2) =  raw_data.(vleo_x)(kk,2);
                    vx(k,1) =  raw_data.(vleo_x)(kk,1);
                    vy(k,2) =  raw_data.(vleo_y)(kk,2);
                    vy(k,1) =  raw_data.(vleo_y)(kk,1);
                    ax(k,2) =  raw_data.(obj_x_arel)(kk,2);
                    ax(k,1) =  raw_data.(obj_x_arel)(kk,1);
                    MoveType(k,2) =  raw_data.(obj_move_type)(kk,2);
                    MoveType(k,1) =  raw_data.(obj_move_type)(kk,1);
                     break
                 end
            end
        end
       end
        raw_data.(obj_ID) = ID;
        raw_data.(obj_y) = y;
        raw_data.(obj_x)  = x;
        raw_data.(obj_cls)  = cls;
        raw_data.(vleo_x) = vx;
        raw_data.(vleo_y) = vy;
        raw_data.(obj_x_arel) = ax;
        raw_data.(obj_move_type) = MoveType;
        raw_data.(ObjExistProp) = exist_prop;
    end

 %右后雷达
    for j = 33:(32+num_max_RR)
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_cls = strcat('ExTarget',num2str(j,'%03d'),"__Tar_Category");
         [k1,~] = size(raw_data.(obj_ID));
         [size_cls,~] = size(raw_data.(obj_cls));
       if k1 == mRR && size_cls == mRR
          continue
       else
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_y = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_Y");
        obj_x = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_X");
        vleo_x = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_X");
        vleo_y = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_Y");
        obj_x_arel = strcat('Target',num2str(j,'%03d'),"__Tar_Accel_X");
        obj_move_type = strcat('Target',num2str(j,'%03d'),"__Tar_DynSta");
        ObjExistProp = strcat('ExTarget',num2str(j,'%03d'),"__Tar_ConfidenceLevel");
        ID = zeros(mRR,2);
        y = zeros(mRR,2);
        x = zeros(mRR,2);
        cls = zeros(mRR,2);
        vx = zeros(mRR,2);
        vy = zeros(mRR,2);
        ax = zeros(mRR,2);
        MoveType = zeros(mRR,2);
        exist_prop = zeros(mRR,2);
        for k = 1:mRR-1
            for kk=1:k1
                 if abs(raw_data.RadarInfo03__NoTar(k,1)-raw_data.(obj_ID)(kk,1))<0.008
                    ID(k,2) = raw_data.(obj_ID)(kk,2);
                    ID(k,1) = raw_data.(obj_ID)(kk,1);
                    y(k,2) =  raw_data.(obj_y)(kk,2);
                    y(k,1) =  raw_data.(obj_y)(kk,1);
                    x(k,2) =  raw_data.(obj_x)(kk,2);
                    x(k,1) =  raw_data.(obj_x)(kk,1);
                    if size_cls>=kk
                    cls(k,2) =  raw_data.(obj_cls)(kk,2);
                    cls(k,1) =  raw_data.(obj_cls)(kk,1);
                    exist_prop(k,2) =  raw_data.(ObjExistProp)(kk,2);
                    exist_prop(k,1) =  raw_data.(ObjExistProp)(kk,1);
                    end
                    vx(k,2) =  raw_data.(vleo_x)(kk,2);
                    vx(k,1) =  raw_data.(vleo_x)(kk,1);
                    vy(k,2) =  raw_data.(vleo_y)(kk,2);
                    vy(k,1) =  raw_data.(vleo_y)(kk,1);
                    ax(k,2) =  raw_data.(obj_x_arel)(kk,2);
                    ax(k,1) =  raw_data.(obj_x_arel)(kk,1);
                    MoveType(k,2) =  raw_data.(obj_move_type)(kk,2);
                    MoveType(k,1) =  raw_data.(obj_move_type)(kk,1);
                     break
                 end
            end
        end
       end
        raw_data.(obj_ID) = ID;
        raw_data.(obj_y) = y;
        raw_data.(obj_x)  = x;
        raw_data.(obj_cls)  = cls;
        raw_data.(vleo_x) = vx;
        raw_data.(vleo_y) = vy;
        raw_data.(obj_x_arel) = ax;
        raw_data.(obj_move_type) = MoveType;
        raw_data.(ObjExistProp) = exist_prop;
    end
    %左前雷达
    for j = 65:(64+num_max_FL)
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_cls = strcat('ExTarget',num2str(j,'%03d'),"__Tar_Category");
         [k1,~] = size(raw_data.(obj_ID));
         [size_cls,~] = size(raw_data.(obj_cls));
       if k1 == mFL && size_cls == mFL
          continue
       else
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_y = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_Y");
        obj_x = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_X");
        vleo_x = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_X");
        vleo_y = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_Y");
        obj_x_arel = strcat('Target',num2str(j,'%03d'),"__Tar_Accel_X");
        obj_move_type = strcat('Target',num2str(j,'%03d'),"__Tar_DynSta");
        ObjExistProp = strcat('ExTarget',num2str(j,'%03d'),"__Tar_ConfidenceLevel");
        ID = zeros(mFL,2);
        y = zeros(mFL,2);
        x = zeros(mFL,2);
        cls = zeros(mFL,2);
        vx = zeros(mFL,2);
        vy = zeros(mFL,2);
        ax = zeros(mFL,2);
        MoveType = zeros(mFL,2);
        exist_prop = zeros(mFL,2);
       for k = 1:mFL-1
            for kk=1:k1
                 if abs(raw_data.RadarInfo05__NoTar(k,1)-raw_data.(obj_ID)(kk,1))<0.008
                    ID(k,2) = raw_data.(obj_ID)(kk,2);
                    ID(k,1) = raw_data.(obj_ID)(kk,1);
                    y(k,2) =  raw_data.(obj_y)(kk,2);
                    y(k,1) =  raw_data.(obj_y)(kk,1);
                    x(k,2) =  raw_data.(obj_x)(kk,2);
                    x(k,1) =  raw_data.(obj_x)(kk,1);
                    if size_cls>=kk
                    cls(k,2) =  raw_data.(obj_cls)(kk,2);
                    cls(k,1) =  raw_data.(obj_cls)(kk,1);
                    exist_prop(k,2) =  raw_data.(ObjExistProp)(kk,2);
                    exist_prop(k,1) =  raw_data.(ObjExistProp)(kk,1);
                    end
                    vx(k,2) =  raw_data.(vleo_x)(kk,2);
                    vx(k,1) =  raw_data.(vleo_x)(kk,1);
                    vy(k,2) =  raw_data.(vleo_y)(kk,2);
                    vy(k,1) =  raw_data.(vleo_y)(kk,1);
                    ax(k,2) =  raw_data.(obj_x_arel)(kk,2);
                    ax(k,1) =  raw_data.(obj_x_arel)(kk,1);
                    MoveType(k,2) =  raw_data.(obj_move_type)(kk,2);
                    MoveType(k,1) =  raw_data.(obj_move_type)(kk,1);

                     break
                 end
            end
       end
       end
        raw_data.(obj_ID) = ID;
        raw_data.(obj_y) = y;
        raw_data.(obj_x)  = x;
        raw_data.(obj_cls)  = cls;
        raw_data.(vleo_x) = vx;
        raw_data.(vleo_y) = vy;
        raw_data.(obj_x_arel) = ax;
        raw_data.(obj_move_type) = MoveType;
        raw_data.(ObjExistProp) = exist_prop;
    end
     %右前雷达
    for j = 97:(96+num_max_FR)
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_cls = strcat('ExTarget',num2str(j,'%03d'),"__Tar_Category");
         [k1,~] = size(raw_data.(obj_ID));
         [size_cls,~] = size(raw_data.(obj_cls));
       if k1 == mFR && size_cls == mFR
          continue
       else
        obj_ID = strcat('Target',num2str(j,'%03d'),"__Tar_ID");
        obj_y = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_Y");
        obj_x = strcat('Target',num2str(j,'%03d'),"__Tar_Pos_X");
        vleo_x = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_X");
        vleo_y = strcat('Target',num2str(j,'%03d'),"__Tar_Vel_Y");
        obj_x_arel = strcat('Target',num2str(j,'%03d'),"__Tar_Accel_X");
        obj_move_type = strcat('Target',num2str(j,'%03d'),"__Tar_DynSta");
        ObjExistProp = strcat('ExTarget',num2str(j,'%03d'),"__Tar_ConfidenceLevel");
        ID = zeros(mFR,2);
        y = zeros(mFR,2);
        x = zeros(mFR,2);
        cls = zeros(mFR,2);
        vx = zeros(mFR,2);
        vy = zeros(mFR,2);
        ax = zeros(mFR,2);
        MoveType = zeros(mFR,2);
        exist_prop = zeros(mFR,2);
        for k = 1:mFR-1
            for kk=1:k1
                 if abs(raw_data.RadarInfo07__NoTar(k,1)-raw_data.(obj_ID)(kk,1))<0.008
                    ID(k,2) = raw_data.(obj_ID)(kk,2);
                    ID(k,1) = raw_data.(obj_ID)(kk,1);
                    y(k,2) =  raw_data.(obj_y)(kk,2);
                    y(k,1) =  raw_data.(obj_y)(kk,1);
                    x(k,2) =  raw_data.(obj_x)(kk,2);
                    x(k,1) =  raw_data.(obj_x)(kk,1);
                    if size_cls>=kk
                    cls(k,2) =  raw_data.(obj_cls)(kk,2);
                    cls(k,1) =  raw_data.(obj_cls)(kk,1);
                    exist_prop(k,2) =  raw_data.(ObjExistProp)(kk,2);
                    exist_prop(k,1) =  raw_data.(ObjExistProp)(kk,1);
                    end
                    vx(k,2) =  raw_data.(vleo_x)(kk,2);
                    vx(k,1) =  raw_data.(vleo_x)(kk,1);
                    vy(k,2) =  raw_data.(vleo_y)(kk,2);
                    vy(k,1) =  raw_data.(vleo_y)(kk,1);
                    ax(k,2) =  raw_data.(obj_x_arel)(kk,2);
                    ax(k,1) =  raw_data.(obj_x_arel)(kk,1);
                    MoveType(k,2) =  raw_data.(obj_move_type)(kk,2);
                    MoveType(k,1) =  raw_data.(obj_move_type)(kk,1);
                     break
                 end
            end
        end
       end
        raw_data.(obj_ID) = ID;
        raw_data.(obj_y) = y;
        raw_data.(obj_x)  = x;
        raw_data.(obj_cls)  = cls;
        raw_data.(vleo_x) = vx;
        raw_data.(vleo_y) = vy;
        raw_data.(obj_x_arel) = ax;
        raw_data.(obj_move_type) = MoveType;
        raw_data.(ObjExistProp) = exist_prop;
    end

%存角雷达数据
%左后雷达
for RL = 1:m1-1
   RadarDataSinlge  = frmData(RL).RadarFrame.RadarObjectList;
   for i = 1:mRL-1
        if abs(raw_data.RadarInfo01__NoTar(i,1)-raw_data.ObstacleStatus__NumberOfObstacles(RL,1))<0.1
           num_RL = raw_data.RadarInfo01__NoTar(i,2);
            for j = 65:(64+num_RL)
                if ((64+num_max_RL)<j&&j<=96)
                   continue
                end
                obj_ID = strcat('Target',num2str(j-64,'%03d'),"__Tar_ID");
                if uint8(raw_data.(obj_ID)(i,2))==0
                    continue
                end
                obj_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_Y");
                obj_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_X");
                obj_cls = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_Category");
                vleo_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_X");
                vleo_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_Y");
                obj_x_arel = strcat('Target',num2str(j-64,'%03d'),"__Tar_Accel_X");
                obj_move_type = strcat('Target',num2str(j-64,'%03d'),"__Tar_DynSta");
                ObjExistProp = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_ConfidenceLevel");
                RadarDataSinlge(j).time_ns = uint64(raw_data.(obj_ID)(i,1)*1000);
                RadarDataSinlge(j).ID = uint16(raw_data.(obj_ID)(i,2));
                RadarDataSinlge(j).y = double(raw_data.(obj_x)(i,2));
                RadarDataSinlge(j).x = double(-raw_data.(obj_y)(i,2));
        
                if raw_data.(obj_cls)(i,2)==0
                    RadarDataSinlge(j).cls = obstacle_cls.unknown;
                elseif raw_data.(obj_cls)(i,2)==1
                    RadarDataSinlge(j).cls = obstacle_cls.radarReflection;
                elseif raw_data.(obj_cls)(i,2)==2
                    RadarDataSinlge(j).cls = obstacle_cls.pedestrian;
                elseif raw_data.(obj_cls)(i,2)==3
                    RadarDataSinlge(j).cls = obstacle_cls.bicycle;
                elseif raw_data.(obj_cls)(i,2)==4
                    RadarDataSinlge(j).cls = obstacle_cls.bus;
                elseif raw_data.(obj_cls)(i,2)==5
                    RadarDataSinlge(j).cls = obstacle_cls.car;
                elseif raw_data.(obj_cls)(i,2)==6
                    RadarDataSinlge(j).cls = obstacle_cls.truck;
                elseif raw_data.(obj_cls)(i,2)==7
                    RadarDataSinlge(j).cls = obstacle_cls.generalObject;
                end
        
                RadarDataSinlge(j).velo_y = double(raw_data.(vleo_x)(i,2));
                RadarDataSinlge(j).velo_x = double(raw_data.(vleo_y)(i,2));
                RadarDataSinlge(j).ay = double(raw_data.(obj_x_arel)(i,2));
                RadarDataSinlge(j).moveType = double(raw_data.(obj_move_type)(i,2));
                RadarDataSinlge(j).det_src = det_src.left_backward;
                 if raw_data.(ObjExistProp)(i,2)<=25
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_25;
                elseif raw_data.(ObjExistProp)(i,2)>25 && raw_data.(ObjExistProp)(i,2)<=50
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_50;
                elseif raw_data.(ObjExistProp)(i,2)>50 && raw_data.(ObjExistProp)(i,2)<=75
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_75;
                elseif raw_data.(ObjExistProp)(i,2)>75 && raw_data.(ObjExistProp)(i,2)<=100
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_99;
                end 
                RadarDataSinlge(j).flag = uint8(1);
                frmData(RL).RadarFrame.RadarObjectList(65:96) = RadarDataSinlge(65:96);
            end
    
        end
    end
end
%右后雷达
for RR = 1:m1-1
   RadarDataSinlge  = frmData(RR).RadarFrame.RadarObjectList;
    for i = 1:mRR-1
        if abs(raw_data.RadarInfo03__NoTar(i,1)-raw_data.ObstacleStatus__NumberOfObstacles(RR,1))<0.1
           num_RR = raw_data.RadarInfo03__NoTar(i,2);
            for j = 97:(96+num_RR)
                if (num_max_RR+96<j&&j<=128)
                   continue
                end
                obj_ID = strcat('Target',num2str(j-64,'%03d'),"__Tar_ID");
                if uint8(raw_data.(obj_ID)(i,2))==0
                    continue
                end
                obj_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_Y");
                obj_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_X");
                obj_cls = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_Category");
                vleo_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_X");
                vleo_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_Y");
                obj_x_arel = strcat('Target',num2str(j-64,'%03d'),"__Tar_Accel_X");
                obj_move_type = strcat('Target',num2str(j-64,'%03d'),"__Tar_DynSta");
                ObjExistProp = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_ConfidenceLevel");
                RadarDataSinlge(j).time_ns = uint64(raw_data.(obj_ID)(i,1)*1000);
                RadarDataSinlge(j).ID = uint16(raw_data.(obj_ID)(i,2));
                RadarDataSinlge(j).y = double(raw_data.(obj_x)(i,2));
                RadarDataSinlge(j).x = double(-raw_data.(obj_y)(i,2));
        
                if raw_data.(obj_cls)(i,2)==0
                    RadarDataSinlge(j).cls = obstacle_cls.unknown;
                elseif raw_data.(obj_cls)(i,2)==1
                    RadarDataSinlge(j).cls = obstacle_cls.radarReflection;
                elseif raw_data.(obj_cls)(i,2)==2
                    RadarDataSinlge(j).cls = obstacle_cls.pedestrian;
                elseif raw_data.(obj_cls)(i,2)==3
                    RadarDataSinlge(j).cls = obstacle_cls.bicycle;
                elseif raw_data.(obj_cls)(i,2)==4
                    RadarDataSinlge(j).cls = obstacle_cls.bus;
                elseif raw_data.(obj_cls)(i,2)==5
                    RadarDataSinlge(j).cls = obstacle_cls.car;
                elseif raw_data.(obj_cls)(i,2)==6
                    RadarDataSinlge(j).cls = obstacle_cls.truck;
                elseif raw_data.(obj_cls)(i,2)==7
                    RadarDataSinlge(j).cls = obstacle_cls.generalObject;
                end
        
                RadarDataSinlge(j).velo_y = double(raw_data.(vleo_x)(i,2));
                RadarDataSinlge(j).velo_x = double(raw_data.(vleo_y)(i,2));
                RadarDataSinlge(j).ay = double(raw_data.(obj_x_arel)(i,2));
                RadarDataSinlge(j).moveType = double(raw_data.(obj_move_type)(i,2));
                RadarDataSinlge(j).det_src = det_src.right_backward;
                if raw_data.(ObjExistProp)(i,2)<=25
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_25;
                elseif raw_data.(ObjExistProp)(i,2)>25 && raw_data.(ObjExistProp)(i,2)<=50
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_50;
                elseif raw_data.(ObjExistProp)(i,2)>50 && raw_data.(ObjExistProp)(i,2)<=75
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_75;
                elseif raw_data.(ObjExistProp)(i,2)>75 && raw_data.(ObjExistProp)(i,2)<=100
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_99;
                end 
                RadarDataSinlge(j).flag = uint8(1);
                frmData(RR).RadarFrame.RadarObjectList(97:128) = RadarDataSinlge(97:128);
            end
    
        end
    end
end
%左前雷达
for FL = 1:m1-1
  RadarDataSinlge  = frmData(FL).RadarFrame.RadarObjectList;
   for i = 1:mFL-1
        if abs(raw_data.RadarInfo05__NoTar(i,1)-raw_data.ObstacleStatus__NumberOfObstacles(FL,1))<0.1
            num_FL = raw_data.RadarInfo05__NoTar(i,2);
            for j = 129:(128+num_FL)
                if (num_max_FL+128<j&&j<=160)
                   continue
                end
                obj_ID = strcat('Target',num2str(j-64,'%03d'),"__Tar_ID");
                if uint8(raw_data.(obj_ID)(i,2))==0
                    continue
                end
                obj_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_Y");
                obj_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_X");
                obj_cls = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_Category");
                vleo_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_X");
                vleo_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_Y");
                obj_x_arel = strcat('Target',num2str(j-64,'%03d'),"__Tar_Accel_X");
                obj_move_type = strcat('Target',num2str(j-64,'%03d'),"__Tar_DynSta");
                ObjExistProp = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_ConfidenceLevel");
                RadarDataSinlge(j).time_ns = uint64(raw_data.(obj_ID)(i,1)*1000);
                RadarDataSinlge(j).ID = uint16(raw_data.(obj_ID)(i,2));
                RadarDataSinlge(j).y = double(raw_data.(obj_x)(i,2));
                RadarDataSinlge(j).x = double(-raw_data.(obj_y)(i,2));
        
                if raw_data.(obj_cls)(i,2)==0
                    RadarDataSinlge(j).cls = obstacle_cls.unknown;
                elseif raw_data.(obj_cls)(i,2)==1
                    RadarDataSinlge(j).cls = obstacle_cls.radarReflection;
                elseif raw_data.(obj_cls)(i,2)==2
                    RadarDataSinlge(j).cls = obstacle_cls.pedestrian;
                elseif raw_data.(obj_cls)(i,2)==3
                    RadarDataSinlge(j).cls = obstacle_cls.bicycle;
                elseif raw_data.(obj_cls)(i,2)==4
                    RadarDataSinlge(j).cls = obstacle_cls.bus;
                elseif raw_data.(obj_cls)(i,2)==5
                    RadarDataSinlge(j).cls = obstacle_cls.car;
                elseif raw_data.(obj_cls)(i,2)==6
                    RadarDataSinlge(j).cls = obstacle_cls.truck;
                elseif raw_data.(obj_cls)(i,2)==7
                    RadarDataSinlge(j).cls = obstacle_cls.generalObject;
                end
        
                RadarDataSinlge(j).velo_y = double(raw_data.(vleo_x)(i,2));
                RadarDataSinlge(j).velo_x = double(raw_data.(vleo_y)(i,2));
                RadarDataSinlge(j).ay = double(raw_data.(obj_x_arel)(i,2));
                RadarDataSinlge(j).moveType = double(raw_data.(obj_move_type)(i,2));
                RadarDataSinlge(j).det_src = det_src.left_forward;
                if raw_data.(ObjExistProp)(i,2)<=25
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_25;
                elseif raw_data.(ObjExistProp)(i,2)>25 && raw_data.(ObjExistProp)(i,2)<=50
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_50;
                elseif raw_data.(ObjExistProp)(i,2)>50 && raw_data.(ObjExistProp)(i,2)<=75
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_75;
                elseif raw_data.(ObjExistProp)(i,2)>75 && raw_data.(ObjExistProp)(i,2)<=100
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_99;
                end 
                RadarDataSinlge(j).flag = uint8(1);
                frmData(FL).RadarFrame.RadarObjectList(129:160) = RadarDataSinlge(129:160);
            end
    
        end
    end
end
%右前雷达
for FR = 1:m1-1
   RadarDataSinlge  = frmData(FR).RadarFrame.RadarObjectList;
    for i = 1:mFR-1
        if abs(raw_data.RadarInfo07__NoTar(i,1)-raw_data.ObstacleStatus__NumberOfObstacles(FR,1))<0.1
           num_FR = raw_data.RadarInfo07__NoTar(i,2);
            for j = 161:(160+num_FR)
                if (num_max_FR+160<j&&j<=192)
                   continue
                end
                obj_ID = strcat('Target',num2str(j-64,'%03d'),"__Tar_ID");
                if uint8(raw_data.(obj_ID)(i,2))==0
                    continue
                end
                obj_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_Y");
                obj_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Pos_X");
                obj_cls = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_Category");
                vleo_x = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_X");
                vleo_y = strcat('Target',num2str(j-64,'%03d'),"__Tar_Vel_Y");
                obj_x_arel = strcat('Target',num2str(j-64,'%03d'),"__Tar_Accel_X");
                obj_move_type = strcat('Target',num2str(j-64,'%03d'),"__Tar_DynSta");
                ObjExistProp = strcat('ExTarget',num2str(j-64,'%03d'),"__Tar_ConfidenceLevel");
                RadarDataSinlge(j).time_ns = uint64(raw_data.(obj_ID)(i,1)*1000);
                RadarDataSinlge(j).ID = uint16(raw_data.(obj_ID)(i,2));
                RadarDataSinlge(j).y = double(raw_data.(obj_x)(i,2));
                RadarDataSinlge(j).x = double(-raw_data.(obj_y)(i,2));
        
                if raw_data.(obj_cls)(i,2)==0
                    RadarDataSinlge(j).cls = obstacle_cls.unknown;
                elseif raw_data.(obj_cls)(i,2)==1
                    RadarDataSinlge(j).cls = obstacle_cls.radarReflection;
                elseif raw_data.(obj_cls)(i,2)==2
                    RadarDataSinlge(j).cls = obstacle_cls.pedestrian;
                elseif raw_data.(obj_cls)(i,2)==3
                    RadarDataSinlge(j).cls = obstacle_cls.bicycle;
                elseif raw_data.(obj_cls)(i,2)==4
                    RadarDataSinlge(j).cls = obstacle_cls.bus;
                elseif raw_data.(obj_cls)(i,2)==5
                    RadarDataSinlge(j).cls = obstacle_cls.car;
                elseif raw_data.(obj_cls)(i,2)==6
                    RadarDataSinlge(j).cls = obstacle_cls.truck;
                elseif raw_data.(obj_cls)(i,2)==7
                    RadarDataSinlge(j).cls = obstacle_cls.generalObject;
                end
        
                RadarDataSinlge(j).velo_y = double(raw_data.(vleo_x)(i,2));
                RadarDataSinlge(j).velo_x = double(raw_data.(vleo_y)(i,2));
                RadarDataSinlge(j).ay = double(raw_data.(obj_x_arel)(i,2));
                RadarDataSinlge(j).moveType = double(raw_data.(obj_move_type)(i,2));
                RadarDataSinlge(j).det_src = det_src.right_forward;
                if raw_data.(ObjExistProp)(i,2)<=25
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_25;
                elseif raw_data.(ObjExistProp)(i,2)>25 && raw_data.(ObjExistProp)(i,2)<=50
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_50;
                elseif raw_data.(ObjExistProp)(i,2)>50 && raw_data.(ObjExistProp)(i,2)<=75
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_75;
                elseif raw_data.(ObjExistProp)(i,2)>75 && raw_data.(ObjExistProp)(i,2)<=100
                    RadarDataSinlge(j).obj_exist_prop = obj_exist_prop.percent_99;
                end 
                RadarDataSinlge(j).flag = uint8(1);
                frmData(FR).RadarFrame.RadarObjectList(161:192) = RadarDataSinlge(161:192);
            end
    
        end
    end
end

end
