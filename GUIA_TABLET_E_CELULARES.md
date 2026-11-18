# Guia Completo do Tablet (Termux) + Celulares Android e iPhone

Este guia traz o **passo a passo completo no terminal**, desde o envio da sua versão personalizada (Tema Oceano + aba **Contrações 5-1-1**) até o `git clone` no **Termux** do Tablet Android, instalação, inicialização e conexão do **Android** e **iPhone**.

---

## Etapa 1 — Preparar o Git no PC (Enviar sua Versão para o GitHub)

> **Por que fazer isso?** Se você clonar `https://github.com/babybuddy/babybuddy.git` direto no Tablet, vai baixar o projeto original sem o Tema Oceano e sem a aba Contrações. Subindo para um repositório seu no GitHub, o Tablet baixa tudo pronto com um `git clone`.

No **PowerShell** do PC, dentro da pasta do projeto:

```powershell
cd c:\Users\luisf\CelularAntigravity\Babybuddy
git add .
git commit -m "Tema Oceano, aba Contracoes 5-1-1 e scripts Termux"
git branch -M main
git remote set-url origin https://github.com/SEU_USUARIO/babybuddy-ocean.git
git push -u origin main
```

*(Crie um repositório vazio chamado `babybuddy-ocean` na sua conta do GitHub antes do `git push`, e substitua `SEU_USUARIO` pelo seu usuário do GitHub.)*

---

## Etapa 2 — Preparar o Termux no Tablet Android (Comandos Iniciais)

> **Importante:** Baixe o aplicativo **Termux** pelo **F-Droid** ou **GitHub oficial** (a versão da Play Store está desatualizada).
> Nas configurações do Android do Tablet, vá em **Aplicativos -> Termux -> Bateria** e selecione **"Sem restrições"** (*Unrestricted*) para o sistema não suspender o servidor.

Abra o **Termux** no Tablet e execute:

```bash
# 1. Atualizar todos os pacotes do Termux
pkg update -y && pkg upgrade -y

# 2. Instalar Git, Python e bibliotecas nativas de imagem e criptografia
pkg install -y git python python-pillow libjpeg-turbo zlib libffi openssl termux-api

# 3. Ativar o Wake Lock (impede o Tablet de suspender o servidor com a tela apagada)
termux-wake-lock
```

*(Se o Termux perguntar durante o `pkg upgrade`, pressione `Enter` para aceitar os padrões.)*

---

## Etapa 3 — Clonar o Repositório pelo Termux (`git clone`)

No terminal do **Termux**, execute:

```bash
# Ir para a pasta inicial do Termux
cd ~

# Clonar o seu repositório do GitHub para a pasta ~/Babybuddy
git clone https://github.com/SEU_USUARIO/babybuddy-ocean.git Babybuddy

# Entrar na pasta do projeto
cd ~/Babybuddy
```

---

## Etapa 4 — Configurar e Instalar Tudo pelo Terminal do Termux

Você pode escolher entre o **script automático** (Opção A) ou executar cada comando manualmente (Opção B).

### Opção A — Instalação Automática em 1 Comando

```bash
cd ~/Babybuddy
bash scripts/setup_termux_tablet.sh
```

### Opção B — Passo a Passo Manual Completo no Terminal

Se preferir rodar comando por comando no terminal do Termux:

```bash
# 1. Entrar na pasta do projeto
cd ~/Babybuddy

# 2. Criar o ambiente virtual aproveitando o Pillow nativo do Termux
python -m venv --system-site-packages .venv

# 3. Ativar o ambiente virtual
source .venv/bin/activate

# 4. Atualizar o pip e instalar as dependências compatíveis com Tablet (SQLite, sem psycopg2)
pip install --upgrade pip
pip install -r requirements-tablet.txt

# 5. Gerar o arquivo .env com chave secreta (SECRET_KEY) forte, idioma pt-BR e DEBUG=False
SECRET_KEY_GERADA=$(python -c "import secrets; print(secrets.token_urlsafe(50))")
cat > .env << EOF
DJANGO_SETTINGS_MODULE=babybuddy.settings.development
DEBUG=False
SERVE_MEDIA=True
SECRET_KEY=${SECRET_KEY_GERADA}
ALLOWED_HOSTS=*
LANGUAGE_CODE=pt-BR
TIME_ZONE=America/Sao_Paulo
EOF

# 6. Copiar os arquivos estáticos (incluindo o Tema Oceano)
mkdir -p babybuddy/static
cp -r static/babybuddy babybuddy/static/

# 7. Criar e migrar o banco de dados SQLite (data/db.sqlite3) e tabela de cache
python manage.py migrate
python manage.py createcachetable || true

# 8. Verificar se não há nenhum erro na instalação
python manage.py check
```

