-- ============================================================================
-- Script 02/04 - Carga dos CSV
-- Rodar via psql (necessário pro \COPY)
-- ============================================================================

SET search_path TO logistica, public;

-- Ajuste o caminho para onde estão os CSV no seu computador.
-- Windows aceita: 'C:/dados/...' ou 'C:\\dados\\...'

\COPY transportadoras FROM '03_dados/transportadoras.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');
\COPY filiais         FROM '03_dados/filiais.csv'         WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');
\COPY envios          FROM '03_dados/envios.csv'          WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8', NULL '');

-- Verificação de carga
SELECT 'transportadoras' AS tabela, COUNT(*) AS linhas FROM transportadoras
UNION ALL
SELECT 'filiais'         AS tabela, COUNT(*) AS linhas FROM filiais
UNION ALL
SELECT 'envios'          AS tabela, COUNT(*) AS linhas FROM envios;

-- Esperado:
-- transportadoras : 7
-- filiais         : 15
-- envios          : 22000
