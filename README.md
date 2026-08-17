# AssetPulse

Monorepo com o backend (`asset-pulse-api`, Rails) e, em breve, o frontend
(`asset-pulse-web`, Next.js). Ambos sobem via Docker a partir da raiz do
projeto.

## Subindo o backend

```bash
cp .env.example .env   # opcional, os defaults já funcionam
docker compose up --build
```

- API disponível em `http://localhost:3000`
- Healthcheck: `http://localhost:3000/up`
- Banco Postgres em `localhost:5432` (dados persistidos no volume
  `asset_pulse_db_data`)

Na primeira subida o `docker-entrypoint` roda `db:prepare` automaticamente
(cria o banco e aplica as migrations). O código de `asset-pulse-api` é
montado como volume, então alterações no host refletem no container sem
rebuild — só é preciso `docker compose build api` de novo se o `Gemfile`
mudar.

### Comandos úteis

```bash
docker compose logs -f api          # logs da API
docker compose exec api bin/rails c # console Rails
docker compose exec api bin/rails db:migrate
docker compose down                 # para tudo (mantém os volumes)
docker compose down -v              # para tudo e apaga os volumes (reset total)
```

## Frontend (planejado)

O serviço `web` já está deixado comentado em [docker-compose.yml](docker-compose.yml)
para quando o projeto Next.js (`asset-pulse-web`) estiver pronto para subir
via Docker também.

## Estrutura

```
.
├── docker-compose.yml       # orquestração (db + api; web entra depois)
├── .env.example              # variáveis de ambiente compartilhadas
├── asset-pulse-api/          # backend Rails
│   ├── Dockerfile             # imagem de produção (Kamal/deploy)
│   └── Dockerfile.dev          # imagem de desenvolvimento (usada pelo compose)
└── asset-pulse-web/           # frontend Next.js
```
