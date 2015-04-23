function confusionMatrix = processVideoFolderR(videoPath, binaryFolder)
    % A video folder should contain 2 folders ['input', 'groundtruth']
	% and the "temporalROI.txt" file to be valid. The choosen method will be
	% applied to all the frames specified in \temporalROI.txt
    
    range = readTemporalFile(videoPath);
    idxFrom = 2;
    idxTo = range(2);
    inputFolder = fullfile(videoPath, 'input');
    display(['Comparing ', videoPath, ' with ', inputFolder, char(10), 'From frame ' ,  num2str(idxFrom), ' to ',  num2str(idxTo), char(10)]);

    % Compare your images with the groundtruth and compile statistics
    groundtruthFolder = fullfile(videoPath, 'groundtruth');
    confusionMatrix = compareImageFiles(groundtruthFolder, binaryFolder, idxFrom, idxTo);
    
    
end
function range = readTemporalFile(path)
    % Reads the temporal file and returns the important range
    
    fID = fopen([path, '\temporalROI.txt']);
    if fID < 0
        disp(ferror(fID));
        exit(0);
    end
    
    C = textscan(fID, '%d %d', 'CollectOutput', true);
    fclose(fID);
    
    m = C{1};
    range = m';
end

function confusionMatrix = compareImageFiles(gtFolder, binaryFolder, idxFrom, idxTo)
    % Compare the binary files with the groundtruth files.
    
    extension = '.png'; % TODO Change extension if required
    threshold = strcmp(extension, '.jpg') == 1 || strcmp(extension, '.jpeg') == 1;
    
    imBinary = imread(fullfile(binaryFolder, ['bin', num2str(idxFrom, '%.6d'), extension]));
    if size(imBinary, 3) > 1
            imBinary = rgb2gray(imBinary);
    end
    int8trap = isa(imBinary, 'uint8') && min(min(imBinary)) == 0 && max(max(imBinary)) == 1;
    
    confusionMatrix = [0 0 0 0 0]; % TP FP FN TN SE
    for idx = idxFrom:idxTo
        fileName = num2str(idx, '%.6d');
        imBinary = imread(fullfile(binaryFolder, ['bin', fileName, extension]));
        if size(imBinary, 3) > 1
            imBinary = rgb2gray(imBinary);
        end
        if islogical(imBinary) || int8trap
            imBinary = uint8(imBinary)*255;
        end
        if threshold
            imBinary = im2bw(imBinary, 0.5);
            imBinary = im2uint8(imBinary);
        end
        imGT = imread(fullfile(gtFolder, ['gt', fileName, '.png']));
        if size(imGT, 3) > 1
            imGT = rgb2gray(imGT);
        end
        confusionMatrix = confusionMatrix + compare(imBinary, imGT);
    end
end

function confusionMatrix = compare(imBinary, imGT)
    % Compares a binary frames with the groundtruth frame
    
    TP = sum(sum(imGT==255&imBinary==255));		% True Positive 
    TN = sum(sum(imGT<=50&imBinary==0));		% True Negative
    FP = sum(sum((imGT<=50)&imBinary==255));	% False Positive
    FN = sum(sum(imGT==255&imBinary==0));		% False Negative
    SE = sum(sum(imGT==50&imBinary==255));		% Shadow Error
    
    
    
    confusionMatrix = [TP FP FN TN SE];
end