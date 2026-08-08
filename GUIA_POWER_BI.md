# Passo a passo — Power BI (Logística)

Do zero até o dashboard: extração dos dados, modelo, todas as medidas DAX e qual gráfico usar em cada bloco do fundo (`06_prints/fundo_dashboard_powerbi.png`).

---

## Parte 1 — Extração dos dados no Power BI

1. Extraia `Logistica_PowerBI.zip` numa pasta.
2. Coloque essa pasta dentro de `projeto-logistica-entregas/`, de forma que exista o caminho `...\projeto-logistica-entregas\03_dados\` com os 3 CSVs (`envios.csv`, `filiais.csv`, `transportadoras.csv`).
3. Abra `Logistica.pbip` com o Power BI Desktop (ele abre como um projeto normal).
4. Menu **Início → Transformar dados → Editar parâmetros**. No parâmetro `CaminhoBase`, cole o caminho completo até a pasta `03_dados`, terminando com `\` (ex: `C:\Users\vitor\Downloads\projeto-logistica-entregas\03_dados\`). Clique OK.
5. **Início → Atualizar**. As 3 tabelas carregam dos CSV.
6. Confirma no painel "Dados" que veio: `envios` (22.000 linhas), `filiais` (15), `transportadoras` (7). Se algum número vier diferente, o `CaminhoBase` está apontando pro CSV errado.

## Parte 2 — Conferir o modelo

1. Vá na view **Modelo** (ícone de diagrama, barra lateral esquerda).
2. Confirme as duas relações: `filiais[filial_id]` → `envios[filial_origem_id]` e `transportadoras[transportadora_id]` → `envios[transportadora_id]`, ambas 1 para muitos, direção única (filtro de filiais/transportadoras para envios).
3. As colunas calculadas já vêm prontas em `envios` (mesma lógica do `03_limpeza.sql`): `dias_reais`, `dias_atraso`, `no_prazo`, `frete_por_kg`, `ano_mes`, `custo_km`. Não precisa recriar nada.

## Parte 3 — Medidas DAX (todas já criadas no modelo)

| Medida | Fórmula DAX | Formato | Valor real (referência) |
|---|---|---|---|
| Envios Totais | `COUNTROWS(envios)` | inteiro | 22.000 |
| Entregues | `CALCULATE(COUNTROWS(envios), envios[status] = "Entregue")` | inteiro | 21.729 |
| No Prazo (qtd) | `CALCULATE(COUNTROWS(envios), envios[no_prazo] = 1)` | inteiro | 18.477 |
| Devolvidos | `CALCULATE(COUNTROWS(envios), envios[status] = "Devolvido")` | inteiro | 128 |
| Extraviados | `CALCULATE(COUNTROWS(envios), envios[status] = "Extraviado")` | inteiro | 143 |
| SLA % | `DIVIDE([No Prazo (qtd)], [Entregues])` | percentual | 85,0% |
| Receita Frete | `SUM(envios[valor_frete])` | moeda | R$ 1.037.081 |
| Ticket Medio | `AVERAGE(envios[valor_frete])` | moeda | R$ 47,14 |
| Dias Medio Entrega | `AVERAGE(envios[dias_reais])` | decimal | 4,4 dias |
| Frete por Kg Medio | `AVERAGE(envios[frete_por_kg])` | moeda | R$ 27,78 |
| Distancia Media Km | `AVERAGE(envios[distancia_km])` | inteiro | 1.277 km |
| Custo por Km Medio | `AVERAGE(envios[custo_km])` | moeda | R$ 0,06 |
| Envios Mes Anterior | ver bloco abaixo | inteiro | — (varia por mês) |
| Crescimento MoM % | `DIVIDE([Envios Totais] - [Envios Mes Anterior], [Envios Mes Anterior])` | percentual | Nov: +36,5% · Dez: +9,4% |
| SLA Mes Anterior | ver bloco abaixo | percentual | — (varia por mês) |
| Delta SLA (p.p.) | `([SLA %] - [SLA Mes Anterior]) * 100` | decimal | Nov: -3,47 p.p. |

`Envios Mes Anterior` e `SLA Mes Anterior` usam a mesma lógica (mês anterior calculado por comparação de texto, já que `ano_mes` no formato `YYYY-MM` ordena certo sem precisar de tabela calendário):

```dax
Envios Mes Anterior =
VAR MesAtual = SELECTEDVALUE(envios[ano_mes])
VAR MesAnterior =
    CALCULATE(MAX(envios[ano_mes]), FILTER(ALL(envios[ano_mes]), envios[ano_mes] < MesAtual))
