<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
  <h1>Script de Configuração de VLAN no Debian</h1>

  <h2>Descrição</h2>
  <p>Este script foi desenvolvido para facilitar a criação, configuração, remoção, ativação e desativação de VLANs em sistemas Debian/Ubuntu. Ele oferece um menu interativo no terminal, permitindo que o usuário execute ações em VLANs de maneira simples e eficiente, como configurar IPs, gerenciar interfaces de rede e muito mais.</p>

  <h3>Funcionalidades Principais</h3>
  <ul>
    <li><strong>Criar VLANs</strong>: Criação de VLANs com IDs e nomes personalizados.</li>
    <li><strong>Configuração de IPs</strong>: Possibilidade de configurar um endereço IP para cada VLAN.</li>
    <li><strong>Gerenciamento de VLANs</strong>: Ativação e desativação das VLANs conforme necessário.</li>
    <li><strong>Remoção de VLANs</strong>: Exclusão de VLANs configuradas.</li>
    <li><strong>Listagem de VLANs</strong>: Exibe todas as VLANs configuradas com informações sobre a interface e o IP.</li>
  </ul>

  <h2>Requisitos</h2>

  <h3>Dependências</h3>
  <p>Para usar este script, você deve garantir que os seguintes pacotes estejam instalados no seu sistema Debian/Ubuntu:</p>
  <ul>
    <li><strong>vlan</strong>: Pacote necessário para a criação e manipulação de VLANs.</li>
    <li><strong>ipcalc</strong>: Ferramenta para validação de endereços IP e sub-redes.</li>
  </ul>

  <h3>Instalação das Dependências</h3>
  <pre>
sudo apt update
sudo apt install vlan ipcalc
  </pre>

  <h3>Habilitar o Suporte a VLANs</h3>
  <p>Certifique-se de que o suporte a VLANs esteja habilitado no seu kernel. Você pode verificar isso com o seguinte comando:</p>
  <pre>lsmod | grep 8021q</pre>
  <p>Se não houver saída, você pode carregar o módulo necessário com:</p>
  <pre>sudo modprobe 8021q</pre>
  <p>Para garantir que o módulo seja carregado automaticamente após a reinicialização, adicione-o ao arquivo de configuração de módulos do kernel:</p>
  <pre>echo "8021q" | sudo tee -a /etc/modules</pre>

  <h3>Instalação do Script</h3>
  <p>Baixe ou clone o repositório que contém o script <code>vlan_config.sh</code>.</p>
  <pre>
git clone <URL do repositório>
cd <diretório do repositório>
  </pre>
  <p>Após ter o script no seu sistema, é necessário conceder permissão de execução:</p>
  <pre>chmod +x vlan_config.sh</pre>
  <p>Agora você pode rodar o script diretamente no terminal com:</p>
  <pre>./vlan_config.sh</pre>
  <p>Se você precisar de permissões de superusuário (root) para realizar algumas ações, como criar ou remover VLANs, execute o script com sudo:</p>
  <pre>sudo ./vlan_config.sh</pre>

  <h2>Como Usar</h2>
  <p>Ao executar o script, você será apresentado a um menu interativo no terminal com várias opções. Cada opção oferece uma funcionalidade diferente para configurar ou gerenciar suas VLANs.</p>

  <h3>Menu Principal</h3>
  <pre>
Escolha uma opção:
1 - Criar VLAN
2 - Editar IP de uma VLAN
3 - Remover VLAN
4 - Ativar/Desativar VLAN
5 - Listar VLANs
0 - Sair
  </pre>
  
  <h3>Opções do Menu</h3>
  <h4>1. Criar VLAN</h4>
  <p>Esta opção permite que você crie uma nova VLAN. O script solicitará:</p>
  <ul>
    <li><strong>Interface de Rede</strong>: O script irá listar as interfaces de rede disponíveis no seu sistema (exceto interfaces loopback, virtuais e wireless). Você deve selecionar uma delas para associar à nova VLAN.</li>
    <li><strong>ID da VLAN</strong>: O ID da VLAN deve ser um número entre 1 e 4094.</li>
    <li><strong>Nome da VLAN</strong>: O nome da VLAN pode ser qualquer string alfanumérica, mas deve ser sem espaços.</li>
    <li><strong>Configuração de IP</strong>: O script perguntará se você deseja configurar um IP para a VLAN. Se sim, será solicitado o IP e a máscara de rede no formato CIDR (por exemplo, 192.168.1.2/24).</li>
    <li><strong>Ativar VLAN</strong>: O script perguntará se você deseja ativar a VLAN logo após a criação.</li>
  </ul>

  <h4>2. Editar IP de uma VLAN</h4>
  <p>Esta opção permite alterar o IP de uma VLAN existente. O script solicitará:</p>
  <ul>
    <li><strong>Nome da VLAN</strong>: Você deve inserir o nome da VLAN (por exemplo, eth0.10).</li>
    <li><strong>Novo IP</strong>: O novo IP será configurado para a VLAN. O script validará se o IP está no formato correto (CIDR).</li>
  </ul>

  <h4>3. Remover VLAN</h4>
  <p>Esta opção permite remover uma VLAN configurada. O script solicitará:</p>
  <ul>
    <li><strong>Nome da VLAN</strong>: Você deve inserir o nome da VLAN a ser removida (por exemplo, eth0.10). O script verificará se a VLAN existe antes de excluí-la.</li>
  </ul>

  <h4>4. Ativar/Desativar VLAN</h4>
  <p>Esta opção permite ativar ou desativar uma VLAN existente. O script solicitará:</p>
  <ul>
    <li><strong>Nome da VLAN</strong>: Você deve inserir o nome da VLAN a ser gerenciada.</li>
    <li><strong>Ação</strong>: Você escolherá entre ativar ou desativar a VLAN.</li>
  </ul>

  <h4>5. Listar VLANs</h4>
  <p>Esta opção exibe uma lista de todas as VLANs configuradas no seu sistema. Para cada VLAN, o script exibirá:</p>
  <ul>
    <li><strong>Nome da VLAN</strong>: O nome completo da VLAN, incluindo a interface de rede associada (por exemplo, eth0.10).</li>
    <li><strong>ID da VLAN</strong>: O ID da VLAN.</li>
    <li><strong>Interface física</strong>: A interface física associada à VLAN (por exemplo, eth0).</li>
    <li><strong>IP configurado</strong>: O endereço IP associado à VLAN (se houver).</li>
  </ul>

  <h4>0. Sair</h4>
  <p>Esta opção encerra o script.</p>

  <h2>Exemplo de Execução</h2>
  <pre>
Escolha uma opção:
1 - Criar VLAN
2 - Editar IP de uma VLAN
3 - Remover VLAN
4 - Ativar/Desativar VLAN
5 - Listar VLANs
0 - Sair
  </pre>
  <p>Se você escolher "1 - Criar VLAN", o script perguntará pela interface de rede, ID da VLAN, nome da VLAN e se deseja configurar um IP.</p>
  <p>Se você escolher "5 - Listar VLANs", o script exibirá informações sobre as VLANs configuradas no sistema.</p>

  <h2>Permissões</h2>
  <p>O script exige permissões de superusuário (root) para manipular interfaces de rede e configurar IPs. Para executar o script como superusuário
