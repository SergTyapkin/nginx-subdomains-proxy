![GithubCI](https://github.com/sergtyapkin/nginx-subdomains-proxy/actions/workflows/deploy.yml/badge.svg)

# Прокси-сервер для поддоменов с авто-деплоем на _Nginx_ в докере и автоматическим получением сертификатов _Letsencrypt_
## Для настройки необходимо только изменить .env файл
_(При запуске `make all` скрипт атоматически предоставит интерфейс для его изменения)_
```dotenv
# .env
DEBIAN_RELEASE=12-slim
NGINX_RELEASE=1.23.3-alpine
COMPOSE_NAME=nginx-subdomains-proxy-compose
DOMAIN_URL=your.domain.com
DEPLOY_BRANCH=main
#------------------------------------------
PROXY_SERVICES_COUNT=2
#------------------------------------------
PROXY_1_SUBDOMAIN=subdomain1
PROXY_1_TARGET_HTTP_PORT=4001
PROXY_1_TARGET_HTTPS_PORT=5001
PROXY_1_NETWORK_NAME=subdomain2-frontend-proxy
#------------------------------------------
PROXY_2_SUBDOMAIN=subdomain2
PROXY_2_TARGET_HTTP_PORT=4002
PROXY_2_TARGET_HTTPS_PORT=5002
PROXY_2_NETWORK_NAME=subdomain2-frontend-proxy
#------------------------------------------
```
> В этой конфигурации прокирование бцдет осуществляться по такой схеме: <br>
> `subdomain1.your.domain.com:80` -> `your.domain.com:4001`
> `subdomain1.your.domain.com:443` -> `your.domain.com:5001`
> 
> `subdomain2.your.domain.com:80` -> `your.domain.com:4002`
> `subdomain2.your.domain.com:443` -> `your.domain.com:5002`

> (Фронтенд для subdomain1 доджен прослушивать порт 4001 для http-запросов, и 5001 для https-запросов)

> [!TIP]
> Для добавления нового проксирования с нового поддомена будет необходимо лишь **увеличить `PROXY_SERVICES_COUNT` на 1**,
и добавить в конец файла **4 новых соответствующих переменных** для проксирования.

> ***Docker-compose.yaml***, а также файлы ***конфигов nginx*** будут сгенерированы автоматически по файлу .env с помощью bash-скриптов из Makefile. 

# Деплой
Развертка выполняется через команды в `Makefile` и команду `make`

## 1. Клонируем репозиторий:
```SHELL
git clone git@github.com:SergTyapkin/nginx-subdomains-proxy.git
```

## 2. Настраиваем вообще всё.
```SHELL
cd nginx-subdomains-proxy
make all # not just "make"!
````
Всё. Наслаждаемся тем, что за нас всё сделали, установили докер, сертификаты получены и автоматически обновятся.
Теперь `Github CI` сам будет проверять, собирается ли контейнер при **Pull Request**'ах, а при **Push**'ах в ветку `master` будет автоматически выполняться `make update` на сервере и обновлять деплой!

_После выполнения не забываем прописать переменные, значения которых команда выдала в консоль, в настройки окружения репозитория на Github, как это написано в пункте 3._

> [!WARNING]
> Во всех фронтендах в докер-контейнерах, на которые вы хотите проксировать запросы с поддоменов, необходимо указывать `network` с именем, указанным в .env-файле, которую обязательно **НЕОБХОДИМО ПОМЕТИТЬ КАК `external: true`**
> ```yaml
> docker-compose.yaml для вашего Фронтенда
>
> services:
>   ...
> networks:
>   nginx-proxy:
>     external: true
>     name: <YOUR_NETWORK_NAME>
> ```

### Полный список действий скриптов
1. Устанавливает `docker`, если его ещё нет
2. Добавляет текущего пользователя в группу `Docker`, чтобы запускать его без `sudo`
3. Предлагает настроить `.env` файл
4. Получает сертификаты Letsencrypt
5. Устанавливает и настраивает `cron` на ежемесячное обновление сертификатов
6. Создаёт пару SSH ключей, публичный добавляет в `~/.ssh/authorized_keys`, приватный выводит в консоль, его нужно добавить как секретную переменную среды `SSH_DEPLOY_KEY` в настройках Github.
7. Собирает приложение из последнего коммита в ветку `master`, запускает финальный docker-контейнер с ним.
8. Показывает остальеые переменные, которые необходимо установить в настройках GitHub для настройки CI/CD.

## 3. Установка переменных
1. Заходим в `Settings` -> `Environments`, создаём новое окружение под названием `deploy` (важно).
![](/README_res/1.png)
2. Создаём внутри окружения все необходимые переменные. Их выведет `make all` после завершения выполнения, или можно прописать самому.
![](/README_res/2.png)
