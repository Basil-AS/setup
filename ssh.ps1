# Включение и запуск службы SSH агента
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent

# Определение пути к SSH ключу
$sshKeyPath = "$HOME\.ssh\id_rsa"

# Создание SSH ключа, если он не существует
if (-Not (Test-Path $sshKeyPath)) {
    ssh-keygen -t rsa -b 4096 -f $sshKeyPath -N ""
}

# Добавление SSH ключа в SSH агент
ssh-add $sshKeyPath

# Вывод публичного ключа
Get-Content "${sshKeyPath}.pub"
