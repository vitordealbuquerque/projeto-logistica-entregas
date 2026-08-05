-- ============================================================================
-- Script 04/04 - Análises intermediárias
-- Usa: CTE, window functions (RANK/LAG), PERCENTILE_CONT, FILTER, JOIN
-- Cada bloco alimenta um card ou visual do dashboard.
-- ============================================================================

SET search_path TO logistica, public;

-- ============================================================================
-- KPI 1 — Panorama executivo
-- ============================================================================
SELECT
    COUNT(*)                                     AS envios_total,
    COUNT(*) FILTER (WHERE status='Entregue')    AS entregues,
    COUNT(*) FILTER (WHERE no_prazo=1)           AS no_prazo,
    COUNT(*) FILTER (WHERE status='Devolvido')   AS devolvidos,
    COUNT(*) FILTER (WHERE status='Extraviado')  AS extraviados,
    ROUND(100.0 * COUNT(*) FILTER (WHERE no_prazo=1) /
                  NULLIF(COUNT(*) FILTER (WHERE status='Entregue'), 0), 2) AS sla_pct,
    ROUND(SUM(valor_frete)::numeric, 2)          AS receita_frete,
    ROUND(AVG(valor_frete)::numeric, 2)          AS ticket_medio,
    ROUND(AVG(dias_reais)::numeric, 2)           AS dias_medio_entrega
FROM envios;

-- ============================================================================
-- KPI 2 — SLA por UF destino (alimenta o mapa)
-- ============================================================================
SELECT
    uf_destino,
    regiao_destino,
    COUNT(*) FILTER (WHERE status='Entregue')  AS entregues,
    SUM(no_prazo) FILTER (WHERE status='Entregue') AS no_prazo,
    ROUND(100.0*SUM(no_prazo) FILTER (WHERE status='Entregue')
              / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2) AS sla_pct
FROM envios
GROUP BY uf_destino, regiao_destino
ORDER BY sla_pct DESC;

-- ============================================================================
-- KPI 3 — Ranking de transportadoras
-- Usa window function pra ranquear e diferença vs. líder
-- ============================================================================
WITH stats AS (
    SELECT
        t.nome                                     AS transportadora,
        COUNT(*)                                   AS envios,
        SUM(e.valor_frete)                         AS receita,
        ROUND(100.0*SUM(no_prazo) FILTER (WHERE status='Entregue')
                    / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2) AS sla_pct
    FROM envios e
    JOIN transportadoras t USING (transportadora_id)
    GROUP BY t.nome
)
SELECT
    transportadora,
    envios,
    receita,
    sla_pct,
    RANK() OVER (ORDER BY sla_pct DESC)                             AS rank_sla,
    ROUND(sla_pct - MAX(sla_pct) OVER (), 2)                        AS diff_vs_lider,
    ROUND(100.0*envios / SUM(envios) OVER (), 2)                    AS share_volume_pct
FROM stats
ORDER BY sla_pct DESC;

-- ============================================================================
-- KPI 4 — Evolução mensal e crescimento MoM (LAG)
-- ============================================================================
WITH mensal AS (
    SELECT
        ano_mes,
        COUNT(*)                                    AS envios,
        SUM(valor_frete)                            AS receita,
        ROUND(100.0*SUM(no_prazo) FILTER (WHERE status='Entregue')
                    / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2) AS sla_pct
    FROM envios
    GROUP BY ano_mes
)
SELECT
    ano_mes,
    envios,
    receita,
    sla_pct,
    LAG(envios) OVER (ORDER BY ano_mes)                                       AS envios_mes_ant,
    ROUND(100.0*(envios - LAG(envios) OVER (ORDER BY ano_mes))
              / NULLIF(LAG(envios) OVER (ORDER BY ano_mes),0), 2)             AS crescimento_pct,
    ROUND(sla_pct - LAG(sla_pct) OVER (ORDER BY ano_mes), 2)                  AS delta_sla
FROM mensal
ORDER BY ano_mes;

