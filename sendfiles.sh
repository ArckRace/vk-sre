#!/bin/bash

# Конфигурации
REMOTE_USER=arck 			# Имя пользователя удаленной машины
REMOTE_HOST=192.168.0.178 		# Адрес удаленной машины
NUM_FILES=3 				# Количество созданных файлов
REMOTE_DIR=/home/$REMOTE_USER/somedir 	# Путь директории на удаленной машине

# Проверка есть ли директория на удаленной машине
if ! ssh "$REMOTE_USER@$REMOTE_HOST" "test -d $REMOTE_DIR"; 
then
  ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir $REMOTE_DIR"
  echo "Директория $REMOTE_DIR создана на удаленной машине"
fi

# Управление временем хранения файлов на другой машине
if ssh "$REMOTE_USER@$REMOTE_HOST" "find '$REMOTE_DIR' -maxdepth 1 -type f -name 'file?.txt' -mtime +7 -delete";
then
	echo "Файлы удалены успешно на удаленной машине"
else
	echo "Ошибка удаления файлов на удаленной машине"
fi

# Создание файлов в /var/log/
for (( i=1; i<=num_files; i++ ));
do
        touch /var/log/file${i}.txt
        echo "This is file ${i}" > /var/log/file${i}.txt
done

# Изменение прав доступа на файлы перед передачей
# chmod 644 /var/log/file*.txt 

# Передача файлов на другую машину
if rsync -avz /var/log/file?.txt "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"; 
then
    echo "Файлы успешно переданы на удаленную машину"
else
    echo "Ошибка передачи файлов на удаленную машину"
fi

# Конфигурация для crontab на выполнение скрипта:
# 0 0 * * * /home/arck/bashscripts/sendfiles.sh
# Данная конфигурация будет запускать скрипт каждый день,
# для запуска без пароля должен быть настроен ssh-ключ
