# Разверка Sentinel dVPN ноды 

> Для разверки ноды можете воспользоваться [веб интерфейсом Cloudmos](https://deploy.cloudmos.io/). О том, как с ним работать можете [описано в этом документе](https://github.com/DecloudNodesLab/Guides/blob/main/Russian/Cloudmos.md).

### Подготовка
1. Создайте в `Keplr` новый аккаунт для dVPN ноды.
2. Зашифруйте мнемоник фразу с помощью `BASE64`, это можно сделать как с помощью приложения `Notepad++` (Плагины-MIME Tools-Base64 Encode), либо с помощью любого безопасного онлайн шифратора Base64.
3. Пополните счет созданного dVPN аккаунта не менее чем на `150dvpn` (~$0.10) для оплаты газа. 

### Развертка узла
Откройте web интерфейс `Cloudmos`, нажмите кнопку `DEPLOY`, выберите пустой темплейт `Empty` и скопируйте туда содержимое [deploy.yml](https://raw.githubusercontent.com/DecloudNodesLab/Projects/main/Software/Sentinel%20dVPN/deploy.yml).