---

## Etapa 5 — Gerenciar Usuários / Senha e Iniciar o Servidor (Comandos Finais)

### 1. Alterar a senha padrão ou criar novo usuário

O usuário inicial padrão é `admin` / `admin`. Recomenda-se alterar a senha antes de usar na rede:

```bash
cd ~/Babybuddy
source .venv/bin/activate

# Alterar a senha do usuário admin
python manage.py changepassword admin

# (Opcional) Criar um novo superusuário
python manage.py createsuperuser
```

### 2. Descobrir o IP do Tablet e Iniciar o Servidor

**Forma 1 — Usando o script pronto** (já ativa o `termux-wake-lock`, detecta os IPs do Wi-Fi e Tailscale e sobe o servidor):

```bash
cd ~/Babybuddy
bash scripts/start_tablet_server.sh
```

**Forma 2 — Comandos diretos no terminal:**

```bash
cd ~/Babybuddy
termux-wake-lock
source .venv/bin/activate

# Ver o IP Wi-Fi do Tablet (ex.: 192.168.1.50)
ip -4 addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f1

# Iniciar o servidor aceitando conexões do iPhone, Android e Tablet
python manage.py runserver 0.0.0.0:8000 --noreload
```

---

## Etapa 6 — Comandos Úteis do Dia a Dia

### Rodar o servidor em segundo plano (sem precisar manter a tela do Termux aberta)

```bash
cd ~/Babybuddy
termux-wake-lock
source .venv/bin/activate
nohup python manage.py runserver 0.0.0.0:8000 --noreload > servidor.log 2>&1 &
```

- **Acompanhar o log em tempo real:**
  ```bash
  tail -f ~/Babybuddy/servidor.log
  ```
- **Encerrar o servidor:**
  - Se estiver rodando na tela: pressione `Ctrl + C`.
  - Se estiver em segundo plano (`nohup`):
    ```bash
    pkill -f "manage.py runserver"
    ```

### Atualizar o Tablet quando você fizer melhorias no GitHub

```bash
cd ~/Babybuddy
pkill -f "manage.py runserver" || true
git pull
cp -r static/babybuddy babybuddy/static/
source .venv/bin/activate
python manage.py migrate
bash scripts/start_tablet_server.sh
```

### Iniciar automaticamente quando o Tablet ligar (`Termux:Boot`)

1. Instale o complemento **Termux:Boot** (F-Droid) e abra-o uma vez para registrar as permissões.
2. No Termux, crie o script de inicialização automática:

```bash
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/start-babybuddy.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
cd ~/Babybuddy
source .venv/bin/activate
nohup python manage.py runserver 0.0.0.0:8000 --noreload > ~/Babybuddy/servidor.log 2>&1 &
EOF
chmod +x ~/.termux/boot/start-babybuddy.sh
```

---

## Etapa 7 — Conectar o Android, o iPhone e o Próprio Tablet

### Na rede Wi-Fi de casa
1. Confira o IP do Tablet exibido no terminal (ex.: `192.168.1.50`).
   - **No próprio Tablet:** acesse `http://127.0.0.1:8000`
   - **No celular Android e no iPhone:** acesse `http://192.168.1.50:8000`
2. **Instalar como Aplicativo na Tela Inicial (PWA):**
   - **iPhone (Safari):** Toque em **Compartilhar** $\rightarrow$ **Adicionar à Tela de Início**.
   - **Android / Tablet (Chrome):** Toque no menu `⋮` $\rightarrow$ **Instalar aplicativo** ou **Adicionar à tela inicial**.
3. **Dica:** Fixe o IP do Tablet nas configurações de reserva DHCP do seu roteador para que o endereço `192.168.X.X` nunca mude.

### Fora de casa no 4G/5G (Tailscale Gratuito)
1. Instale o aplicativo **Tailscale** no **Tablet**, no **Android** e no **iPhone** usando a mesma conta.
2. Ative a VPN do Tailscale nos 3 aparelhos.
3. O script `start_tablet_server.sh` mostrará o IP do Tailscale (ex.: `http://100.X.X.X:8000`) — acesse esse link nos celulares de qualquer lugar fora de casa.

---

## Extra — Testar Agora Pelo PC (Antes de Passar para o Tablet)

No PowerShell do Windows:

```powershell
cd c:\Users\luisf\CelularAntigravity\Babybuddy
.\scripts\iniciar_rede_local_pc.ps1
```
