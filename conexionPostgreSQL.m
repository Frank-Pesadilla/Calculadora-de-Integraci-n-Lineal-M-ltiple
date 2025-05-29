function conexionPostgreSQL()
    fprintf('=== CONFIGURACIÓN POSTGRESQL ===\n');
    fprintf('1. Agregando driver JDBC...\n');
    
    % Tu ruta específica del driver
    ruta_driver = 'C:\Program Files\MATLAB\R2024b\postgresql-42.7.5.jar';
    
    try
        % Verificar que el archivo existe
        if exist(ruta_driver, 'file')
            javaaddpath(ruta_driver);
            fprintf('   ✓ Driver agregado correctamente\n');
            
            % Verificar que se agregó al classpath
            classpath_actual = javaclasspath('-dynamic');
            if any(contains(classpath_actual, 'postgresql'))
                fprintf('   ✓ Driver confirmado en classpath\n');
            else
                fprintf('   ⚠ Driver agregado pero no confirmado\n');
            end
        else
            error('Archivo no encontrado en: %s', ruta_driver);
        end
    catch ME
        fprintf('   ✗ Error agregando driver: %s\n', ME.message);
        return;
    end
    
    % PASO 2: Probar conexión
    fprintf('2. Probando conexión a bd_RegresionLineal...\n');
    conn = conectarBD();
    
    if ~isempty(conn) && isempty(conn.Message)
        fprintf('   ✓ ¡CONEXIÓN EXITOSA!\n');
        
        % Prueba de consulta
        try
            result = fetch(conn, 'SELECT current_database() as bd, now() as fecha');
            fprintf('   ✓ Base de datos: %s\n', string(result.bd));
            fprintf('   ✓ Fecha/Hora: %s\n', string(result.fecha));
        catch ME
            fprintf('   ⚠ Conexión OK, error en consulta: %s\n', ME.message);
        end
        
        close(conn);
        fprintf('3. Conexión cerrada correctamente\n');
        
    else
        fprintf('   ✗ Error en conexión\n');
        if ~isempty(conn)
            fprintf('   Detalle del error: %s\n', conn.Message);
        end
        
        % Sugerencias de diagnóstico
        fprintf('\n=== VERIFICAR ===\n');
        fprintf('- ¿PostgreSQL está ejecutándose?\n');
        fprintf('- ¿Existe la BD "bd_RegresionLineal"?\n');
        fprintf('- ¿Contraseña correcta: francesfranco2004?\n');
    end
end

% Función auxiliar para conectar
function conn = conectarBD()
    try
        conn = database('bd_RegresionLineal', 'postgres', 'francesfranco2004', ...
            'org.postgresql.Driver', ...
            'jdbc:postgresql://localhost:5432/bd_RegresionLineal');
    catch ME
        fprintf('Error al crear objeto de conexión: %s\n', ME.message);
        conn = [];
    end
end