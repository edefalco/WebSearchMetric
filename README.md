# WebSearchMetric
This repo contains Matlab codes to generate a web association metric (described in De Falco et al. 2016 https://doi.org/10.1038/ncomms13408) between a set of searchable concepts using either the Bing search API or the Google search API 

If using this code please cite: De Falco E. et al., Nat Commun 2016. https://doi.org/10.1038/ncomms13408 and link the Github repo.

How to use the code. 

1. Create a Bing Search API account account at https://azure.microsoft.com/en-us/free/ai/, follow the instructions to get an API key for the Bing Search API. 
Paste the key in the file 'Search_hits.m' in the variable bing_key (substitute the words my_key with your actual key).
If using Bing Search API also update the variable my_market according to where you want to perform the search.

If you prefer to use the Google API instead, create a custom search engine here https://developers.google.com/custom-search/json-api/v1/overview.
Past your search engine ID and key in the file 'Search_hits.m'  in the variables google_ID and goolge_key (lines 17 and 18, substitute my_ID and my_key).

2.Define the list of concepts you want to search in the text file 'All_names_search.txt'. Each concept is separated by a new line, make sure there are no extra blank spaces in the text, 
as the will consider them as valid characters. 

3.Run the code Fill_webmat.m (the default option is to use Bing API (website=1) and the mutual information metric (type=2)). Default parameters can be changed when calling the function with inputs:
 Fill_webmat(website,type)
