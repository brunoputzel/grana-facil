#  GranaFácil 💸

Este é o projeto de um aplicativo de finanças pessoais, GranaFácil, desenvolvido como atividade avaliativa para o curso de Análise e Desenvolvimento de Sistemas. O objetivo é fornecer uma ferramenta simples e intuitiva para o gerenciamento de receitas e despesas.

[![Assista à apresentação do APP no YouTube](https://img.youtube.com/vi/r5msRwARDEU/hqdefault.jpg)](https://youtu.be/r5msRwARDEU)
*Clique na imagem para assistir à demonstração no YouTube.*

---

### ✨ Funcionalidades

* **✔️ Dashboard Dinâmico:** Tela inicial com saldo atual, gráfico de pizza interativo mostrando a distribuição de despesas por categoria e uma lista das transações mais recentes.
* **✔️ Registro de Transações:** Tela para adicionar novas receitas ou despesas, com campos para valor, descrição e categoria.
* **✔️ Cotação de Moedas em Tempo Real (API):** Na tela de nova transação, o usuário pode digitar um valor em Dólar (USD) ou Euro (EUR) e ver a conversão em tempo real para Reais (BRL), graças à integração com a API da Frankfurter.app. O valor salvo é sempre o convertido para BRL.
* **✔️ Histórico Completo:** Uma tela dedicada para visualizar todas as transações, com a possibilidade de filtrar por "Todos", "Receitas" e "Despesas".
* **✔️ Exclusão de Transações:** Na tela de histórico, cada item possui um botão para exclusão, atualizando o estado do aplicativo em tempo real.
* **✔️ Perfil de Usuário Persistente:** Uma seção de perfil onde o usuário pode inserir e salvar dados básicos (nome, e-mail), que permanecem salvos no dispositivo mesmo após fechar o aplicativo.

---

### 🛠️ Tecnologias Utilizadas

O projeto foi desenvolvido utilizando as seguintes tecnologias e pacotes:

* **Framework:** Flutter
* **Linguagem:** Dart
* **Pacotes Principais:**
    * `http`: Para realizar as chamadas à API de cotação de moedas.
    * `fl_chart`: Para a criação do gráfico de pizza dinâmico.
    * `shared_preferences`: Para o armazenamento local e persistente dos dados do perfil do usuário.
    * `flutter_launcher_icons`: Para a geração automática dos ícones do aplicativo.
    * `flutter_native_splash`: Para a criação da tela de abertura (splash screen).

---

### 🚀 Como Executar o Projeto

Para executar este projeto localmente, siga os passos abaixo:

```bash
# 1. Clone o repositório
git clone [https://github.com/brunoputzel/grana-facil.git](https://github.com/brunoputzel/grana-facil.git)

# 2. Navegue até a pasta do projeto
cd grana-facil

# 3. Instale as dependências
flutter pub get

# 4. Execute o aplicativo
flutter run
```

---

### 👨‍💻 Autor

**Bruno Sisterhenn Putzel**