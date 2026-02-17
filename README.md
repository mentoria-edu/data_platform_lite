# data_platform_lite

## Sumário

- [Descrição](##Descrição)
- [Estrutura](##Estrutura)
- [caracteristicas](##Características)
- [Get Started](##Get_started)
- [Documentação](##Documentação)
- [Créditos](##Créditos)

## Descrição

Plataforma completa para desenvolvimento e testes de pipelines de dados com Apache Spark, Apache Hudi e MinIO (compatível com S3). Toda infraestrutura roda localmente em containers Docker, proporcionando um ambiente isolado e reprodutível.

A plataforma é composta por um cluster Spark Standalone com um master e dois workers, todos com Apache Hudi 1.1.0 pré-integrado. O MinIO atua como storage S3, com buckets criados automaticamente para eventos do Spark History Server e dados das aplicações. O Spark History Server está disponível para consulta dos logs de execução.

O ambiente é orquestrado pelo Docker Compose. O arquivo docker-compose.yml define cinco serviços: spark-master, spark-worker-1, spark-worker-2, spark-history e minio. Todos os serviços Spark compartilham a mesma imagem construída a partir do Dockerfile, que copia os JARs do Hudi gerados pelo Maven.

O script start_platform.sh automatiza todo o processo: cria diretórios necessários, executa o Maven para gerar os JARs com Hudi e sobe os containers com docker compose up -d --build. A flag --build garante que a imagem seja construída com cache inteligente, reconstruindo apenas camadas alteradas.

Após a execução, as interfaces ficam acessíveis: Spark Master em http://localhost:8083, Workers em 8084 e 8085, History Server em 18080 e MinIO Console em 9001 com usuário/senha minioadmin. Os dados são persistidos no diretório data/ e os buckets spark-logs e data-bureau são criados automaticamente.

Para submeter jobs, basta executar spark-submit dentro do container spark-master, utilizando as configurações S3 já predefinidas no spark-defaults.conf que apontam para o MinIO.

## Estrutura

```text
spark-hudi-minio-platform/
│
├── docker-compose.yml          # Orquestração dos serviços
├── Dockerfile                  # Build da imagem Spark/Hudi
├── start_platform.sh           # Script principal de bootstrap
├── stop_platform.sh           # Script de parada (opcional)
├── pom.xml                    # Dependências Maven (Hudi)
│
├── conf/                      # Configurações
│   └── spark/
│       └── spark-defaults.conf  # Configs Spark (S3, History)
│
├── scripts/                   # Scripts utilitários
│   └── submit-job.sh         # Exemplo: submeter jobs
│
├── target/                   # Gerado pelo Maven
│   └── jars/                # JARs com Hudi integrado
│
├── data/                     # Dados persistentes
│   ├── minio/               # Dados do MinIO (volumes)
│   └── spark-events/        # Event logs do Spark
│
└── examples/                # (Opcional) Jobs de exemplo
    ├── hudi_cow_example.py
    └── s3_read_write.py
```

## Características:

- Spark 4.0.1 em modo Standalone (1 Master + 2 Workers)
- Apache Hudi 1.1.0 pré-integrado nos JARs
- MinIO como storage compatível com S3
- Spark History Server para visualização de métricas
- Docker Compose com build otimizado e cache inteligente

## Get_started

1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/spark-hudi-minio-platform.git
cd spark-hudi-minio-platform
```

2. Execute a plataforma

```bash
chmod +x start_platform.sh
./start_platform.sh
```

3. Execute o pipeline:

```bash
sudo docker exec spark-master bash -c "/opt/spark/bin/spark-submit /opt/scripts/meu_pipeline.py"
```

4. Acesse as interfaces

```text
Spark Master	http://localhost:8083	-
Spark Worker 1	http://localhost:8084	-
Spark Worker 2	http://localhost:8085	-
Spark History	http://localhost:18080	-
MinIO Console	http://localhost:9001	minioadmin/minioadmin
```

## Documentação

Se você está planejando contribuir ou apenas deseja saber mais sobre este projeto, leia nossa [documentation](https://www.notion.so/1c408c995dce8017827cf53f445a924d?v=1c408c995dce803eb025000cdbd98892&p=29908c995dce8021ad68f9924a4e221c&pm=s).

## Creditos

- [Leonardo Adelmo](https://github.com/Leo-Adelmo)
- [Luiz Vaz](https://github.com/luiz-vaz)
- [Phill Andrade](https://github.com/Phill-Andrade)
- [Eduardo Katsurayama](https://github.com/eduardoKatsurayama)
