%-------------------------------------------------------------------------------------------------------------
%------- PONG ------------------------------------------------------------------------------------------------
%------- Trabajo 1: Coceptos básicos de PDI ------------------------------------------------------------------
%------- Por: Oscar Giovanny Duque Perdomo   ogiovanny.duque@udea.edu.co -------------------------------------
%-------      Estudiante Facultad de Ingenieria --------------------------------------------------------------
%-------      CC 1054559362, Tel 3127162489,  Wpp 3127162489 -------------------------------------------------
%------- Por: Eduardo José Maya Rodriguez    eduardo.maya@udea.edu.co ----------------------------------------
%-------      Estudiante Facultad de Ingenieria --------------------------------------------------------------
%-------      CC 1039462746, Tel 3115450311,  Wpp 3115450311 -------------------------------------------------
%------- Curso Procesamiento digital de imagenes -------------------------------------------------------------
%------- Marzo de 2020 ---------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

%-------------------------------------------------------------------------------------------------------------
%--1. Inicializacion del sistema -----------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

clear all;                      % Inicializa todas las variables
close all;                      % Cierra todas las ventanas, archivos y procesos abiertos
clc                             % Limpia la ventana de comandos

objects = imaqfind;             % Muestra posibles entradas de video que haya conectadas
delete(objects);                % Borra las entradas de video disponibles

x = 50;                         % Posicion inicial de la bolita en el eje x 
y = 230;                        % Posicion inicial de la bolita en el eje y
vx = 10;                        % velocidad de la bolita en el eje x
vy = 5;                         % velocidad de la bolita en el eje y
dt = 0.8;                       % Cambio de tiempo para ecuacion de movimiento rectilineo uniforme
tetha = pi/3;                   % Angulo inicial en el cual la bolita es lanzada

jugador1 = 0;                   % Score inicial para jugador 1
jugador2 = 0;                   % Score inicial para jugador 2

table = imread('table2.jpg');   % Carga la imagen de tablero de PONG

meta = 5;                       % Objetivo en puntos al que deben llegar los jugadores
Goal = 0;                       % Bandera para desplegar el mensaje de GOAL para cada que hay punto

Video = videoinput('winvideo', 1, 'YUY2_160x120');  % Definicion del elemento con el cual se hace captura de imagenes

set(Video, 'FramesPerTrigger', Inf);                % Definicion de la cantidad de imagenes por captura
set(Video, 'returnedcolorspace', 'rgb');            % Definicion del espacio de color con el cual se hace la imagen capturada

start(Video);                                       % Inicio de la captura de imagenes de la camara web
imshow(table);                                      % Visulizacion de la imagen de tablero de PONG

%------------------------------------------------------------------------------------------------------------------------------------------------
%-- 2.Inicio de juego ---------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------

while jugador1 < meta && jugador2 < meta
%------------------------------------------------------------------------------------------------------------------------------------------------
%-- 3.Procesamiento de la imagen obtenida -------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------
    
    frame = getsnapshot(Video);                              % Se captura una imagen
    frame = flip(frame,2);                                   % Se realiza efecto espejo
   
    solo_rojo = imsubtract(frame(:,:,1), rgb2gray(frame));   % De la imagen se toma la capa 1 y se toma el color solo_rojo
    solo_rojo = medfilt2(solo_rojo, [3 3]);                  % Evita el ruido que se encuentra en la imagen
    solo_rojo = imbinarize(solo_rojo, 0.12);                 % Se binariza con la matriz en escala de grises.
    solo_rojo = bwareaopen(solo_rojo, 150);                  % Metodo de filtrado de imagen binarizada para descartar objetos con area menor a 150 pixeles.
    solo_rojo = imresize(solo_rojo, 3);                      % Redimensionamiento de la imagen capturada
    
%----- Segmentacion y busqueda del centro del disco obtenido -------------------------------------------------------------------------------------

    [matriz, elem] = bwlabel(solo_rojo); % Etiqueta los objetos encontrados en la imagen binarizada
                                         % matriz devuelve los objetos etiquetados, elem devuelve un numero entero de los objetos que encontro
    j = 1;                               % Inicializacion de variable para el conteo de elementos obtenidos
     
    for i = 1:elem                       % i Representa el numero de etiqueta
        temp = solo_rojo*0;              % Matriz con las mismas dimensiones de solo_rojo llena de ceros.
        temp(matriz==i) = 1;             % Se pregunta cuales valores de esa matriz tienen ese valor de esa etiqueta
        area = sum(temp(:));             % Suma todos los unos y calcula el area del objeto
       
        if area > 400                    % Tener en cuenta los objetos con area mayor a 400
           Discos{j} = temp;             % Almacenamiento del objeto obtenido en la variable Disco
           j = j+1;                      % Incremento de variable para seguir buscando objetos
        end
    end

