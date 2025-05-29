function exito = guardarEnBD(Y, X, nombre, descripcion)
    exito = false;
    
    try
        % *** CARGAR DRIVER AUTOMÁTICAMENTE ***
        fprintf('🔧 Verificando driver JDBC...\n');
        
        % Cargar driver si no está cargado
        if ~cargarDriverJDBC()
            error('No se pudo cargar el driver JDBC de PostgreSQL');
        end
        
        fprintf('🔗 Conectando a base de datos...\n');
        
        conn = database('bd_RegresionLineal', 'postgres', 'francesfranco2004', ...
            'org.postgresql.Driver', ...
            'jdbc:postgresql://localhost:5432/bd_RegresionLineal');
        
        if isempty(conn) || ~isempty(conn.Message)
            fprintf('❌ Error de conexión: %s\n', conn.Message);
            error('No se pudo conectar a la base de datos: %s', conn.Message);
        end
        
        fprintf('✅ Conexión exitosa\n');
        
        % Preparar datos
        num_obs = length(Y);
        num_vars = size(X, 2);
        
        fprintf('📊 Preparando datos:\n');
        fprintf('   Observaciones: %d\n', num_obs);
        fprintf('   Variables independientes: %d\n', num_vars);
        fprintf('   Nombre: "%s"\n', nombre);
        fprintf('   Descripción: "%s"\n', descripcion);
        
        % Limpiar nombre y descripción para SQL
        nombre_limpio = strrep(nombre, '''', '''''');
        descripcion_limpia = strrep(descripcion, '''', '''''');
        
        % 1. Obtener ID ANTES de insertar (para evitar problemas de secuencia)
        fprintf('🔍 Obteniendo próximo ID...\n');
        try
            sqlNextId = 'SELECT COALESCE(MAX(id), 0) + 1 as next_id FROM public.datasets';
            resultadoNext = fetch(conn, sqlNextId);
            next_id = resultadoNext.next_id(1);
            fprintf('✅ Próximo ID será: %d\n', next_id);
        catch
            next_id = 1; % Si falla, usar 1
            fprintf('⚠ Usando ID por defecto: %d\n', next_id);
        end
        
        % 2. Insertar dataset
        fprintf('💾 Insertando dataset...\n');
        
        sqlDataset = sprintf(['INSERT INTO public.datasets ' ...
                             '(nombre, descripcion, num_observaciones, num_variables_indep) ' ...
                             'VALUES (''%s'', ''%s'', %d, %d)'], ...
                             nombre_limpio, descripcion_limpia, num_obs, num_vars);
        
        fprintf('📝 SQL Dataset: %s\n', sqlDataset);
        
        try
            exec(conn, sqlDataset);
            fprintf('✅ Dataset insertado\n');
        catch ME_dataset
            fprintf('❌ Error al insertar dataset: %s\n', ME_dataset.message);
            close(conn);
            error('Error en inserción de dataset: %s', ME_dataset.message);
        end
        
        % 3. Obtener el ID real del dataset insertado (método múltiple)
        dataset_id = [];
        
        % Método 1: Usar MAX(id)
        try
            fprintf('🔍 Método 1: Obteniendo ID con MAX...\n');
            sqlMaxId = 'SELECT MAX(id) as id FROM public.datasets';
            resultado = fetch(conn, sqlMaxId);
            if ~isempty(resultado) && ~isempty(resultado.id)
                dataset_id = resultado.id(1);
                fprintf('✅ ID obtenido con MAX: %d\n', dataset_id);
            end
        catch ME1
            fprintf('⚠ Método 1 falló: %s\n', ME1.message);
        end
        
        % Método 2: Buscar por nombre y descripción si el método 1 falla
        if isempty(dataset_id)
            try
                fprintf('🔍 Método 2: Buscando por nombre y descripción...\n');
                sqlFind = sprintf(['SELECT id FROM public.datasets ' ...
                                 'WHERE nombre = ''%s'' AND descripcion = ''%s'' ' ...
                                 'ORDER BY id DESC LIMIT 1'], ...
                                 nombre_limpio, descripcion_limpia);
                resultado = fetch(conn, sqlFind);
                if ~isempty(resultado) && ~isempty(resultado.id)
                    dataset_id = resultado.id(1);
                    fprintf('✅ ID obtenido por búsqueda: %d\n', dataset_id);
                end
            catch ME2
                fprintf('⚠ Método 2 falló: %s\n', ME2.message);
            end
        end
        
        % Método 3: Usar el next_id calculado anteriormente
        if isempty(dataset_id)
            fprintf('🔍 Método 3: Usando ID calculado previamente...\n');
            dataset_id = next_id;
            fprintf('✅ Usando ID calculado: %d\n', dataset_id);
        end
        
        % Verificar que tenemos un ID válido
        if isempty(dataset_id) || dataset_id <= 0
            error('No se pudo obtener un ID válido para el dataset');
        end
        
        % 4. Insertar observaciones
        fprintf('📈 Insertando %d observaciones con dataset_id = %d...\n', num_obs, dataset_id);
        
        observaciones_exitosas = 0;
        
        for i = 1:num_obs
            try
                % Crear array de variables independientes para PostgreSQL
                vars_array = '';
                for j = 1:num_vars
                    if j == 1
                        vars_array = sprintf('%.6f', X(i, j));
                    else
                        vars_array = sprintf('%s,%.6f', vars_array, X(i, j));
                    end
                end
                vars_str = sprintf('{%s}', vars_array);
                
                sqlObs = sprintf(['INSERT INTO public.observaciones ' ...
                                 '(dataset_id, fila, variable_dependiente, variables_independientes) ' ...
                                 'VALUES (%d, %d, %.6f, ''%s'')'], ...
                                 dataset_id, i, Y(i), vars_str);
                
                % Debug para primera observación
                if i == 1
                    fprintf('📝 SQL Observación ejemplo: %s\n', sqlObs);
                end
                
                exec(conn, sqlObs);
                observaciones_exitosas = observaciones_exitosas + 1;
                
                % Mostrar progreso
                if mod(i, 2) == 0 || i == num_obs
                    fprintf('   ✅ Progreso: %d/%d observaciones insertadas\n', observaciones_exitosas, num_obs);
                end
                
            catch ME_obs
                fprintf('❌ Error en observación %d: %s\n', i, ME_obs.message);
                fprintf('   SQL problemático: %s\n', sqlObs);
                continue;
            end
        end
        
        % 5. Verificación final
        try
            fprintf('🔍 Verificación final...\n');
            sqlVerificar = sprintf('SELECT COUNT(*) as total FROM public.observaciones WHERE dataset_id = %d', dataset_id);
            verificacion = fetch(conn, sqlVerificar);
            total_guardado = verificacion.total(1);
            fprintf('✅ Verificación: %d observaciones guardadas en BD\n', total_guardado);
            
            if total_guardado == num_obs
                exito = true;
            end
        catch ME_verify
            fprintf('⚠ No se pudo verificar: %s\n', ME_verify.message);
            if observaciones_exitosas == num_obs
                exito = true;
            end
        end
        
        % Cerrar conexión
        close(conn);
        
        if exito
            fprintf('🎉 ¡GUARDADO COMPLETAMENTE EXITOSO!\n');
            fprintf('   Dataset ID: %d\n', dataset_id);
            fprintf('   Nombre: %s\n', nombre);
            fprintf('   Descripción: %s\n', descripcion);
            fprintf('   Observaciones: %d/%d guardadas\n', observaciones_exitosas, num_obs);
        else
            fprintf('⚠ Guardado parcial o con errores\n');
            fprintf('   Dataset guardado, pero solo %d/%d observaciones\n', observaciones_exitosas, num_obs);
        end
        
    catch ME
        fprintf('❌ ERROR GENERAL: %s\n', ME.message);
        
        if ~isempty(ME.stack)
            fprintf('📍 Error en: %s, línea %d\n', ME.stack(1).name, ME.stack(1).line);
        end
        
        if exist('conn', 'var') && ~isempty(conn)
            try
                close(conn);
                fprintf('🔐 Conexión cerrada\n');
            catch
            end
        end
        
        exito = false;
    end
end

% *** FUNCIÓN INTERNA COMPACTA PARA CARGAR DRIVER ***
function exito = cargarDriverJDBC()
    try
        % Ruta directa conocida
        ruta_driver = 'C:\Program Files\MATLAB\R2024b\postgresql-42.7.5.jar';
        
        % Verificar si ya está cargado
        classpath_actual = javaclasspath('-dynamic');
        if any(contains(classpath_actual, 'postgresql'))
            exito = true;
            return;
        end
        
        % Verificar que el archivo existe
        if ~exist(ruta_driver, 'file')
            fprintf('❌ Driver no encontrado en: %s\n', ruta_driver);
            exito = false;
            return;
        end
        
        % Cargar driver
        javaaddpath(ruta_driver);
        fprintf('✅ Driver PostgreSQL cargado\n');
        exito = true;
        
    catch ME
        fprintf('❌ Error cargando driver: %s\n', ME.message);
        exito = false;
    end
end