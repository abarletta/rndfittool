function fmtStr=readFields(fname);
%% readFields - reading data structure from text file
%
% fmtStr=readFields(fname)
%
% Input:
%         fname - name of text file to be read
% Output
%        fmtStr - structure array with following fields
%               'Title','Description','Author','Institution','Mail','Version'
%
% Example:
%
% * Create a file 'contacts.txt' containing the following text 
%   (without spaces at beginning of every row)
%
%      \\Suggested contact:\\
%      A:John Smith;
%      D:Public relations;
%      I:Abcdefg.inc, New York;
%      M:jsmith@abcdefg.us
%      \\Other contacts:\\
%      A:Jane Williams;
%      D:Office Desk;
%      I:Abcdefg.inc, New York;
%      M:jwilliams@abcdefg.us
%      &
%      A:Tom Miller;
%      D:Office Desk;
%      I:Abcdefg.inc, New York;
%      M:tmiller@abcdefg.us
%
% * Run
%
%      str=readFields('contacts.txt');
%
% * Obtained output
% 
% str(1)
%
% ans = 
% 
%           Title: 'Suggested contact:'
%          Author: 'John Smith'
%     Description: 'Public relations'
%     Institution: 'Abcdefg.inc, New York'
%            Mail: 'jsmith@abcdefg.us'
% 
% str(2)
% 
% ans = 
% 
%           Title: 'Other contacts:'
%          Author: 'Jane Williams'
%     Description: 'Office Desk'
%     Institution: 'Abcdefg.inc, New York'
%            Mail: 'jwilliams@abcdefg.us'
% 
% str(3)
% 
% ans = 
% 
%           Title: []
%          Author: 'Tom Miller'
%     Description: 'Office Desk'
%     Institution: 'Abcdefg.inc, New York'
%            Mail: 'tmiller@abcdefg.us'


% Author:
%
% Andrea Barletta
% abarletta@econ.au.dk

fid=fopen(fname,'r');
str=textscan(fid,'%s','Delimiter',';');
str=str{1};
fclose(fid);

nl=[];
for i=1:length(str)
    tmp=strfind(str{i},'\\');
    if (isempty(tmp)==0)&&(length(tmp)==2)
        nl=[nl i];
    end
    tmp=strfind(str{i},'&');
    if isempty(tmp)==0
        nl=[nl i];
    end
end   

tags={'A:','D:','I:','M:','V:'};
labels={'Author','Description','Institution','Mail','Version'};
fmtStr=struct;
ind=0;
for i=1:length(str)
    if (ind+1<=length(nl))&&(i==nl(ind+1))
        ind=ind+1;
        if length(str{i})>1
            fmtStr(ind).Title=str{i}(3:end-2);
        else
            fmtStr(ind).Title='&';
        end
    else
        for j=1:length(tags)
            tmp=strfind(str{i},tags{j});
            if isempty(tmp)==0
                fmtStr(ind).(labels{j})=str{i}(3:end);
            end
        end
    end
end
   
end