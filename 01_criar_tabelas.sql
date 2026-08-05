-- ============================================================================
-- PROJETO: Performance de Entregas — Transportadora Nacional (Brasil, 2024)
-- Script 01/04 - DDL: schema, dimensões, fato, índices, constraints
-- PostgreSQL 15+
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS logistica;
SET search_path TO logistica, public;

-- --------------------------------------------------------------------------
-- Dimensão: transportadoras
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS envios         CASCADE;
DROP TABLE IF EXISTS filiais        CASCADE;
DROP TABLE IF EXISTS transportadoras CASCADE;

CREATE TABLE transportadoras (
    transportadora_id  SMALLINT     PRIMARY KEY,
    nome               VARCHAR(60)  NOT NULL,
    tipo               VARCHAR(20)  NOT NULL,
    sede_uf            CHAR(2)      NOT NULL,
    ano_fundacao       SMALLINT     CHECK (ano_fundacao BETWEEN 1990 AND 2030),
    frota_veiculos     INTEGER      CHECK (frota_veiculos > 0)
);

-- --------------------------------------------------------------------------
-- Dimensão: filiais (centros de distribuição)
-- --------------------------------------------------------------------------
CREATE TABLE filiais (
    filial_id  SMALLINT     PRIMARY KEY,
    uf         CHAR(2)      NOT NULL,
    cidade     VARCHAR(60)  NOT NULL,
    regiao     VARCHAR(15)  NOT NULL
        CHECK (regiao IN ('Norte','Nordeste','Centro-Oeste','Sudeste','Sul')),
    tipo       VARCHAR(20)  NOT NULL
);

-- --------------------------------------------------------------------------
-- Fato: envios
-- --------------------------------------------------------------------------
CREATE TABLE envios (
    envio_id           BIGINT       PRIMARY KEY,
    transportadora_id  SMALLINT     NOT NULL REFERENCES transportadoras(transportadora_id),
    filial_origem_id   SMALLINT     NOT NULL REFERENCES filiais(filial_id),
    data_coleta        TIMESTAMP    NOT NULL,
    data_prometida     DATE         NOT NULL,
    data_entrega       TIMESTAMP,                 -- NULL se extraviado
    uf_origem          CHAR(2)      NOT NULL,
    uf_destino         CHAR(2)      NOT NULL,
    regiao_destino     VARCHAR(15)  NOT NULL,
    distancia_km       INTEGER      CHECK (distancia_km > 0),
    peso_kg            NUMERIC(8,2) CHECK (peso_kg > 0),
    valor_declarado    NUMERIC(10,2),
    valor_frete        NUMERIC(10,2) CHECK (valor_frete > 0),
    modal              VARCHAR(20)  CHECK (modal IN ('Rodoviário','Aéreo','Rodoaéreo')),
    categoria_produto  VARCHAR(30)  NOT NULL,
    status             VARCHAR(15)  CHECK (status IN ('Entregue','Devolvido','Extraviado')),
    motivo             VARCHAR(60)
);

-- Índices que aceleram as análises mais usadas
CREATE INDEX idx_env_transp        ON envios(transportadora_id);
CREATE INDEX idx_env_filial        ON envios(filial_origem_id);
CREATE INDEX idx_env_coleta        ON envios(data_coleta);
CREATE INDEX idx_env_dest_uf       ON envios(uf_destino);
CREATE INDEX idx_env_status        ON envios(status);
CREATE INDEX idx_env_regiao        ON envios(regiao_destino);

COMMENT ON TABLE  envios                     IS 'Fato: cada envio da operação em 2024';
COMMENT ON COLUMN envios.data_prometida      IS 'Data prometida pelo comercial no ato da venda';
COMMENT ON COLUMN envios.data_entrega        IS 'Data efetiva; NULL se extraviado';
COMMENT ON COLUMN envios.motivo              IS 'Preenchido quando houve atraso, devolução ou extravio';
