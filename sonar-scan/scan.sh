#!/bin/bash
echo "Escaneando o sistema DVWA ..."
cd /dvwa/ && sonar-scanner
echo "#####################################################################"
echo "Escaneando o sistema WordPress 3.3.0 ..."
cd /wordpress/ && sonar-scanner