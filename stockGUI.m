function stockGUI
close all

background = [0 .6 .6];

background = [.5 .5 .5];

f = figure(...
    'Units','Normalized',...
    'Position', [0 0 1 1],...
    'Name','Stock Watcher',...
    'MenuBar','None',...
    'Color',background,...
    'Visible','off');

graph = axes('Parent',f,...
    'Units','Normalized',...
    'NextPlot','add',...
    'Position',[.05 .6 .7 .35]);

uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'Position',[.8 .925 .15 .05],...
    'String','Enter Ticker Symbol',...
    'BackGroundColor',background,...
    'FontUnits','Normalized',...
    'FontSize',.5);

tickerBox = uicontrol('style','edit',...
    'Parent',f,...
    'Units','Normalized',...
    'Position',[.8 .9 .15 .04],...
    'String','',...
    'FontUnits','Normalized',...
    'FontSize',.6);


uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'Position',[.8 .83 .15 .05],...
    'String','Recent Searches',...
    'BackGroundColor',background,...
    'FontUnits','Normalized',...
    'FontSize',.5);

tickerHistory = uicontrol('style','listBox',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.1,...
    'Position',[.8 .5 .15 .35],...
    'CallBack', @selectList);

statTitle = uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.05 .45 .25 .05],...
    'String','',...
    'BackGroundColor',background);

tickerStatBox = uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.05,...
    'Position', [.05 .05 .25 .4],...
    'HorizontalAlignment','left',...
    'BackGroundColor','white');

rssTitle = uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.5 .45 .25 .05],...
    'String','',...
    'BackGroundColor',background);

rss = uicontrol('style','listBox',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.05,...
    'Position', [.35 .05 .6 .4],...
    'CallBack', @selectRSS);

uicontrol('style','text',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.05 .52 .1 .05],...
    'String','Start Date',...
    'BackGroundColor',background);

months = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
days = [31 28 31 30 31 30 31 31 30 31 30 31];
years = 2011:-1:2008;

monthsBox = uicontrol('style','popupmenu',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.15 .52 .05 .05],...
    'String', months,...
    'CallBack', @changeDays);

