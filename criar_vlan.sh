#!/bin/bash

# Informações sobre o script
echo "===================================="
echo " Script de Configuração de VLAN Temporaria no Debian"
echo " Autor: Felipe Thiago"
echo " Descrição: Este script facilita a criação, configuração e ativação/desativação de Vlans Temporarias no Debina. após o reboot da maquina as vlans são removidas."
echo " Requisitos: Necessita do pacote 'vlan' e 'ipcalc' instalados."
echo "===================================="
echo

# Verificação de dependência (pacote vlan)
if ! dpkg -s vlan &> /dev/null; then
  echo "O pacote 'vlan' não está instalado."
  echo "Por favor, instale-o usando: sudo apt install vlan"
  exit 1
fi

# Verificação de dependência (pacote ipcalc)
if ! dpkg -s ipcalc &> /dev/null; then
  echo "O pacote 'ipcalc' não está instalado."
  echo "Por favor, instale-o usando: sudo apt install ipcalc"
  exit 1
fi

# Função para listar interfaces de rede disponíveis e permitir seleção
selecionar_interface() {
  interfaces=($(ip link show | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2}'))

  echo "Selecione uma interface de rede ou digite '0' para voltar ao menu principal:"
  select interface_base in "${interfaces[@]}"; do
    if [[ "$REPLY" == "0" ]]; then
      return 1
    elif [[ -n "$interface_base" ]]; then
      echo "Interface selecionada: $interface_base"
      break
    else
      echo "Opção inválida. Por favor, selecione um número válido."
    fi
  done
}

# Função para validar o formato do IP
validar_ip() {
  ipcalc -n "$1" &> /dev/null
  return $?  # 0 se o IP for válido, 1 se for inválido
}

# Função para criar a VLAN
criar_vlan() {
  if ! selecionar_interface; then
    return 0
  fi

  echo "Digite o ID da VLAN (um número entre 1 e 4094) ou '0' para voltar ao menu principal:"
  read vlan_id
  if [[ "$vlan_id" == "0" ]]; then
    return 0
  fi

  # Verifica se o ID da VLAN é válido
  if [[ "$vlan_id" -lt 1 || "$vlan_id" -gt 4094 ]]; then
    echo "ID da VLAN inválido. Deve estar entre 1 e 4094."
    return 1
  fi

  echo "Digite o nome da VLAN (somente caracteres alfanuméricos, sem espaços) ou '0' para voltar ao menu principal:"
  read vlan_name
  if [[ "$vlan_name" == "0" ]]; then
    return 0
  fi

  # Verifica se o nome da VLAN é válido (apenas alfanuméricos, sem espaços)
  if [[ ! "$vlan_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Nome da VLAN inválido. Use apenas caracteres alfanuméricos e sem espaços."
    return 1
  fi

  # Define o nome completo da VLAN na interface selecionada
  vlan_iface="${interface_base}.${vlan_name}"

  echo "Criando a VLAN $vlan_iface na interface $interface_base com ID $vlan_id..."

  # Cria a VLAN com o nome personalizado
  sudo ip link add link "$interface_base" name "$vlan_iface" type vlan id "$vlan_id"

  # Pergunta se o usuário quer configurar um IP
  echo "Deseja configurar um IP para a VLAN? (s/n)"
  read resposta_ip
  if [[ "$resposta_ip" == "s" ]]; then
    while true; do
      echo "Digite o IP para a VLAN (exemplo: 192.168.1.2/24) ou '0' para voltar ao menu principal:"
      read ip_vlan
      if [[ "$ip_vlan" == "0" ]]; then
        return 0
      fi

      # Valida o formato do IP
      if validar_ip "$ip_vlan"; then
        # Configura o IP na VLAN
        sudo ip addr add "$ip_vlan" dev "$vlan_iface"
        echo "IP $ip_vlan configurado na VLAN $vlan_iface."
        break
      else
        echo "Erro: IP inválido. Tente novamente."
      fi
    done
  fi

  # Pergunta se o usuário quer ativar a VLAN
  echo "Deseja ativar a VLAN agora? (s/n)"
  read resposta_ativar
  if [[ "$resposta_ativar" == "s" ]]; then
    sudo ip link set dev "$vlan_iface" up
    echo "VLAN $vlan_iface ativada."
  else
    echo "VLAN $vlan_iface criada, mas permanece desativada."
  fi
}

# Função para editar IP de uma VLAN
editar_vlan_ip() {
  echo "Digite o nome da VLAN que deseja editar (exemplo: eth0.vlanname) ou '0' para voltar ao menu principal:"
  read vlan_iface
  if [[ "$vlan_iface" == "0" ]]; then
    return 0
  fi

  # Verifica se a VLAN existe
  if ! ip link show "$vlan_iface" &>/dev/null; then
    echo "A VLAN $vlan_iface não existe."
    return 1
  fi

  # Pergunta se o usuário deseja alterar o IP
  echo "Digite o novo IP para a VLAN $vlan_iface (exemplo: 192.168.1.2/24) ou '0' para voltar ao menu principal:"
  read ip_vlan
  if [[ "$ip_vlan" == "0" ]]; then
    return 0
  fi

  # Valida o formato do novo IP
  if validar_ip "$ip_vlan"; then
    # Remove o IP antigo antes de adicionar o novo
    sudo ip addr flush dev "$vlan_iface"
    sudo ip addr add "$ip_vlan" dev "$vlan_iface"
    echo "IP $ip_vlan configurado na VLAN $vlan_iface."
  else
    echo "Erro: IP inválido. Tente novamente."
  fi
}

# Função para remover uma VLAN
remover_vlan() {
  echo "Digite o nome da VLAN que deseja remover (exemplo: eth0.vlanname) ou '0' para voltar ao menu principal:"
  read vlan_iface
  if [[ "$vlan_iface" == "0" ]]; then
    return 0
  fi

  # Verifica se a VLAN existe
  if ! ip link show "$vlan_iface" &>/dev/null; then
    echo "A VLAN $vlan_iface não existe."
    return 1
  fi

  # Remove a VLAN
  sudo ip link delete "$vlan_iface"
  echo "VLAN $vlan_iface removida."
}

# Função para ativar ou desativar uma VLAN
gerenciar_vlan() {
  echo "Digite o nome da VLAN que deseja gerenciar (exemplo: eth0.vlanname) ou '0' para voltar ao menu principal:"
  read vlan_iface
  if [[ "$vlan_iface" == "0" ]]; then
    return 0
  fi

  # Verifica se a VLAN existe
  if ! ip link show "$vlan_iface" &>/dev/null; then
    echo "A VLAN $vlan_iface não existe."
    return 1
  fi

  echo "Escolha uma ação para a VLAN $vlan_iface:"
  echo "1 - Ativar"
  echo "2 - Desativar"
  echo "0 - Voltar ao menu principal"
  read acao

  case $acao in
    1)
      sudo ip link set dev "$vlan_iface" up
      echo "VLAN $vlan_iface ativada."
      ;;
    2)
      sudo ip link set dev "$vlan_iface" down
      echo "VLAN $vlan_iface desativada."
      ;;
    0)
      return 0
      ;;
    *)
      echo "Opção inválida."
      ;;
  esac
}