-- ============================================================================
-- KPI 5 — Top 10 motivos de atraso
-- ============================================================================
SELECT
    motivo,
    COUNT(*)                                          AS ocorrencias,
    ROUND(100.0*COUNT(*) / SUM(COUNT(*)) OVER (), 2)  AS pct_do_total
FROM envios
WHERE status = 'Entregue' AND no_prazo = 0
GROUP BY motivo
ORDER BY ocorrencias DESC
LIMIT 10;

-- ============================================================================
-- KPI 6 — Modal x SLA x custo
-- ============================================================================
SELECT
    modal,
    COUNT(*)                                     AS envios,
    ROUND(100.0*SUM(no_prazo) FILTER (WHERE status='Entregue')
              / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2) AS sla_pct,
    ROUND(AVG(valor_frete)::numeric, 2)          AS ticket_medio,
    ROUND(AVG(frete_por_kg)::numeric, 2)         AS frete_por_kg_medio,
    ROUND(AVG(dias_reais)::numeric, 2)           AS dias_entrega_medio
FROM envios
GROUP BY modal
ORDER BY sla_pct DESC;

-- ============================================================================
-- KPI 7 — Rotas mais caras por R$/kg (mín. 30 envios)
-- Usa NTILE pra classificar em quartis
-- ============================================================================
WITH rotas AS (
    SELECT
        uf_origem,
        uf_destino,
        COUNT(*)                              AS envios,
        ROUND(AVG(frete_por_kg)::numeric, 2)  AS frete_kg_medio,
        ROUND(AVG(distancia_km)::numeric, 0)  AS distancia_media
    FROM envios
    GROUP BY uf_origem, uf_destino
    HAVING COUNT(*) >= 30
)
SELECT
    uf_origem,
    uf_destino,
    envios,
    frete_kg_medio,
    distancia_media,
    NTILE(4) OVER (ORDER BY frete_kg_medio DESC) AS quartil_preco
FROM rotas
ORDER BY frete_kg_medio DESC
LIMIT 10;

-- ============================================================================
-- KPI 8 — Percentis de tempo de entrega por região
-- ============================================================================
SELECT
    regiao_destino,
    COUNT(*)                                                      AS entregues,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY dias_reais)::numeric, 1) AS p50_dias,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY dias_reais)::numeric, 1) AS p90_dias,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY dias_reais)::numeric, 1) AS p99_dias
FROM envios
WHERE status = 'Entregue'
GROUP BY regiao_destino
ORDER BY p90_dias DESC;

-- ============================================================================
-- KPI 9 — Melhor transportadora por região (RANK dentro do grupo)
-- ============================================================================
WITH sla_transp_reg AS (
    SELECT
        e.regiao_destino,
        t.nome                                                                       AS transportadora,
        COUNT(*)                                                                     AS envios,
        ROUND(100.0*SUM(no_prazo) FILTER (WHERE status='Entregue')
                    / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2)        AS sla_pct
    FROM envios e
    JOIN transportadoras t USING (transportadora_id)
    GROUP BY e.regiao_destino, t.nome
)
SELECT *
FROM (
    SELECT
        regiao_destino,
        transportadora,
        envios,
        sla_pct,
        RANK() OVER (PARTITION BY regiao_destino ORDER BY sla_pct DESC) AS pos
    FROM sla_transp_reg
) x
WHERE pos <= 3
ORDER BY regiao_destino, pos;

-- ============================================================================
-- KPI 10 — Custo médio de operação por filial de origem
-- ============================================================================
SELECT
    f.cidade                                       AS cd_origem,
    f.uf                                           AS uf_cd,
    f.regiao                                       AS regiao_cd,
    COUNT(*)                                       AS envios,
    ROUND(SUM(e.valor_frete)::numeric, 2)          AS receita,
    ROUND(AVG(e.valor_frete)::numeric, 2)          AS ticket_medio,
    ROUND(100.0*SUM(e.no_prazo) FILTER (WHERE status='Entregue')
                / NULLIF(COUNT(*) FILTER (WHERE status='Entregue'),0), 2) AS sla_pct
FROM envios e
JOIN filiais f ON f.filial_id = e.filial_origem_id
GROUP BY f.cidade, f.uf, f.regiao
ORDER BY receita DESC;
