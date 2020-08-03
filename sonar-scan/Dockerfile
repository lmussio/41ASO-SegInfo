FROM sonarsource/sonar-scanner-cli:4.4

WORKDIR /dvwa
RUN git clone --depth=1 https://github.com/ethicalhack3r/DVWA .
COPY ./sonar-scan/sonar-project.properties.dvwa /dvwa/sonar-project.properties

WORKDIR /wordpress
COPY ./wordpress/site/ /wordpress/
COPY ./sonar-scan/sonar-project.properties.wordpress /wordpress/sonar-project.properties

COPY ./sonar-scan/scan.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/scan.sh

CMD ["scan.sh"]