%% findKernels - determining valid kernels in target folder
% [kernelList, kernelLabels, fileNames, errLog] = findKernels(tgtPth)

function [kernelList, kernelLabels, fileNames, errLog] = findKernels(tgtPth)

kernelList={};
kernelLabels={};
fileNames={};
errLog={};

fileList=dir(tgtPth);
for i=1:length(fileList)
    if length(fileList(i).name)>=5
        if strcmp(fileList(i).name(end-3:end),'.mat')==1
            load([tgtPth '\' fileList(i).name]);
            flag=1;
            if (isfield(kernelDensity,'name')==0)|| ...
                    (isfield(kernelDensity,'parameters')==0)|| ...
                    (isfield(kernelDensity,'pdf')==0)|| ...
                    (isfield(kernelDensity,'kerpar0')==0)|| ...
                    (isfield(kernelDensity,'label')==0)
                
                flag=0;
                errLog=[errLog; 'Structure in file ' fileList(i).name ' does not possess required fields.'];
            end
            
            if flag==1
                try
                    if (isfield(kernelDensity.parameters,'infVal')==0)|| ...
                            (isfield(kernelDensity.parameters,'supVal')==0)
                        flag=0;
                        errLog=[errLog; 'Structure of parameters in file ' fileList(i).name ' does not possess required fields.'];
                    end
                    
                    if strcmp(kernelDensity.label,fileList(i).name(1:end-4))==0
                        flag=0;
                        errLog=[errLog; 'Kernel label does not match filename ' fileList(i).name '.'];
                    end
                catch ME
                    flag=0;
                    errLog=[errLog; 'Structure of parameters in file ' fileList(i).name ' does not possess required fields.'];
                end
            end
            
            if flag==1
                kernelList=[kernelList; kernelDensity.name];
                kernelLabels=[kernelLabels; fileList(i).name(1:end-4)];
                fileNames=[fileNames;fileList(i).name];
            end
        end
        
    end
end

