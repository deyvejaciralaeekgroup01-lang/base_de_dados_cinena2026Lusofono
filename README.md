# **Projeto Final – Base de Dados 2026**

Repositório do projeto de avaliação da unidade curricular de **Base de Dados**.

---

## 📌 **1. Clonar o Repositório**
```bash
git clone https://github.com/deyvejaciralaeekgroup01-lang/base_de_dados_cinena2026Lusofono

```
---

## 📁 **2. Estrutura do Projeto**

<p>A estrutura principal do projeto é apresentada nas imagens abaixo:</p>
<p></p><img width="420" height="267" alt="Screenshot 2026-01-11 165107" src="https://github.com/user-attachments/assets/ec1532a9-7c03-4022-aa2e-8a81a1ed98f4" /></P>
<p></p><img width="392" height="232" alt="image" src="https://github.com/user-attachments/assets/c6285683-9ba4-4842-9750-6be926b6c257" /></p>

---

## 🗂️ **Descrição das Pastas**

### **a) `ficheiros/`**
Contém todos os ficheiros utilizados para popular a base de dados.

**Ficheiros disponíveis:**
- `Movies`
- `Actores`
- `Directors`
- `Genres`
- `MovieActor`
- `MovieDirector`
- `Genres_movies`
- `Movie_votes`

---

### **b) `jar/`**

-Inclui o ficheiro `.jar` necessário para estabelecer a conexão entre Java e a base de dados.
-Adicionar o jar no classpath do projecto


---

### **c) `sql/`**
Contém o ficheiro SQL com todos os comandos **DDL** e **DML** utilizados no projeto.

- Abra o ficheiro **`Base de dados_Deyve Silva.sql`**.
- Ajuste o diretório da pasta `ficheiros/` conforme o caminho no seu computador.

<img width="1493" height="443" alt="image" src="https://github.com/user-attachments/assets/7c25cd81-9843-4523-a96b-6994c623fce4" />

- Execute o ficheiro
- Faça um select de uma tabelas para ter confirmacao das tabelas e a insercao dos dados
---

### **d) `src/`**
Contém o código-fonte Java organizado segundo a arquitetura **MVC**.

---

## 🧩 **3. Estrutura do Código (MVC)**

### **📦 Pacote `BDConnection`**
Inclui três classes responsáveis pela comunicação com a base de dados:

- **`BDConnection`**  
  Classe responsável pela conexão com a base de dados.  
  ➤ <img width="923" height="336" alt="image" src="https://github.com/user-attachments/assets/a172a422-9382-47db-948f-cc346d4138bf" />


- **`ConsultaRepositorio`**  
  Classe responsável por consultas SQL.

- **`CrudActorDirectorDAO`**  
  Classe responsável por criar, atualizar e apagar dados de **Actors** e **Directors**.

---

### **📦 Pacote `control`**
Contém as classes de controlo da aplicação:

- **`JTableFilmes`** – Gere a tabela de Actors e Directors.  
- **`Estatisticas`** – Implementa funcionalidades dos exercícios 4.3, 2.11, triggers e auditoria.  
- **`FilmeGUI`** – Classe principal responsável pela criação dos componentes gráficos.

---

### **📦 Pacote `view`**
Contém as classes relacionadas com interface e utilitários:

- **`Tarefas`** – Métodos utilitários.  
- **`Toast`** – Notificações após operações.  

---

