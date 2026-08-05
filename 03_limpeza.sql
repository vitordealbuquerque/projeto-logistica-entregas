-- ============================================================================
-- Script 03/04 - Limpeza, checagens e criação de colunas derivadas
-- Nível: intermediário (usa CASE, INTERVAL, ALTER TABLE)
-- ============================================================================

SET search_path TO logistica, public;

-- ------------------------------------------------------------------
-- 1) NULOS por coluna crítica
-- ------------------------------------------------------------------
SELECT
    SUM(CASE WHEN transportadora_id IS NULL THEN 1 ELSE 0 END) AS null_transp,
    SUM(CASE WHEN data_coleta       IS NULL THEN 1 ELSE 0 END) AS null_coleta,
    SUM(CASE WHEN data_prometida    IS NULL THEN 1 ELSE 0 END) AS null_prometida,
    SUM(CASE WHEN valor_frete       IS NULL THEN 1 ELSE 0 END) AS null_frete,
    SUM(CASE WHEN status            IS NULL THEN 1 ELSE 0 END) AS null_status
FROM envios;

-- ------------------------------------------------------------------
-- 2) Consistência temporal: data_entrega < data_coleta é erro
-- ------------------------------------------------------------------
SELECT COUNT(*) AS entregas_antes_da_coleta
FROM envios
WHERE data_entrega IS NOT NULL
  AND data_entrega < data_coleta;

-- ------------------------------------------------------------------
-- 3) UF destino fora do padrão IBGE
-- ------------------------------------------------------------------
SELECT uf_destino, COUNT(*) AS qtd
FROM envios
WHERE uf_destino NOT IN
     ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MG','MS','MT',
      'PA','PB','PE','PI','PR','RJ','RN','RO','RR','RS','SC','SE','SP','TO')
GROUP BY uf_destino;

-- ------------------------------------------------------------------
-- 4) Outliers de peso e valor (percentis)
-- ------------------------------------------------------------------
SELECT
    MIN(peso_kg)                                            AS peso_min,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY peso_kg)   AS peso_p50,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY peso_kg)   AS peso_p95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY peso_kg)   AS peso_p99,
    MAX(peso_kg)                                            AS peso_max,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY valor_frete) AS frete_p95
FROM envios;

-- ------------------------------------------------------------------
-- 5) Colunas derivadas
-- ------------------------------------------------------------------
ALTER TABLE envios
    ADD COLUMN IF NOT EXISTS dias_prometidos INTEGER,
    ADD COLUMN IF NOT EXISTS dias_reais      INTEGER,
    ADD COLUMN IF NOT EXISTS dias_atraso     INTEGER,
    ADD COLUMN IF NOT EXISTS no_prazo        SMALLINT,
    ADD COLUMN IF NOT EXISTS frete_por_kg    NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS ano_mes         CHAR(7);

UPDATE envios
SET dias_prometidos = (data_prometida - data_coleta::date),
    dias_reais      = CASE WHEN data_entrega IS NULL THEN NULL
                           ELSE (data_entrega::date - data_coleta::date) END,
    dias_atraso     = CASE WHEN data_entrega IS NULL THEN NULL
                           ELSE GREATEST(0, data_entrega::date - data_prometida) END,
    no_prazo        = CASE WHEN status = 'Entregue' AND data_entrega::date <= data_prometida THEN 1
                           WHEN status = 'Entregue' THEN 0
                           ELSE NULL END,
    frete_por_kg    = ROUND(valor_frete / peso_kg, 2),
    ano_mes         = TO_CHAR(data_coleta, 'YYYY-MM');

-- ------------------------------------------------------------------
-- 6) Índice extra depois das derivadas
-- ------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_env_no_prazo ON envios(no_prazo);
CREATE INDEX IF NOT EXISTS idx_env_ano_mes  ON envios(ano_mes);
