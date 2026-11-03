# Java service for Kubernetes on Wodby

Build and run Java applications on Kubernetes with Wodby.

This repository defines the Wodby service manifests and operational
configuration for Java.

- [Browse Wodby services](https://wodby.com/services)
- [Wodby service documentation](https://wodby.com/docs/2.0/services/)
- [Service manifest reference](https://wodby.com/docs/2.0/services/template/)

## Start with a boilerplate

Use one of the boilerplates exposed by this service to start with compatible
build configuration and Wodby CI:

- [Java boilerplate](https://github.com/wodby/java-boilerplate)

The [Spring Boot service](https://github.com/wodby/service-spring-boot), based on this service, exposes the
[Spring Boot boilerplate](https://github.com/wodby/spring-boot-boilerplate).

## Services based on this service

- [Spring Boot](https://github.com/wodby/service-spring-boot)
- [Kotlin](https://github.com/wodby/service-kotlin)

## Wodby stacks using this service

- [Java application stack](https://github.com/wodby/stack-java)
- [Spring Boot application stack](https://github.com/wodby/stack-spring-boot), through the Spring Boot service
- [Kotlin application stack](https://github.com/wodby/stack-kotlin), through the Kotlin service

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `java` |
| Type | Application service |
| Versions | `25` by default, `21` |
| Workloads | `main` (Deployment), primary; scalable |
| Containers | `java` using `wodby/java`, build target |
| Endpoints | `java`: HTTP 8080 (main) |
| Service links | DBMS (`db`), optional, Mail Transfer Agent (`sendmail`), optional, Redis, optional |
| Application build | Git source connection enabled; Dockerfile: `Dockerfile`; boilerplates: Java boilerplate |
| Helm | chart `oci://registry-1.docker.io/wodby/java`; version `0.1.0` |
| Configuration | 1 integration slots |

## Use this service

Use this service in a custom Wodby stack by referencing `java`, or use the
[Java application stack](https://github.com/wodby/stack-java).

A service is a reusable component and does not deploy by itself. The stack
defines its links, settings, versions, resources, and relationship to the rest
of the application.

## Maintain a custom version

1. Fork this repository.
2. Edit the service manifest and referenced files.
3. Import the repository as a [Git-backed service](https://wodby.com/docs/2.0/services/create/#create-a-git-backed-service).
4. Reference the service from a stack manifest.

Keep service, workload, container, endpoint, link, volume, config, and
derivative names stable unless dependent stacks and app-level overrides are
updated at the same time.

Validate the manifests with:

```bash
wodby service validate-manifest service.yml --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).

## Development workspaces

`workspace-java prepare` downloads the project's dependencies with Maven or the Gradle wrapper.
`workspace-java start` builds the checkout and runs its jar, then builds again and restarts the
application whenever a file in the checkout changes. A failed build keeps the previous build
running. `WORKSPACE_JAVA_WATCH=0` turns watching off and `WORKSPACE_JAVA_COMMAND` overrides startup.
Dependencies, build tools and the running jar are kept in `.wodby-workspace/` in the checkout;
`target/`, `build/` and `.gradle/` are excluded from Git status through `.git/info/exclude`.

Requires a runtime image declaring workspace contract version 1. Ordinary and development option tags must use matching revisions.
