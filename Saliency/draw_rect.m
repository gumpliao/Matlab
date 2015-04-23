function [state,result]=draw_rect(img,startPosition,windowSize,showOrNot)
% �������ã�[state,result]=draw_rect(img,startPosition,windowSize,showOrNot)
% �������ܣ���ͼ�񻭸������ο�
% �������룺imgΪԭʼ�Ĵ�ͼ����Ϊ�Ҷ�ͼ����Ϊ��ɫͼ
%          startPosition ������Ͻ��ڴ�ͼ�е�����(ÿ�д���x,y����)��startPosition=[10,30],�ֱ��ʾx,yΪ10,30
%          windowSize ��Ĵ�С windowSize=[112,92] �ֱ��ʾ����
%          showOrNot �Ƿ�Ҫ��ʾ���?Ĭ��Ϊ��ʾ����?
% ���������state -- ��ʾ������״̬?
%          result - ���ͼ������ 


if nargin < 4
    showOrNot = 1;
end

rgb = [255 0 0];                                 % �߿���ɫ
lineSize = 1;                                      % �߿��С��ȡ1,2,3

windowSize(1,1)=windowSize(1,1);
windowSize(1,2) = windowSize(1,2);
if windowSize(1,2) > size(img,1) ||...
        windowSize(1,1) > size(img,2)
    state = -1;                                     % ˵������̫��ͼ��̫С��
    disp('the window size is larger then image...');
    return;
end

result = img;
if size(img,3) == 3
    for k=1:3
        for i=1:size(startPosition,1) %���ο������
			if(startPosition(i,1)>=0 && startPosition(i,2)>=0)
				result(startPosition(i,2),startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k); %���ϱ߿�  
				result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);%���ұ߿�
				result(startPosition(i,2)+windowSize(i,2),startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);  %���±߿�   
				result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1),k) = rgb(1,k);   %����߿�  
			
				if lineSize == 2 || lineSize == 3
					result(startPosition(i,2)+1,startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);  
					result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1)+windowSize(i,1)-1,k) = rgb(1,k);
					result(startPosition(i,2)+windowSize(i,2)-1,startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);
					result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1)-1,k) = rgb(1,k);
				
					if lineSize == 3
						result(startPosition(i,2)-1,startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);   
						result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1)+windowSize(i,1)+1,k) = rgb(1,k);
						result(startPosition(i,2)+windowSize(i,2)+1,startPosition(i,1):startPosition(i,1)+windowSize(i,1),k) = rgb(1,k);
						result(startPosition(i,2):startPosition(i,2)+windowSize(i,2),startPosition(i,1)+1,k) = rgb(1,k);
					end
				end
			end
        end
    end
end

state = 1;

if showOrNot == 1
    figure;
	hold on;
    imshow(result);
end