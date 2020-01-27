Для успешного запуска и выполнения скрипта:
1. Установленный Python последней версии для всех пользователей:
	В главном окне поставить галочки Install for all users и Add to PATH - Customize installation 
	Optional Features выбрать все галочки
	Advanced Options выбрать все галочки
	Disable path lenght limit
2. Импорт необходимых модулей для работы скрипта:
	1. Запустить cmd от имени Администратора, в нем python -m pip install requests
	2. Control Panel\Programs - Turn Windows features on or off - Active Directory Ligthweight Directory Services
3. Файлы create_new_user_yandex.py и disable_user_yandex.py должны находиться в одной папке со скриптом
4. Разрешить Powershell запуск скриптов:
	Запуск Powershell от имени Администратора, в нем set-executionpolicy remotesigned и выбрать [A] Yes to All
5. Запуск скрипта в powershell: 
	.\newuser
6. В случае иероглифов установите русскую локаль.