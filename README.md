# Equipe
Gustavo Ferreira Wanderley - mestreguga24@gmail.com

Luís Guilherme Pontes Melquiades - luis.melquiades@ufape.edu.br

# MGB
O MGB (My Gaming Backlog) é um aplicativo inspirado no Letterboxd, mas voltado exclusivamente para o universo dos videogames. Seu objetivo é ajudar jogadores a organizar, registrar e compartilhar sua lista de jogos — sejam eles já concluídos, em progresso ou desejados para jogar no futuro.

O perfil do usuário é composto por jogadores que buscam gerenciar melhor seu backlog de jogos, descobrir novos títulos através de recomendações da comunidade e interagir com outros gamers com interesses semelhantes.
Através do MGB, espera-se que o usuário seja capaz de:
* Criar e gerenciar listas personalizadas de jogos (Seus favoritos, jogos finalizados, jogos em andamento, jogos abandonados, lista de desejo);
* Marcar jogos como “Jogando”, “Zerado”, “100% ou Platina”, Abandonado ou “Quero Jogar”;
* Avaliar e escrever resenhas sobre os jogos finalizados;
* Seguir amigos e outros usuários para trocar recomendações;
* Descobrir novos jogos baseados em tendências da comunidade.

Assim, o MGB funciona como uma rede social focada em backlog de games, tornando o hábito de jogar mais organizado, motivador e social.

# Inspiração
Foi utilizado como inspiração para a construção do app, o Letterboxd.

<img width="312" height="616" alt="image" src="https://github.com/user-attachments/assets/5c709b15-5aaa-43d7-8e5c-2a899a74bd44" />
<img width="306" height="660" alt="image" src="https://github.com/user-attachments/assets/0b117c60-58fc-46ee-90c4-546bac90af61" />

# Links do projeto
[Protótipo interativo](https://www.figma.com/design/sJ67i2ROQWYl8goO5Kr4rI/-MGB--My-Game-Backlog?node-id=0-1&t=H2xyQFrSXui2n0WP-1)

[Telas no Figma](https://www.figma.com/design/sJ67i2ROQWYl8goO5Kr4rI/-MGB--My-Game-Backlog?node-id=0-1&t=H2xyQFrSXui2n0WP-1)

[Planilha de experiência](https://docs.google.com/spreadsheets/d/1v3umWa8yu2SOK51Jbf5CVEYaB8qHqCJDRGZftgwhfbk/edit?usp=sharing)

# MGB App Backlog

## Gerenciar Conta/Perfil de Jogador

- **Como um novo visitante**, eu quero me cadastrar na plataforma usando meu nome, e-mail e senha, para que eu possa ter um perfil pessoal e organizar minha biblioteca de jogos.
- **Como um usuário cadastrado**, eu quero fazer login no aplicativo, para que eu possa acessar meu perfil, minhas listas e interagir com a comunidade.
- **Como um usuário cadastrado**, eu quero editar meu perfil, adicionando uma foto e uma breve biografia, para personalizar minha identidade na plataforma.

## Funcionalidades de Jogos e Listas

- **Como um usuário**, eu quero buscar por jogos na aplicação, para que eu possa encontrá-los e avaliá-los (ex: 1 a 5 estrelas).
- **Como um usuário**, eu quero buscar por jogos em uma base de dados, para que eu possa encontrá-los e adicioná-los às minhas listas.
- **Como um usuário**, eu quero marcar um jogo como "Quero Jogar", para que eu possa criar e gerenciar minha lista de desejos (backlog).
- **Como um usuário**, eu quero escrever uma resenha textual sobre um jogo que avaliei, para que eu possa compartilhar minhas críticas com a comunidade.

## Funcionalidades de Interação da Comunidade

- **Como um usuário**, eu quero buscar e seguir outros usuários na plataforma, para que eu possa acompanhar suas atividades.
- **Como um usuário**, eu quero visitar o perfil de outros usuários, para que eu possa ver suas listas, jogos favoritos e resenhas.
- **Como um usuário**, eu quero ter um feed de atividades recentes dos usuários que sigo, para que eu possa descobrir o que eles estão jogando.
- **Como um usuário**, eu quero ver uma seção com jogos em alta na comunidade (tendências), para que eu possa descobrir novos títulos populares entre outros usuários.
- **Como um usuário**, eu quero acessar uma página com as minhas estatísticas (ex: nº de jogos zerados e média de notas), para que eu possa visualizar um resumo do meu histórico.

# Planejamento do Desenvolvimento

A divisão de tarefas inicial para a equipe de desenvolvimento está organizada da seguinte forma:

### Programador 1: Gustavo Ferreira Wanderley
*Foco principal no gerenciamento de usuários, perfil e interações sociais.*

| Funcionalidade | Foco do Desenvolvimento |
| :--- | :--- |
| **Cadastro de novo usuário** | Criação da tela e lógica para registro de novos jogadores. |
| **Login de usuário** | Implementação do sistema de autenticação. |
| **Edição de Perfil** | Desenvolvimento da página de perfil do usuário (edição de foto/bio). |
| **Seguir Usuários** | Lógica para adicionar/remover “amigos” e gerenciar a lista de seguidores. |
| **Ver Perfil de Outros** | Criação da visualização pública do perfil de outros jogadores. |
| **Feed de Atividades** | Construção do feed que exibe as ações dos amigos e tendências da comunidade. |

### Programador 2: Luís Guilherme Pontes Melquiades
*Foco principal na gestão da biblioteca de jogos, avaliações e descoberta de conteúdo.*

| Funcionalidade | Foco do Desenvolvimento |
| :--- | :--- |
| **Busca de Jogos** | Implementação da busca e integração com a base de dados de jogos. |
| **Adicionar à Lista de Desejos**| Lógica para marcar um jogo como "Quero Jogar". |
| **Marcar como "Jogando"** | Funcionalidade para alterar o status de um jogo para o estado atual. |
| **Marcar como "Zerado"** | Lógica para finalizar um jogo no sistema. |
| **Marcar com Status Avançados**| Implementação dos status "100%" e "Abandonado". |
| **Avaliar um Jogo (Nota)** | Sistema de avaliação por estrelas. |
| **Escrever Resenha** | Interface e lógica para salvar as resenhas dos usuários. |
| **Criar Listas Personalizadas**| Desenvolvimento da funcionalidade de criação e gestão de listas temáticas. |