%------------------------------------------------------------------------------------------------------------------------------------------------
%-- 4.Definicion de objetos usados en el juego --------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------------------     
     
%---- Capturar el centroide de la region segmentada ---------------------------------------------------------------------------------------------
    for i=1:j-1
        centro{i} = regionprops(Discos{i}, 'Centroid'); % Entrega el centroide de las figuras obtenidas de la imagen binarizada
    end
    
%----- Definicion de las figuras disco para que se muevan en pantalla ---------------------------------------------------------------------------
    for i = 1: j-1
%----- Discos region positiva eje Y -------------------------------------------------------------------------------------------------------------
        if i == 1 && centro{i}.Centroid(2) <= 180       % Condicion de creacion para la figura Disco para el jugador 1
            Disco(i) = rectangle('Position',[centro{i}.Centroid(1), centro{i}.Centroid(2),40,40],'Curvature',[1 1], 'FaceColor', 'b' ); % Creacion de la figura del jugador 1 en la parte negativa de Y
        
%----- Discos region positiva eje Y -------------------------------------------------------------------------------------------------------------
         elseif i == 1 && centro{i}.Centroid(2) > 180   % Condicion de creacion para la figura Disco para el jugador 1
            Disco(i) = rectangle('Position',[centro{i}.Centroid(1), centro{i}.Centroid(2),40,40],'Curvature',[1 1], 'FaceColor', 'b');  % Creacion de la figura del jugador 1 en la parte positiva de Y
        end
%----- Discos region positiva eje Y -------------------------------------------------------------------------------------------------------------
        if i == 2 && centro{i}.Centroid(2) <= 180       % Condicion de creacion para la figura Disco para el jugador 2
            Disco(i) = rectangle('Position',[centro{i}.Centroid(1), centro{i}.Centroid(2),40,40],'Curvature',[1 1], 'FaceColor', 'r');  % Creacion de la figura del jugador 2 en la parte negativa de Y
        
%----- Discos region positiva eje Y -------------------------------------------------------------------------------------------------------------
         elseif i == 2 && centro{i}.Centroid(2) > 180   % Condicion de creacion para la figura Disco para el jugador 2
            Disco(i) = rectangle('Position',[centro{i}.Centroid(1), centro{i}.Centroid(2),40,40],'Curvature',[1 1], 'FaceColor', 'r');  % Creacion de la figura del jugador 2 en la parte positiva de Y
         end
    end
    
    bolita = rectangle('Position',[x,y,30,30],'Curvature',[1 1], 'FaceColor', 'g'); % Creacion de la figura bolita para poder jugar

%---------------------------------------------------------------------------------------------------------------
%-- 5.Definicion de las fisicas del juego y condiciones de anotacion de puntos ---------------------------------
%---------------------------------------------------------------------------------------------------------------
    
%----- Actualizacion de la bola --------------------------------------------------------------------------------
    x = x + vx*dt;  % Definicion del movimiento en el eje X para la bolita
    y = y + vy*dt;  % Definicion del movimiento en el eje Y para la bolita
    
%----- Anotacion primer jugador ---------------------------------------------------------------------------------
    if(x > 440) && (y >= 1) && (y <= 360)
        jugador1 = jugador1 + 1;    % Anotacion del punto para jugador 1    
        x = 100;                    % Definicion nueva coordenada en X para la bolita
        y = 250;                    % Definicion nueva coordenada en Y para la bolita
        
        Goal = text(50, 170, 'GOAL  ');                                     % Muestra Mensaje de Anotacion para el jugador 1
        set(Goal, 'Fontsize', 40, 'color', 'blue', 'FontName', 'Arial');    % Propiedades del mensaje desplegado en pantalla    
        pause(1)
    end
   
%----- Anotacion segundo jugador ----------------------------------------------------------------------------------
    if(x < 10) && (y >= 1) && (y <= 360)
        jugador2 = jugador2 + 1;                                            % Anotacion del punto para jugador 1
        x = 250;                                                            % Definicion nueva coordenada en X para la bolita
        y = 200;                                                            % Definicion nueva coordenada en Y para la bolita
        Goal = text(290, 170, 'GOAL  ');                                    % Muestra Mensaje de Anotacion para el jugador 1  
        set(Goal, 'Fontsize', 40, 'color', 'red', 'FontName', 'Arial');     % Propiedades del mensaje desplegado en pantalla    
        pause(1)
    end
    
    puntos = text(70, 50, num2str(jugador1));                               % Mensaje que muestra el puntaje del jugador 1
    set(puntos, 'Fontsize', 40, 'color', 'green', 'FontName', 'Arial');     % Propiedades del mensaje desplegado en pantalla
    
    puntos2 = text(360, 50, num2str(jugador2));                             % Mensaje que muestra el puntaje del jugador 2 
    set(puntos2, 'Fontsize', 40, 'color', 'green', 'FontName', 'Arial');    % Propiedades del mensaje desplegado en pantalla
    
