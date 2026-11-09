## 📦 `cra2` — Умная синхронизация Git-репозиториев

`cra2` — это CLI-утилита для автоматического создания, трекинга и синхронизации Git-репозиториев с GitHub, GitLab или Bitbucket. Полностью модульная, с автообновлением, поддержкой crontab/launchd, логами и интерактивным режимом.

---

### 🚀 Возможности

✅ Инициализация и пуш в GitHub/GitLab/Bitbucket  
✅ Автосинхронизация всех отслеживаемых репозиториев  
✅ Модульная архитектура (подключаемые модули из `modules/`)  
✅ Поддержка `.create-repo.local.conf` для каждого проекта  
✅ Логи успехов и ошибок (`~/.create-repo.log`, `~/.create-repo-errors.log`)  
✅ Цветной CLI-вывод  
✅ Поддержка crontab/launchd для автосинка  
✅ Интерактивный режим  
✅ Автоопределение платформы  
✅ Автообновление и сборка `.deb` / `.pkg`

---

### 🛠 Установка

```bash
curl -sSL https://raw.githubusercontent.com/justrunme/cra2/main/install-create-repo.sh | bash
```

---

### ⚙️ Основные команды

#### 📁 `create-repo`

Создаёт и пушит новый репозиторий, отслеживает его в `.repo-autosync.list`.

```bash
create-repo my-project
```

Флаги:
- `--interactive` — запуск с пошаговыми вопросами
- `--platform=github|gitlab|bitbucket` — указать платформу вручную
- `--sync-now` — немедленно синхронизировать
- `--pull-before-sync` — выполнять `git pull` перед `push`
- `--remove` — удалить проект из трекинга
- `--update` — обновить скрипт
- `--version` — текущая версия
- `--help` — все флаги и примеры

---

#### 🔁 `update-all`

Синхронизирует все репозитории из `~/.repo-autosync.list`.

```bash
update-all
```

Дополнительные флаги:
| Флаг         | Описание |
|--------------|----------|
| `--pull-only` | Только `git pull`, без `push` |
| `--dry-run`   | Симуляция: покажет `git status`, но не сделает `push` |
| `--help`      | Справка по командам |

✅ Учитывает локальные настройки в `.create-repo.local.conf`:
```bash
disable_sync=true   # отключает автосинк для конкретного проекта
```

---

### 📝 Логирование

- `~/.create-repo.log` — успешные синхронизации  
- `~/.create-repo-errors.log` — ошибки при `pull`/`push`

Формат:
```
2025-03-19 17:15:02 | SUCCESS | my-repo | /home/user/projects/my-repo
2025-03-19 17:16:48 | ERROR   | blog | /home/user/web/blog
```

---

### ⚙️ Локальная конфигурация

В каждом проекте можно создать `.create-repo.local.conf`:

```bash
disable_sync=true
default_branch=main
platform=github
```

---

### 🧠 Пример сценария автосинхронизации

Добавьте в `crontab -e`:
```
*/15 * * * * /usr/local/bin/update-all >> ~/.update-all-cron.log 2>&1
```

---

### 📌 Требования

- `git`, `curl`, `jq`
- `gh` (для GitHub) или `glab` (для GitLab)
- `bash` 4.x+

---

### 🧩 Структура проекта

```
cra2/
├── create-repo
├── update-all
├── install-create-repo.sh
└── modules/
    ├── colors.sh
    ├── config.sh
    ├── cron.sh
    ├── flags.sh
    ├── git.sh
    ├── logger.sh
    ├── platform.sh
    ├── repo.sh
    ├── update.sh
    ├── utils.sh
    └── version.sh
```

---

### 🎯 Roadmap

- [ ] Поддержка Telegram-уведомлений  
- [ ] CI/CD-интеграция  
- [ ] Поддержка JSON-логов  
- [ ] Web UI для управления репозиториями  

---

### 💡 Примеры

```bash
create-repo my-app --interactive
update-all --dry-run
create-repo --remove my-old-repo
update-all --pull-only
```

---

### 🤝 Поддержка

Если ты нашёл баг или хочешь внести вклад — [создай issue](https://github.com/justrunme/cra2/issues) или сделай pull request. Проект открыт для коммьюнити 🚀

---

### ⚡ Авторы

**Author:** Andrey Lesnikov, Senior DevOps & AI Platform Engineer — [ORCID](https://orcid.org/0009-0004-7583-4314)  
Скрипт и модульная архитектура: [@justrunme](https://github.com/justrunme)  
💬 Идеи и код: ChatGPT + 🧠

---
