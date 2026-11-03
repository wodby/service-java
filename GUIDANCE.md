# Java on Wodby

What Wodby sets up for an application that runs on this service. Check it before changing the build, the port or connection settings in the code.

## Build and start

The service's Dockerfile copies the repository to `/usr/src/app` and builds it with the repository's own build setup:

- Maven, when `pom.xml` is at the root: the Maven wrapper (`mvnw`) when the repository has one, or else Maven from the image, runs `package` with `-Dmaven.test.skip=true`. The runnable jar is taken from `target/`.
- Gradle, when `build.gradle` or `build.gradle.kts` is at the root: the Gradle wrapper (`gradlew`) runs `assemble`. The runnable jar is taken from `build/libs/`. A Gradle project without the wrapper fails to build.

Tests are not compiled or run: run them in CI. Jars ending in `-sources`, `-javadoc`, `-tests` or `-plain`, and Maven's `original-*.jar`, are not counted. When the build leaves more than one other jar, add `JAVA_BUILD_JAR` to the service with the one to run, relative to the repository, such as `app/target/app.jar` for a multi-module build. `JAVA_BUILD_COMMAND` replaces the build command; `JAVA_BUILD_ARGS` adds arguments to Maven or Gradle. The build reads these three as build variables, so give them the build scope; a development workspace builds at runtime, so give them the runtime scope too.

The jar is copied to `/home/wodby/app.jar`; build output and downloaded dependencies are removed. The container starts `java-app`, which runs `java $JAVA_OPTS -jar /home/wodby/app.jar`. `JAVA_OPTS` is `-XX:MaxRAMPercentage=75.0` by default, so the heap follows the container's memory limit; set the service's memory limit rather than `-Xmx`. A pipeline that passes a Dockerfile from the repository (`wodby ci build java -f Dockerfile`) uses that file instead; it must still end with a command that starts the server.

- The application must listen on port 8080, on all interfaces. That is the port of the service's HTTP endpoint.
- The service is ready when port 8080 answers HTTP with a status below 500 at `/`. With `JAVA_READY_PATH` set, such as `/health`, that path must answer 200 instead.
- The service declares no volume of its own: files written inside the container are lost when it is replaced.

## Linked services

Links to other services reach the application as environment variables. Nothing in the image reads them: the application reads them itself. Do not hardcode hosts or credentials.

| Link | Variables |
| --- | --- |
| Database (MariaDB, MySQL or PostgreSQL) | `DB_HOST`, `DB_PORT`, `DB_NAME` (also `DB_DATABASE`), `DB_USERNAME`, `DB_PASSWORD`, `DB_DRIVER` (also `DB_CONNECTION`), `DATABASE_URL` |
| Mail | `SMTP_HOST`, `SMTP_PORT` |
| Redis or Valkey | `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` |

`DATABASE_URL` is a URL such as `postgresql://user:password@host:5432/db`, not a JDBC URL: build the JDBC URL from the `DB_*` variables, such as `jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}`. All three links are optional. A variable is present only while its link exists and the linked service is enabled. The mail link carries no credentials.

## Environment

- `WODBY_HOSTS` is a JSON array of the environment's hosts, not a comma-separated string. `WODBY_PRIMARY_HOST` and `WODBY_PRIMARY_URL` are the canonical ones for links generated outside a request.
- `WODBY_APP_SERVICE_NAME` is this service's host name inside the environment. Other services reach the application at that name on port 8080.
- `WODBY_ENV_TYPE` tells a development environment from a production-like one.

## In a development workspace

- The checkout is mounted at `/usr/src/app`. It is built as above and the jar is run from `.wodby-workspace/app.jar`. The checkout is watched: when a file changes, it is built again and the application is restarted with the new build, in the same container, usually within a few seconds. Nothing has to be restarted or deployed for a code change. A build that fails leaves the previous build running; the build's errors are in the service's logs. When the first build fails, the container waits for a change instead of stopping.
- Workspace setup downloads dependencies with `workspace-java prepare`: `mvn dependency:go-offline`, or `gradlew dependencies`. Code that does not compile yet does not fail it.
- Maven's local repository, the Maven wrapper's downloads and Gradle's home are kept in `.wodby-workspace/` in the checkout, so a restart downloads nothing again. A `-Dmaven.repo.local` in `MAVEN_OPTS` or a `GRADLE_USER_HOME` set on the service is kept. Maven and Gradle in a login shell in the workspace use the same locations. Gradle builds keep the Gradle daemon running between builds.
- `target/`, `build/`, `.gradle/` and `.wodby-workspace/` are kept out of Git status without touching `.gitignore`, and changes in them do not start a build.
- `WORKSPACE_JAVA_WATCH=0` turns watching off. `WORKSPACE_JAVA_COMMAND` on the service replaces the start command.
- A change to variables or linked services still needs a deployment of the environment.

## Check the result

- `java-ready && echo ready` from the container shows whether the application answers as the service expects.
- `mvn -q compile` or `./gradlew compileJava` in the checkout shows compile errors at once; the service's logs show them too when a change does not appear.
