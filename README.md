# Jobtracker_clean — Flutter client

Flutter client for JobTracker. Registration requires a password of at least 6 characters. Field validation updates while you edit. It includes login/registration, a dashboard, and a searchable, paginated application list with create/edit/delete. Each record stores date applied, position, company, location, experience, portal, job link, status, and notes.

## Run with the local stack

Use Flutter 3.50.1 and Docker Compose v2. From the parent project folder, copy the local environment template and start the stack:

```sh
cd ..
cp .env.local.example .env.local
docker compose --env-file .env.local -f deploy/compose.yaml up --build
```

Open `http://localhost:8080`. This runs Flutter web, the Java API with Spring profile `local`, and PostgreSQL. To run Flutter from your IDE instead, start PostgreSQL and the Java API using the parent README’s “Run the API from your IDE/Maven” steps, then run from this directory:

```sh
flutter pub get
flutter run -d macos
# Or: flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081/api/v1
```

Android emulator uses `10.0.2.2` by default; iOS/macOS and browser use `localhost`. For a physical device, pass `--dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:8081/api/v1`. Use HTTPS outside local development. Android debug builds permit local HTTP; release builds do not.

## Clean Architecture

```text
lib/
├── app/                         # Auth gate and responsive app shell
├── core/                        # API client, secure storage, DI, theme, shared widgets
└── features/
    ├── auth/{data,domain,presentation}
    ├── applications/{data,domain,presentation}
    └── dashboard/presentation
```

UI pages call presentation view models. View models call domain use cases through repository contracts. Data repositories implement those contracts and coordinate API data sources and JSON models. The composition root at `lib/core/di/app_dependencies.dart` wires the application graph. Domain code does not import Flutter, HTTP, or persistence implementation details.

Follow one request end to end: `JobApplicationViewModel` → use case → repository contract → remote data source → API model; then follow the Spring side from the controller through application service and domain port to the JPA adapter.
# job_tracker
