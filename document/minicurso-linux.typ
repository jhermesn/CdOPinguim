
#import "@preview/ilm:1.4.1": *

#set text(lang: "pt")
#show: ilm.with(
  title: [Minicurso Linux],
  author: "Ananda Nunes, Filipe Cruz, Jorge Hermes, Matheus William",
  abstract: [
              // Guia para o minicurso de Linux ministrado durante a semana acadêmica da UEPA.
            ],
  preface: [ 
            #align("Material de estudos para o minicurso de Linux que irá ser ministrado durante a semana acadêmica da UEPA.", center).\
            ],
  paper-size: "a4",
  // figure-index: (enabled: true),
  // table-index: (enabled: true),
  // listing-index: (enabled: true),
)
#show table.cell.where(y: 0): strong

// === tag: #link("/home/felops/Documents/1_notes/2-indexes/computer-science/computer-science.pdf")[Computer Science], #link("")[Atividades UEPA]
// = Ambiente
//   Instalação de um ambiente Linux utilizando o _Windows Subsytem for Linux 2_ (WSL 2).
//   + Passo-a-passo \
//     // + Habilitar o WSL no Windows \


= Fundamentos de Linux
== O que é o Linux
O Linux é um sistema operacional criado por Linus Torvalds, em 1991. Seu código fonte é liberado como Free Software (software livre), sob licença GPL.

Isto quer dizer que você não precisa pagar nada para usar o Linux, e não é crime fazer cópias para instalar em outros computadores, o que é um dos motivos da estabilidade e velocidade em que novos recursos são adicionados ao sistema.

No Linux, o Kernel Linux mais o conjunto de ferramentas GNU, compõem o sistema operacional Linux. Por isso é comum ler o termo GNU/Linux, ao se referir ao S.O.

//
// == Importância do Linux na Atualidade
// Atualmente, o Linux é o sistema mais utilizado em servidores, devido a sua estabilidade, modularidade, segurança e custo zero.
//
// O Linux também é um excelente sistema para usuários que buscam mais opções de personalização e um controle maior do seu sistema.
//

== Distribuições Linux
Distros de Linux são um pacote composto do GNU\Linux + Outras aplicações que compõem um sistema operacional. Geralmente, cada distro busca atender um público-alvo e direciona suas funcionalidades para satisfazer as necessidades desse público, seguindo uma filosofia de desenvolvimento.\

=== Debian
Uma das distros mais antigas (desde 1993), o Debian é focado em estabilidade e por isso ele se torna uma das melhores escolhas para servidores, sendo utilizável por anos sem precisar de uma atualização.

=== Fedora
Uma disto patrocinado pela Red Hat, funciona como um campo de testes para tecnologias que serão implementadas no Red Hat Enterprise Linux (RHEL). Atende desenvolvedores que buscam estabilidade, mas sem sacrificar atualizações mais frequentes.

=== Arch Linux
O Arch segue a filosofia _KISS_ (Keep It Simple, Stupid). Simples, nesse caso, significa que o sistema não vem com nada instalando por padrão, o usuário deve escolher quais pacotes instalar; incluindo o Kernel Linux e o Desktop Enviroment.

#pagebreak()
= Estrutura de Arquivos no Linux (FHS)
== O que é um sistema de arquivos
Um sistema de arquivos é uma estrutura usada por um sistema operacional para organizar e gerenciar arquivos em um dispositivo de armazenamento, como um disco rígido, SSD ou pendrive. Ele define como os dados são armazenados, acessados e organizados no dispositivo de armazenamento.
== O que é um diretório
Um diretório é uma pasta, ou seja, é um local dentro do sistema de arquivos usado para guardar e organizar arquivos. Ele também pode conter outros diretórios, ajudando a manter tudo organizado em diferentes níveis.
#figure(
  image("assets/fhs-linux.png"),
  caption: [
    Filesystem Hierachy Standard - Estrutura de Hierarquia
  ],
)
=== Principais diretórios do Linux
==== /home
Diretório pessoal dos usuários. Cada usuário possui seu próprio subdiretório dentro desta pasta para armazenar seus arquivos pessoais.

==== /usr
Contém os diretórios e arquivos de uso comum do sistema, como programas, bibliotecas, documentação, entre outros. É uma das áreas mais extensas do sistema de arquivos.

==== /etc
Armazena arquivos de configuração do sistema, incluindo arquivos de inicialização (init.d) e configurações globais. É um diretório importante para administradores de sistema.