%----- Rebote de la bolita ----------------------------------------------------------------------------------------------------------
    if(x > 440)
        vx = -vx;               % Cambia el sentido de direccion en X de la bolita en caso de detectar la colision
    end
    
    if(x < 10)
        vx = -vx;               % Cambia el sentido de direccionen X de la bolita en caso de detectar la colision      
    end
    
    if(y > 330)
        vy = -vy;               % Cambia el sentido de direccion en Y de la bolita en caso de detectar la colision
    end
    
    if(y < 10)
        vy = -vy;               % Cambia el sentido de direccion en Y de la bolita en caso de detectar la colision
    end
    pause(0.000000000000000001) % Detiene por una fraccion de tiempo para el cambio de direccion de la bolita
    
%----- colision entre bolita y Discos -----------------------------------------------------------------------------------------------
    R = 20 + 15;                                    % Definicion de la distancia a la cual se detecta la colisión
    for i =1: elem
        disx = centro{i}.Centroid(1) - x;           % Calculo de distancia entre el disco y la bolita para eje X
        disy = centro{i}.Centroid(2) - y;           % Calculo de distancia entre el disco y la bolita para eje Y
        distancia = sqrt(disx^2 + disy^2);          % Calculo de hipotenusa para definir la distancia entre centroides de bolita y disco
        
        if distancia <= R                           % Condicion para cuando la distancia entre centroides es mayor a 
            magnitud_velocidad = sqrt(vx^2 + vy^2); % Calculo de la magnitud de la velocidad de la bolita
            if disy < 0
                tetha = atan(disx/disy);            % Definicion del nuevo angulo de rebote de la bolita
                vx = magnitud_velocidad*sin(tetha); % Calculo de la nueva velocidad en X para la bolita
                vy = magnitud_velocidad*cos(tetha); % Calculo de la nueva velocidad en Y para la bolita
            elseif disy >= 0
                tetha = atan(disy/disx);            % Definicion del nuevo angulo de rebote de la bolita
                vx = magnitud_velocidad*cos(tetha); % Calculo de la nueva velocidad en X para la bolita
                vy = magnitud_velocidad*sin(tetha); % Calculo de la nueva velocidad en Y para la bolita
            end
        end
    end
%------------------------------------------------------------------------------------------------------------------------------------
%-- 6.Visualizacion de graficos y control de objetos --------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------

%----- Desaparecemos los objetos de la pantalla -------------------------------------------------------------------------------------
     set(bolita, 'Visible', 'off');     % Desaparicion de la posicion anterior de la bolita
     set(Disco(1), 'Visible', 'off');   % Desaparicion de la posicion anterior del disco del jugador 1
     set(Disco(2), 'Visible', 'off');   % Desaparicion de la posicion anterior del disco del jugador 2
     set(puntos, 'Visible', 'off');     % Desaparicion de la posicion anterior del puntaje anterior del jugador 1
     set(puntos2, 'Visible', 'off');    % Desaparicion de la posicion anterior del puntaje anterior del jugador 2

    if Goal ~= 0                        % Condicion para cuando se gana un punto
        set(Goal, 'Visible', 'off');    % Desaparicion del mensaje de GOAL cuando se reanuda el juego
    end 
end

stop(Video);                            % Detencion del dispositivo de captura de imagenes                   
flushdata(Video);                       % Elimina todos los datos que estan en el buffer

%------------------------------------------------------------------------------------------------------------------------------------
%-- 7.Definicion del ganador de la partida -------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------  

if jugador1 > jugador2                                                  % Condicion para cuando el jugador 1 llega al puntaje definido     
    Ganador = text(15, 180, 'JUGADOR 1 WIN');                           % Mensaje que indica al jugador 1 como ganador
    set(Ganador, 'Fontsize', 20, 'color', 'blue', 'FontName', 'Arial'); % Propiedades del mensaje desplegado en pantalla
else
    Ganador = text(250, 180, 'JUGADOR 2 WIN');                          % Mensaje que indica al jugador 2 como ganador
    set(Ganador, 'Fontsize', 20, 'color', 'red', 'FontName', 'Arial');  % Propiedades del mensaje desplegado en pantalla
end

%------------------------------------------------------------------------------------------------------------------------------------
%---------------------------  FIN DEL PROGRAMA --------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------------------
