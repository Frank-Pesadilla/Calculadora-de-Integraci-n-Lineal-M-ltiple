function verDatos()
    % Ver todos los datasets guardados
    
    try
        conn = database('bd_RegresionLineal', 'postgres', 'francesfranco2004', ...
            'org.postgresql.Driver', ...
            'jdbc:postgresql://localhost:5432/bd_RegresionLineal');
        
        sql = 'SELECT id, nombre, descripcion, num_observaciones, num_variables_indep FROM public.datasets ORDER BY id DESC';
        datos = fetch(conn, sql);
        
        if isempty(datos)
            fprintf('📭 No hay datasets guardados.\n');
        else
            fprintf('\n=== DATASETS GUARDADOS ===\n');
            fprintf('%-4s %-20s %-35s %-6s %-6s\n', 'ID', 'Nombre', 'Descripción', 'Obs', 'Vars');
            fprintf('%s\n', repmat('-', 1, 75));
            
            for i = 1:height(datos)
                desc = datos.descripcion{i};
                if length(desc) > 35
                    desc = [desc(1:32) '...'];
                end
                
                fprintf('%-4d %-20s %-35s %-6d %-6d\n', ...
                    datos.id(i), datos.nombre{i}, desc, ...
                    datos.num_observaciones(i), datos.num_variables_indep(i));
            end
            
            fprintf('\n✅ Total: %d datasets\n', height(datos));
        end
        
        close(conn);
        
    catch ME
        fprintf('❌ Error: %s\n', ME.message);
    end
end