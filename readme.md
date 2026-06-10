# Arquitetura de Memória Longa para Agente Conversacional de Atendimento

## 1. Introdução

Este projeto apresenta uma solução de automação conversacional voltada ao atendimento de pedidos em uma lanchonete, com foco na implementação de memória longa estruturada por cliente. A proposta integra orquestração de fluxos, persistência de dados e interação via WhatsApp, de modo a possibilitar um atendimento mais contextualizado, consistente e reproduzível.

<strong>Acesse o vídeo de explicação e demonstração aqui!</strong>

A solução foi desenvolvida com uma arquitetura baseada em serviços, utilizando n8n como orquestrador do fluxo conversacional, PostgreSQL como banco relacional para persistência da memória, Redis como suporte de fila e cache, e Evolution API como camada de integração com a plataforma de mensagens.

## 2. Objetivos do projeto

O projeto tem como objetivo principal demonstrar a construção de um agente conversacional com capacidade de:

- identificar o cliente de forma simples;
- registrar telefone como chave de referência;
- recuperar histórico de interação anterior;
- oferecer repetição do último pedido;
- confirmar pedidos de maneira estruturada;
- preservar o contexto entre sessões de atendimento.

## 3. Escopo funcional

O atendimento é restrito a um cardápio fixo composto apenas por três opções:

- X-Salada;
- X-Bacon;
- X-Burguer.

O agente deve atuar de forma objetiva, educada e curta, conduzindo a conversa até a identificação do nome do cliente, telefone e lanche desejado. O fluxo também contempla o uso de memória longa, permitindo recuperar o último pedido salvo quando houver correspondência de telefone.

## 4. Stack tecnológica

### 4.1 n8n
O n8n é utilizado como plataforma de orquestração dos fluxos. Ele recebe eventos por webhook, trata mensagens recebidas, executa validações, consulta a memória persistente e coordena a interação com o modelo de linguagem. No projeto, o n8n opera em modo de fila, com um worker dedicado para processamento assíncrono.

### 4.2 PostgreSQL
O PostgreSQL é o sistema de gerenciamento de banco de dados relacional adotado para armazenar tanto a infraestrutura do n8n quanto os dados persistentes do projeto. Ele foi configurado com bancos separados para isolar responsabilidades e reduzir dependências entre os serviços.

### 4.3 Redis
O Redis atua como mecanismo de fila para o n8n e também como camada de cache para a Evolution API. Seu uso contribui para maior estabilidade operacional e melhor desacoplamento entre eventos de entrada e processamento.

### 4.4 Evolution API
A Evolution API é responsável pela integração com o WhatsApp. Ela recebe mensagens, expõe eventos por webhook e mantém informações relacionadas às sessões da instância de comunicação.

### 4.5 Modelo de linguagem
O fluxo utiliza um modelo de linguagem acessado por meio da camada Groq para gerar respostas naturais a partir do contexto da conversa, das regras do atendimento e dos dados recuperados da memória do cliente.

## 5. Arquitetura da solução

A arquitetura foi organizada em camadas, com responsabilidades bem definidas:

1. O cliente envia uma mensagem via WhatsApp.
2. A Evolution API captura o evento de entrada.
3. O webhook do n8n recebe a requisição.
4. O fluxo extrai telefone, mensagem e indicadores da interação.
5. O sistema consulta a memória do cliente no PostgreSQL.
6. O agente de IA formula a resposta com base no contexto e nas regras de negócio.
7. Quando aplicável, o pedido é confirmado e os dados são preservados de forma estruturada.

Essa abordagem favorece rastreabilidade, modularidade e facilidade de manutenção.

## 6. Modelo de memória

A memória longa do sistema é estruturada por telefone, o que permite identificar o cliente de forma consistente ao longo de múltiplas interações. A tabela `customer_memory` armazena os seguintes atributos:

- telefone;
- nome;
- último pedido;
- data do último pedido;
- data de atualização.

Esse modelo é adequado ao problema proposto porque privilegia recuperação rápida de informações recorrentes sem necessidade de manter todo o histórico bruto na resposta do agente.

## 7. Estrutura dos arquivos

