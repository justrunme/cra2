FROM alpine:3.17

# Установим зависимости
RUN apk add --no-cache bash git curl

# Создадим рабочую директорию
WORKDIR /opt/cra2

# Скопируем все файлы проекта
COPY . /opt/cra2/

# Сделаем сценарии исполняемыми
RUN chmod +x create-repo update-all install-create-repo.sh && \
    chmod +x modules/*.sh

# По умолчанию PATH не будет включать /opt/cra2, добавим:
ENV PATH="/opt/cra2:${PATH}"

# Можно задать переменные окружения по умолчанию (если нужно)
# ENV PLATFORM_MAP="/data/.create-repo.platforms" \
#     REPO_LIST="/data/.repo-autosync.list" ...

# Установим по желанию (или оставим пустым)
CMD ["create-repo", "--help"]
