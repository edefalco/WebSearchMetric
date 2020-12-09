function Fill_webmat(website,type,repeat)
%the function creates or fills up a web association matrix.
%If a file 'web_matrix.mat' does NOT exists in the current folder, the
%function looks for the txt file 'ALL_names_search.txt' containing the list
%of names to search for.

%If a file 'web_matrix.mat' already exists in the current folder, the function
%loads it and tries to fill up any missing value (nans) in the matrix.
%(this is used because sometimes the web search might get stuck for any reason,
%this way we don't loose any search result already obtained

%WARNING If using the option repeat (repeat=1) the function will recalculate the
%whole matrix and overwrite the old one regardless.

%INPUTS
%website: website=1 (default) ==> Bing Search API with autentication (Default) Create an account at https://azure.microsoft.com/en-us/free/ai/
%         website=2 ==> google search api with autentication. Create a custom search engine here https://developers.google.com/custom-search/json-api/v1/overview
%         website=3 ==> google.com  (Not recommended)

%The different types of measures are called by the variable type (default type=2):
%type=1 ==> %association based on NWD as defined in "Normalized Web Distance and Word Similarity Rudi L. Cilibrasi 2009"
            %it uses e^-NWD as a measure of similarity
%type=2 (default) ==>mutual information between the two concepts =log2(hits(A&B)/hits(A)*hits(B)) because this is not normalized this will usually be a negative value 
%type=3 ==>mutual information between the two concepts normalized by size of database =log2(hits(A&B)*M/hits(A)*hits(B))

%repeat: 0 or 1 (default =0). if repeat == 0 load the existend web_matrix.mat (if any) and tries to fill in the Nans. 
%                             If repeat == 1 will use the search list in All_names_search.txt and overwrite any previous web matrix

%OUTPUT 
%saves a matlab file 'web_matrix.mat'containing the variables:
%'hits_name' list of searched names corresponding to rows and columns of matrices 'hits_mat','web_matrix','zscored_web_matrix'
%'hits_mat' matrix containing on the main diagonal the number of hits for each searched name in hits_name and off-diagonal the number of hits for pairs of names searched 
%'web_matrix' matrix containing in the upper diagonal the association scores between pairs of searched names according to the type of metric chosen
%%'zscored_web_matrix' matrix containing in the upper diagonal the zscored association scores between pairs of searched names according to the type of metric chosen

if ~exist('website','var') || isempty(website); website=1; end
if ~exist('repeat','var') || isempty(repeat); repeat=0; end
if ~exist('type','var') || isempty(type); type=2; end


%try loading an existent matrix, if not create a new one from the list of names in ALL_names_search.txt
if exist('web_matrix.mat','file') && repeat==0
    load 'web_matrix.mat'
else
    [hits_name]= textread([ 'All_names_search.txt' ], '%s', 'delimiter', '\n');   
    hits_mat=nan(length(hits_name));
end

num=length(hits_name);
web_matrix=nan(num,num);

% loop on all the hits matrix entries
for i=1:num
    if isnan(hits_mat(i,i))
        query=['"' hits_name{i} '"' ];
        try
            hits_x= Search_hits(query,website);
            hits_mat(i,i)= hits_x;
            save ('web_matrix.mat' , 'hits_mat', 'hits_name','web_matrix')
        catch
            fprintf('problem while searching %s\n',query );
        end
    end
    for j=i+1:num
        if isnan(hits_mat(i,j))
            query=['"' hits_name{i} '"+"' hits_name{j} '"' ];
            
            try
                hits_xy= Search_hits(query,website);
                hits_mat(i,j)= hits_xy;
                hits_mat(j,i)= hits_xy;
                save ('web_matrix.mat' , 'hits_mat', 'hits_name','web_matrix')
            catch
                fprintf('problem with searching %s\n', query);
            end
        end
    end
end


for x=1:num-1  %calculate association score between the two points
    for j=x+1:num
        web_matrix(x,j)=web_association(hits_mat(x,x),hits_mat(j,j),hits_mat(x,j),type,website);
    end
end
%% replace inf values (hits(xy)=0)
ind_inf=isinf(web_matrix);
diag=logical(isnan(web_matrix));
std_notinf=std(web_matrix(~logical(diag+ind_inf)));
numinf=length(find(ind_inf));
web_matrix(ind_inf)=min(web_matrix(~logical(diag+ind_inf)))-((rand(numinf,1)-0.5)*2*std_notinf);

%save a zscored version of the web_matrix
zscored_web_matrix=nan(size(web_matrix));
zscored_web_matrix(~isnan(web_matrix))=zscore(web_matrix(~isnan(web_matrix)));

save ('web_matrix.mat' , 'hits_mat', 'hits_name','web_matrix','zscored_web_matrix')
end

