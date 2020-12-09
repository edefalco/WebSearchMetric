function similarity=web_association(xx,yy,xy,type,website)
%the function calculates the similarity of two concepts given
%the number of hits for concept 1 (xx), the number of hits for concept 2
%(yy) and the combined number of hits (xy).
%The different types of measures are called by the variable type (default type=2):

%type=1 ==> %association based on NWD as defined in "Normalized Web Distance and Word Similarity Rudi L. Cilibrasi 2009"
            %it uses e^-NWD as a measure of similarity
%type=2 ==>mutual information between the two concepts
%=log2(hits(A&B)/hits(A)*hits(B)) because this is not normalized this will usually be a negative value 
%type=3 ==>mutual information between the two concepts normalized by size of database =log2(hits(A&B)*M/hits(A)*hits(B))

%website is  only necessary if type==1 or type==3
%         website=1 ==> Bing Search API with autentication (Default)
%         website=2 ==> google search api with autentication. Create a custom serach engine here https://developers.google.com/custom-search/json-api/v1/overview
%         website=3 ==> google.com  (Not recommended)

% the size of the database is just an estimation, and as long as all terms
% are searched on the same database it's just a normalization term and it
% doesn't affect the results. To estimate it search the word 'the' and
% multiply the result for 0.67 (67%of text contains the word 'the' on
% average)

if ~exist('website','var') || isempty(website); website=1; end
if ~exist('type','var') || isempty(type); type=2; end

if website==1 && (type ==3 || type==1) %define size for Bing database
    fprintf ('is the database size for Bing API updated ? \n')
    M=3.2687e+8;
elseif website==2 && (type ==3 || type==1) %define size for Google Api database
    fprintf ('is the database size for Google API updated ? \n')
    M=6.403e+9;
elseif website==2 && (type ==3 || type==1) %define size for Google.com database
    fprintf ('is the database size for Google API updated ? \n')
    M=3.7716e+10;
end


switch type
    case 1 %NWD
        if xy==0; xy=1; end
        maxg= max(log(xx),log(yy));
        ming= min(log(xx),log(yy));
        similarity= exp(-(maxg-log(xy))/(log(M)-ming));
    case 2 %not normalized mutual information P(1&2)/P(1)*P(2)
        similarity=log2((xy)/(xx*yy));
    case 3  % normalized mutual information P(1&2)*M/P(1)*P(2)
        similarity=log2((xy*M)/(xx*yy));
end


end