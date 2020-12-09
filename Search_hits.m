function [ num_hits ] = Search_hits(query,website)

%it performs an automatic serch of the string in 'query' using the specified search engine (default: Bing Search API)
% and returns the number of hits obtained

%9/10/2018% updated to the new Bing Search Api

%INPUTS: query: char containing the query to search for (e.g. query= 'Bill Clinton')

%website: website=1 ==> Bing Search API with autentication (Default). Create an account at https://azure.microsoft.com/en-us/free/ai/
%         website=2 ==> google search api with autentication. Create a custom serach engine here https://developers.google.com/custom-search/json-api/v1/overview
%         website=3 ==> google.com  (Not recommended)


bing_key= 'my_key'; %Insert here your Bing Search Api subscription key

google_ID='my_ID';% your custom search ID and key
google_key='my_key';

if ~exist('website','var') || isempty(website)
    website=1;
end

%MARKET code, specifies on which market to search(i.e. language and country) only for Bing Search API
my_market='%en-US'; % for Italy use: 'it-IT';

switch website
    case 1 % Bing Search API
        
        options=weboptions('HeaderFields',{'Ocp-Apim-Subscription-Key' bing_key});
        search_url = 'https://api.bing.microsoft.com/v7.0/search';
        disp (['searching : ' query ' on Bing Search API ']);
        results=webread(search_url,'q',query,'textDecorations','True', 'textFormat','HTML','mkt',my_market,options);
        num_hits=(results.webPages.totalEstimatedMatches);
        
    case 2 %google search API
        disp (['searching : ' query ' on Google Search API ']);
        website=['https://www.googleapis.com/customsearch/v1?cx=' google_ID '&key=' google_key '&q='];
        query=strrep(query,'"', '%22');
        query=strrep(query,'+', '%2B');
        query=strrep(query,' ', '%20');
        
        link=[website query];
        
        S = urlread(link);
        results = regexpi(S, '"totalResults": "[0-9_\,]*"', 'match');
        if ~isempty(results)
            results = regexpi(results{1}, '[0-9]*', 'match');
            num_hits = str2double(results{1}); % number of results
        else
            error('Something went wrong during the query:');
            fprintf(' %s ' , link);
        end
        
    case 3
        disp (['searching : ' query ' on Google.com']);
        query=strrep(query,'"', '%22');
        query=strrep(query,'+', '%2B');
        query=strrep(query,' ', '%20');
        
        randt=40+(randi(600)/10); %up to one minute  and 40 waiting time
        T = timer('TimerFcn',@(~,~)disp('searching'),'StartDelay',randt); %timer to wait between searches, otherwise google could block the autosearch
        start(T);
        wait(T);
        website = 'https://google.com/search?q='; %the search engine where we're going to search
        link = [website  query];
        S = urlread(link);
        
        % search for no. of results
        results = regexpi(S, 'About [0-9_\,]* results', 'match');
        if ~isempty(results)   % parse further or error out
            results = textscan(results{1}, '%s'); % tokenize string
            num_hits = str2double(results{1}{2}); % number of results
        else
            results = regexpi(S, '>[0-9_\,]* results<', 'match');
            if ~isempty(results)
                results = regexpi(results{1}, '[0-9]*', 'match');
                num_hits = str2double(results{1}); % number of results
            else
                error('Something went wrong during the query:');
                fprintf(' %s ' , link);
            end
        end
end
end