==== /root
Diretório pessoal do usuário root (superusuário). O superusuário é o administrador do sistema.

==== /opt
Destinado à instalação de pacotes de software adicionais de terceiros (opcionais).

==== /lib
Contém bibliotecas de código compartilhado usadas pelos programas do sistema.

==== /boot
Armazena arquivos relacionados ao processo de inicialização (boot) do sistema, como o bootloader e o kernel.

==== /sbin
Contém utilitários do sistema para a administração e operação do sistema. Esses utilitários sãoArmazena arquivos relacionados ao processo de inicialização (boot) do sistema, como o bootloader e o kernel. geralmente acessíveis apenas pelo superusuário.

==== /bin
Contém os utilitários (programas) essenciais para o funcionamento básico do sistema, acessíveis a todos os usuários.

==== /var
Armazena arquivos de dados variáveis, como arquivos de log, banco de dados, spool de impressão, entre outros. Esses arquivos são alterados regularmente durante a operação do sistema.

==== /mnt
Diretório para montagem temporária de sistemas de arquivos adicionais.

==== /media
Diretório de montagem automática para dispositivos de mídia removíveis, como CDs, DVDs e dispositivos USB.

==== /tmp
Diretório para arquivos temporários usados pelos programas em execução no sistema. Os arquivos armazenados neste diretório

==== /dev
Contém os dispositivos do sistema, como discos rígidos, unidades USB, impressoras, entre outros. Cada dispositivo é representado por um arquivo especial.

==== /srv
Diretório que contém dados específicos do serviço, como arquivos de log, arquivos de configuração de sites, entre outros.

==== /proc
Sistema de arquivos virtual que fornece informações sobre os processos em execução e o estado do sistema.

== Tipos de sistemas de arquivos
#let si-table = table(
  columns: 2,
  table.header[Sistema Operacional][Sistemas de Arquivos Suportados],
  [Linux],[EXT3, EXT4, BTRFS, XFS, JFS],
  [MacOS],[HFS],
  [Windows],[FAT, HPFS, NTFS],
)
#figure(caption: [Tipos de Sistemas de Arquivos por S.O.], si-table)

- EXT3: usado como padrão no Linux a partir de 2001. Possui journal, que ajuda a recuperar o sistema em caso de desligamento inesperado. Suporta até 16 TB no sistema de arquivos, 2 TB por arquivo e até 32 mil subpastas em uma pasta. 

- EXT4: padrão do Linux desde 2008. É mais rápido e moderno que o EXT3. Suporta até 1 EB no sistema de arquivos, 16 TB por arquivo e ilimitadas subpastas em uma pasta.

#pagebreak()
= Editores de Texto de Linha de Comando
Programas que permitem a criação e edição de arquivos pela linha de comando.
== Vi
Editor texto padrão de muitos sistemas POSIX. Ele utiliza de diferentes "modos" de edição para permitir mais funcionalidades.  \
Comandos úteis:\
- Modo NORMAL (Aperte <\ESC\> para entrar nesse modo)\
  - utilize <\h, j, k, l\> para mover o cursor
  - :q! --> Sair sem salvar
  - :w --> Salvar
  - :wq --> Sair e Salvar
- Modo INSERÇÃO/INSERT (Aperte <\i\> para entrar nesse modo)
  - Esse modo permite a inserção de texto.
== Vim
Um sucessor do Vi, adiciona várias opções de qualidade de vida como o realce de sintaxe, plugins e o modo visual. Utiliza a maioria dos comandos do Vi.\
== Nano
Editor de texto simples e de fácil uso. Não tem modos como o Vi ou Vim.\
Comandos úteis:\
- Salvar: CTRL + O
- Sair: CTRL + X

#pagebreak()
= Comandos Básicos
== Man
As páginas de manual dos comandos são a pricipal fonte de documentação do Linux quando você tem alguma dúvida sobre um comando. Essas páginas podem ser acessadas da seguinte forma:

#align(center)[man [_nome do comando_]]

As páginas man oferecem um breve resumo da finalidade, da sintaxe e das opções associadas a um comando específico.

A documentação exibida de um comando normalmente terá muitas páginas.Para navegar pelas páginas, use osbotões a seguir do teclado:

- Tecla de *seta* para *cima* ou para *baixo*: rola para cima ou para baixo uma linha, respectivamente
- *Page Up* ou *Page Down*: rola uma página para cima ou para baixo, respectivamente
- *Barra de espaço*: rola uma página para baixo