makeDayList = @(num) mat2cell(num2str([1:num]'), ones(1,num),2);

    function out = checkLeapYear(year)
        if(~rem(year,4) && (rem(year,100) || ~rem(year,400)))
            out = true;
        else
            out = false;
        end
    end

daysBox = uicontrol('style','popupmenu',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.2 .52 .05 .05],...
    'String', makeDayList(31));

yearsBox = uicontrol('style','popupmenu',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.25 .52 .05 .05],...
    'String', mat2cell(num2str(years'), ones(1,length(years)),4),...
    'CallBack', @changeYear);

    function changeDays(src, event)
        index = get(src,'Value') ;
        if(get(daysBox,'Value') > days(index));
            set(daysBox,'Value',days(index));
        end
        set(daysBox, 'String', makeDayList(days(index)))        
    end

    function changeYear(src, event)
        index = get(src,'Value');
        if(checkLeapYear(years(index)))
            days(2) = 29;
        else
            days(2) = 28;
        end
        
        if (get(monthsBox,'Value') == 2)
            if (get(daysBox,'Value') > 28)
            set(daysBox,'Value', 28)
            end
            set(daysBox,'String',makeDayList(days(2)))
        end
    end

uicontrol('style','pushbutton',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.5,...
    'Position', [.32 .53 .05 .04],...
    'String', 'Update',...
    'CallBack', @updateHistory);

ticker = 'VMW';
startMonth = '11';
startDay = '31';
startYear = '2010';
freq = 'd';
plotField = 'closePrice';
a=false;
history =[];
plotHandles =[];
feed = [];
%  createStockChart();
set(monthsBox,'Value',12);
set(daysBox,'Value',31);
set(yearsBox,'Value',2);

isRealTicker = createStockChart();
if(isRealTicker)   
    quote = updateQuote();
    plotQuoteData(quote);
    updateRSSFeed();
end

%% work in progress

fid = fopen('companies.txt');
companies = textscan(fid,'%s','Delimiter','\n');
companies = companies{1};

compList = uicontrol('style','listBox',...
    'Parent',f,...
    'Units','Normalized',...
    'FontUnits','Normalized',...
    'FontSize',.05,...
    'Position',[.76 .5 .23 .4],...
    'visible','off');

%%

set(f,'Visible','on');
jTickerBox = findjobj(tickerBox, 'nomenu');
set(jTickerBox, 'KeyTypedCallBack',@helpList);
set(jTickerBox, 'KeyPressedCallBack', @checkDownArrow);
jTickerBox.setSelectAllOnFocus(false);

jList =[];

uicontrol(tickerBox);



%%

    function newTick(src, event)
        set(compList,'visible','off'); 
        jList = [];
        ticker = upper(get(src,'String'));
        set(src,'String','');
        set(tickerHistory, 'Value',1);
        isRealTicker = createStockChart();
        if(isRealTicker)
            addToHistory(ticker);
            quote = updateQuote();
            plotQuoteData(quote);
            updateRSSFeed();
        else
            warndlg('That Security Does Not Exists','Invalid ticker','modal')
        end
    end

    function plotQuoteData(quote)
        yLimits = get(graph,'YLim');
        if(strcmp(class(quote.moving50),'double'))
            plotHandles(1) = plot([1, length(history)], [quote.moving50 quote.moving50],'b--',...
                'LineWidth', 2);
        end
        if(strcmp(class(quote.openValue),'double'))
            if(strcmp(class(quote.moving50),'double'))
                if (quote.openValue >= quote.moving50)
                    color ='g';
                else
                    color = 'r';
                end
            else
                color = 'k';
            end
            plotHandles(2) = plot([1, length(history)], [quote.openValue quote.openValue], [color '--'],...
                'LineWidth', 2);
        end
        %         plotHandles(3) = legend(graph,{'', 'Day''s Low', 'Day''s High'}, 'Location', 'SouthEast');
        axis(graph, [1 length(history) yLimits]);
        
    end

    function addToHistory(tickerName)
        pastHistory = get(tickerHistory,'String');
        pastHistory(strcmp(pastHistory,tickerName))=[];
        pastHistory = [{tickerName};pastHistory];
        if(length(pastHistory) > 10)
            pastHistory = pastHistory(1:10);
        end
        set(tickerHistory,'String',pastHistory);
    end

    function quote = updateQuote()
        quote = getStockQuote(ticker);
        title(graph, sprintf('%s: %s', ticker, quote.name), 'FontUnits', 'normalized', 'FontSize', .1);
        set(statTitle, 'String', sprintf('Quote For: %s', ticker))
        
        qString = {
            ''
            ['Symbol: ' ticker]
            ['Name: ' quote.name]
            ''
            '---------------------------------------------------------'
            ''
            ['Change: ' num2str(quote.change)];
            ['Percent Change: ' num2str(quote.percentChange) '%']
            ['Previous Close: ' num2str(quote.previousClose)]
            ['Opening: ' num2str(quote.openValue)]
            ['Day Range: ' num2str(quote.dayLow) ' - ' num2str(quote.dayHigh)]
            ['52 Week Range: ' num2str(quote.low52) ' - ' num2str(quote.high52)]
            ''
            '---------------------------------------------------------'
            ''
            ['% Change From 50 Day Average: ' num2str(quote.percentChange50) '%']
            ['% Change From 200 Day Average: ' num2str(quote.percentChange200) '%']
            ''
            };
        
        
        set(tickerStatBox, 'String', qString)
    end

    function result = createStockChart()
        history = getStockHistory(ticker, startMonth, startDay, startYear, freq);
        if (isempty(history))
            result = false;
            return;
        end
        delete(plotHandles)
        set(graph,'YLimMode','auto','XLimMode','auto');
        result = true;
        if(ishandle(a))
            set(a,'YData', [history.(plotField)]);
        else
            a = area([history.(plotField)],...
                'Parent', graph,...
                'FaceColor','blue',...
                'EdgeColor','black',...
                'LineWidth',3);
            alpha(.5)
            ylabel(graph, 'Price ($)', 'FontUnits', 'normalized', 'FontSize', .05);
            grid on
        end
        
        %title(graph, sprintf('%s', ticker), 'FontUnits', 'normalized', 'FontSize', .1);
        monthTransitions = find(diff([history.month]))+1;
        monthNumbers = [history(monthTransitions).month];
        monthLabels = months(monthNumbers);
        
        for jj = find(monthNumbers == 1)
            monthLabels{jj} = [monthLabels{jj} ' ''' num2str(mod(history(monthTransitions(jj)).year,100))];
            
        end
        
        set(graph, 'XTick', monthTransitions, 'XTickLabel',monthLabels);
    end

    function selectList(src, event)
        value = get(src,'Value');
        string = get(src, 'String');
        ticker = string{value};
        isRealTicker = createStockChart();
        if(isRealTicker)
            quote = updateQuote();
            plotQuoteData(quote);
            updateRSSFeed();
        end
    end

    function checkDownArrow(src, event)
        if(get(event,'KeyCode') == 40 && strcmpi(get(compList,'visible'),'on'))
           uicontrol(compList)            
        end
    end

    function helpList(src, event)
        if(int32(get(event,'keyChar')) == 10)
            newTick(tickerBox,event);
        else
            str = lower(get(src,'Text'));
            if(~isempty(str))
                strfind(companies,str);
                matches = companies(~cellfun(@isempty,strfind(lower(companies),str)));
                set(compList,'String',matches,'value',1,'visible','on');
            else
               set(compList,'visible','off'); 
            end
        end
        if(isempty(jList))
            hList = findjobj(compList, 'nomenu'); 
            hList = hList.getViewport.getComponent(0);
            jList = handle(hList, 'CallbackProperties');
            set(jList, 'MouseReleasedCallback', @checkClickList)
            set(jList, 'KeyTypedCallback', @checkEnterList)
            set(jList, 'KeyPressedCallback', @checkUpArrow)
        end
    end

    function checkUpArrow(src, event)
        if(get(event,'KeyCode') == 38 && get(compList,'value') == 1)
            uicontrol(tickerBox)
        end        
    end

    function checkEnterList(src, event)
       if(int32(get(event,'keyChar')) == 10)
          index = get(compList, 'value');
          selectTick(index,event) 
       end        
       
    end

    function checkClickList(src, event)
       mousePos = java.awt.Point(event.getX, event.getY);
       index = jList.locationToIndex(mousePos) + 1; 
       selectTick(index, event)
    end

    function selectTick(index,event)              
       str = get(compList, 'String');
       str = str{index};        
       [ticker rest] = strtok(str,'-');
       ticker = ticker(1:end-1);
       set(compList, 'Value',[]);
       set(tickerBox,'String',ticker);
       newTick(tickerBox,event)
    end

    function updateRSSFeed()
        set(rssTitle, 'String', sprintf('RSS FEED : %s', ticker))
        feed = getRSSFeed(ticker);
        stories = cell(1,length(feed));
        for ii = 1:length(feed)
            stories{ii} = ['<HTML>' feed(ii).title ' <FONT COLOR=FF99FF>' feed(ii).site '</FONT> <FONT COLOR=acacFF>' feed(ii).date '</FONT><HTML>'];
        end
        
        set(rss,'String',stories)
        
    end

    function selectRSS(src, event)
        if(strcmpi(get(f,'SelectionType'),'open'))
            index = get(src,'Value');
            web(feed(index).link,'-browser')
            
        end
    end

    function updateHistory(src, event)
        if(~isempty(ticker))
            startMonth = num2str((get(monthsBox,'Value')-1));
            startDay = num2str(get(daysBox,'Value'));
            startYear = num2str(years(get(yearsBox,'Value')));
            createStockChart()
            quote = updateQuote();
            plotQuoteData(quote);
        end
    end
end
