# Настройка имени пользователя и электронной почты для Git
$gitUserName = "Vasilii S"
$gitUserEmail = "vasiliiskrypnik02@gmail.com"

# Установка глобальных настроек Git
git config --global user.name $gitUserName
git config --global user.email $gitUserEmail

# Определение пути к SSH ключу
$sshKeyPath = "$HOME\.ssh\id_rsa"

# Вывод публичного ключа
$publicKey = Get-Content "${sshKeyPath}.pub"
Write-Host "Ваш публичный SSH ключ для добавления в GitHub:"
Write-Host $publicKey