Você também pode pesquisar a página man de um comando usando o caractere de barra (/):

#align(center)[/<\searchString\>]

Para sair das páginas de manual, digite *q*.


== Comandos para manipulação de diretório
  - ls \
    Lista os arquivos de um diretório. \
    Cores diferentes representam diferentes tipos de arquivos \
    ls [opções][_caminho/arquivo_][_caminho1/arquivo1_]... \

#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-l],[Formato longo (mostra *permissões*)],
  [-h],[Tamanhos de arquivo relatados em um formato amigável para humanos],
  [-s],[Mostra o tamanho de cada arquivo e o tamanho do diretório],
  [-a],[Mostra todos os arquivos, incluindo arquivos ocultos],
  [-R],[Lista subdiretórios],
  [-X],[Classifica em ordem alfabética por extensão de arquivo],
  [-S],[Classifica por tamanho de arquivo],
  [-t],[Classifica por tempo de modificação],
)
#figure(caption: [Opções úteis para o comando ls], si-table)
#colbreak()

  - cd \
    Entra em um diretório no qual você tem permissão de execução. \
    cd [_diretório_]

  - mkdir \
    Cria um diretório no sistema \
    mkdir [opções][_caminho/diretório_][_caminho1/diretório1_]...
    
#pagebreak()
== Comandos para manipulação de arquivos
  - cat \
    Mostra o conteúdo de um arquivo binário ou texto \
    cat[opções][_diretório/arquivo_][_diretório1/arquivo1_]...

  - rm \
    Apaga arquivos, diretórios e subdiretórios vazios o que contenham arquivos. \
    rm [opções][_caminho_][_arquivo/diretório_][_caminho1_][_arquivo1/diretório1_]...
#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-d],[Remove um diretório se o diretório estiver vazio],
  [-r],[Força a remoção de um diretório não vazio],
  [-f],[Não envia prompt ao usuário. Útil para diretórios com muitos arquivos],
  [-i],[Interativo - envia prompt para confirmar cada arquivo],
  [-v],[Exibe nomes dos arquivos excluídos],
)
#figure(caption: [Opções úteis para o comando rm], si-table)
#colbreak()

  - cp \
    Copia arquivos e diretórios. \
    Por padrão, o comando sobreescreve arquivos existentes com o mesmo nome. \
    cp [opções][_origem_][_destino_]

#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-a],[Arquiva arquivos],
  [-f],[Força cópia sobrescrevendo o arquivo de destino, se necessário],
  [-i],[Interativo - Pergunta antes de sobrescrever],
  [-n],[Não sobrescreve arquivos],
  [-v],[Modo detalhado - Imprime mensagens informativas],
  [-l],[Vincula arquivos em vez de copiar],
)
#figure(caption: [Opções úteis para o comando cp], si-table)
#colbreak()

  - mv \
    Move ou renomeia arquivos e diretórios. Executa o mesmo processo do cp, mas apaga o arquivo de origem no final do processo. \
    mv [opções][_origem_][_destino_] \
#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-i],[Envia um prompt antes de sobrescrever um arquivo],
  [-f],[Evita receber prompts],
  [-n],[Não sobrescreve arquivos existentes],
  [-v],[Mostra o nome dos arquivos que são movidos ou renomeados],
)
#figure(caption: [Opções úteis para o comando mv], si-table)

    É possível utilizar uma expressão regular para mover arquivos do mesmo tipo. \
    #align(center)[mv \*.png dir1] \
    Move todos os arquivos do tipo *.png* para *dir1*
#colbreak()

  - find \
    Pesquisa arquivos que correspondem a critérios específicos em um diretório designado. \
    Pode pesquisar por: 
      - Proprietário
      - Nome do Arquivo
      - Tamanho do arquivo
      - Data de modificação do arquivo
      - Tipo de arquivo
    find [_diretório de origem_][opções][_o que encontrar_]
#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-name],[Pesquisa por nome de arquivo],
  [-iname],[Pesquisa por nome de arquivo, mas ignora letras maiúsculas],
  [-user],[Pesquisa por proprietário do arquivo],
  [-type],[Pesquisa por tipo de arquivo],
)
#figure(caption: [Opções úteis para o comando find], si-table)

  - grep \
    Pesquisa o conteúdo de um arquivo em busca de um determinado padrão de texto ou string e exibe cada ocorrência. \
    grep [opções][_texto a ser procurado_][_diretório onde procurar_]