RETURN
    CALCULATE([Envios Totais], envios[ano_mes] = MesAnterior)
```

Isso espelha o `LAG()` usado no `04_analises.sql` (KPI 4), sem precisar montar tabela calendário à parte.

## Parte 4 — Gráficos: o que colocar em cada bloco do fundo

Abra `fundo_dashboard_powerbi.png` como imagem de fundo da página (**Formatar página → Imagem de fundo**, transparência 0%) e encaixe os visuais exatamente nas molduras:

### Cards de KPI (topo)

| Bloco no fundo | Visual | Campo |
|---|---|---|
| RECEITA TOTAL | Cartão | `Receita Frete` |
| ENVIOS NO PERÍODO | Cartão | `Envios Totais` |
| SLA MÉDIO | Cartão | `SLA %` |
| TICKET MÉDIO | Cartão | `Ticket Medio` |
| CUSTO POR KM | Cartão | `Custo por Km Medio` |

### MAPA POR UF

Visual (ícone no painel Visualizações): **Mapa**.
* Local/Localização: `envios[uf_destino]`
* Tamanho da bolha: `SLA %`
* Tooltip extra: `Envios Totais`, `Entregues`

Esse é o visual padrão de mapa de bolhas do Power BI, já resolve por nome de UF sem precisar de mapa customizado (o visual "Mapa de Formas" é outro ícone, só usa se quiser preencher o estado inteiro em vez de bolha).

### RANKING TRANSPORTADORAS

Visual (ícone no painel Visualizações): **Gráfico de Barras Agrupadas** (o de barra na horizontal, não confundir com "Gráfico de Colunas Agrupadas" que é na vertical).
* Eixo Y: `transportadoras[nome]`
* Valores: `SLA %`
* Rótulos de dados ligados
* Cor condicional opcional: destaque em verde oliva pra quem está acima da média, terracota pra quem está mais de 5 p.p. abaixo do líder (regra: `[SLA %] < MAX([SLA %]) - 0.05`)

### EVOLUÇÃO MENSAL

Visual (ícone no painel Visualizações): **Gráfico de Linhas**.
* Eixo X: `envios[ano_mes]`
* Valores (eixo primário): `Envios Totais`
* Valores (eixo secundário): `SLA %`
* Tooltip: `Crescimento MoM %`, `Delta SLA (p.p.)`

### MODAL X CUSTO

Visual (ícone no painel Visualizações): **Gráfico de Colunas Clusterizadas e Linhas** (combo — eixo X = modal, eixo y da coluna = Ticket Medio, eixo y da linha = SLA %). Um gráfico de colunas simples achata a métrica de escala menor, por isso o combo.
* Eixo X: `envios[modal]`
* Eixo y da coluna: `Ticket Medio`
* Eixo y da linha: `SLA %`

### Página extra (opcional) — Motivos de atraso

Não está no fundo atual, mas dá pra adicionar como página 2:
* Visual: gráfico de barras
* Eixo Y: `envios[motivo]`
* Valores: contagem de `envios[envio_id]`
* Filtro de página: `envios[no_prazo] = 0`

## Depois de montar

Aplica o tema salvo em `tema_verde_oliva.json` (**Exibir → Temas → Procurar tema**) se quiser garantir que os gráficos usem exatamente a mesma paleta do fundo. Tira os prints direto do Power BI Desktop com os dados reais carregados — são esses que entram no README e no post do LinkedIn.
