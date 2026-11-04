% =================================================================
% COMPILADOR DE FOTOGRAMAS PNG A GIF ANIMADO EN MATLAB
% =================================================================

% Ruta exacta de la carpeta con los fotogramas PNG
folderPath = 'C:\Users\pfran\Documents\Processing\sketch_251211h\secuencia_frames';

% Nombre del archivo GIF resultante
outputFile = fullfile(folderPath, 'marie_curie_ascension.gif');

% Obtener la lista de imágenes PNG
files = dir(fullfile(folderPath, 'frame-*.png'));

% Si los archivos no tienen el prefijo 'frame-', busca cualquier .png
if isempty(files)
    files = dir(fullfile(folderPath, '*.png'));
end

if isempty(files)
    error('No se encontraron archivos PNG en la ruta especificada.');
end

% Configuración de velocidad:
% 0.0333 segundos per frame = 30 FPS (Fluidez exacta del sketch)
% 0.0400 segundos per frame = 25 FPS
delayTime = 0.0333; 

fprintf('Procesando %d fotogramas desde la ruta...\n', length(files));

for k = 1:length(files)
    % Cargar imagen PNG
    filename = fullfile(folderPath, files(k).name);
    img = imread(filename);
    
    % Convertir la imagen RGB a mapa de colores indexado (256 colores)
    [imind, cm] = rgb2ind(img, 256);
    
    % Escribir fotogramas en el archivo GIF
    if k == 1
        imwrite(imind, cm, outputFile, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
    else
        imwrite(imind, cm, outputFile, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
    end
end

fprintf('>>> ¡GIF animado creado con éxito!\n');
fprintf('>>> Guardado en: %s\n', outputFile);