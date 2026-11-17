# Guia de Instalação e Uso — Tablet Android + Celular Android + iPhone (Opção 3)

Com esta configuração, **o próprio Tablet Android vira o servidor do Baby Buddy** (sem precisar deixar o PC ligado). Todos os registros ficam sincronizados em tempo real entre o **Tablet**, o **celular Android** e o **iPhone**.

---

## Parte 1 — Instalar no Tablet Android (Termux)

> **Importante:** Baixe o **Termux** pelo **F-Droid** ou **GitHub oficial** (a versão antiga da Play Store não recebe mais atualizações).

1. Abra o **Termux** no Tablet e copie a pasta `Babybuddy` para dentro dele (via `git clone` do seu repositório ou copiando os arquivos para `/data/data/com.termux/files/home/Babybuddy`).
   - Se for copiar do armazenamento interno do Tablet (`/sdcard/Download/Babybuddy`), primeiro dê permissão de armazenamento:
     ```bash
     termux-setup-storage
     cp -r ~/storage/downloads/Babybuddy ~/Babybuddy
     ```
2. Entre na pasta e rode o instalador automático (preparado para ARM64 sem `psycopg2`):
   ```bash
   cd ~/Babybuddy
   bash scripts/setup_termux_tablet.sh
   ```
3. Inicie o servidor:
   ```bash
   bash scripts/start_tablet_server.sh
   ```
   O script ativará o `termux-wake-lock` (para o Android não dormir o servidor quando a tela apagar) e mostrará os endereços na tela, por exemplo:
   - **No próprio Tablet:** `http://127.0.0.1:8000`
   - **No Wi-Fi de casa (Android e iPhone):** `http://192.168.X.X:8000`

### Dica: Iniciar automaticamente quando o Tablet ligar
Se quiser que o servidor ligue sozinho ao reiniciar o Tablet:
1. Instale o complemento **Termux:Boot** (F-Droid).
2. Crie o arquivo `~/.termux/boot/start-babybuddy.sh`:
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   termux-wake-lock
   bash ~/Babybuddy/scripts/start_tablet_server.sh
   ```
   E dê permissão: `chmod +x ~/.termux/boot/start-babybuddy.sh`.
3. Nas configurações do Android do Tablet, em **Bateria -> Termux**, marque **"Sem restrições"** (*Unrestricted*) para o sistema não fechar o Termux em segundo plano.

---

## Parte 2 — Conectar o Celular Android e o iPhone no Wi-Fi

1. Conecte o **iPhone** e o **celular Android** na mesma rede Wi-Fi do Tablet.
2. Abra o navegador e acesse o endereço exibido pelo script (`http://192.168.X.X:8000`).
3. Entre com seu usuário e senha (padrão inicial: `admin` / `admin` — lembre-se de alterar em **Configurações do Usuário**).
4. **Instale como Aplicativo na Tela Inicial (PWA):**
   - **iPhone (Safari):** Toque em **Compartilhar** (ícone do quadrado com seta) $\rightarrow$ **Adicionar à Tela de Início**.
   - **Android / Tablet (Chrome):** Toque no menu `⋮` $\rightarrow$ **Instalar aplicativo** ou **Adicionar à tela inicial**.

### Dica Extra: IP Fixo no Wi-Fi do Roteador
Para que o endereço `192.168.X.X` do Tablet nunca mude depois de reiniciar o roteador, entre nas configurações do seu roteador (reserva de DHCP) e fixe o IP do Tablet, **ou** configure o IP estático nas configurações avançadas do Wi-Fi do próprio Tablet.

---

## Parte 3 — Acessar Fora de Casa no 4G/5G (Tailscale Gratuito)

Se quiser que o iPhone e o Android acessem o Baby Buddy mesmo fora de casa (sem abrir portas no roteador):

1. Instale o aplicativo gratuito **Tailscale** no **Tablet**, no **Android** e no **iPhone**.
2. Faça login nos 3 aparelhos com a **mesma conta** (Google ou Apple).
3. Ative a chave do Tailscale nos 3 aparelhos.
4. O script `start_tablet_server.sh` detectará automaticamente o IP do Tailscale (ex.: `http://100.X.X.X:8000`) — você pode acessar esse mesmo endereço de qualquer lugar do mundo com total segurança!

---

## Parte 4 — Testar Agora Pelo PC (Opcional)

Enquanto você ainda não transfere o projeto para o Tablet, pode testar o novo tema **Oceano** nos seus celulares usando o PC na rede local:
1. No PowerShell, execute:
   ```powershell
   .\scripts\iniciar_rede_local_pc.ps1
   ```
2. Acesse no iPhone e Android o endereço `http://192.168.X.X:8000` exibido no terminal.
