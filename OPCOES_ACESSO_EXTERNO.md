# Opções de Acesso Externo ao Baby Buddy (Sem Tailscale)

Este documento reúne as alternativas para acessar o servidor do Baby Buddy (rodando no **Termux** do Tablet Android) pela internet (4G/5G fora de casa) **sem usar o Tailscale**, para avaliação futura.

---

## Comparativo Geral

| Alternativa | Custo | URL Fixa? | Precisa instalar app nos celulares? | Funciona atrás de CGNAT? | HTTPS Automático? | Prós e Contras |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1A. Cloudflare Tunnel (Modo Rápido)** | R\$ 0 | Não (muda ao reiniciar) | Não | ✅ Sim | ✅ Sim | Zero configuração e sem conta; link muda a cada reinício. |
| **1B. Cloudflare Tunnel (Domínio Fixo)** | ~R\$ 40/ano (só o domínio) | ✅ Sim | Não | ✅ Sim | ✅ Sim | **Melhor opção definitiva**: link permanente, sem tela de aviso e com suporte a Cloudflare Access (PIN/e-mail extra). |
| **2. ngrok (Plano Gratuito)** | R\$ 0 | ✅ Sim (1 domínio estático) | Não | ✅ Sim | ✅ Sim | Link fixo gratuito (`*.ngrok-free.app`); exibe uma tela intermediária (*Visit Site*) no primeiro acesso. |
| **3. Túnel SSH (`localhost.run` / `Pinggy`)** | R\$ 0 | Não (temporária) | Não | ✅ Sim | ✅ Sim | Não instala quase nada além do `openssh`; ideal apenas para uso pontual (ex.: consulta/maternidade). |
| **4. Port Forwarding + DDNS (DuckDNS/No-IP)** | R\$ 0 | ✅ Sim | Não | ❌ Não (bloqueado se houver CGNAT) | ⚠️ Manual (precisa proxy/SSL) | Depende da operadora dar IP público real; expõe a porta do roteador sem criptografia se não houver reverse proxy. |
| **5. Outras VPNs P2P (ZeroTier / WireGuard)** | R\$ 0 | ✅ IP privado fixo | Sim (app VPN no Android e iPhone) | ✅ Sim | N/A (túnel VPN privado) | Mesma ideia do Tailscale (tráfego 100% privado), mas exige app instalado em cada celular. |

---

## Detalhamento e Comandos no Termux

### 1. Cloudflare Tunnel (`cloudflared`) — *Recomendada*

Cria um túnel criptografado de saída do Tablet para a rede da Cloudflare, sem abrir portas no roteador e funcionando normalmente mesmo com CGNAT.

#### Opção 1A: Túnel Rápido (sem conta e sem domínio)
```bash
pkg install -y cloudflared
cloudflared tunnel --url http://127.0.0.1:8000
```
- Gera automaticamente um link temporário no formato `https://nome-aleatorio.trycloudflare.com`.
- O endereço muda sempre que o comando ou o Tablet for reiniciado.

#### Opção 1B: Túnel Fixo (com domínio próprio na Cloudflare)
1. Criar conta gratuita na Cloudflare e apontar um domínio (ex.: `bebe.seudominio.com.br`).
2. Autenticar e criar o túnel no Termux:
   ```bash
   pkg install -y cloudflared
   cloudflared tunnel login
   cloudflared tunnel create babybuddy-tablet
   cloudflared tunnel route dns babybuddy-tablet bebe.seudominio.com.br
   ```
3. Criar o arquivo de configuração `~/.cloudflared/config.yml` apontando para `http://127.0.0.1:8000` e rodar:
   ```bash
   cloudflared tunnel run babybuddy-tablet
   ```
4. **Camada extra opcional (Cloudflare Access):** permite exigir confirmação por código enviado ao e-mail dos pais antes mesmo de carregar a tela de login do Baby Buddy.

---

### 2. ngrok (1 Domínio Fixo Gratuito)

O plano gratuito do ngrok oferece 1 domínio estático permanente (`https://seu-subdominio.ngrok-free.app`) com HTTPS automático.

1. Criar conta gratuita em [ngrok.com](https://ngrok.com/), copiar seu `authtoken` e reservar seu domínio estático gratuito no painel.
2. Instalar/configurar o binário ARM64 do `ngrok` no Termux e autenticar:
   ```bash
   ngrok config add-authtoken SEU_TOKEN_AQUI
   ngrok http --domain=seu-subdominio.ngrok-free.app 8000
   ```
- **Observação:** no plano gratuito, ao abrir pelo celular pela primeira vez no navegador, o ngrok exibe uma página de aviso pedindo para clicar em **Visit Site**.

---

### 3. Túneis SSH Gratuitos (`localhost.run` ou `Pinggy`)

Útil para gerar um link externo temporário rapidamente sem criar conta nem instalar pacotes extras além do `openssh`.

```bash
pkg install -y openssh

# Usando localhost.run
ssh -R 80:localhost:8000 nokey@localhost.run

# Ou usando Pinggy
ssh -p 443 -R0:localhost:8000 a.pinggy.io
```
- **Observação:** no uso gratuito, a URL expira após algumas horas e muda a cada execução.

---

### 4. Port Forwarding no Roteador + DDNS (DuckDNS / No-IP)

1. Reservar um IP fixo na rede local para o Tablet no roteador (ex.: `192.168.1.50`).
2. Configurar redirecionamento de porta (*Port Forwarding*) no roteador apontando para `192.168.1.50:8000`.
3. Atualizar um subdomínio gratuito (ex.: `meubebe.duckdns.org`) apontando para o IP público da casa.

**Por que costuma ser evitada:**
- A maioria das operadoras residenciais usa **CGNAT**, bloqueando acesso externo direto às portas do roteador.
- Expor HTTP sem HTTPS/SSL pela internet pública trafega usuário, senha e cookies sem criptografia — se optar por este caminho, é recomendável colocar um *reverse proxy* com certificado TLS (como Caddy ou Nginx + Let's Encrypt).

---

### 5. Alternativas ao Tailscale com VPN Privada (ZeroTier / WireGuard)

Caso a intenção seja apenas trocar o Tailscale por outra VPN privada (sem expor nenhuma URL pública na internet):
- **ZeroTier:** cria uma rede virtual privada gratuita com IPs fixos e possui aplicativo para Android, iOS e suporte no Linux/Termux (ou via roteador).
- **WireGuard:** exige que o roteador de casa (ou um dispositivo na rede com IP público/DDNS) atue como servidor WireGuard, conectando os celulares por túnel criptografado.

---

## Ajustes Obrigatórios no Baby Buddy ao Ativar Qualquer Túnel HTTPS

Sempre que o Baby Buddy passar a ser acessado por uma URL pública `https://...` (Cloudflare Tunnel, ngrok, localhost.run ou proxy reverso), lembre-se de conferir os itens abaixo no arquivo `.env` do Tablet:

1. **`CSRF_TRUSTED_ORIGINS`** (obrigatório no Django 5 para login e envio de formulários via HTTPS):
   ```env
   CSRF_TRUSTED_ORIGINS=https://*.trycloudflare.com,https://*.ngrok-free.app
   ```
   *(Ou o seu domínio fixo exato, como `https://bebe.seudominio.com.br`.)*
2. **Senha forte:** nunca deixe a senha padrão `admin` / `admin` em um endereço acessível pela internet; troque com:
   ```bash
   python manage.py changepassword admin
   ```
3. **`DEBUG=False`:** mantenha `DEBUG=False` no `.env` (já configurado nos scripts atuais) para não expor informações internas em caso de erro.
