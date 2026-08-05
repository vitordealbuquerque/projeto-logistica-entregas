# 01 · Extração dos dados

## Fontes públicas de referência

Dados transacionais reais de transportadoras raramente ficam abertos (compliance, contratos, LGPD). O caminho de portfólio é combinar:

1. **KPIs setoriais oficiais** para calibrar a amostra:
   - ANTT — Anuário do Transporte Rodoviário de Cargas
   - ILOS — Painel de Custos Logísticos no Brasil
   - Confederação Nacional do Transporte (CNT) — Boletim Estatístico

2. **Amostra sintética fiel às distribuições reais**, para poder mostrar SQL, gráficos e história sem violar dado sensível. É o que este projeto faz.

## Como a amostra foi gerada

O script gera:

- **7 transportadoras** com nome fictício, tipo (rodoviário/aéreo), UF sede, ano de fundação e frota. Cada uma tem multiplicador de qualidade diferente (AeroExpress é a melhor, TransNorte a pior).
- **15 filiais** (CDs) em 15 cidades das 5 regiões.
- **22.000 envios** distribuídos ao longo de 2024, com:
  - Categoria do produto (10 categorias com peso, preço e taxa de fraude diferentes)
  - Origem (uma das 15 filiais) e destino (uma das 27 UFs)
  - Distância calculada a partir das UFs de origem/destino
  - Peso lognormal, valor frete função de peso × distância × modal
  - Data coleta, data prometida e data entrega (com atraso ajustado por região destino, transportadora e sazonalidade)
  - Modal: rodoviário (90%), aéreo (8%), rodoaéreo (2%)
  - Status: entregue (98,7%), devolvido (0,6%), extraviado (0,7%)

### Regras de negócio embutidas nos dados

- **SLA médio geral:** ~85% (fiel ao padrão do setor no e-commerce brasileiro)
- **Norte tem 1,75× mais atraso que o Sudeste** (limitação de infraestrutura)
- **Nov/Dez explodem** (Black Friday e Natal puxam volume +55% a +65% e pioram SLA em ~1,2×)
- **Transação para UF diferente da origem** aumenta o tempo médio
- **Aéreo custa 3,2× o rodoviário** por unidade
- **Ticket médio de fraude é 4,5× o legítimo** — não usado aqui, mas mesmo padrão do outro projeto

## Se você quiser dado real

- **DataSUS/DataViva/portais estaduais** — algumas prefeituras publicam volumes de coleta de resíduos, transporte público etc. Não é logística de carga, mas serve pra treinar.
- **Kaggle · Brazilian E-Commerce Public Dataset by Olist**
  https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
  100k pedidos reais do Olist com dados de entrega, sla, região e reviews. Formato ideal pra rodar SQL e Power BI.
- **Kaggle · Supply Chain Analysis**
  https://www.kaggle.com/datasets/harshsingh2209/supply-chain-analysis
  Dataset de operação de moda internacional com transportadora, custo, produto.

## Como carregar seu próprio dado

O script `02_sql/02_carregar_dados.sql` usa `\COPY` do psql. Basta:

1. Salvar seu CSV em `03_dados/`
2. Ajustar os nomes de coluna no `01_criar_tabelas.sql` se necessário
3. Rodar os 4 scripts na ordem
