function convertRes

INPUT_DIR = './res/ADE';
OUTPUT_DIR = './data-USA/res/ADE/';
if ~exist(OUTPUT_DIR, 'dir'), mkdir(OUTPUT_DIR); end

setfolders = dir([INPUT_DIR, '/set*']);
for i=1:length(setfolders)
    folder = setfolders(i).name; setID = str2double(setfolders(i).name(4:5));
    outputSetFolder = [OUTPUT_DIR,'/',setfolders(i).name];
    if ~exist(outputSetFolder,'dir'), mkdir(outputSetFolder); end
    vfolders = dir([INPUT_DIR, '/', folder, '/V*']);
    for j=1:length(vfolders)
        dats = [];
        folder1 = vfolders(j).name; vID = str2double(vfolders(j).name(2:4));
        Ifiles = dir([INPUT_DIR, '/', folder, '/', folder1, '/I*']);
        for k=1:length(Ifiles)
            IfileID = str2double(Ifiles(k).name(2:6));
            tmp = load([INPUT_DIR, '/', folder, '/', folder1, '/', Ifiles(k).name]);
            dats = [dats; repmat(IfileID+1,size(tmp,1),1) tmp];
        end
        if isempty(dats), continue; end
        filename=sprintf('%s/set%02d/V%03d.txt', OUTPUT_DIR, setID, vID);
        dlmwrite(filename,dats);            
    end        
end
    
    
  
    