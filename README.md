# Performance de Entregas — Transportadora Nacional 2024

Projeto de portfólio para transição de carreira para Análise de Dados.
Setor: **Logística**. Ciclo completo: modelagem SQL → limpeza → análise → dashboard geográfico.

---

## Pergunta de negócio

**Onde estamos perdendo prazo, quanto isso custa e qual transportadora está puxando o SLA para baixo?**

Cinco perguntas derivadas:

1. Qual o SLA geral e quanto de receita a operação movimenta?
2. Em que estado destino a entrega mais atrasa?
3. Que transportadora está abaixo do padrão?
4. Que motivos concentram os atrasos?
5. Vale a pena o custo do modal aéreo?

---

## Stack

| Etapa                | Ferramenta                                  |
| -------------------- | ------------------------------------------- |
| Modelagem e ETL      | PostgreSQL 15                               |
| Análise exploratória | SQL (CTE, window functions, PERCENTILE)     |
| Dashboard            | Power BI + Microsoft Excel                  |
| Apresentação         | LinkedIn                                    |

---

## Estrutura do projeto

```
projeto-logistica-entregas/
├── README.md
├── 01_extracao_dados.md              # como os dados foram gerados
├── 02_sql/
│   ├── 01_criar_tabelas.sql          # DDL + índices + constraints
│   ├── 02_carregar_dados.sql         # COPY dos CSV
│   ├── 03_limpeza.sql                # checagens + colunas derivadas
│   └── 04_analises.sql               # 10 KPIs com CTE/RANK/PERCENTILE
├── 03_dados/
│   ├── transportadoras.csv           # 7 empresas parceiras
│   ├── filiais.csv                   # 15 CDs de origem
│   └── envios.csv                    # 22.000 envios em 2024
├── 04_dashboard_entregas.xlsx        # dashboard executivo
├── 05_post_linkedin.md               # texto pronto pra postar
└── 06_prints/                        # 5 imagens pro post
    ├── print_01_erd.png              # ERD estilo DBeaver
    ├── print_02_sql.png              # query com resultado (DBeaver)
    ├── print_03_dashboard.png        # dashboard Power BI
    ├── print_04_mapa_bi.png          # mapa de bolhas por UF
    └── print_05_insights.png         # slide de insights
```

---

## Ordem para reproduzir

1. Instale PostgreSQL 15+ e um cliente (DBeaver ou pgAdmin).
2. Crie um banco `logistica_db`.
3. Rode `02_sql/01_criar_tabelas.sql`.
4. Coloque os CSV em `03_dados/` e rode `02_sql/02_carregar_dados.sql`.
5. Rode `02_sql/03_limpeza.sql` (cria colunas derivadas: dias_atraso, no_prazo, frete_por_kg, ano_mes).
6. Rode `02_sql/04_analises.sql` — cada bloco alimenta um card do dashboard.
7. Abra `04_dashboard_entregas.xlsx` para conferir os KPIs.
8. Se quiser recriar em Power BI, use os prints do dashboard como referência de layout.

---

## Modelo de dados

Estrela simplificada com 1 fato + 2 dimensões:

```
transportadoras (7 linhas)  ─┐
                             ├──► envios (22.000 linhas — fato)
filiais (15 linhas)  ────────┘
```

---

## Principais achados

| KPI                                        | Valor           |
| ------------------------------------------ | --------------- |
| Envios totais                              | 22.000          |
| Entregues                                  | 21.729          |
| SLA geral                                  | 85,03%          |
| Receita frete                              | R$ 1,04 milhão  |
| Tempo médio de entrega                     | 4,4 dias        |
| Ticket médio de frete                      | R$ 47,14        |
| Melhor SLA (transportadora)                | AeroExpress 87,6% |
| Pior SLA (transportadora)                  | TransNorte Cargo 77,8% |
| Pior SLA (região)                          | Norte 72,4%     |
| Melhor SLA (região)                        | Sudeste 87,5%   |
| Modal mais caro                            | Aéreo R$ 124    |
| Modal mais barato                          | Rodoviário R$ 38 |
| Top motivo de atraso                       | Falha na roteirização |

---

## Sobre os dados

Amostra sintética modelada a partir de KPIs setoriais públicos de transportadoras brasileiras (ANTT, ILOS 2023-2024). A estrutura das tabelas espelha um dataset real de operadora nacional — troque o CSV pelo dado da sua empresa e o SQL roda igual.

---

## Autor

**Vitor França** — engcivil.vitorfranca@gmail.com
Em transição para Análise de Dados.
