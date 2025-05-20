#!/bin/bash 
################################################################################
##  File:  kvm.sh
##  Desc:  Installs KVM (Kernel-based Virtual Machine) components for Linux
################################################################################

# Verificar se o hardware suporta virtualização
echo "Checking hardware virtualization support..."
if ! grep -E 'vmx|svm' /proc/cpuinfo &> /dev/null; then
    echo "ERROR: CPU does not support hardware virtualization. KVM cannot be installed."
    exit 1
fi

# Instalar pacotes necessários para KVM
echo "Installing KVM packages..."
apt-get update
apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# Adicionar usuário atual ao grupo libvirt e kvm
echo "Configuring user permissions..."
usermod -aG libvirt $USER
usermod -aG kvm $USER

# Iniciar e habilitar serviços
echo "Starting and enabling libvirt services..."
systemctl enable libvirtd
systemctl start libvirtd

# Verificar se o módulo KVM está carregado
echo "Validating KVM installation..."
if ! lsmod | grep -i kvm &> /dev/null; then
    echo "ERROR: KVM modules are not loaded. Installation failed."
    exit 1
fi

# Verificar se o serviço libvirt está em execução
if ! systemctl is-active --quiet libvirtd; then
    echo "ERROR: libvirtd service is not running. Installation failed."
    exit 1
fi

# Testar funcionalidade básica do KVM
echo "Testing KVM functionality..."
if ! virsh list --all &> /dev/null; then
    echo "ERROR: Cannot connect to libvirt. Installation failed."
    exit 1
fi

# Verificar se o usuário tem permissões corretas
echo "Checking user permissions..."
if ! groups $USER | grep -E 'libvirt|kvm' &> /dev/null; then
    echo "WARNING: Current user is not in libvirt or kvm groups. You may need to log out and log back in for permissions to take effect."
fi


echo "KVM installation completed successfully!"
