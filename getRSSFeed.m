function out = getRSSFeed(ticker)
url = 'http://finance.yahoo.com/rss/headline?s=';
url = [url ticker];

xml = xml2struct(url);
nodes = xml.children.children;
stories = nodes(strcmp({nodes.name},'item'));

for ii = length(stories):-1:1
    story = stories(ii).children;
    out(ii).title = story(strcmp({story.name},'title')).children.data;
    out(ii).link = story(strcmp({story.name},'link')).children.data;
    out(ii).date = story(strcmp({story.name},'pubDate')).children.data;
    out(ii).site = extractSite(out(ii).link);
end
end

function out = extractSite(link)
link = link(strfind(link,'*')+1:end);
ex = 'http[^/]+//([^/]*)/.*';
site =  regexp(link,ex,'tokens','once');
out = site{1};

end

function out = xml2struct(xmlfile)
% XML2STRUCT Read XML file into a structure.

% adapted from Douglas M. Schwarz

xml = xmlread(xmlfile);

children = xml.getChildNodes;
for i = children.getLength:-1:1
    out(i) = node2struct(children.item(i-1));
end

end
function s = node2struct(node)

s.name = char(node.getNodeName);

try
    s.data = char(node.getData);
catch err
    s.data = '';
end

if node.hasChildNodes
    children = node.getChildNodes;
    nchildren = children.getLength;
    c = cell(1,nchildren);
    s.children = struct('name',c,'data',c,'children',c);
    for i = 1:nchildren
        child = children.item(i-1);
        s.children(i) = node2struct(child);
    end
else
    s.children = [];
end
end