# Função para listar VLANs configuradas
listar_vlans() {
  echo "VLANs configuradas:"
  
  # Filtra a saída de ip link show para exibir apenas o nome da VLAN, ID e a interface física
  ip -d link show | grep -E "vlan" | while read -r linha; do
    # Usando expressão regular para extrair nome da VLAN, ID e interface física
    if [[ "$linha" =~ ([a-zA-Z0-9_-]+)\.([a-zA-Z0-9_-]+)@([a-zA-Z0-9_-]+) ]]; then
      nome_vlan="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"  # Nome da VLAN com interface física
      id_vlan="${BASH_REMATCH[2]}"  # ID da VLAN (correto agora)
      interface="${BASH_REMATCH[3]}"  # Interface física
      
      # Procurando o IP configurado na interface da VLAN
      ip_vlan=$(ip addr show dev "$nome_vlan" | grep "inet " | awk '{print $2}')
      
      # Exibe as informações no formato desejado
      if [[ -n "$ip_vlan" ]]; then
        echo "Nome: $nome_vlan | ID: $id_vlan | Interface: $interface | IP: $ip_vlan"
      else
        echo "Nome: $nome_vlan | ID: $id_vlan | Interface: $interface"
      fi
    fi
  done
}

# Menu principal do script
while true; do
  echo "Escolha uma opção:"
  echo "1 - Criar VLAN"
  echo "2 - Editar IP de uma VLAN"
  echo "3 - Remover VLAN"
  echo "4 - Ativar/Desativar VLAN"
  echo "5 - Listar VLANs"
  echo "0 - Sair"
  read opcao

  case $opcao in
    1)
      criar_vlan
      ;;
    2)
      editar_vlan_ip
      ;;
    3)
      remover_vlan
      ;;
    4)
      gerenciar_vlan
      ;;
    5)
      listar_vlans
      ;;
    0)
      echo "Saindo do script."
      break
      ;;
    *)
      echo "Opção inválida. Tente novamente."
      ;;
  esac
done
