# Builder aşaması
FROM quay.io/keycloak/keycloak:25.0.6 AS builder

# Ortam değişkenlerini ARG olarak tanımlayın
ARG KC_HEALTH_ENABLED
ARG KC_METRICS_ENABLED
ARG KC_FEATURES=preview
ARG KC_DB
ARG KC_HTTP_ENABLED
ARG PROXY_ADDRESS_FORWARDING
ARG QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY
ARG KC_HOSTNAME
ARG KC_LOG_LEVEL
ARG KC_DB_POOL_MIN_SIZE

# Apple ve Discord sağlayıcılarını indir ve ekle
ADD --chown=keycloak:keycloak https://github.com/klausbetz/apple-identity-provider-keycloak/releases/download/1.7.1/apple-identity-provider-1.7.1.jar /opt/keycloak/providers/apple-identity-provider-1.7.1.jar
ADD --chown=keycloak:keycloak https://github.com/wadahiro/keycloak-discord/releases/download/v0.5.0/keycloak-discord-0.5.0.jar /opt/keycloak/providers/keycloak-discord-0.5.0.jar

# Özel tema dosyasını kopyala
COPY /theme/keywind /opt/keycloak/themes/keywind

# Keycloak'u optimize edilmiş bir şekilde build et
RUN /opt/keycloak/bin/kc.sh build

# Çalıştırma aşaması
FROM quay.io/keycloak/keycloak:25.0.6

# Java konfigürasyon dosyasını kopyala
COPY java.config /etc/crypto-policies/back-ends/java.config

# Önceki aşamadan oluşturulmuş build dosyalarını kopyala
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Ortam değişkenlerini tanımla ve preview modunu etkinleştir
ENV KC_FEATURES=preview
ENV PROXY_ADDRESS_FORWARDING=true
ENV KC_HTTP_PORT=8080

# Sağlık kontrollerini etkinleştir
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Giriş komutları
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

# Keycloak'u optimized modda başlat ve preview özellikleri aktif et
CMD ["start", "--optimized", "--features=preview", "--import-realm"]
