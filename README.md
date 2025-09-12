API de Gestão de Organizações e Membros
Visão Geral do Projeto
Este projeto é uma API RESTful construída com Ruby on Rails que permite o gerenciamento de usuários, organizações, metas e finanças. A API inclui um sistema de autenticação seguro com JWT (JSON Web Tokens) e controle de acesso baseado em papéis (ADMIN, MANAGER, EMPLOYEE).

Principais Funcionalidades
Autenticação: Login e reset de senha com tokens JWT.

Gerenciamento de Usuários: CRUD (Criar, Ler, Atualizar, Deletar) de usuários e gerenciamento de perfis (/me).

Organizações: CRUD de organizações e um sistema de convites para novos membros.

Autorização: Controle de acesso por papéis (ADMIN/MANAGER) para funcionalidades sensíveis.

Metas e Finanças: Módulos para gerenciar metas e transações financeiras.

Assistente IA: Integração com a API da OpenAI para um assistente de IA focado em finanças.

Configuração do Projeto
Para rodar o projeto localmente, você precisa ter o Podman e o podman-compose instalados.

Clone o repositório:

Bash

git clone <URL_DO_REPOSITORIO>
cd <nome_da_pasta>
Configure o .env:
Crie um arquivo .env na raiz do projeto com suas chaves de API e segredos.

Bash

JWT_SECRET_KEY=sua-chave-secreta-muito-forte
OPENAI_API_KEY=sua-chave-secreta-da-openai
Inicie os contêineres:
Este comando irá construir a imagem, instalar as dependências e iniciar o banco de dados e o servidor Rails.

Bash

podman-compose up --build
Documentação dos Endpoints
Todos os endpoints da API são acessados a partir do endereço base http://localhost:4000/.

Autenticação: Rotas protegidas exigem o cabeçalho Authorization: Bearer <token>.

Autenticação e Usuário
POST /auth/login
Descrição: Autentica um usuário e retorna um token JWT.

GET /me
Descrição: Retorna os dados do usuário autenticado.

Autorização: Apenas usuários logados.

POST /users
Descrição: Cria um novo usuário com endereço.

GET /users/:id
Descrição: Busca um usuário pelo ID.

Autorização: Apenas usuários logados.

PATCH /users/:id
Descrição: Atualiza os dados de um usuário.

Autorização: Apenas usuários logados.

DELETE /users/:id
Descrição: Deleta um usuário.

Autorização: Apenas usuários logados.

Organizações e Membros
POST /organizations
Descrição: Cria uma nova organização.

Autorização: Apenas usuários logados.

GET /organizations
Descrição: Lista todas as organizações.

Autorização: Apenas usuários logados.

GET /organizations/:id
Descrição: Busca uma organização pelo ID.

Autorização: Apenas usuários logados.

PATCH /organizations/:id
Descrição: Atualiza os dados de uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

DELETE /organizations/:id
Descrição: Deleta uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

POST /organizations/:id/invite
Descrição: Convida um usuário para uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

GET /organizations/:id/members
Descrição: Lista todos os membros de uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

PATCH /organizations/:id/members/:member_id
Descrição: Atualiza a role de um membro.

Autorização: Apenas ADMIN ou MANAGER da organização.

DELETE /organizations/:id/members/:member_id
Descrição: Remove um membro de uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

Metas (Goals)
GET /organizations/:organization_id/goals
Descrição: Lista as metas de uma organização.

Autorização: Apenas ADMIN ou MANAGER da organização.

POST /organizations/:organization_id/goals
Descrição: Cria uma nova meta.

Autorização: Apenas ADMIN ou MANAGER da organização.

PATCH /organizations/:organization_id/goals/:id
Descrição: Atualiza uma meta.

Autorização: Apenas ADMIN ou MANAGER da organização.

DELETE /organizations/:organization_id/goals/:id
Descrição: Deleta uma meta.

Autorização: Apenas ADMIN ou MANAGER da organização.

Transações Financeiras
GET /organizations/:organization_id/transactions
Descrição: Lista as transações de uma organização (com paginação e filtros).

Autorização: Apenas ADMIN ou MANAGER da organização.

POST /organizations/:organization_id/transactions
Descrição: Cria uma nova transação.

Autorização: Apenas ADMIN ou MANAGER da organização.

PATCH /organizations/:organization_id/transactions/:id
Descrição: Atualiza uma transação.

Autorização: Apenas ADMIN ou MANAGER da organização.

DELETE /organizations/:organization_id/transactions/:id
Descrição: Deleta uma transação.

Autorização: Apenas ADMIN ou MANAGER da organização.

Endpoints de IA
POST /chat
Descrição: Envia uma mensagem para o assistente de IA.

Autorização: Apenas usuários logados.