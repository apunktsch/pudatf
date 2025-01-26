% add testfiles to path
folder_path = '_test/';
addpath(genpath(folder_path));
% add original files to path
folder_path = '/Users/adrianschulze/Documents/Github/pudatf/DEMO';
addpath(genpath(folder_path));
% add MOxUnit to path
folder_path = 'MOxUnit';
addpath(genpath(folder_path));
% add MOxUnit to path
folder_path = 'MOcov';
addpath(genpath(folder_path));
cdir = cd('_test/');
success=moxunit_runtests('./',...
                     '-with_coverage',...
                     '-cover','/Users/adrianschulze/Documents/Github/pudatf/DEMO',...
                     '-cover_xml_file','coverage.xml',...
                     '-cover_html_dir','coverage_html');
cd(cdir);
