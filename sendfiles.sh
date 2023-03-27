#!/bin/bash

# Конфигурации
remote_host=arck@192.168.0.178 # Адрес удаленной машины
num_files=3 # Количество созданных файлов
remote_dir=/home/arck/testdir # Путь директории на удаленной машине

# Проверка есть ли директория на удаленной машине
if ! ssh "$remote_host" "test -d $remote_dir"; then
  ssh "$remote_host" "mkdir $remote_dir"
  echo "Директория $remote_dir создана на удаленной машине"
fi

# Управление временем хранения файлов на другой машине
if ssh "$remote_host" "find '$remote_dir' -maxdepth 1 -type f -name 'file?.txt' -mmin +5 -delete";
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
chmod 644 /var/log/file*.txt

# Передача файлов на другую машину
if rsync -avz /var/log/file?.txt "$remote_host:$remote_dir"; then
    echo "Файлы успешно переданы на удаленную машину"
else
    echo "Ошибка передачи файлов на удаленную машину"
fi

# Конфигурация для crontab на выполнение скрипта:
# 0 0 * * 0 /home/arck/bashscripts/sendfiles.sh
