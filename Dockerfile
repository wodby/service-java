ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM
ARG COPY_TO=/usr/src/app
COPY --chown=wodby:wodby ${COPY_FROM} ${COPY_TO}

# Build with the repository's Maven or Gradle setup and keep the runnable jar. Downloaded
# dependencies and build output are removed so they do not enlarge the image.
RUN set -e; \
    java-build "${JAVA_APP_JAR}"; \
    if [ -f pom.xml ]; then rm -rf target; elif [ -f gradlew ]; then rm -rf build .gradle; fi; \
    rm -rf /home/wodby/.m2/repository /home/wodby/.m2/wrapper /home/wodby/.gradle/*

CMD ["java-app"]
