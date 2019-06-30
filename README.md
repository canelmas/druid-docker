## What's Druid?

Check out official [Druid website](https://druid.apache.org/).

## Tags

- 1.1.0-druid-0.15.0
- 1.1.0-druid-0.14.0

Check [DockerHub](https://hub.docker.com/r/canelmas/druid/tags) for complete list.

## Sample stack

```yml
version: '3.7'

networks:
  druid-net:
    external: true

volumes:   
  data-mysql:
  data-broker:
  data-coordinator:
  data-historical:
  data-overlord:
  data-router:  
  data-middlemanager:  

services:

  mysql:
    image: mysql:5.7
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
      MYSQL_DATABASE: druid
      MYSQL_USER: druid
      MYSQL_PASSWORD: diurd
    command:
      - --character-set-server=utf8
      - --collation-server=utf8_unicode_ci
    volumes:
      - data-mysql:/var/lib/mysql
    deploy:
      replicas: 1
      placement:
        constraints: 
          - node.labels.node.type == manager
    networks: 
      - druid-net

  historical:    
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: historical
    ports:
      - 8083:8083
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-historical:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql
    deploy:
      mode: global
      placement:
        constraints: 
          - node.labels.node.type == data      
      restart_policy:
        condition: on-failure
    networks: 
      - druid-net

  broker:
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: broker
    ports:
      - 8082:8082
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-broker:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql      
    deploy:
      replicas: 1
      placement:
        constraints: 
          - node.labels.node.type == query      
      restart_policy:
        condition: on-failure
    networks: 
      - druid-net

  coordinator:
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: coordinator
    ports:
      - 8081:8081
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-coordinator:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql
    deploy:
      replicas: 1
      placement:
        constraints: 
          - node.labels.node.type == manager
      restart_policy:
        condition: on-failure
    networks: 
      - druid-net

  overlord:
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: overlord
    ports:
      - 8090:8090
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-overlord:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql
    deploy:
      replicas: 1
      placement:
        constraints: 
          - node.labels.node.type == manager      
      restart_policy:
        condition: on-failure
    networks: 
      - druid-net
      
  router:
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: router
    ports:
      - 8888:8888
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-router:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql
      - coordinator
      - broker
    deploy:
      replicas: 1
      placement:
        constraints: 
          - node.labels.node.type == query
      restart_policy:
        condition: on-failure
    networks: 
      - druid-net
  
  middleManager:
    image: canelmas/druid:1.1.0-druid-0.15.0
    command: middleManager
    ports:
      - 8091:8091
    volumes:
      - ~/conf-druid:/opt/druid/conf
      - data-middlemanager:/opt/druid/var
    depends_on:
      - zookeeper
      - mysql
      - broker
    deploy:
      replicas: 2
      placement:
        constraints: 
          - node.labels.node.type == ingestion
    networks: 
      - druid-net    
```

## Configuration

```bash
conf-druid
└── druid
    ├── _common
    │   ├── common.runtime.properties
    │   └── log4j2.xml
    ├── broker
    │   ├── jvm.config
    │   ├── main.config
    │   └── runtime.properties
    ├── coordinator
    │   ├── jvm.config
    │   ├── main.config
    │   └── runtime.properties
    ├── historical
    │   ├── jvm.config
    │   ├── main.config
    │   └── runtime.properties
    ├── middleManager
    │   ├── jvm.config
    │   ├── main.config
    │   └── runtime.properties
    ├── overlord
    │   ├── jvm.config
    │   ├── main.config
    │   └── runtime.properties
    └── router
        ├── jvm.config
        └── runtime.properties
```