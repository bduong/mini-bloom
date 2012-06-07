function output = getStockHistory(ticker, startMonth, startDay, startYear, freq)

url = 'http://ichart.finance.yahoo.com/table.csv?';
url = [url '&s=' ticker];
url = [url '&a=' startMonth];
url = [url '&b=' startDay];
url = [url '&c=' startYear];
url = [url '&g=' freq];
[history, status] = urlread(url);

if (status)
    parsedList = parseHistoryCSV(history);
    parsedList = parsedList(2:end);
    
    regex = buildRegex;
    
    for ii = length(parsedList):-1:1
        output(ii) = convertToNumeric(extractData(parsedList{ii}, regex));
    end
    
    output = fliplr(output);
else
    output = [];
end

end

function parsedCSV = parseHistoryCSV(csv)

newLines = [0 find(csv == sprintf('\n'))];

parsedCSV = cell(length(newLines)-1, 1);

for ii = 1:length(newLines) - 1
    begin = newLines(ii)+1;
    ending = newLines(ii+1)-1;
    parsedCSV{ii} = csv(begin:ending);
    
end

end

function regex = buildRegex
p1 = '(?<year>[0-9]+)-(?<month>[0-9]+)-(?<day>[0-9]+)';
p2 = '(?<openPrice>[0-9\.]+)';
p3 = '(?<high>[0-9\.]+)';
p4 = '(?<low>[0-9\.]+)';
p5 = '(?<closePrice>[0-9\.]+)';
p6 = '(?<volume>[0-9\.]+)';
p7 = '(?<adjustedClose>[0-9\.]+)';

regex = [p1 ',' p2 ',' p3 ',' p4 ',' p5 ',' p6 ',' p7];
end

function data = extractData(string, regex)
data = regexp(string, regex, 'names');
end

function data = convertToNumeric(stringData)
data = stringData;
fields = fieldnames(stringData);

for ii = 1:length(fields)
    field = fields{ii};
    data.(field) = str2num(stringData.(field));
    
end

end