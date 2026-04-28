# routerich-bcw-manager
Удобный CLI-менеджер для запуска и автоматизации оригинального blockcheckw на роутерах RouteRich.

Основа работы — оригинальный проект blockcheckw от rcd27.  
Огромная благодарность автору за мощный и полезный инструмент.  
Отдельная благодарность bol-van за оригинальный zapret2.  

Официальный репозиторий blockcheckw: https://github.com/rcd27/blockcheckw  
Если вам нужен сам движок проверки стратегий - используйте оригинальный проект.  
Официальный репозиторий zapret2 - https://github.com/bol-van/zapret2  

Этот репозиторий содержит только оболочку-менеджер для удобного использования на роутерах RouteRich.

Специально адаптировано для роутеров RouteRich.

Проверено на устройстве RouteRich с 512 MB RAM.
Важно: использование 256 потоков может приводить (и приведёт) к нехватке памяти и остановке выполнения скрипта.
Рекомендуемое значение - 128 потоков.

## Возможности

- установка / обновление blockcheckw
- быстрый поиск стратегий
- полный поиск (scan + check)
- автоматическая остановка / восстановление zapret2
- выбор протокола (http / tls12 / tls13)
- выбор DNS режима
- сохранение рабочих стратегий в файл
- просмотр результатов
- очистка логов и отчётов
- запуск одной командой: `bcw`

## Установка

```bash
wget -O /tmp/install.sh https://raw.githubusercontent.com/dedikar/routerich-bcw-manager/main/install.sh && sh /tmp/install.sh
```

## Удаление

```bash
wget -O /tmp/uninstall.sh https://raw.githubusercontent.com/dedikar/routerich-bcw-manager/main/uninstall.sh && sh /tmp/uninstall.sh
```
