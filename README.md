# 📊 Looker Period-over-Period (YoY) Example

Este repositório demonstra como resolver o clássico problema de comparação de períodos (Year-over-Year - YoY) no Looker, especificamente quando os usuários precisam **filtrar anos específicos** na visualização.

## ⚠️ O Problema

Nativamente, quando um usuário aplica um filtro de data no Looker (ex: Ano = 2026), a query SQL gerada remove completamente os dados dos anos anteriores (ex: 2025). 

Como resultado, métricas que utilizam o tipo `percent_of_previous` (ou *Table Calculations* tradicionais) param de funcionar, pois o Looker não possui os dados do ano anterior na tabela de resultados para realizar a matemática.

## 💡 A Solução

Este projeto explora duas abordagens diferentes em LookML para contornar essa limitação. O banco de dados simulado para este exemplo suporta funções de janelamento (*Window Functions*), como BigQuery, PostgreSQL ou SQL Server.

### Opção 1: Sem Tabela Derivada (Abordagem Nativa com Injeção)
* **Views envolvidas:** `store_sales`
* **Explore:** `store_sales`

**Como funciona:** Utiliza um filtro dummy (`analysis_year`) aliado a um parâmetro Liquid no `sql_always_where` do Explore. Se o usuário filtra "2026", o Liquid altera a query SQL "por baixo dos panos" para buscar 2026 **E** 2025 (`ano selecionado + 1`).

* **Prós:** Não exige a criação de tabelas derivadas no banco de dados. Usa a função nativa `percent_of_previous`.
* **Contras (Por que não recomendamos):** Como a query retorna o ano base (2025) para fazer o cálculo, a coluna de 2025 **aparecerá na visualização final** com as métricas de YoY em branco/nulas. O usuário final será obrigado a ocultar essa coluna manualmente clicando em *"Hide from Visualization"*, o que gera atrito na usabilidade.

### Opção 2: Com Tabela Derivada (⭐ Solução Recomendada)
* **Views envolvidas:** `store_sales_new`, `store_sales_yoy_precalc`
* **Explore:** `store_sales_new`

**Como funciona:** Cria uma Tabela Derivada Nativa (Derived Table) usando a função SQL `LAG() OVER()`. O valor de vendas do ano anterior é pré-calculado diretamente no banco de dados e exposto como uma métrica (`prev_year_sales_usd`) na mesma linha do ano atual. O Explore faz um `LEFT JOIN` dessa tabela com a base principal.

* **Prós:** A experiência do usuário é perfeita. Ao filtrar por "2026", a visualização trará apenas a coluna de 2026 já com a variação percentual calculada, sem a necessidade de ocultar colunas em branco ou realizar gambiarras na interface.

---

## 🚀 Como utilizar a visualização (Guia para Usuários Finais)

Para tirar proveito da solução pré-calculada (Opção 2) e montar um painel de comparação limpo e autônomo, siga os passos abaixo:

1. **Acesse o Explore:** Navegue até o Explore **`Store Sales New`**.
2. **Filtre o Período:** Na view `Store Sales New`, adicione a dimensão **`Date Year (Dropdown)`** à seção de Filtros (*Filters*). Selecione os anos exatos que você deseja analisar (por exemplo, `2025` e `2026`).
3. **Quebre os Dados:** 
   * Escolha as dimensões para as linhas (ex: clique em **`Store Name`**).
   * Faça um *Pivot* pela dimensão de data para criar colunas anuais (clique no ícone de Pivot na frente de **`Date Year`**).
4. **Adicione as Métricas:** Abra a view **`Store Sales Yoy Precalc`** e selecione:
   * **`Total Sales USD`**: Traz o volume absoluto de vendas do ano.
   * **`% YoY Sales (Pre-calculated)`**: Traz a variação percentual em relação ao ano anterior, calculada com precisão.
5. **Execute:** Clique no botão **Run** (Executar).

**✨ Resultado:**
A tabela e os gráficos serão renderizados de forma 100% limpa, exibindo apenas os anos solicitados no filtro, com suas respectivas taxas de crescimento YoY prontas para uso em Dashboards ou Looks.

<img width="3798" height="1312" alt="image" src="https://github.com/user-attachments/assets/c709d43a-8e87-4c03-97a4-448d2326b074" />
