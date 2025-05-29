
function resultados = calcularRegresionMultiple(Y, X)
    % Motor de Regresión Lineal Múltiple
    % Input: Y = vector columna (variable dependiente)
    %        X = matriz (variables independientes)
    % Output: estructura con resultados completos
    
    try
        % ===== VALIDACIONES =====
        if size(Y, 2) > 1
            error('Y debe ser un vector columna');
        end
        
        if size(Y, 1) ~= size(X, 1)
            error('Y y X deben tener el mismo número de filas');
        end
        
        if size(Y, 1) <= size(X, 2)
            error('Número de observaciones debe ser mayor que número de variables');
        end
        
        % Verificar valores faltantes
        if any(isnan(Y)) || any(isnan(X(:)))
            error('No se permiten valores NaN en los datos');
        end
        
        % ===== CÁLCULOS PRINCIPALES =====
        n = size(Y, 1);  % número de observaciones
        k = size(X, 2);  % número de variables independientes
        
        % Agregar columna de 1s para el intercepto
        X_con_intercepto = [ones(n, 1), X];
        
        % Verificar singularidad de matriz
        if rank(X_con_intercepto) < size(X_con_intercepto, 2)
            error('Matriz X''X es singular. Verificar multicolinealidad');
        end
        
        % Cálculo de coeficientes: β = (X'X)^(-1)X'Y
        XtX = X_con_intercepto' * X_con_intercepto;
        XtY = X_con_intercepto' * Y;
        beta = XtX \ XtY;
        
        % Valores predichos
        Y_pred = X_con_intercepto * beta;
        
        % Residuos
        residuos = Y - Y_pred;
        
        % ===== ESTADÍSTICAS DE BONDAD DE AJUSTE =====
        % Suma de cuadrados
        SST = sum((Y - mean(Y)).^2);  % Total
        SSR = sum((Y_pred - mean(Y)).^2);  % Regresión
        SSE = sum(residuos.^2);  % Error
        
        % R-cuadrado
        R2 = SSR / SST;
        
        % R-cuadrado ajustado
        R2_adj = 1 - ((1 - R2) * (n - 1)) / (n - k - 1);
        
        % Error estándar de la regresión
        MSE = SSE / (n - k - 1);
        error_estandar = sqrt(MSE);
        
        % ===== PRUEBAS ESTADÍSTICAS =====
        % Estadístico F para significancia global
        F_stat = (SSR / k) / MSE;
        
        % Matriz de covarianza de los coeficientes
        var_covar_beta = MSE * inv(XtX);
        
        % Errores estándar de los coeficientes
        se_beta = sqrt(diag(var_covar_beta));
        
        % Estadísticos t
        t_stats = beta ./ se_beta;
        
        % ===== ECUACIÓN DE REGRESIÓN =====
        ecuacion = 'Y = ';
        ecuacion = [ecuacion sprintf('%.4f', beta(1))];  % Intercepto
        
        for i = 2:length(beta)
            if beta(i) >= 0
                ecuacion = [ecuacion sprintf(' + %.4f*X%d', beta(i), i-1)];
            else
                ecuacion = [ecuacion sprintf(' - %.4f*X%d', abs(beta(i)), i-1)];
            end
        end
        
        % ===== ESTRUCTURA DE RESULTADOS =====
        resultados = struct();
        resultados.beta = beta;
        resultados.se_beta = se_beta;
        resultados.t_stats = t_stats;
        resultados.Y_pred = Y_pred;
        resultados.residuos = residuos;
        resultados.R2 = R2;
        resultados.R2_adj = R2_adj;
        resultados.error_estandar = error_estandar;
        resultados.F_stat = F_stat;
        resultados.SST = SST;
        resultados.SSR = SSR;
        resultados.SSE = SSE;
        resultados.MSE = MSE;
        resultados.ecuacion = ecuacion;
        resultados.n = n;
        resultados.k = k;
        
        % Mensaje de éxito
        fprintf('✓ Regresión calculada exitosamente\n');
        fprintf('  R² = %.4f, R² ajustado = %.4f\n', R2, R2_adj);
        fprintf('  %s\n', ecuacion);
        
    catch ME
        error('Error en cálculo de regresión: %s', ME.message);
    end
end

% ===== FUNCIÓN AUXILIAR PARA MOSTRAR RESULTADOS =====
function mostrarResultados(resultados)
    fprintf('\n=== RESULTADOS DE REGRESIÓN LINEAL MÚLTIPLE ===\n');
    fprintf('Ecuación: %s\n\n', resultados.ecuacion);
    
    fprintf('ESTADÍSTICAS DE BONDAD DE AJUSTE:\n');
    fprintf('R² = %.4f\n', resultados.R2);
    fprintf('R² ajustado = %.4f\n', resultados.R2_adj);
    fprintf('Error estándar = %.4f\n', resultados.error_estandar);
    fprintf('Estadístico F = %.4f\n\n', resultados.F_stat);
    
    fprintf('COEFICIENTES:\n');
    fprintf('%-12s %-10s %-10s %-10s\n', 'Variable', 'Coef.', 'Error Std', 't-stat');
    fprintf('%-12s %-10.4f %-10.4f %-10.4f\n', 'Intercepto', ...
        resultados.beta(1), resultados.se_beta(1), resultados.t_stats(1));
    
    for i = 2:length(resultados.beta)
        fprintf('%-12s %-10.4f %-10.4f %-10.4f\n', sprintf('X%d', i-1), ...
            resultados.beta(i), resultados.se_beta(i), resultados.t_stats(i));
    end
    
    fprintf('\nNúmero de observaciones: %d\n', resultados.n);
    fprintf('Número de variables: %d\n', resultados.k);
end