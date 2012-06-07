function output = getStockQuote(ticker)
url = 'http://finance.yahoo.com/d/quotes.csv?';
url = [url '&s=' ticker];
url = [url '&f=' ];
url = [url 'n'];    % Name
url = [url 'c1'];   % Change
url = [url 'p2'];   % Percent Change
url = [url 'p'];    % Previous Close
url = [url 'o'];    % Open Value
url = [url 'h'];    % Day's High
url = [url 'g'];    % Day's Low
url = [url 'k'];    % 52-week High
url = [url 'j'];    % 52-week Low
url = [url 'm6'];   % Percent Change From 200 Day Average
url = [url 'm8'];   % Percent Change From 50 Day Average
url = [url 'm3'];   % 50 Day Moving Average

[quote status] = urlread(url);

if(status)
    regex = buildRegex;
    output = convertToNumeric(parseCSV(quote,regex));
else
    output = [];
end


end

function regex = buildRegex
p{1} = '\"?(?<name>[\x23-\x7E !]+)\"?';
p{2} = '(?<change>[N/A0-9\.-+]+)';
p{3} = '\"?(?<percentChange>[-N/A\.0-9+]+)%?\"?';
p{4} = '(?<previousClose>[N/A0-9\.-]+)';
p{5} = '(?<openValue>[N/A0-9\.-]+)';
p{6} = '(?<dayHigh>[N/A0-9\.-]+)';
p{7} = '(?<dayLow>[N/A0-9\.-]+)';
p{8} =  '\"?(?<high52>[-N/A\.0-9]+)\"?';
p{9} =  '\"?(?<low52>[-N/A\.0-9]+)\"?';
p{10} = '(?<percentChange200>[N/A0-9\.-+]+)%?';
p{11} = '(?<percentChange50>[N/A0-9\.-+]+)%?';
p{12} = '(?<moving50>[N/A0-9\.-+]+)';

regex = p{1};
for ii = 2:length(p);
    regex = [regex ',' p{ii}];
end

end

function parsed = parseCSV(csv, regex)
parsed = regexp(csv, regex, 'names');
end

function nObj= convertToNumeric(obj)
fields = fieldnames(obj);
nObj = obj;

for ii = 1:length(fields)
    field = fields{ii};
    num = str2num(obj.(field));
    if(~isempty(num))
        nObj.(field) = num;
    end
    
end

end