```text
.
├── docker-compose.yml
├── README.md
├── Prospeccao-1.json
└── postgres/
    └── init/
        ├── 01-init-multiple-dbs.sql
        └── 02-ai-memory-schema.sql
```

## 8. Descrição dos artefatos

### 8.1 docker-compose.yml
Arquivo responsável pela definição e orquestração dos serviços da stack local, incluindo PostgreSQL, Redis, n8n, worker do n8n e Evolution API.

### 8.2 Prospeccao-1.json
Arquivo de exportação do workflow do n8n. Contém a lógica do agente, o tratamento de entrada, a interação com a memória e a estrutura de confirmação do pedido.

### 8.3 01-init-multiple-dbs.sql
Script SQL utilizado para criação de múltiplos bancos e respectivos usuários no PostgreSQL.

### 8.4 02-ai-memory-schema.sql
Script SQL responsável pela criação da tabela de memória longa do cliente.

## 9. Pré-requisitos

Para executar o projeto, recomenda-se ter instalado:

- Docker;
- Docker Compose;
- navegador web moderno;
- acesso ao n8n;
- credenciais compatíveis com os serviços definidos na stack.

## 10. Execução do projeto

### 10.1 Inicialização da stack

Na raiz do projeto, executar:

```bash
docker compose down -v
docker compose up -d
```

O primeiro comando remove containers e volumes anteriores. O segundo comando inicia todos os serviços definidos no arquivo de composição.

### 10.2 Acesso ao n8n

Após a inicialização dos serviços, acessar o painel do n8n no endereço configurado localmente, normalmente `http://localhost:5678`.

### 10.3 Importação do workflow

Para carregar o fluxo principal no n8n:

1. Abrir o painel do n8n.
2. Acessar a seção de workflows.
3. Selecionar a opção de importação de arquivo.
4. Escolher o arquivo `Prospeccao-1.json`.
5. Salvar o workflow importado.
6. Ajustar credenciais e ativar o fluxo.

## 11. Configuração dos bancos

O script `01-init-multiple-dbs.sql` cria três bancos distintos:

- `n8n`, utilizado pela própria aplicação de automação;
- `ai_memory`, utilizado para persistência da memória do agente;
- `evolution`, utilizado pela Evolution API.

A separação dos bancos favorece isolamento lógico, organização da infraestrutura e clareza na manutenção.

## 12. Persistência da memória

A tabela `public.customer_memory` foi desenhada para armazenar o histórico mínimo necessário à personalização do atendimento. O uso de uma estrutura relacional é vantajoso porque permite consultas diretas por telefone e atualização controlada dos dados.

Em termos práticos, isso viabiliza respostas como a recuperação do último pedido do cliente e a continuidade da conversa em uma nova sessão.

## 13. Validação do funcionamento

Após a importação do workflow e a configuração das credenciais, recomenda-se validar o sistema com o seguinte procedimento:

1. Enviar uma mensagem de teste pelo WhatsApp integrado.
2. Confirmar o recebimento do evento pela Evolution API.
3. Verificar o processamento no n8n.
4. Observar a gravação ou leitura da memória no PostgreSQL.
5. Testar a retomada do atendimento a partir do mesmo telefone.

## 14. Observações técnicas

Os scripts localizados em `/docker-entrypoint-initdb.d` são executados somente na primeira inicialização de um volume vazio do PostgreSQL. Portanto, quando houver alteração nos scripts de inicialização, pode ser necessário recriar os volumes com `docker compose down -v` antes de subir novamente a stack.

Além disso, o fluxo foi restrito a um conjunto fixo de itens do cardápio, em conformidade com as regras de negócio estabelecidas para o projeto.

## 15. Considerações finais

A solução proposta demonstra a aplicação de conceitos de integração, automação, persistência e memória longa em um cenário de atendimento conversacional. A arquitetura adotada é modular e extensível, permitindo evolução futura para novas funcionalidades sem comprometer a organização do fluxo principal. <strong>É importante lembrar sempre que NEM TODO AGENTE DE IA PRECISA DE MEMÓRIA LONGA! Esse tópico é bastante debatido no vídeo em anexo e recomendo que assista-o antes de implementar em seus projetos. Bom Estudos! :)</strong>