#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-i],[Ignora maiúsculas],
  [-r],[Executa pesquisas recursivas],
  [-l],[Lista apenas nomes de arquivos],
  [-n],[Exibe o número de linha],
  [-c],[Contagem de linhas de correspondentes],
)
#figure(caption: [Opções úteis para o comando grep], si-table)
#colbreak()

  - tar \
    Compacta uma coleção de arquivos em um único arquivo para facilitar a cópia ou o download. O pacote criado é chamado de tarball \
    O conteúdo de um arquivo compactado pode, opcionalmente, ser compactado. \
    O comando também é usado para descompactar um arquivo \
    tar [opções][_nome_do_arquivo.tar_][_arquivo1/diretório1_][_arquivo2/diretório2..._] 

    Exemplos:
      - Para compactar arquivos em um tarball: \
          tar -cvf tarball.tar file1 file2 file3

      - Para compactar arquivos utilizando compressão: \
          tar -cafv tarball.tar.gz file1 file2 file3

      - Para descompactar arquivos desse tarball: \
          tar -xaf tarball.tar \
          tar -xaf tarball.tar.gz (arquivo com compressão)

      - Para compactar o tarball utilizando gzip \
          gzip tarball.tar

#let si-table = table(
  columns: 2,
  table.header[Opção][Decrição],
  [-c],[Cria um novo tarball],
  [-x],[Extrai o conteúdo de um tarball],
  [-z],[Compacta o conteúdo de um tarball usando o utilitário gzip],
  [-a],[Detecta automaticamente o tipo de compressão necessário, ao ler a extensão do arquivo],
  [-f],[Especifica o nome do tarball],
  [-v],[Produz uma saída detalhada mostrando os nomes dos arquivos enquanto o tarball é processado],
)
#figure(caption: [Opções úteis para o comando tar], si-table)

// #pagebreak()
// = Operadores Básicos

#pagebreak()
= Permissões de Arquivos no Linux
No Linux, cada arquivo e pasta tem permissões que controlam quem pode ler (r), escrever (w) ou executar (x). Essas permissões são divididas em três grupos: dono (owner), grupo (group) e outros (others). Assim, o sistema garante que cada usuário tenha apenas o acesso necessário. \
// #figure(
//   image("assets/tabela-permissoes-linux.png", height: 50%),
//   caption: [
//     Tabela Auxiliar
//   ],
// )

#let si-table = table(
  columns: 2,
  table.header[][Utilizadores],
  [u],[User (Owner)],
  [g], [Grupo (Group)],
  [o], [Outros (Other)],
  [a], [All (Todos)],
)
#figure(caption: [Tabela Auxiliar 1], si-table)

#let si-table = table(
  columns: 2,
  table.header[][Permissões],
  [r],[Leitura (Read)],
  [w], [Escrita (Write)],
  [x], [Executar (Execute)],
)
#figure(caption: [Tabela Auxiliar 2], si-table)

#let si-table = table(
  columns: 2,
  table.header[][Operadores],
  [+],[Adiciona permissão],
  [-], [Remove permissão],
  [=], [Define permissão, remove as restantes (para u, g, o, a)],
)
#figure(caption: [Tabela Auxiliar 3], si-table)
#pagebreak()

// #table


== Exemplo de saída do arquivo (comando ls -l)
// #figure(
//   image("assets/permissoes-arquivos-linux.png", height: 20%),
//   caption: [
//     Como ler permissões de arquivos 
//   ],
// )
#figure(
  image("assets/permissoes-de-arquivos.png", height: 35%),
  caption: [
    Como ler permissões de arquivos 
  ],
)

Exemplo:
*-rw-rw-r−− 1 aluno curso 1024 Fev 13 10:55 teste* \
*-*: tipo do arquivo (- = arquivo comum, d = diretório, l = link, etc.) \
*rw-*: permissões do dono (read, write, sem execução) \
*rw-*: permissões do grupo (read, write, sem execução) \
*r--*: permissões de outros (read, sem write, sem execução) \
*1*: número de links ou hard links para o arquivo \
*aluno*: dono do arquivo \
*curso*: grupo do arquivo 

== Comandos para definição de permissões
- chmod: usado para alterar as permissões de leitura, escrita e execução de arquivos e pastas. \
 Exemplo: chmod 700 arquivo ou chmod u+rwx arquivo
- chown: usado para mudar o dono (usuário e grupo) de um arquivo ou diretório. \
 Exemplo: chown usuario:grupo arquivo

