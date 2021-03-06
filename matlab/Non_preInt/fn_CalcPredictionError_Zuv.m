function e = fnCalcPredictionError_Zuv(RptFeatureObs, K, X, Zobs, nPoses, nPts, ImuTimestamps)

    global PreIntegration_options

    %nObsId_FeatureObs = 2;
    fx = K(1,1); cx0 = K(1,3); fy = K(2,2); cy0 = K(2,3);

    if((PreIntegration_options.bUVonly == 1) || (PreIntegration_options.bPreInt == 1))
        idx = (nPoses-1)*6;
    else
        nIMUdata = ImuTimestamps(nPoses)-ImuTimestamps(1);
        idx = (nIMUdata)*6;%(nPoses-1)*nIMUrate
    end
    
    %p3d0 = reshape(X((idx+1):(idx+3*nPts), 1), 3, []);
    p3d0 = X.feature;
    e = Zobs;
    
    % index of Au2c, Tu2c
    if(PreIntegration_options.bUVonly == 1)
        idx = (nPoses-1)*6+nPts*3;
    else
        if(PreIntegration_options.bPreInt == 1)
            idx = ((nPoses-1)*6+nPts*3+3*nPoses+3);%(nPoses-1)*6+nPts*3+3*nPoses + 9
        else
            idx = (nIMUdata)*6+3*nPts+3*(nIMUdata+1)+3;%(nPoses-1)*nIMUrate ((nPoses-1)*nIMUrate+1)
        end
    end
    
    %alpha = X(idx+1);beta = X(idx + 2); gamma = X(idx + 3);
    alpha = X.Au2c.val(1); beta = X.Au2c.val(2); gamma = X.Au2c.val(3);
    Ru2c = fnRFromABG(alpha, beta, gamma);
    %Tu2c = X((idx+4):(idx+6));
    Tu2c = X.Tu2c.val;
    nUV = 0;
    % Reprojection at each pose
    nfs = size(RptFeatureObs,1);
    
    for(fid=1:nfs)        
        nObs = RptFeatureObs(fid).nObs;
        
        for(oid=1:nObs)            
            
            pid = RptFeatureObs(fid).obsv(oid).pid; 
            
            if(pid > nPoses)
                break;
            elseif(pid > 1)
                
                if((PreIntegration_options.bUVonly == 1) ||(PreIntegration_options.bPreInt == 1))
                    idx = (pid-2)*6;
                else
                    idx = (ImuTimestamps(pid)-ImuTimestamps(1)-1)*6;%  (pid-1)*nIMUrate -6???
                end
                
                %alpha = X(1+idx); beta = X(2+idx); gamma = X(3+idx); 
                %Tu = X((4+idx):(idx+6), 1);
                Au = X.pose(pid-1).ang.val;
                alpha = Au(1); beta = Au(2); gamma = Au(3);
                Tu = X.pose(pid-1).trans.xyz;
                Ru = fnRFromABG(alpha, beta, gamma);%Rx(alpha) * fRy (beta) * fRz(gamma);
                
            else % Pose 1 is special                
                Tu = zeros(3,1); 
                Ru = eye(3);                
            end
            
            Rc = Ru2c * Ru;
            Tc = Tu + (Ru)' * Tu2c;
            %ncurrentObsdPts = 1;%size(obsfeatures{pid}, 1);    
            %p3d1 = Rc * (p3d0(:, fid) - repmat(Tc, 1, ncurrentObsdPts));
            %u1 = fx * p3d1(1, :) ./ p3d1(3, :) + repmat(cx0, 1, ncurrentObsdPts);
            %v1 = fy * p3d1(2, :) ./ p3d1(3, :) + repmat(cy0, 1, ncurrentObsdPts);
            p3d1 = Rc * ( p3d0(fid).xyz - Tc );
            u1 = fx * p3d1(1) / p3d1(3) + cx0;
            v1 = fy * p3d1(2) / p3d1(3) + cy0;
        %     d1 = p3d1(3, :);
        %     et = [u1;v1;d1];
        
            %et = [u1;v1];
            %et = et(:);%nPts*2*(pid-1)%nPts*2*pid
            %e((nUV+1):(nUV+2*ncurrentObsdPts), 1) = et - Zobs((nUV+1):(nUV+2*ncurrentObsdPts), 1);    
            %nUV = nUV + 2*ncurrentObsdPts;
            nUV = nUV + 1;
            e.fObs(nUV).uv = [u1;v1] - Zobs.fObs(nUV).uv;        
        end
    end
    