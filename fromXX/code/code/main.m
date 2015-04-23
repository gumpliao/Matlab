if ~exist('EVA','var')
    clear variables
end
close all

Debug=0;    %don't use
if ~exist('EVA','var')
DefTransType=2;  %1:artificial; 2:image pair
end

DefMode=1;
%0:normal 
%1:Multiscale
MultiHeight=5;  MultiDebug=0;
%2:Region Based
RegionNum=[2 2];  GlobalCorrection=1; method.Global=1; method.Local=0;

TransType=DefTransType;
OUTPUT=~exist('EVA','var'); %no output when test in batch
DefRestrainTrans=0;
Print=OUTPUT&1; %cmd output
DefShowFinallDiff=OUTPUT&1;    DefShowVelocity=OUTPUT&1;  DefShowGroundTruth=OUTPUT&1;  interval=25; %visual output
DefShowD=OUTPUT&0; 
DefEstErr=1;  %get mae and mme?
DefExhibit=OUTPUT&1; %show orignal image or noised image

if ~exist('EVA','var')
DefNoisy=0; Noise=0.07;%0.07 0.0018 0.005 0.018 Noise=10;
DefExpand=1;
end
DefNoisyBefore=0;
Expand=20;
DefBlurBefore=1;DefBlurAfter=0;    Blur=5;
DefTest=0;  %don't use

theta=0:30:179;
% theta=[0 30 60 90 120 150];
% theta=[0 45 90 135];

%show debug info?
debug.DefShowImgs    =0;  debug.DefShowRadon   =0;  debug.DefShowItheta  =0;
debug.DefShowRItheta =0;  debug.DefShowGtheta  =0;  debug.DefSavePlot=0; debug.expand=Expand;

if ~exist('EVA','var');
img1 = 'in000007.jpg';
img2 = 'in000008.jpg';
%   img1='circle.jpg';%img1='gaussf.bmp';  %img1='cross.bmp';
%    img1='test.jpg';
%   img1='test1.jpg';
%  img1='forest3.bmp';
%  img1='office.bmp';
%  img1='brain.png';
%   img1='lena.jpg';
%  img1='gaussiannoise.bmp';
%  img1='square.bmp';
%  img1='gradualsquare.bmp';

% img1='8images\1.jpg';
%    img1='new2binarytreed-20.tif';
%    img2='new2binarytreed-21.tif';
% %    
%    img1='new2binarytreet-34.tif';
%    img2='new2binarytreet-35.tif';
%    img1='cones_left.ppm';
%    img2='cones_right.ppm';
%    img1='left.ppm';
%     img2='right.ppm';
%     img1='teddy_left.ppm';
%     img2='teddy_right.ppm';
% img1='venus_left.ppm';
% img2='venus_right.ppm';

%     img1='yosemite07.png';
%     img2='yosemite08.png';
    

%   M=[0.07   -0.12
%      0.09   0.1];
%   V=[1   2];
  M=[0.02   0.010
     0.20   0.04];
  V=[0.1   0.2];
%     M=[0.05   0.010
%      0.080   0.04];
%   V=[10.0   20.0];
%   M=[0.05   0.010
%      0.010   0.06];
%   V=[0.5   0.5];
%  M=[0.1   0.120
%      0.090   -0.2];
%   V=[3   0.5];
  
%     M=[0.05   0.010
%      0.080   0.04];
%   V=[10.0   20.0];

%  M=[-0.3   0.120
%     0.120   -0.5];
%   V=[10.0   20.0];
% M=[0.006 0.068
%     -0.034 0.012];
% V=[0.1 0.2];

% angle=20;
% M=[cos(angle*pi/180)-1   -sin(angle*pi/180)
%    sin(angle*pi/180)   cos(angle*pi/180)-1];
% V=[0 0];
end

while(DefTransType==1)

     I1 = (imread(img1));          
     if size(I1, 3)~=1
         I1 = rgb2gray(I1);
     end
%      I1_ori=I1;

    if DefExhibit==1
        A(1:2,1:2)=eye(2)+M';
        A(3,1:2)=V;