#pagebreak()
= Instalação de Pacotes - Via Instalador no Terminal (Apt Install) e Arquivos (.deb, tar.gz e outros)
== Função geral da instalação de pacotes:
O objetivo é adicionar novos softwares ou bibliotecas ao sistema de forma organizada, garantindo que todos os arquivos necessários sejam instalados, que dependências sejam resolvidas e que o programa funcione corretamente. Pacotes simplificam a manutenção do sistema e evitam conflitos, além de permitir atualizações fáceis. \

== Instalação via terminal
- apt update
Comando utilizado em distribuições Debian/Ubuntu para instalar pacotes diretamente dos repositórios oficiais. Ele baixa automaticamente os arquivos necessários, resolve dependências e instala o software de forma segura e padronizada. É a forma mais prática de manter o sistema atualizado e consistente. \
Ex: 
sudo apt update  && sudo apt install vim \

- pacman -Syu
Comando utilizado em distribuições Arch Linux e derivadas para instalar e atualizar pacotes. -S instala pacotes, -y sincroniza a base de pacotes, e -u atualiza o sistema. Assim como o APT, ele resolve dependências automaticamente, mas é específico para sistemas baseados em Arch. \
Ex: 
sudo pacman -Syu   && sudo pacman -S firefox \

== Instalação por arquivos
- Arquivos .deb:
Pacotes pré-compilados para Debian/Ubuntu, contendo todos os arquivos e informações necessárias para instalação. São úteis quando o pacote não está disponível nos repositórios oficiais. \
Ex: 
sudo dpkg -i pacote.deb

- Arquivos .tar.gz e outros compactados:
Arquivos que normalmente contêm o código-fonte do software. Para instalar, é necessário descompactar, configurar, compilar e instalar manualmente. Esse método oferece maior flexibilidade, mas exige conhecimento sobre dependências e configurações do sistema. \
Ex:
tar -xzf pacote.tar.gz \
cd pacote \
./configure \
make \
sudo make install \

#pagebreak()
= Caça ao Pinguin!
Dinâmica envolvendo os conhecimentos adquiridos sobre Linux até agora.

#pagebreak()
= Desafio: Instalação da distro Arch Linux
Em sua casa, tente instalar a distribuição Arch Linux, mas sem usar o script _archinstall_ ! \
Para mais informações refira-se ao guia de instalação presente na wiki oficial do Arch:\ 
#link("https://wiki.archlinux.org/title/Main_page_(Portugu%C3%AAs)")[*Arch Wiki em PT-BR*] \
#link("https://archlinux.org/download/")[*Instalação da ISO do Arch*] \
Caso queira utilizar um ambiente isolado no seu computador, tente a #link("https://www.virtualbox.org/")[*Oracle Virtual Box*]\

#pagebreak()
= Referências
  - #link("https://www.guiafoca.org/guiaonline/inicianteintermediario/")[Guia Foca Linux (Iniciante + Intermediário)]
  - #link("https://roadmap.sh/linux")[Roadmap.sh (Linux)]
  - #link("https://guialinux.uniriotec.br/permissao-de-acesso/")[Permissões de acesso no LInux]
  - #link("https://sempreupdate.com.br/como-instalar-programas-tar-gz-bz2-xz-no-linux/")[Instalaçao de tar.gz, tar.xz, tar.bz2]
  - #link("https://e-tinet.com/linux/instalar-tar-gz-no-linux-guia-completo/")[Instalação de tar.gz no Linux]
  - #link("https://www.certificacaolinux.com.br/particoes-linux/")[Partições no Linux]
  - #link("https://www.linuxando.com/tutorial.php?t=A+estrutura+de+diret%C3%B3rios+Linux_6")[Estrutura de diretórios no Linux]
  - #link("https://sempreupdate.com.br/entendendo-a-hierarquia-do-sistema-de-arquivos-linux-um-guia-abrangente/")[Entendendo a Hierarquia do Sistema de Arquivo do Linux]
  - #link("https://guialinux.uniriotec.br/sistemas-de-arquivos/")[Sistema de Arquivos no Linux]
  - #link("https://www.vivaolinux.com.br/artigo/Hierarquia-do-Sistema-de-Arquivos-GNU-Linux")[Hierarquia de Sistema de Arquivos no GNU/Linux]
  - #link("https://archlinux.org/")[Arch Wiki]
  - #link("https://www.debian.org/")[Debian Wiki]
  - #link("https://fedoraproject.org/")[Fedora Wiki]














