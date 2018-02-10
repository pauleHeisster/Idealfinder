function stop = plotXValues(x,~,~)
stop = false;

n = length(x);

plotX = plot(1:n,x(:,1),'k+','MarkerFaceColor',[1 0 1]);
set(plotX,'Tag','optimplotX');
hold on;
plot([1,n],[1,1],'-k');% rightBorder
plot([1,n],[-1,-1],'-k'); % leftBorder
plot([1,n],[0,0],'--g'); % Mittellinie
hold off;
ylim([-1.1,1.1]);
set(gca,'Ydir','reverse');
xlim([1,inf]);

title('Current X Values');
xlabel('X-Variable');
ylabel('Bounds');