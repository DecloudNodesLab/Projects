# Deploy V2RAY vpn server on Akash Network
# Развертка сервера V2RAY в Akash Network

![image](https://user-images.githubusercontent.com/23629420/219872517-2adc32b1-5f64-4d48-9a81-1e2ef6b01a53.png)

| [Akash Network](https://akash.network/) | [Decloud Nodes Lab](https://declab.pro/) | 
___
Before you start - subscribe to our news channels: 

Прежде чем начать - подпишитесь на наши новостные каналы:

| [Discord Akash Network](https://discord.gg/WR56y8Wt) | [Telegram Akash Network](https://t.me/AkashNW) | [Telegram Akash Network RU](https://t.me/akash_ru) | [Twitter Akash Network](https://twitter.com/akashnet_) | 

| [Discord Decloud Nodes Lab](https://discord.gg/rPENzerwZ8) | [Twitter Decloud Nodes Lab](https://twitter.com/NodesLab) | [Telegram channel Decloud Nodes Lab](https://t.me/NodesLab) |

| [How to deploy in CloudMos?](https://github.com/DecloudNodesLab/Guides/blob/main/English/Cloudmos.md) | [Как развернуть в CloudMos?](https://github.com/DecloudNodesLab/Guides/blob/main/Russian/Cloudmos.md) |
___

Product documentation. | Документация по продукту. 

| [Site V2RAY](https://www.v2fly.org/en_US) | [GitHub V2RAY](https://github.com/v2fly) | 

> [Инструкция на русском](https://github.com/DecloudNodesLab/Projects/blob/main/Software/v2ray_vpn/README.md#%D0%B8%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D1%8F-%D0%BD%D0%B0-%D1%80%D1%83%D1%81%D1%81%D0%BA%D0%BE%D0%BC-%D1%8F%D0%B7%D1%8B%D0%BA%D0%B5)

## Step 1 (Create and share your config.json)

You can use example [config.json](https://github.com/DecloudNodesLab/Projects/blob/main/Software/v2ray_vpn/example_config.json), replacing the `ID` ([generator UUID](https://www.uuidgenerator.net/))in the file to have your id.
Or create your own `config.json` by going to the[ documentation](https://www.v2fly.org/en_US/guide/start.html).
Place your `config.json` file on any platform where direct download will be available (github, google drive, etc.).

## Step 2 (Deploy on Akash Network)

Deploy `deploy.yml` file on Akash Network. If need, replace with your own link, the value in the `CONFIG_LINK` variable. Select provider and waiting finish deploy.
![image](https://github.com/DecloudNodesLab/Projects/assets/23629420/9a72129d-080a-4cec-8fb9-2e257e0d3bcb)

![image](https://github.com/DecloudNodesLab/Projects/assets/23629420/28c10d71-6cfd-4977-86e4-65278fda11ea)

## Step 3 (Usage)

You can use the **v2ray** as a `socks` proxy for your browser or application. And in the role of a VPN connection. 

For the browser - set the settings - `socks`, your provider's address and forwarded port from the **LEASES UI CloudMos** tab.

<img src=https://github.com/DecloudNodesLab/Projects/assets/23629420/862dca25-b57c-424f-8a3a-b394aabc558e width=50%>

For example, for Android, there is an [application](https://play.google.com/store/apps/details?id=com.v2ray.ang) **v2ray NG** .
In **v2ray NG** - create a new profile, where specify the provider's address, the `vmess` forwarded port and the `UUID` specified in `config.toml`.
Profile setup example:

<img src=https://github.com/DecloudNodesLab/Projects/assets/23629420/047ef1a7-f219-4b97-9315-b68d9f79e867 width=20%>

More client's application in [v2ray github](https://github.com/v2fly/v2ray-core/releases) and use [v2ray docs](https://www.v2fly.org/en_US/guide/start.html#client) .

**Do you have any questions? Answer on our [Discord](https://discord.gg/rPENzerwZ8)!**

[UP](https://github.com/DecloudNodesLab/Projects/blob/main/Software/v2ray_vpn/README.md#deploy-v2ray-vpn-server-on-akash-network)

#### Инструкция на русском языке.

## Шаг 1 (Создайте и разместите свой config.json)

Вы можете использовать пример [config.json](https://github.com/DecloudNodesLab/Projects/blob/main/Software/v2ray_vpn/example_config.json), заменив `ID` ( [generator UUID](https://www.uuidgenerator.net/) ) в файле, где будет указан ваш идентификатор.
Или создайте свой собственный `config.json`, перейдя в [документацию](https://www.v2fly.org/en_US/guide/start.html).
Разместите файл `config.json` на любой платформе, где будет доступна прямая загрузка (github, Google Drive и т.д.).

## Шаг 2 (развертывание в сети Akash)

Разверните файл `deploy.yml` в Akash Network . При необходимости замените своей ссылкой значение переменной `CONFIG_LINK`. Выберите провайдера и дождитесь завершения развертывания.
![image](https://github.com/DecloudNodesLab/Projects/assets/23629420/f32076a4-fc11-4bb1-96a7-8ee812657f10)

![image](https://github.com/DecloudNodesLab/Projects/assets/23629420/ee285e15-9127-41da-8ea3-e61c00153409)

## Шаг 3 (Использование)

Вы можете использовать **v2ray** в качестве прокси-сервера типа`socks` для вашего браузера или приложения. Так и в роли VPN-соединения.
Для браузера - установите настройки - `socks`, адрес вашего провайдера и переадресованный порт из вкладки **LEASES UI CloudMos**.

<img src=https://github.com/DecloudNodesLab/Projects/assets/23629420/862dca25-b57c-424f-8a3a-b394aabc558e width=50%>

![image](https://github.com/DecloudNodesLab/Projects/assets/23629420/26dba7bd-b87c-487c-86d8-072ec1ec72c7)

В Android, выступает [приложение](https://play.google.com/store/apps/details?id=com.v2ray.ang) **v2ray NG**.
Для приложения **v2ray NG** - создайте новый профиль, где укажите адрес провайдера, переадресованный порт `vmess` и `UUID` указанный в `config.toml`.
Пример настройки профиля:

<img src=https://github.com/DecloudNodesLab/Projects/assets/23629420/047ef1a7-f219-4b97-9315-b68d9f79e867 width=20%>

Больше клиентских приложений можно найти в [v2ray github](https://github.com/v2fly/v2ray-core/releases) и использовать [v2ray docs](https://www.v2fly.org/en_US/guide/start.html#client) .

**Остались вопросы? Ответим в нашем [Discord](https://discord.gg/rPENzerwZ8)!**

[В начало](https://github.com/DecloudNodesLab/Projects/blob/main/Software/v2ray_vpn/README.md#deploy-v2ray-vpn-server-on-akash-network)
