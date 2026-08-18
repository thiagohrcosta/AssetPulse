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

## Testes (backend)

Suite em RSpec (+ FactoryBot/Faker para dados, Shoulda Matchers para
validações/associações, SimpleCov cobrindo a coverage). Roda contra o mesmo
serviço `db` do compose, banco `asset_pulse_api_test`, sem precisar de nada
extra:

```bash
docker compose up -d db api
docker compose exec -e RAILS_ENV=test api bin/rails db:prepare   # só na 1ª vez / após migration nova
docker compose exec -e RAILS_ENV=test api bundle exec rspec
```

O SimpleCov falha o processo (exit 2) se a cobertura de linhas cair abaixo
de 90% — configurado em [asset-pulse-api/spec/rails_helper.rb](asset-pulse-api/spec/rails_helper.rb).
Relatório HTML fica em `asset-pulse-api/coverage/index.html`.

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
