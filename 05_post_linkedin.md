# Post pronto pro LinkedIn (versão humanizada — final)

> Terminei mais um projeto do portfólio.
>
> Dessa vez fui pra logística. Modelei uma operação de transportadora nacional do zero: 22 mil envios em 2024, 7 transportadoras, 15 CDs, cobertura em todas as UFs. Base e análises em PostgreSQL, dashboard no Power BI.
>
> No SQL brinquei com CTE, window function (RANK, LAG pra crescimento MoM) e PERCENTILE_CONT pra medir a cauda de tempo de entrega. No Power BI o mapa por estado virou o centro do dashboard — junto vieram o ranking das transportadoras e a curva mensal.
>
> O SLA médio foi 85%. Achei razoável até quebrar por região e ver o Norte a 72%. Uma das 7 transportadoras ficou 9,7 pontos atrás da líder. Novembro e Dezembro pesam: volume sobe 80% com Black Friday e Natal, e o SLA cai junto.
>
> Sou eng civil em transição pra dados. Se você tá no mesmo caminho, chega junto. Recrutador que quiser conversar sobre vaga jr, chama no DM.
>
> Link do repo no primeiro comentário.
>
> #analisededados #sql #powerbi

---

# Versões descartadas (arquivo)

Três versões — escolha a que combina mais com sua voz. Todas escritas pra sair natural, sem cara de IA.

---

## VERSÃO 1 — Storytelling da transição (recomendada)

> Segundo projeto do meu portfólio de análise de dados. Dessa vez fui pra logística.
>
> Modelei uma operação de transportadora nacional: 22 mil envios, 7 transportadoras parceiras, 15 CDs, 27 UFs atendidas. Tudo em PostgreSQL, dashboard em Power BI com mapa por estado.
>
> O que saiu:
>
> → SLA geral 85% · o padrão do setor é 90%, então já entrei com uma hipótese
> → Norte tem 72% de SLA · 15 pontos abaixo do Sudeste
> → TransNorte Cargo está 9,7 pontos atrás da líder
> → Nov e Dez explodem — Black Friday e Natal puxam +80% de volume e derrubam SLA
> → Aéreo entrega em 1 dia · mas custa 3× o rodoviário
> → Top motivo de atraso: "falha na roteirização" (500 ocorrências)
>
> O que aprendi montando: dashboard fica bonito rápido. Mas o difícil é decidir a métrica certa. Comecei olhando SLA global (85% parece razoável), aí quebrei por região e descobri que o Norte estava puxando pra baixo. Sem a segmentação, o problema fica invisível.
>
> Repositório completo (SQL + CSV + Excel + Power BI mockup) no primeiro comentário.
>
> Se você também está em transição, chega junto. Compartilhar tropeço economiza tempo dos dois.
>
> #dados #sql #postgresql #powerbi #logistica #transicaodecarreira

---

## VERSÃO 2 — Direta, focada no que fez

> Novo projeto no portfólio: análise de performance de entregas de uma transportadora nacional.
>
> **Stack:** PostgreSQL (modelagem + análise), Power BI (dashboard).
>
> **O que fiz:**
> · Modelei 3 tabelas em modelo estrela (transportadoras, filiais, envios)
> · Escrevi 4 scripts SQL — DDL, carga, limpeza e 10 análises
> · Usei CTE, window functions (RANK, LAG) e PERCENTILE_CONT
> · Dashboard com mapa de bolhas por UF, ranking de transportadoras, evolução mensal e análise de modais
>
> **Insight que valeu a construção:** transportadora com pior SLA (77,8%) está exatamente 9,7 pontos atrás da líder. Isso é conversa comercial. Foco só no SLA médio (85%) esconderia.
>
> Deixei tudo público no primeiro comentário. Feedback é bem-vindo.
>
> #sql #postgresql #powerbi #logistica #dataanalytics

---

## VERSÃO 3 — Curta

> Novo projeto: performance de entregas de transportadora nacional.
>
> 22 mil envios, PostgreSQL, Power BI, 10 análises.
>
> Três coisas que descobri:
> 1. SLA geral parece ok (85%) — mas o Norte está a 72%
> 2. Uma das 7 transportadoras está 9,7p atrás da líder
> 3. Aéreo é 3× mais caro, mas entrega em 1 dia
>
> Repositório no comentário.
>
> #dados #sql #powerbi

---

## Dicas de postagem

**Ordem sugerida de imagens no post:**
1. `print_05_insights.png` — abre com números que prendem atenção
2. `print_03_dashboard.png` — prova visual (o mapa por UF chama muito atenção)
3. `print_04_mapa_bi.png` — mapa em zoom (destaca o Power BI)
4. `print_02_sql.png` — mostra o SQL de verdade (window function)
5. `print_01_erd.png` — modelagem — atrai o olhar técnico

**Melhor horário para publicar:** terça a quinta, 8h-10h ou 18h-20h.

**No primeiro comentário** (LinkedIn penaliza link no corpo):
> Repositório completo aqui: [link do GitHub]
> Se preferir só o dashboard: [link direto do arquivo]

**O que responder ao recrutador:**
> "Se quiser conversar sobre a vaga, me chama no DM — mando o currículo e a gente marca uma call."
