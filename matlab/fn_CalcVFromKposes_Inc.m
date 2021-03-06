function [tv,xcol,tid] = fn_CalcVFromKposes_Inc( nPoseNew, nPoseOld, ...
    nPoses, nPts, nIMUdata, ImuTimestamps, nIMUrate, ...
    x, xcol, dtIMU, inertialDelta, SLAM_Params, imufulldata)    
    
    global PreIntegration_options
    
    tid = 0
    tv = repmat( ...
                    struct( ...
                       'xyz', zeros(3, 1), ...
                        'col', [] ...
                        ), ...
                    1, ...
                    1 ...
                );
    
    if(nPoseOld == 1)
        % The velocity of the first pose.
        tid = tid + 1;
        tv(tid).xyz = ( x.pose(1).trans.xyz ...
                        - 0.5 * dtIMU(2) * dtIMU(2) * SLAM_Params.g0 ...
                        - inertialDelta.dp(:,2) ...
                       ) / (dtIMU(2));

        tv(tid).col = (1:3) + xcol;   
        xcol = xcol + 3;
    end

    pid_start = nPoseOld+1;           
    pid_end = nPoseNew-1;
    for(pid=pid_start:pid_end)
      tid = tid + 1;
      Au = x.pose(pid-1).ang.val;
      Ri = fn_RFromABG( Au(1), Au(2), Au(3) );

      tv(tid).xyz = ...
                ( ...
                    x.pose(pid).trans.xyz - x.pose(pid-1).trans.xyz ...
                    - 0.5 * dtIMU(pid+1) * dtIMU(pid+1) * SLAM_Params.g0 ...
                    - Ri' * inertialDelta.dp(:, (pid+1) ) ...
                ) / dtIMU(pid+1);
      tv(tid).col = (1:3) + xcol;   
      xcol = xcol + 3;
    end
    
    % The velocity of the last pose.
    tid = tid + 1;
    Au = x.pose(nPoseNew-1).ang.val;
    Ri = fn_RFromABG( Au(1), Au(2), Au(3));
    if (tid > 1)
        tv(tid).xyz = tv(tid-1).xyz ...
                        + dtIMU(nPoseNew) * SLAM_Params.g0 ...
                        + Ri' * inertialDelta.dv(:,nPoseNew);
        tv(tid).col = (1:3) + xcol;   
        xcol = xcol + 3;
    else
       tv(tid).xyz = x.velocity(nPoseNew - 1).xyz ...
                    + dtIMU(nPoseNew) * SLAM_Params.g0...
                    + Ri' * inertialDelta.dv(:,nPoseNew);    
       tv(tid).col = (1:3) + xcol;   
       xcol = xcol + 3;
    end
