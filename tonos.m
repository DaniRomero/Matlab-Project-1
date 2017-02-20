function tonos(arg)
% TONOS 
% El sistema de Tono Dual Multi-Frecuencia (TDMF) especifica que el 
% tono que se genera al pulsar una tecla de un telefono se determina
% mediante el promedio de dos funciones senoidales, cutas frecuencias
% estan determinadas por la posicion que ocupa la boton pulsado
% en el teclado. Este programa es capaza de genera el tono para 
% cado boton de un teclado telefonico. 

% USTED DEBE COMPLETARLO PARA QUE SEA CAPAZ DEL PROCESO INVERSO:
% AL CARGAR UN ARCHIVO CON UNA SEÑAL CON 11 NUMEROS, EL PROGRAMA 
% DEBE SER CAPAZ DE INDICAR CUAL FUE EL NUMERO TELEFONICO MARCADO


if nargin == 0

   % Inicializacion
   load pad             % Dialpad D, 

   clf
   shg
   set(gcf,'double','on','name','Tonos', ...
      'menu','none','numbertitle','off'); %CREA LA VENTANA

   %TEXTO PARA EL NUMERO TELEFONICO
   ax.tn = uicontrol('Style', 'text','units','normal', ...
   'pos', [.60,.82,.36,.05], 'string','Aqui DEBE aparecer el numero', ...
   'tag','TexNum','FontSize',9); %TEXTO para el Numero

  %PAD DE NUMEROS
   ax.dialpad = axes('pos',[.14 .46 .30 .50]);
   imagesc(D)
   colormap(gray)
   set(ax.dialpad,'tag','dialpad',...
      'userdata',[zeros(1,4) 96397],...
      'xtick',[],'xcolor',[1 1 1],'ytick',[],'ycolor',[1 1 1]);

 
  %GRAFICA ESQUINA SUPERIOR DERECHA
   ax.signal = axes('pos',[.60 .55 .36 .25]);
   %axis([min(t) max(t) -1 1])
   axis([0 1/64 -5/4 5/4])   
   xlabel('t(segs)')

  %GRAFICA ESQUINA INFERIOR IZQUIERDA
   ax.muestra = axes('pos',[.10 .16 .36 .25]);
   axis([0 1/64 -5/4 5/4])
   xlabel('t(segs)')
   
  %GRAFICA ESQUINA INFERIOR DERECHA
   ax.potencia = axes('pos',[.60 .16 .36 .25]);
   axis([500 1700 0 600])
   xlabel('f(Hz)')
   title('Frecuencias')

   set(gcf,'userdata',ax,'windowbuttonupfcn', ...
      'tonos(get(gca,''tag''))')

   uicontrol('units','normal','pos',[.72,.90,.12,.06], ...
      'string','CARGAR','callback','tonos cargar'); %BOTON Carga
   uicontrol('units','normal','pos',[.38,.02,.12,.05], ...
      'string','Ayuda','callback','helpwin tonos');%BOTON Ayuda
   uicontrol('units','normal','pos',[.52,.02,.12,.05], ...
      'string','Cerrar','callback','close(gcf)');  %BOTON Cerrar

elseif isequal(arg,'dialpad')
   % DTMF, Dual tone multi-frequencies, Hz
   fr = [697 770 852 941];
   fc = [1209 1336 1477];
  
   % Tiempo (segundos)
   Fs = 32767;
   t = 0:1/Fs:0.25;

   % Graficas de las frecuencias componentes
   cp = get(gca,'currentpoint'); 
   k = min(max(ceil(cp(1,2)/50),1),4);
   j = min(max(ceil(cp(1,1)/50),1),3);
   f = [fr(k) fc(j)];
   p = [100 100]; % p = [1/2 1/2];
   ax = get(gcf,'userdata');
   set(gcf,'currentaxes',ax.potencia)
   plot([f;f],[0*p;p],'c-',f,p,'b.','markersize',16)
   axis([500 1700 0 200])
   set(gca,'xtick',[fr(k) fc(j)])
   xlabel('f(Hz)')
   title('Potencia')

   
   % Tono: Dos senoidales superpuestas
   y1 = sin(2*pi*fr(k)*t);
   y2 = sin(2*pi*fc(j)*t);
   y = (y1 + y2)/2;

   % Grafica del Tono
   set(gcf,'currentaxes',ax.muestra)
   plot(t(1:512),y(1:512),'k');
   axis([0 1/64 -5/4 5/4])
   xlabel('t(secs)')

   % Reproducce el tono
   sound(y,Fs)
   
   %===========================================
   % AYUDA PARA LA DECODIFICACION
    ax = get(gcf,'userdata');
    set(gcf,'currentaxes',ax.potencia)
    n = length(y);
    f = (Fs/n)*(0:n-1);
    p = abs(fft(y));
    hold on
    plot(f,p,'color',[0 2/3 0])
    axis([500 1700 0 200])
    hold off
   %===========================================

elseif isequal(arg,'cargar')      
   %GRAFICA ESQUINA SUPERIOR DERECHA
   ax.signal = axes('pos',[.60 .55 .36 .25]);
   %axis([min(t) max(t) -1 1])
   axis([0 1/64 -5/4 5/4])   
   xlabel('t(segs)')
   
   load signal  % Señal grabada en y, frecuencia de la muestra fs
   fr=[697 770 852 941];
   fc=[1209 1336 1477];
   sound(y,Fs);
   valorab=y;
   mystring='';
   mymatrix=['1' '2' '3'; '4' '5' '6'; '7' '8' '9'; '#' '0' '*'];
   Fs = 32767;
   t = 0:1/Fs:0.25;
   for i=1:11
       %aplicamos el valor absoluto a la transformada de fourier de cada
       %numero
       a=8192*(i-1)+1;
       vec=valorab(a:8192*i);
       vec2=abs(fft(vec));
       n = length(vec2);
       f = (Fs/n)*(0:n-1);
       
       % grafica de la señal
       hold on
       set(gcf,'currentaxes',ax.signal)
       plot(t(1:512), vec(1:512));
       axis([0 1/64 -5/4 5/4])   
       
       %hallamos los picos de cada numero
       [pks, locs]=findpeaks(vec2, 'NPEAKS', 2);
       a=f(locs(1));
       b=f(locs(2));
       var=10^6;
       
       %calculamos el error con los vectores de frecuencias para saber que
       %numero es...
       for j=1:4
           if (abs(fr(j)-a) < var)
               c=j;
               var=abs(fr(j)-a);
           end
       end
       var=10^6;
       for k=1:3
           if (abs(fc(k)-b) < var)
               d=k;
               var=abs(fc(k)-b);
           end
       end
       %concatenamos el numero al string
       mystring = [mystring mymatrix(c,d)];
   end

   ax = get(gcf,'userdata');
   set(ax.tn,'String',mystring, 'FontSize',9)
   set(gcf,'currentaxes',ax.signal)
   text(0.2,0.5,'DEBES LLENAR ESTA GRAFICA','FontSize',10)
   text(1,0,'Y MODIFICAR LAS OTRAS','FontSize',10)
end
