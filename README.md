# 41ASO-SegInfo
Estudo sobre ataques de SQLi e XSS com PoC em sqlmap e BeeF. Turma `41ASO`, disciplina `ARCHITECTURE FOR MASTERING STRATEGIC AND EMERGING TECHNOLOGY INNOVATION`, professor `Ricardo Giorgi`.

## Pré-requisito
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## WordPress
Foi criado um container de WordPress na versão 3.3.0, obtido através da referência [WordPress Releases](https://wordpress.org/download/releases/).

Para construir a imagem do container de WordPress 3.3.0, é necessário realizar o comando `docker-compose build wordpress`.

Para executar o sistema WordPress, é necessário realizar os seguintes comandos:
```
docker-compose up -d db
docker-compose up -d wordpress
```
Enquanto o container de MariaDB não finalizar sua inicialização, o container do WordPress ficará restartando.

Realizamos o backup do diretório `/var/www/html/`, localizado em `wordpress/site/`, onde efetuamos a montagem desse diretório para o container, a fim de disponibilizar o ambiente preparado para o estudo.

Também realizamos o backup da base de dados `wordpress`, localizado em `wordpress\wordpress.sql`, onde efetuamos a montagem desse arquivo no container de MariaDB, para que seja carregado para o MariaDB durante sua primeira inicialização, trazendo todas as configurações realizadas no WordPress.

Exemplo de comando para realização do backup da base de dados:
```
mysqldump -u admin -padmin --quick --extended-insert wordpress > wordpress.sql
```

### Credenciais WordPress
- Home: `http://127.0.0.1:8889/`
- Página de login: `http://127.0.0.1:8889/wp-login.php`
- Usuário: `admin`
- Senha: `admin`

### Credenciais Base de Dados WordPress
- Host: `db`
- Usuário: `admin`
- Senha: `admin`
- Database: `wordpress`

## DVWA
Para auxiliar no estudo, configuramos um container de DVWA.

Para executar o container do sistema DVWA, é necessário realizar o seguinte comando:
```
docker-compose up -d dvwa
```

Para interagir com o sistema, acessar a URL `http://127.0.0.1:8888/`. Segue referência do [código-fonte](https://github.com/ethicalhack3r/DVWA).

## SonarQube
Para auxiliar no estudo, configuramos um container de SonarQube, a fim de escanear códigos-fonte, na tentativa de identificação de vulnerabilidades.

Para executar o container do sistema DVWA, é necessário realizar o seguinte comando:
```
docker-compose up -d sonarqube
```
Pode demorar alguns minutos para terminar de inicializar o sistema.

Para interagir com o sistema, acessar a URL `http://127.0.0.1:9000/`.