%         I1o=flipud(I1);
        picCenter=floor((size(I1)+1)/2);
        T=maketform('affine',A);
        I2o=imtransform(I1,T,'FillValues',255,'UData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'VData',[size(I1,1)-picCenter(1),-picCenter(1)+1],...
    'XData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'YData',[size(I1,1)-picCenter(1),-picCenter(1)+1],'Size',size(I1));
%         I2o=flipud(I2o);
        I1o=I1;
        figure('Name','original image');
        imshow(I1o);
        axis off
        figure('Name','deformed image');
        imshow(I2o);
        axis ij
    end

     if DefExpand==1
        I1tmp=zeros(size(I1)+2.*[Expand Expand]);
        I1tmp(Expand+1:end-Expand,Expand+1:end-Expand)=I1;
        I1=uint8(I1tmp);
%                 I2tmp=zeros(size(I2)+2.*[Expand Expand]);
%         I2tmp(Expand+1:end-Expand,Expand+1:end-Expand)=I2;
%         I2=uint8(I2tmp);
     end
    
    if DefBlurBefore==1
%         w=fspecial('gaussian',[10 10],10);
        w=fspecial('average',[Blur Blur]);
        I1=imfilter(I1,w);
    end

    if DefNoisyBefore==1
        %     I2_ori=I2;
        I1tmp=I1;
        I1=imnoise(I1,'gaussian',0,Noise);
        snr1=SNR(double(I1tmp),double(I1));
        if Print~=0
            fprintf('SNR1:%f\n',snr1);
        end
    end
    
% I1=edge(I1,'canny');

%     I1=double(I1)/255;
%     p = I1;
%     r = 4; % try r=2, 4, or 8
%     eps = 0.2^2; % try eps=0.1^2, 0.2^2, 0.4^2
%     q = guidedfilter(I1, p, r, eps);
%     figure();
%     I1=q*255;
if Print~=0
    !echo ==============================================
    fprintf('img:%s \nimgSize:[%d %d] TransType:1 UseMultiscale:%d\n',...
            img1,...
            size(I1,1),size(I1,2),DefMode);
end
    A(1:2,1:2)=eye(2)+M';
    A(3,1:2)=V;

    picCenter=floor((size(I1)+1)/2);
    T=maketform('affine',A);
    I2=imtransform(I1,T,'FillValues',0,'UData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'VData',[size(I1,1)-picCenter(1),-picCenter(1)+1],...
    'XData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'YData',[size(I1,1)-picCenter(1),-picCenter(1)+1],'Size',size(I1));
   
    if DefNoisy==1
        %     I2_ori=I2;
        I1tmp=I1;I2tmp=I2;
        I1=imnoise(I1,'gaussian',0,Noise);
        I2=imnoise(I2,'gaussian',0,Noise);

        % I1=awgn(double(I1),Noise,'measured');I2=awgn(double(I2),Noise,'measured');

        % I1=AddGaussianNoise(I1,20);I2=AddGaussianNoise(I2,20);
        snr1=SNR(double(I1tmp),double(I1));snr2=SNR(double(I2tmp),double(I2));
        if Print~=0
            fprintf('SNR1:%f SNR2:%f\n',snr1,snr2);
        end
    end
    
    if DefBlurAfter==1
%         w=fspecial('gaussian',[5 5],3);
        w=fspecial('average',[Blur Blur]);
        I1=imfilter(I1,w);
        I2=imfilter(I2,w);
    end
%     figure
%     imshow(I2);

%     I1=double(I1)/255;
%     I2=double(I2)/255;
%     p1 = I1;p2=I2;
%     r = 2; % try r=2, 4, or 8
%     eps = 0.1^2; % try eps=0.1^2, 0.2^2, 0.4^2
%     q1 = guidedfilter(I1, p1, r, eps);
%     q2 = guidedfilter(I2, p2, r, eps);
%     I1=q1*255;I2=q2*255;

    DefTransType=0;
end
while(DefTransType==2)
   
    I1=(imread(img1));
    I2=(imread(img2));
    if size(I1, 3)~=1
        I1 = rgb2gray(I1);
    end
    if size(I2, 3)~=1
        I2 = rgb2gray(I2);
    end
    if DefExhibit==1
        I1o=I1;
        I2o=I2;
        figure('Name','original image');
        imshow(I1o);
        axis off
        figure('Name','deformed image');
        imshow(I2o);
        axis ij
    end
%     I1_ori=I1;I2_ori=I2;
%      I1=I1';
%      I2=I2';
%     w=fspecial('gaussian',[10 10],10);
%     w=fspecial('average',[2 2]);
%     I1=imfilter(I1,w);
%     I2=imfilter(I2,w);

%     I1=double(I1)/255;
%     I2=double(I2)/255;
%     p1 = I1;p2=I2;
%     r = 2; % try r=2, 4, or 8
%     eps = 0.1^2; % try eps=0.1^2, 0.2^2, 0.4^2
%     q1 = guidedfilter(I1, p1, r, eps);
%     q2 = guidedfilter(I2, p2, r, eps);
%     I1=q1*255;I2=q2*255;
   
    if DefExpand==1
        I1tmp=zeros(size(I1)+[20 20]);
        I1tmp(11:end-10,11:end-10)=I1;
        I1=uint8(I1tmp);
        I2tmp=zeros(size(I2)+[20 20]);
        I2tmp(11:end-10,11:end-10)=I2;
        I2=uint8(I2tmp);
    end
    if Print~=0
        !echo ==============================================
            fprintf('img1:%s img2:%s\nimgSize:[%d %d] TransType:2 UseMultiscale:%d\n',...
            img1,img2,...
            size(I1,1),size(I1,2),DefMode);
    end
    if DefNoisy==1
        %     I2_ori=I2;
        I1tmp=I1;I2tmp=I2;
        I1=imnoise(I1,'gaussian',0,Noise);
        I2=imnoise(I2,'gaussian',0,Noise);

        % I1=awgn(double(I1),Noise,'measured');I2=awgn(double(I2),Noise,'measured');

        % I1=AddGaussianNoise(I1,20);I2=AddGaussianNoise(I2,20);
        snr1=SNR(double(I1tmp),double(I1));snr2=SNR(double(I2tmp),double(I2));
        if Print~=0
            fprintf('SNR1:%f SNR2:%f\n',snr1,snr2);
        end
    end
    if DefBlurAfter==1
%         w=fspecial('gaussian',[10 10],10);
        w=fspecial('average',[Blur Blur]);
        I1=imfilter(I1,w);
        I2=imfilter(I2,w);
    end
    
    %         I1=I1(145:288,193:384);I2=I2(145:288,193:384);
%         I1=I1(1:144,193:384);I2=I2(1:144,193:384);
    DefTransType=0;
end

% ang=0;mag=0;time=0
% return

tic
v0='null'; m='null';
if Debug==1
    if DefMode==0
        [v0,m]=EstimateAffineD(I1,I2,theta,debug,DefRestrainTrans);
    elseif DefMode==1
        [v0,m,vx,vy]=MultiscaleD(I1,I2,MultiHeight-1,MultiDebug,theta,debug,DefRestrainTrans);
    elseif DefMode==2
        [v0reg,mreg,vx,vy,regionRows,regionCols]=...
            RegionBasedD(I1,I2,RegionNum,GlobalCorrection,theta,debug,DefRestrainTrans,method);
    end
else
    if DefMode==0
        [v0,m]=EstimateAffine(I1,I2,theta,DefRestrainTrans);
    elseif DefMode==1
        [v0,m,vx,vy]=Multiscale(I1,I2,MultiHeight-1,theta,DefRestrainTrans);
    elseif DefMode==2
        [v0reg,mreg,vx,vy,regionRows,regionCols]=...
            RegionBased(I1,I2,RegionNum,GlobalCorrection,theta,DefRestrainTrans,method);
    end
end

if DefTest==1
dx1=floor((vx(1,1)+vx(end,1))/2);dx2=floor((vx(1,end)+vx(end,end))/2);
dy1=floor((vy(end,1)+vy(end,end))/2);dy2=floor((vy(1,1)+vx(1,end))/2);
I1(:,1:-dx1)=0;
I1(:,end-dx2:end)=0;
I1(1:dy2,:)=0;
I1(end+dy1:end,:)=0;
[v0,m,vx,vy]=Multiscale(I1,I2,MultiHeight-1,theta,DefRestrainTrans);
end
time=toc;

if Print~=0
fprintf('time:%f',time);
disp(' ');
disp('v0 = ');
disp(v0);
disp('m = ');
disp(m);
end

DefShowFinallDiff=DefShowFinallDiff&~((DefMode==1)&MultiDebug);
if DefShowFinallDiff==1 && (DefMode==0||DefMode==1) 
    if DefExhibit==1
        A(1:2,1:2)=(eye(2)+m')^-1;
        A(3,1:2)=-v0*A(1:2,1:2);
        picCenter=floor((size(I1o)+1)/2);
        T=maketform('affine',A);
        I3=imtransform(I2o,T,'FillValues',0,'UData',[-picCenter(2)+1,size(I1o,2)-picCenter(2)],'VData',[size(I1o,1)-picCenter(1),-picCenter(1)+1],...
        'XData',[-picCenter(2)+1,size(I1o,2)-picCenter(2)],'YData',[size(I1o,1)-picCenter(1),-picCenter(1)+1],'Size',size(I1o));
        figure;
        imshow(abs(I1o-I3),[]);
    else
        A(1:2,1:2)=(eye(2)+m')^-1;
        A(3,1:2)=-v0*A(1:2,1:2);
        picCenter=floor((size(I1)+1)/2);
        T=maketform('affine',A);
        I3=imtransform(I2,T,'FillValues',0,'UData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'VData',[size(I1,1)-picCenter(1),-picCenter(1)+1],...
        'XData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'YData',[size(I1,1)-picCenter(1),-picCenter(1)+1],'Size',size(I1));
        figure;
        imshow(abs(I1-I3),[]);
    end
%     title('diff');
end

%====motion field: estimation and groundtruth==============================
    picCenter=floor((size(I1)+1)/2);
    [X,Y]=meshgrid(-picCenter(2)+1:size(I1,2)-picCenter(2),...size(I1,2)/10
            size(I1,1)-picCenter(1):-1:-picCenter(1)+1);
    vxc=zeros(size(X));vyc=zeros(size(X));
    
    if  DefMode==0
%         vx=zeros(size(X));vy=zeros(size(X));
%         for i=1:size(X,1)
%             for j=1:size(X,2)
%                 v=v0'+m*[X(i,j) Y(i,j)]';
%                 vx(i,j)=v(1);  vy(i,j)=v(2);
%             end
%         end
        vx=m(1,1)*X+m(1,2)*Y+v0(1);
        vy=m(2,1)*X+m(2,2)*Y+v0(2);
    end
    
    if TransType==1        
%         for i=1:size(X,1)
%             for j=1:size(X,2)
%                 v=V'+M*[X(i,j) Y(i,j)]';
%                 vxc(i,j)=v(1); vyc(i,j)=v(2);
%             end
%         end
        vxc=M(1,1)*X+M(1,2)*Y+V(1);
        vyc=M(2,1)*X+M(2,2)*Y+V(2);

    elseif TransType==2 && strncmp(img1,'new2binarytreed',15)      
        ff=fopen('Div20_ux_150x150_float32.raw');
        raw=fread(ff,'*float32');
%         vxc=zeros(150,150);
        for i=1:150
            for j=1:150
                vxc(i,j)=raw((i-1)*150+j);
            end
        end
        ff=fopen('Div20_uy_150x150_float32.raw');
        raw=fread(ff,'*float32');
%         vyc=zeros(150,150);
        for i=1:150
            for j=1:150
                vyc(i,j)=raw((i-1)*150+j);
            end
        end
        
    elseif TransType==2 && strncmp(img1,'new2binarytreet',15)      
        ff=fopen('Trans20_ux_150x150_float32.raw');
        raw=fread(ff,'*float32');
%         vxc=zeros(150,150);
        for i=1:150
            for j=1:150
                vxc(i,j)=raw((i-1)*150+j);
            end
        end
        ff=fopen('Trans20_uy_150x150_float32.raw');
        raw=fread(ff,'*float32');
%         vyc=zeros(150,150);
        for i=1:150
            for j=1:150
                vyc(i,j)=raw((i-1)*150+j);
            end
        end
        
   elseif TransType==2 && strncmp(img1,'left',4)
        s=load('final_labels.mat');
        final_labels=s.final_labels;
%         vxc=zeros(size(I1));
        for i=1:size(I1,1)
            for j=1:size(I1,2)
                vxc(i,j)=-final_labels(i,j);
            end
        end
%         vyc=zeros(size(I1));
%         for i=1:size(I1,1)
%             for j=1:size(I1,2)
%                 vyc(i,j)=0;
%             end
%         end
    elseif TransType==2 && strncmp(img1,'yosemite',8)
        s=load('yosemite.mat');
        vxc=s.flow.vx;
        vyc=s.flow.vy;
    end
    
    fclose('all');
%==========================================================================

%=========show motion field==========
if DefShowVelocity==1
    
%     picCenter=floor((size(I1)+1)/2);
%     [X_disp,Y_disp]=meshgrid(-picCenter(2)+1:interval:size(I1,2)-picCenter(2),...size(I1,2)/10
%             size(I1,1)-picCenter(1):-interval:-picCenter(1)+1);%size(I1,1)/10
    X_disp=X(1:interval:end,1:interval:end);
    Y_disp=Y(1:interval:end,1:interval:end);

%     if DefMode==0
%         vx_disp=zeros(size(X_disp));vy_disp=zeros(size(X_disp));
%         for i=1:size(X_disp,1)
%             for j=1:size(X_disp,2)
%                 v=v0'+m*[X_disp(i,j) Y_disp(i,j)]';
%                 vx_disp(i,j)=v(1);
%                 vy_disp(i,j)=v(2);
%             end
%         end
%     elseif DefMode==2||DefMode==1
        vx_disp=vx(1:interval:end,1:interval:end);
        vy_disp=vy(1:interval:end,1:interval:end);
%     end

    iptsetpref('ImshowAxesVisible','on')
    figure;

    if DefExhibit==1
%         I1show=I1(Expand+1:end-Expand,Expand+1:end-Expand);
        picCenterShow=floor((size(I1o)+1)/2);
        imshow(I1o,[],'XData',[-picCenterShow(2)+1,size(I1o,2)-picCenterShow(2)],'YData',[size(I1o,1)-picCenterShow(1),-picCenterShow(1)+1]);
    else
        imshow(I1,[],'XData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'YData',[size(I1,1)-picCenter(1),-picCenter(1)+1]);
    end
    
    axis xy
    hold on
    
    quiver(X_disp,Y_disp,vx_disp,vy_disp,'-r');
    
    if DefShowGroundTruth==1
        vxc_disp=vxc(1:interval:end,1:interval:end);
        vyc_disp=vyc(1:interval:end,1:interval:end);
        quiver(X_disp,Y_disp,vxc_disp,vyc_disp,'-g');
    end
    
    if DefMode==2
        for i=2:size(regionRows,2)-1
            plot([-picCenter(2)+1,size(I1,2)-picCenter(2)],[regionRows(i)-picCenter(1)+1,regionRows(i)-picCenter(1)+1],'-g');
        end
        for i=2:size(regionCols,2)-1
             plot([regionCols(i)-picCenter(2)+1,regionCols(i)-picCenter(2)+1],[-picCenter(2)+1,size(I1,2)-picCenter(2)],'-g');
        end
    end    
    

        
%     if TransType==1
%         vxc_disp=zeros(size(X_disp));vyc_disp=zeros(size(X_disp));
%         for i=1:size(X_disp,1)
%             for j=1:size(X_disp,2)
%                 v=V'+M*[X_disp(i,j) Y_disp(i,j)]';
%                 vxc_disp(i,j)=v(1);
%                 vyc_disp(i,j)=v(2);
%             end
%         end
%         quiver(X_disp,Y_disp,vxc_disp,vyc_disp,'-g');
%     elseif TransType==2
%         
%     end
    
    hold off
     
    %=========show disparity==========
    if DefShowD==1
        d=zeros(size(vx));
        for i=1:size(vx,1)
            for j=1:size(vx,2)
                d(i,j)=norm([vx(i,j),vy(i,j)],2);
            end
        end
        figure;
        imshow(d,[],'XData',[-picCenter(2)+1,size(I1,2)-picCenter(2)],'YData',[-picCenter(1)+1,size(I1,1)-picCenter(1)]);
        colormap(hot), colorbar
    end
end

%=========MAE and MME==========
if DefEstErr==1
%     ang=-1; mag=-1;
%     if TransType==1 && DefMode~=2
%         [ang mag]=ComputeErr(I1,M,V,m,v0);
%
%     elseif TransType==2 && strncmp(img1,'new2binarytreed',14) && DefMode~=2        
%         ff=fopen('Div20_ux_150x150_float32.raw');
%         raw=fread(ff,'*float32');
%         VX=zeros(150,150);
%         for i=1:150
%             for j=1:150
%                 VX(i,j)=raw((i-1)*150+j);
%             end
%         end
%         ff=fopen('Div20_uy_150x150_float32.raw');
%         raw=fread(ff,'*float32');
%         VY=zeros(150,150);
%         for i=1:150
%             for j=1:150
%                 VY(i,j)=raw((i-1)*150+j);
%             end
%         end
%      
%         [ang mag]=ComputeErr(I1,VX,VY,m,v0);
%         
%    elseif TransType==2 && strncmp(img1,'left',4) && DefMode~=2        
%         s=load('final_labels.mat');
%         final_labels=s.final_labels;
%         VX=zeros(size(I1));
%         for i=1:size(I1,1)
%             for j=1:size(I1,2)
%                 VX(i,j)=final_labels(i,j)/2^0.5;
%             end
%         end
%         VY=zeros(size(I1));
%         for i=1:size(I1,1)
%             for j=1:size(I1,2)
%                 VY(i,j)=final_labels(i,j)/2^0.5;
%             end
%         end
%      
%         [~, mag]=ComputeErr(I1,VX,VY,m,v0);
%         ang=-1;
%         
%    elseif TransType==2 && strncmp(img1,'left',4) && DefMode==2        
%         s=load('final_labels.mat');
%         final_labels=s.final_labels;
%         VX=zeros(size(I1));
%         for i=1:size(I1,1)
%             for j=1:size(I1,2)
%                 VX(i,j)=final_labels(i,j)/2^0.5;
%             end
%         end
%         VY=zeros(size(I1));
%         for i=1:size(I1,1)
%             for j=1:size(I1,2)
%                 VY(i,j)=final_labels(i,j)/2^0.5;
%             end
%         end
%      
%         [~, mag]=ComputeErr(I1,VX,VY,vx,vy);
%         ang=-1;
%         
%     elseif  TransType==1 && DefMode==2
%         [ang mag]=ComputeErr(I1,M,V,vx,vy);
%         
%     elseif  TransType==2 && DefMode==2 && strncmp(img1,'new2binarytreed',14)
%          ff=fopen('Div20_ux_150x150_float32.raw');
%          raw=fread(ff,'*float32');
%          VX=zeros(150,150);
%          for i=1:150
%              for j=1:150
%                  VX(i,j)=raw((i-1)*150+j);
%              end
%          end
%          ff=fopen('Div20_uy_150x150_float32.raw');
%          raw=fread(ff,'*float32');
%          VY=zeros(150,150);
%          for i=1:150
%              for j=1:150
%                  VY(i,j)=-raw((i-1)*150+j);
%              end
%          end
%      
%         [ang mag]=ComputeErr(I1,VX,VY,vx2,vy2);
%     end
%     [ang mag]=ComputeErr(I1,vxc,vyc,vx,vy);
    ang=0;mag=0;
    for i=1:size(X,1)
        for j=1:size(X,2)
            Ve=[vx(i,j) vy(i,j) 1];
            Vc=[vxc(i,j) vyc(i,j) 1];
            ang=ang+acos(Ve*Vc'/(norm(Vc,2)*norm(Ve,2)));
            mag=mag+abs(norm(Vc,2)-norm(Ve,2));
        end
    end        
    ang=180*ang/(size(X,1)*size(X,2))/pi;
    mag=mag/(size(X,1)*size(X,2));
    
    if Print~=0
        fprintf('ang=%f  mag=%f\n',ang,mag);
    end
end
